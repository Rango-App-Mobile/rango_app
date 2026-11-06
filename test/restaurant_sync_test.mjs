// Runs with `node --test test/restaurant_sync_test.mjs`. Apps Script files have
// no modules, so they are loaded into a VM context with fakes for its services.
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { test } from 'node:test';
import vm from 'node:vm';

const source = (name) =>
  readFileSync(new URL(`../tools/restaurant_sync/${name}`, import.meta.url), 'utf8');

function load(globals = {}) {
  const context = vm.createContext({ ...globals });
  vm.runInContext(source('rules.gs'), context);
  vm.runInContext(source('sync.gs'), context);
  return context;
}

// Objects from the VM have another realm's prototypes, which deepEqual rejects.
const plain = (value) => JSON.parse(JSON.stringify(value));

const rules = load();

const RATING = 'Nota principal (Google > iFood > outras)';
const LINKS = 'Links para pedir (Google quando não houver link direto)';
const IFOOD_URL = 'https://www.ifood.com.br/delivery/porto-alegre-rs/xis/abc';

const HEADER = [
  'Restaurantes Zona',
  'Bairro',
  'Restaurante',
  'Tipo de comida',
  RATING,
  'Telefone',
  'Endereço',
  'Geolocalização (latitude, longitude)',
  'Comidas Servidas',
  LINKS,
  'Comidas (correção)',
];

function row(overrides = {}) {
  const defaults = {
    Bairro: 'Bom Fim',
    Restaurante: 'Boxfim Xis',
    'Tipo de comida': 'Lanchonete de xis gaúcho',
    [RATING]: '4,8/5',
    Telefone: '+55 51 2314-0910',
    Endereço: 'Rua Fernandes Vieira, 427',
    'Geolocalização (latitude, longitude)': '-30.033109, -51.210987',
    'Comidas Servidas': 'Xis Borússia',
    [LINKS]: IFOOD_URL,
    'Comidas (correção)': '',
  };
  const merged = { ...defaults, ...overrides };
  return HEADER.map((column) => merged[column] ?? '');
}

// In these rows a links cell holds its address as text; the real cell shows a
// label, which the syncRestaurants tests cover through the rich text fake.
const parseRows = (values) =>
  rules.parseSheet(values, (rowIndex, column) => (values[rowIndex][column] ? [values[rowIndex][column]] : []));

test('parseRating recovers a rating the sheet turned into a date', () => {
  assert.equal(rules.parseRating('46269'), 4.9);
  assert.equal(rules.parseRating('46085'), 4.3);
  assert.equal(rules.parseRating('04/09/2026'), 4.9);
});

test('parseRating reads a rating with text after it', () => {
  assert.equal(rules.parseRating('4,8/5 (Bom Fim POA; Google, 06/10/2026)'), 4.8);
  assert.equal(rules.parseRating('4.5'), 4.5);
  assert.equal(rules.parseRating('5/5 (diretório)'), 5);
  assert.equal(rules.parseRating('4,05/5'), 4.1);
});

test('parseRating returns null without a rating on the 0 to 5 scale', () => {
  for (const text of ['', 'Não encontrado', '0 avaliações no Tripadvisor', '8,1/10 — Foursquare', '7,5']) {
    assert.equal(rules.parseRating(text), null, text);
  }
});

test('parsePhone keeps the first number in national format', () => {
  assert.equal(rules.parsePhone('+55 51 3012-2675; +55 51 3012-5924'), '(51) 3012-2675');
  assert.equal(rules.parsePhone('(51) 98174-7578 (telefone; WhatsApp não confirmado)'), '(51) 98174-7578');
});

test('parsePhone returns null without a number', () => {
  for (const text of ['', 'Somente instagram', 'Não encontrado', '3012-2675']) {
    assert.equal(rules.parsePhone(text), null, text);
  }
});

test('parseLocation accepts only coordinates in the Porto Alegre region', () => {
  assert.deepEqual(plain(rules.parseLocation('-30.056443, -51.214672')), {
    latitude: -30.056443,
    longitude: -51.214672,
  });
  for (const text of ['', 'perto do mercado', '-51.214672, -30.056443', '-23.5, -46.6']) {
    assert.equal(rules.parseLocation(text), null, text);
  }
});

test('parseDeliveryLinks separates iFood from the other order links', () => {
  const links = rules.parseDeliveryLinks([
    'https://www.rappi.com.br/x',
    'https://www.ifood.com.br/delivery/y',
  ]);
  assert.deepEqual(plain(links), {
    ifood: 'https://www.ifood.com.br/delivery/y',
    others: ['https://www.rappi.com.br/x'],
  });
});

test('parseDeliveryLinks drops pages that do not take orders and non-https links', () => {
  const links = rules.parseDeliveryLinks([
    'https://linktr.ee/a',
    'https://facebook.com/b',
    'https://www.restaurantguru.com.br/c',
    'http://site.com.br',
  ]);
  assert.deepEqual(plain(links), { ifood: null, others: [] });
});

test('parseDeliveryLinks drops a Google search, which the app already offers by itself', () => {
  const links = rules.parseDeliveryLinks([
    'https://www.google.com/search?q=%22Brado%22%20Porto%20Alegre%20iFood',
    'https://www.google.com.br/search?q=Brado',
  ]);
  assert.deepEqual(plain(links), { ifood: null, others: [] });
});

test('parseDeliveryLinks rejects a link that only looks like iFood', () => {
  const links = rules.parseDeliveryLinks([
    'https://www.ifood.com.br@evil.example/x',
    'https://ifood.com.br.evil.example/y',
  ]);
  assert.equal(links.ifood, null);
  assert.deepEqual(plain(links.others), ['https://ifood.com.br.evil.example/y']);
});

test('deduceFoods finds menu foods in the sheet text, ignoring accents and case', () => {
  assert.deepEqual(plain(rules.deduceFoods('Lanchonete de XIS gaúcho', 'Açaí; pão de queijo')), [
    'xis',
    'acai',
  ]);
  assert.deepEqual(plain(rules.deduceFoods('Buffet', 'Comida caseira')), []);
});

test('deduceFoods does not read a savory pie or a Portuguese tart as the menu foods', () => {
  assert.deepEqual(plain(rules.deduceFoods('Padaria', 'torta de frango; pastel de nata')), []);
});

test('resolveFoods keeps the deduced foods when the correction is empty', () => {
  assert.deepEqual(plain(rules.resolveFoods(['xis'], '  ')), { foods: ['xis'], unknown: [] });
});

test('resolveFoods lets the correction replace the deduced foods', () => {
  assert.deepEqual(plain(rules.resolveFoods(['sushi'], 'Macarrão; pizza')), {
    foods: ['spaghetti', 'pizza'],
    unknown: [],
  });
  assert.deepEqual(plain(rules.resolveFoods(['sushi'], 'Nenhuma')), { foods: [], unknown: [] });
});

test('resolveFoods reports names that are not on the menu', () => {
  assert.deepEqual(plain(rules.resolveFoods([], 'Pizza; Feijoada')), {
    foods: ['pizza'],
    unknown: ['Feijoada'],
  });
});

test('every food id exists in the menu of the app', () => {
  const menu = readFileSync(new URL('../lib/data/local_category_repository.dart', import.meta.url), 'utf8');
  const ids = [...menu.matchAll(/id: '(\w+)',\s*label: '[^']+',\s*parentId: '(?:savory|sweet)'/g)].map((m) => m[1]);
  assert.equal(ids.length, 32);
  assert.deepEqual([...plain(rules.FOODS.map((food) => food.id))].sort(), [...ids].sort());
});

test('restaurantId is stable across accents, apostrophes and neighborhood notes', () => {
  assert.equal(rules.restaurantId('Du\'Attos Restaurante', 'Centro Histórico'), 'duattos-restaurante--centro-historico');
  assert.equal(
    rules.restaurantId('Pizzaria Sorella', 'Passo d’Areia'),
    rules.restaurantId('Pizzaria Sorella', "Passo d'Areia (Rappi indica outro)"),
  );
});

test('parseSheet turns a row into a restaurant', () => {
  const { restaurants, rejected, skipped } = parseRows([HEADER, row()]);
  assert.deepEqual(plain(rejected), []);
  assert.deepEqual(plain(skipped), []);
  assert.deepEqual(plain(restaurants), [
    {
      id: 'boxfim-xis--bom-fim',
      name: 'Boxfim Xis',
      location: { latitude: -30.033109, longitude: -51.210987 },
      foods: ['xis'],
      cuisine: 'Lanchonete de xis gaúcho',
      address: 'Rua Fernandes Vieira, 427',
      rating: 4.8,
      phone: '(51) 2314-0910',
      deliveryLinks: {
        ifood: IFOOD_URL,
        others: [],
      },
    },
  ]);
});

test('parseSheet ignores blank rows and finds columns by name, whatever their order', () => {
  const reversed = [[...HEADER].reverse(), [...row()].reverse(), HEADER.map(() => '')];
  const { restaurants } = parseRows(reversed);
  assert.equal(restaurants.length, 1);
  assert.equal(restaurants[0].name, 'Boxfim Xis');
});

test('parseSheet throws when a required column is missing', () => {
  const header = HEADER.filter((column) => column !== 'Restaurante');
  assert.throws(() => parseRows([header]), /Restaurante/);
  assert.throws(() => parseRows([]), /Restaurante/);
});

test('parseSheet rejects invalid rows and says why, keeping the sheet row number', () => {
  const { restaurants, rejected } = parseRows([
    HEADER,
    row({ 'Geolocalização (latitude, longitude)': 'sem posição' }),
    row({ Restaurante: '' }),
    row({ Restaurante: 'Outro', 'Comidas (correção)': 'Feijoada' }),
  ]);
  assert.equal(restaurants.length, 0);
  assert.deepEqual(
    plain(rejected).map(({ row: number, reason }) => [number, reason]),
    [
      [2, 'Coordenada inválida'],
      [3, 'Sem nome'],
      [4, 'Comida fora do cardápio: Feijoada'],
    ],
  );
});

test('parseSheet rejects the second row with the same name and neighborhood', () => {
  const { restaurants, rejected } = parseRows([HEADER, row(), row()]);
  assert.equal(restaurants.length, 1);
  assert.equal(rejected[0].row, 3);
  assert.equal(rejected[0].reason, 'Restaurante repetido');
});

test('parseSheet skips a restaurant with no menu food, which the app could never show', () => {
  const { restaurants, skipped } = parseRows([
    HEADER,
    row({ 'Tipo de comida': 'Buffet', 'Comidas Servidas': 'Comida caseira' }),
  ]);
  assert.equal(restaurants.length, 0);
  assert.equal(skipped[0].name, 'Boxfim Xis');
});

const parsedRestaurant = () => parseRows([HEADER, row()]).restaurants[0];

test('toFirestoreFields encodes the shape the app reads', () => {
  const fields = plain(rules.toFirestoreFields(parsedRestaurant()));
  assert.deepEqual(fields.deliveryLinks, {
    mapValue: {
      fields: {
        ifood: { stringValue: 'https://www.ifood.com.br/delivery/porto-alegre-rs/xis/abc' },
        others: { arrayValue: {} },
      },
    },
  });
  assert.deepEqual(fields.foods, { arrayValue: { values: [{ stringValue: 'xis' }] } });
  assert.deepEqual(fields.location, { geoPointValue: { latitude: -30.033109, longitude: -51.210987 } });
  assert.deepEqual(fields.rating, { doubleValue: 4.8 });
  assert.deepEqual(fields.active, { booleanValue: true });
  assert.deepEqual(fields.source, { stringValue: 'sheet' });
});

test('toFirestoreFields stores a missing rating, phone and iFood link as null or absent', () => {
  const restaurant = { ...parsedRestaurant(), rating: null, phone: null, deliveryLinks: { ifood: null, others: [] } };
  const fields = plain(rules.toFirestoreFields(restaurant));
  assert.deepEqual(fields.rating, { nullValue: null });
  assert.deepEqual(fields.phone, { nullValue: null });
  assert.deepEqual(fields.deliveryLinks.mapValue.fields, { others: { arrayValue: {} } });
});

const stored = (restaurant, extra = {}) => ({
  id: restaurant.id,
  fields: { ...rules.toFirestoreFields(restaurant), updatedAt: { timestampValue: '2026-11-05T00:00:00Z' }, ...extra },
});

test('planSync writes only what is new or changed', () => {
  const same = parsedRestaurant();
  const changed = { ...parsedRestaurant(), id: 'changed', phone: '(51) 1111-1111' };
  const added = { ...parsedRestaurant(), id: 'added' };
  const plan = rules.planSync(
    [same, changed, added],
    [],
    [stored(same), stored({ ...changed, phone: null })],
  );
  assert.deepEqual(plain(plan.writes.map((write) => write.id)), ['changed', 'added']);
  assert.equal(plan.unchanged, 1);
  assert.deepEqual(plain(plan.deactivate), []);
});

test('planSync deactivates a sheet restaurant that left the sheet, never deleting it', () => {
  const gone = { ...parsedRestaurant(), id: 'gone' };
  const plan = rules.planSync([parsedRestaurant()], [], [stored(gone)]);
  assert.deepEqual(plain(plan.deactivate), ['gone']);
});

test('planSync keeps a restaurant whose row was rejected as it is', () => {
  const invalid = { ...parsedRestaurant(), id: 'invalid-now' };
  const plan = rules.planSync([parsedRestaurant()], ['invalid-now'], [stored(invalid)]);
  assert.deepEqual(plain(plan.deactivate), []);
});

test('planSync does not touch documents the team registered by hand', () => {
  const manual = {
    id: 'ChIJ-places-id',
    fields: { deliveryLinks: { mapValue: { fields: {} } } },
  };
  const plan = rules.planSync([parsedRestaurant()], [], [manual]);
  assert.deepEqual(plain(plan.deactivate), []);
});

test('planSync does not deactivate twice', () => {
  const gone = { ...parsedRestaurant(), id: 'gone' };
  const plan = rules.planSync(
    [parsedRestaurant()],
    [],
    [stored(gone, { active: { booleanValue: false } })],
  );
  assert.deepEqual(plain(plan.deactivate), []);
});

test('planSync brings back a restaurant that returned to the sheet', () => {
  const back = parsedRestaurant();
  const plan = rules.planSync([back], [], [stored(back, { active: { booleanValue: false } })]);
  assert.deepEqual(plain(plan.writes.map((write) => write.id)), [back.id]);
});

test('isSafeToSync refuses an empty sheet or one that lost most of its rows', () => {
  assert.equal(rules.isSafeToSync(0, 0), false);
  assert.equal(rules.isSafeToSync(100, 300), false);
  assert.equal(rules.isSafeToSync(150, 300), true);
  assert.equal(rules.isSafeToSync(10, 0), true);
});

test('buildCommitBatches writes full documents with a server timestamp', () => {
  const restaurant = parsedRestaurant();
  const plan = { writes: [{ id: restaurant.id, fields: rules.toFirestoreFields(restaurant) }], deactivate: ['gone'] };
  const [batch] = plain(rules.buildCommitBatches(plan, 'projects/p/databases/(default)/documents'));
  assert.equal(batch[0].update.name, 'projects/p/databases/(default)/documents/restaurants/boxfim-xis--bom-fim');
  assert.ok(batch[0].updateMask.fieldPaths.includes('deliveryLinks'));
  assert.ok(!batch[0].updateMask.fieldPaths.includes('updatedAt'));
  assert.deepEqual(batch[0].updateTransforms, [{ fieldPath: 'updatedAt', setToServerValue: 'REQUEST_TIME' }]);
  assert.deepEqual(batch[1].update.fields, { active: { booleanValue: false } });
  assert.deepEqual(batch[1].updateMask.fieldPaths, ['active']);
  assert.deepEqual(batch[1].currentDocument, { exists: true });
});

test('buildCommitBatches splits writes under the Firestore limit', () => {
  const deactivate = Array.from({ length: 450 }, (_, i) => `gone-${i}`);
  const batches = rules.buildCommitBatches({ writes: [], deactivate }, 'root');
  assert.deepEqual(plain(batches.map((batch) => batch.length)), [400, 50]);
});

// Fakes for the Apps Script services used by syncRestaurants.
const richCell = (...urls) => ({ getRuns: () => urls.map((url) => ({ getLinkUrl: () => url })) });

// By default a cell links to its own text when that text is an address.
function fakeServices({ sheetValues, existing = [], richTextOverrides = {} }) {
  const requests = [];
  const report = [];
  const richText = sheetValues.map((cells, rowIndex) =>
    cells.map((cell, column) => {
      const key = `${rowIndex}:${column}`;
      if (key in richTextOverrides) return richTextOverrides[key];
      return richCell(/^https:/.test(cell) ? cell : null);
    }),
  );
  const mainSheet = {
    getSheetId: () => 740736283,
    getDataRange: () => ({
      getDisplayValues: () => sheetValues,
      getRichTextValues: () => richText,
    }),
  };
  const reportSheet = {
    clearContents: () => report.push('cleared'),
    getRange: () => ({ setValues: (values) => report.push(...values) }),
  };
  const spreadsheet = {
    getSheets: () => [mainSheet],
    getSheetByName: () => reportSheet,
    insertSheet: () => reportSheet,
  };
  const response = (body) => ({ getResponseCode: () => 200, getContentText: () => JSON.stringify(body) });
  const globals = {
    SpreadsheetApp: { getActiveSpreadsheet: () => spreadsheet, getUi: () => ({}) },
    LockService: { getScriptLock: () => ({ tryLock: () => true, releaseLock: () => {} }) },
    PropertiesService: {
      getScriptProperties: () => ({
        getProperty: () => JSON.stringify({ client_email: 'sync@example.com', private_key: 'key' }),
      }),
    },
    Utilities: {
      base64EncodeWebSafe: (value) => String(value),
      computeRsaSha256Signature: () => 'signature',
    },
    UrlFetchApp: {
      fetch: (url, options = {}) => {
        requests.push({ url, options });
        if (url.includes('oauth2')) return response({ access_token: 'token' });
        if (url.endsWith(':commit')) return response({});
        return response({ documents: existing });
      },
    },
  };
  return { globals, requests, report };
}

const firestoreName = (id) => `projects/rango-f0485/databases/(default)/documents/restaurants/${id}`;

test('syncRestaurants writes the sheet to Firestore and reports it', () => {
  const { globals, requests, report } = fakeServices({ sheetValues: [HEADER, row()] });
  load(globals).syncRestaurants();
  const commit = requests.find((request) => request.url.endsWith(':commit'));
  const { writes } = JSON.parse(commit.options.payload);
  assert.equal(writes[0].update.name, firestoreName('boxfim-xis--bom-fim'));
  assert.equal(commit.options.headers.Authorization, 'Bearer token');
  assert.ok(report.flat().some((cell) => /Gravados/.test(String(cell))));
});

const committedLinks = (requests) => {
  const commit = requests.find((request) => request.url.endsWith(':commit'));
  const { fields } = JSON.parse(commit.options.payload).writes[0].update;
  return fields.deliveryLinks.mapValue.fields;
};

test('syncRestaurants reads the addresses inside a links cell, not the label it shows', () => {
  const linksColumn = HEADER.indexOf(LINKS);
  const { globals, requests } = fakeServices({
    sheetValues: [HEADER, row({ [LINKS]: 'iFood | 99Food' })],
    richTextOverrides: {
      [`1:${linksColumn}`]: richCell(IFOOD_URL, null, 'https://oia.99app.com/dlp9/abc'),
    },
  });
  load(globals).syncRestaurants();
  const links = committedLinks(requests);
  assert.equal(links.ifood.stringValue, IFOOD_URL);
  assert.deepEqual(
    links.others.arrayValue.values.map((value) => value.stringValue),
    ['https://oia.99app.com/dlp9/abc'],
  );
});

test('syncRestaurants ignores links in other columns and a links cell that is not text', () => {
  const { globals, requests } = fakeServices({
    sheetValues: [HEADER, row({ [LINKS]: '' })],
    richTextOverrides: {
      [`1:${HEADER.indexOf('Restaurante')}`]: richCell('https://www.rappi.com.br/not-from-this-column'),
      [`1:${HEADER.indexOf(LINKS)}`]: null,
    },
  });
  load(globals).syncRestaurants();
  const links = committedLinks(requests);
  assert.equal(links.ifood, undefined);
  assert.equal(links.others.arrayValue.values, undefined);
});

test('syncRestaurants commits nothing when nothing changed', () => {
  const restaurant = parseRows([HEADER, row()]).restaurants[0];
  const existing = [{ name: firestoreName(restaurant.id), fields: plain(rules.toFirestoreFields(restaurant)) }];
  const { globals, requests } = fakeServices({ sheetValues: [HEADER, row()], existing });
  load(globals).syncRestaurants();
  assert.equal(requests.some((request) => request.url.endsWith(':commit')), false);
});

test('syncRestaurants changes nothing when the sheet is empty, and reports the error', () => {
  const restaurant = parseRows([HEADER, row()]).restaurants[0];
  const existing = [{ name: firestoreName(restaurant.id), fields: plain(rules.toFirestoreFields(restaurant)) }];
  const { globals, requests, report } = fakeServices({ sheetValues: [HEADER], existing });
  assert.throws(() => load(globals).syncRestaurants());
  assert.equal(requests.some((request) => request.url.endsWith(':commit')), false);
  assert.ok(report.flat().some((cell) => /Nada foi alterado/.test(String(cell))));
});

test('syncRestaurants changes nothing when a column disappears, and reports the error', () => {
  const header = HEADER.map((column) => (column === 'Restaurante' ? 'Nome' : column));
  const { globals, requests, report } = fakeServices({ sheetValues: [header, row()] });
  assert.throws(() => load(globals).syncRestaurants());
  assert.equal(requests.some((request) => request.url.endsWith(':commit')), false);
  assert.ok(report.flat().some((cell) => /Nada foi alterado/.test(String(cell))));
});
