// Sheets, Firestore and the trigger: everything that needs Apps Script services.
// How to install it is in docs/restaurantes.md.

var PROJECT_ID = 'rango-f0485';
var DOCUMENTS_ROOT = 'projects/' + PROJECT_ID + '/databases/(default)/documents';
var FIRESTORE_URL = 'https://firestore.googleapis.com/v1/';
var TOKEN_URL = 'https://oauth2.googleapis.com/token';
var FIRESTORE_SCOPE = 'https://www.googleapis.com/auth/datastore';

// By id, not by title: the tab is called "Todos 300", which will stop being true.
var RESTAURANTS_SHEET_ID = 740736283;
var REPORT_SHEET_NAME = 'Sincronização';
var SERVICE_ACCOUNT_PROPERTY = 'FIRESTORE_SERVICE_ACCOUNT';
var DAILY_SYNC_HOUR = 4;

function onOpen() {
  SpreadsheetApp.getUi()
    .createMenu('Rango')
    .addItem('Sincronizar agora', 'syncFromMenu')
    .addItem('Ligar sincronização diária', 'installDailySync')
    .addToUi();
}

function syncFromMenu() {
  syncRestaurants();
  SpreadsheetApp.getActiveSpreadsheet().toast('Veja o resultado na aba ' + REPORT_SHEET_NAME + '.', 'Rango');
}

function installDailySync() {
  ScriptApp.getProjectTriggers()
    .filter((trigger) => trigger.getHandlerFunction() === 'syncRestaurants')
    .forEach((trigger) => ScriptApp.deleteTrigger(trigger));
  ScriptApp.newTrigger('syncRestaurants')
    .timeBased()
    .everyDays(1)
    .atHour(DAILY_SYNC_HOUR)
    .inTimezone('America/Sao_Paulo')
    .create();
  SpreadsheetApp.getActiveSpreadsheet().toast('A sincronização vai rodar todo dia de madrugada.', 'Rango');
}

function syncRestaurants() {
  const lock = LockService.getScriptLock();
  // The button and the trigger running together would read and write twice.
  if (!lock.tryLock(30000)) throw new Error('Já existe uma sincronização em andamento.');
  try {
    runSync_();
  } finally {
    lock.releaseLock();
  }
}

// Apps Script gives null instead of rich text for a cell that does not hold text.
function cellLinks_(richText) {
  if (!richText) return [];
  return richText.getRuns().map((run) => run.getLinkUrl()).filter(Boolean);
}

function runSync_() {
  const spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
  const progress = { committedWrites: 0 };
  try {
    const sheet = spreadsheet.getSheets().find((tab) => tab.getSheetId() === RESTAURANTS_SHEET_ID);
    if (!sheet) throw new Error('A aba de restaurantes não foi encontrada.');
    const range = sheet.getDataRange();
    const richText = range.getRichTextValues();
    const parsed = parseSheet(range.getDisplayValues(), (row, column) => cellLinks_(richText[row][column]));

    const token = fetchAccessToken_();
    const existing = listRestaurantDocuments_(token);
    const activeCount = existing.filter(isActiveSheetDocument).length;
    if (!isSafeToSync(parsed.restaurants.length, activeCount)) {
      throw new Error(
        'A planilha tem ' + parsed.restaurants.length + ' restaurantes válidos, e o banco tem ' +
          activeCount + ' ativos. Isso parece um erro de edição.',
      );
    }

    const rejectedIds = parsed.rejected.map((row) => row.id).filter(Boolean);
    const plan = planSync(parsed.restaurants, rejectedIds, existing);
    buildCommitBatches(plan, DOCUMENTS_ROOT).forEach((writes) => {
      commitWrites_(token, writes);
      progress.committedWrites += writes.length;
    });
    writeReport_(spreadsheet, successReport_(parsed, plan));
  } catch (error) {
    // The failure stays visible in the sheet, and rethrowing makes Apps Script
    // email whoever owns the trigger.
    writeReport_(spreadsheet, failureReport_(error, progress.committedWrites));
    throw error;
  }
}

function fetchAccessToken_() {
  const serialized = PropertiesService.getScriptProperties().getProperty(SERVICE_ACCOUNT_PROPERTY);
  if (!serialized) throw new Error('A chave ' + SERVICE_ACCOUNT_PROPERTY + ' não foi configurada.');
  const account = JSON.parse(serialized);

  const issuedAt = Math.floor(Date.now() / 1000);
  const encode = (value) => Utilities.base64EncodeWebSafe(value).replace(/=+$/, '');
  const unsigned =
    encode(JSON.stringify({ alg: 'RS256', typ: 'JWT' })) +
    '.' +
    encode(
      JSON.stringify({
        iss: account.client_email,
        scope: FIRESTORE_SCOPE,
        aud: TOKEN_URL,
        iat: issuedAt,
        exp: issuedAt + 3600,
      }),
    );
  const signature = encode(Utilities.computeRsaSha256Signature(unsigned, account.private_key));

  const response = fetchJson_(TOKEN_URL, {
    method: 'post',
    payload: {
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: unsigned + '.' + signature,
    },
  });
  return response.access_token;
}

function listRestaurantDocuments_(token) {
  const documents = [];
  let pageToken = '';
  do {
    const query = '?pageSize=300' + (pageToken ? '&pageToken=' + encodeURIComponent(pageToken) : '');
    const page = fetchJson_(FIRESTORE_URL + DOCUMENTS_ROOT + '/' + RESTAURANTS_COLLECTION + query, {
      headers: { Authorization: 'Bearer ' + token },
    });
    (page.documents || []).forEach((document) => {
      documents.push({ id: document.name.split('/').pop(), fields: document.fields || {} });
    });
    pageToken = page.nextPageToken || '';
  } while (pageToken);
  return documents;
}

function commitWrites_(token, writes) {
  fetchJson_(FIRESTORE_URL + DOCUMENTS_ROOT + ':commit', {
    method: 'post',
    contentType: 'application/json',
    headers: { Authorization: 'Bearer ' + token },
    payload: JSON.stringify({ writes: writes }),
  });
}

function fetchJson_(url, options) {
  const response = UrlFetchApp.fetch(url, Object.assign({ muteHttpExceptions: true }, options));
  const code = response.getResponseCode();
  // Only the status: a token response body must never reach logs or the sheet.
  if (code < 200 || code >= 300) throw new Error('Falha de rede (HTTP ' + code + ').');
  return JSON.parse(response.getContentText());
}

function successReport_(parsed, plan) {
  const rows = [
    ['Última sincronização', new Date(), ''],
    ['Gravados', plan.writes.length, ''],
    ['Sem mudança', plan.unchanged, ''],
    ['Desativados (saíram da planilha)', plan.deactivate.length, ''],
    ['Rejeitados', parsed.rejected.length, ''],
    ['Sem comida do cardápio (fora do app)', parsed.skipped.length, ''],
  ];
  const issues = parsed.rejected.concat(parsed.skipped);
  if (issues.length === 0) return rows;
  return rows
    .concat([['', '', ''], ['Linha', 'Restaurante', 'Motivo']])
    .concat(issues.map((issue) => [issue.row, issue.name, issue.reason]));
}

function failureReport_(error, committedWrites) {
  const outcome =
    committedWrites > 0
      ? committedWrites + ' restaurantes foram gravados antes da falha.'
      : 'Nada foi alterado.';
  return [
    ['Última sincronização', new Date(), ''],
    ['Erro', error.message, ''],
    ['Resultado', outcome, ''],
  ];
}

function writeReport_(spreadsheet, rows) {
  const sheet =
    spreadsheet.getSheetByName(REPORT_SHEET_NAME) || spreadsheet.insertSheet(REPORT_SHEET_NAME);
  sheet.clearContents();
  sheet.getRange(1, 1, rows.length, rows[0].length).setValues(rows);
}
