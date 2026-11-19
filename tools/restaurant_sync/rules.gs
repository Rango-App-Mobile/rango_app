// Pure rules for reading the team's restaurant sheet: no Apps Script services
// here, so `test/restaurant_sync_test.mjs` can run them under Node.

var RESTAURANTS_COLLECTION = 'restaurants';
var SHEET_SOURCE = 'sheet';
var MAX_WRITES_PER_COMMIT = 400;

// Rango is a local app: a position outside this box is a typo, such as swapped
// latitude and longitude, not a restaurant the app could show.
var REGION = { minLat: -30.4, maxLat: -29.8, minLng: -51.4, maxLng: -50.9 };

// Pages the sheet lists as links but where no order can be placed. The sheet uses
// a Google search when it has no direct link, and the app already offers that.
var NON_ORDER_HOSTS = [
  'google.com',
  'google.com.br',
  'linktr.ee',
  'beacons.ai',
  'restaurantguru.com',
  'restaurantguru.com.br',
  'facebook.com',
  'instagram.com',
  'tripadvisor.com',
  'tripadvisor.com.br',
];

var COLUMNS = {
  neighborhood: 'Bairro',
  name: 'Restaurante',
  cuisine: 'Tipo de comida',
  rating: 'Nota principal (Google > iFood > outras)',
  phone: 'Telefone',
  address: 'Endereço',
  location: 'Geolocalização (latitude, longitude)',
  served: 'Comidas Servidas',
  orderLinks: 'Links para pedir (Google quando não houver link direto)',
};
var CORRECTION_COLUMN = 'Comidas (correção)';

// Ids come from `LocalCategoryRepository`; a test keeps both lists equal. The
// patterns run on `normalizeText` output: lowercase and without accents.
var FOODS = [
  { id: 'spaghetti', label: 'Macarrão', pattern: /\b(macarrao|massas?|espaguete|spaghetti|penne|fettuccine|talharim|nhoque|italiana)\b/ },
  { id: 'pizza', label: 'Pizza', pattern: /\b(pizzas?|pizzaria)\b/ },
  { id: 'burger', label: 'Hambúrguer', pattern: /\b(hamburguer(es|ia)?|hamburgers?|burgers?|cheeseburger|smash)\b/ },
  { id: 'xis', label: 'Xis', pattern: /\bxis\b/ },
  { id: 'lasagna', label: 'Lasanha', pattern: /\b(lasanhas?|lasagna)\b/ },
  { id: 'sushi', label: 'Sushi', pattern: /\b(sushi|temaki|uramaki|sashimi|japonesa|japones)\b/ },
  { id: 'barbecue', label: 'Churrasco', pattern: /\b(churrasco|churrascaria|parrilla|picanha|costela|espeto)\b/ },
  { id: 'pastel', label: 'Pastel', pattern: /\b(past(el|eis)(?! de (nata|belem))|pastelaria)\b/ },
  { id: 'savory_snacks', label: 'Salgadinhos', pattern: /\b(salgados?|salgadinhos?|coxinhas?|kibes?|quibes?|risoles?)\b/ },
  { id: 'hot_dog', label: 'Cachorro-quente', pattern: /\b(cachorro.quente|hot.?dogs?)\b/ },
  { id: 'mexican', label: 'Mexicana', pattern: /\b(mexicana?|tacos?|burritos?|nachos|quesadillas?)\b/ },
  { id: 'chinese', label: 'Chinesa', pattern: /\b(chinesa|chines|yakisoba|rolinhos?|frango xadrez)\b/ },
  { id: 'fried_chicken', label: 'Frango frito', pattern: /\b(frango frito|frango empanado|fried chicken|tiras de frango)\b/ },
  { id: 'poke', label: 'Poke', pattern: /\b(pokes?)\b/ },
  { id: 'arabic', label: 'Árabe', pattern: /\b(arabe|esfihas?|esfirras?|beirutes?|falafel|oriente medio|libanesa)\b/ },
  { id: 'parmigiana', label: 'Parmegiana', pattern: /\b(parmegianas?|parmigiana)\b/ },
  { id: 'ice_cream', label: 'Sorvete', pattern: /\b(sorvetes?|sorveteria|gelatos?|sundae|picoles?)\b/ },
  { id: 'cake', label: 'Bolo', pattern: /\b(bolos?|cakes?)\b/ },
  { id: 'acai', label: 'Açaí', pattern: /\b(acai)\b/ },
  { id: 'brigadeiro', label: 'Brigadeiro', pattern: /\b(brigadeiros?|beijinhos?)\b/ },
  { id: 'donut', label: 'Donut', pattern: /\b(donuts?|rosquinhas?)\b/ },
  { id: 'churros', label: 'Churros', pattern: /\b(churros?)\b/ },
  { id: 'crepe', label: 'Crepe doce', pattern: /\b(crepes?)\b/ },
  { id: 'waffle', label: 'Waffle', pattern: /\b(waffles?)\b/ },
  { id: 'milkshake', label: 'Milk-shake', pattern: /\b(milk.?shakes?)\b/ },
  { id: 'brownie', label: 'Brownie', pattern: /\b(brownies?)\b/ },
  { id: 'cookie', label: 'Cookie', pattern: /\b(cookies?)\b/ },
  { id: 'pudding', label: 'Pudim', pattern: /\b(pudins?)\b/ },
  { id: 'paleta', label: 'Paleta mexicana', pattern: /\b(paletas? mexicanas?)\b/ },
  { id: 'pie', label: 'Torta doce', pattern: /\btortas?(?! de (frango|palmito|legumes|camarao|carne))\b/ },
  { id: 'petit_gateau', label: 'Petit gâteau', pattern: /\b(petit gateau)\b/ },
  { id: 'bonbon', label: 'Bombom', pattern: /\b(bombons?|trufas?)\b/ },
];

function normalizeText(text) {
  return String(text || '')
    .normalize('NFKD')
    .replace(/[̀-ͯ]/g, '')
    .toLowerCase()
    .replace(/\s+/g, ' ')
    .trim();
}

function slugify(text) {
  return normalizeText(text)
    .replace(/['’`´]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

// The sheet adds notes in parentheses to some neighborhoods; fixing one must
// not turn the restaurant into a new document.
function restaurantId(name, neighborhood) {
  const place = String(neighborhood || '').replace(/\(.*$/, '');
  return slugify(name) + '--' + slugify(place);
}

function ratingFromDayAndMonth(day, month) {
  return month <= 9 ? validRating(day + month / 10) : null;
}

function validRating(value) {
  const rounded = Math.round(value * 10) / 10;
  return rounded > 0 && rounded <= 5 ? rounded : null;
}

// Sheets in pt-BR read "4,9" typed with a slash or dot as a date, 4 September,
// and the cell may then hold its serial number instead of the rating.
function parseRating(text) {
  const value = String(text || '').trim();
  if (/^\d{5}(\.0+)?$/.test(value)) {
    const date = new Date(Date.UTC(1899, 11, 30) + Number(value) * 86400000);
    return ratingFromDayAndMonth(date.getUTCDate(), date.getUTCMonth() + 1);
  }
  const asDate = value.match(/^0?(\d)\/0?(\d)\/\d{2,4}$/);
  if (asDate) return ratingFromDayAndMonth(Number(asDate[1]), Number(asDate[2]));
  if (/^\d[.,]\d\s*\/\s*10\b/.test(value)) return null;
  if (/^5\s*\/\s*5\b/.test(value)) return 5;
  const decimal = value.match(/^(\d)[.,](\d+)\b/);
  return decimal ? validRating(parseFloat(decimal[1] + '.' + decimal[2])) : null;
}

function parsePhone(text) {
  const match = String(text || '').match(/(?:\+55\s*)?\(?\b(\d{2})\)?[\s.-]*(9?\d{4})[\s.-]*(\d{4})\b/);
  return match ? '(' + match[1] + ') ' + match[2] + '-' + match[3] : null;
}

function parseLocation(text) {
  const match = String(text || '').match(/^\s*(-?\d+\.\d+)\s*,\s*(-?\d+\.\d+)\s*$/);
  if (!match) return null;
  const latitude = Number(match[1]);
  const longitude = Number(match[2]);
  const inRegion =
    latitude >= REGION.minLat &&
    latitude <= REGION.maxLat &&
    longitude >= REGION.minLng &&
    longitude <= REGION.maxLng;
  return inRegion ? { latitude: latitude, longitude: longitude } : null;
}

function linkHost(url) {
  const authority = url.replace(/^https:\/\//, '').split(/[/?#]/)[0].toLowerCase();
  // `https://ifood.com.br@evil.example` opens evil.example.
  return authority.includes('@') ? null : authority.replace(/^www\./, '');
}

function isIfood(host) {
  return host === 'ifood.com.br' || (host !== null && host.endsWith('.ifood.com.br'));
}

function isOrderPage(host) {
  return (
    host !== null &&
    !NON_ORDER_HOSTS.some((blocked) => host === blocked || host.endsWith('.' + blocked))
  );
}

function parseDeliveryLinks(urls) {
  const secure = urls.filter((url) => url.startsWith('https://'));
  const ifoods = secure.filter((url) => isIfood(linkHost(url)));
  return {
    ifood: ifoods.length > 0 ? ifoods[0] : null,
    others: secure.filter((url) => {
      const host = linkHost(url);
      return !isIfood(host) && isOrderPage(host);
    }),
  };
}

function deduceFoods(cuisine, served) {
  const text = normalizeText(cuisine + ' ; ' + served);
  return FOODS.filter((food) => food.pattern.test(text)).map((food) => food.id);
}

// A filled correction cell replaces what was deduced. "Nenhuma" means the
// restaurant serves nothing on the menu.
function resolveFoods(deduced, correction) {
  const text = String(correction || '').trim();
  if (!text) return { foods: deduced, unknown: [] };
  const names = text.split(';').map((name) => name.trim()).filter(Boolean);
  const foods = [];
  const unknown = [];
  names.forEach((name) => {
    const normalized = normalizeText(name);
    if (normalized === 'nenhuma') return;
    const food = FOODS.find((item) => normalizeText(item.label) === normalized);
    if (!food) unknown.push(name);
    else if (!foods.includes(food.id)) foods.push(food.id);
  });
  return { foods: foods, unknown: unknown };
}

function columnIndexes(header) {
  const trimmed = (header || []).map((cell) => String(cell).trim());
  const missing = Object.keys(COLUMNS).filter((key) => !trimmed.includes(COLUMNS[key]));
  if (missing.length > 0) {
    throw new Error('Coluna ausente: ' + missing.map((key) => COLUMNS[key]).join(', '));
  }
  const indexes = { correction: trimmed.indexOf(CORRECTION_COLUMN) };
  Object.keys(COLUMNS).forEach((key) => {
    indexes[key] = trimmed.indexOf(COLUMNS[key]);
  });
  return indexes;
}

// `values` are the display values of the tab, header first. The links column only
// shows labels such as "iFood | 99Food", so `linksAt(rowIndex, columnIndex)` gives
// the addresses inside a cell. Rejected rows have a problem to fix, and their
// Firestore document stays as it is until then; skipped rows are valid but serve
// nothing on the menu, so the app could never show them.
function parseSheet(values, linksAt) {
  const indexes = columnIndexes(values[0]);
  const restaurants = [];
  const rejected = [];
  const skipped = [];
  const seen = {};

  values.slice(1).forEach((cells, index) => {
    if (cells.every((cell) => !String(cell).trim())) return;
    const rowNumber = index + 2;
    const cell = (key) => (indexes[key] < 0 ? '' : String(cells[indexes[key]] || '').trim());
    const name = cell('name');
    const reject = (id, reason) => rejected.push({ row: rowNumber, id: id, name: name, reason: reason });

    if (!name) return reject(null, 'Sem nome');
    const id = restaurantId(name, cell('neighborhood'));
    if (seen[id]) return reject(null, 'Restaurante repetido');
    seen[id] = true;

    const location = parseLocation(cell('location'));
    if (!location) return reject(id, 'Coordenada inválida');
    const resolved = resolveFoods(deduceFoods(cell('cuisine'), cell('served')), cell('correction'));
    if (resolved.unknown.length > 0) {
      return reject(id, 'Comida fora do cardápio: ' + resolved.unknown.join(', '));
    }
    if (resolved.foods.length === 0) {
      return skipped.push({ row: rowNumber, name: name, reason: 'Sem comida do cardápio' });
    }

    restaurants.push({
      id: id,
      name: name,
      location: location,
      foods: resolved.foods,
      cuisine: cell('cuisine'),
      address: cell('address'),
      rating: parseRating(cell('rating')),
      phone: parsePhone(cell('phone')),
      deliveryLinks: parseDeliveryLinks(linksAt(index + 1, indexes.orderLinks)),
    });
  });

  return { restaurants: restaurants, rejected: rejected, skipped: skipped };
}

function stringField(value) {
  return { stringValue: value };
}

function nullableString(value) {
  return value === null ? { nullValue: null } : stringField(value);
}

function stringList(values) {
  return values.length > 0 ? { arrayValue: { values: values.map(stringField) } } : { arrayValue: {} };
}

function toFirestoreFields(restaurant) {
  const links = { others: stringList(restaurant.deliveryLinks.others) };
  if (restaurant.deliveryLinks.ifood) links.ifood = stringField(restaurant.deliveryLinks.ifood);
  return {
    name: stringField(restaurant.name),
    location: { geoPointValue: restaurant.location },
    foods: stringList(restaurant.foods),
    cuisine: stringField(restaurant.cuisine),
    address: stringField(restaurant.address),
    rating: restaurant.rating === null ? { nullValue: null } : { doubleValue: restaurant.rating },
    phone: nullableString(restaurant.phone),
    deliveryLinks: { mapValue: { fields: links } },
    active: { booleanValue: true },
    source: stringField(SHEET_SOURCE),
  };
}

function canonicalJson(value) {
  if (Array.isArray(value)) return '[' + value.map(canonicalJson).join(',') + ']';
  if (value && typeof value === 'object') {
    const keys = Object.keys(value).sort();
    return '{' + keys.map((key) => JSON.stringify(key) + ':' + canonicalJson(value[key])).join(',') + '}';
  }
  return JSON.stringify(value);
}

function sameFields(fields, existingFields) {
  return Object.keys(fields).every(
    (key) => canonicalJson(fields[key]) === canonicalJson(existingFields[key]),
  );
}

function isActiveSheetDocument(document) {
  const fields = document.fields || {};
  return (
    fields.source !== undefined &&
    fields.source.stringValue === SHEET_SOURCE &&
    fields.active !== undefined &&
    fields.active.booleanValue === true
  );
}

// Only what changed is written: the free tier bills per write. A restaurant that
// left the sheet is deactivated, never deleted, so a bad edit loses no data.
// Documents registered by hand have no `source` and are left alone.
function planSync(restaurants, rejectedIds, existingDocuments) {
  const existingById = {};
  existingDocuments.forEach((document) => {
    existingById[document.id] = document;
  });
  const keptIds = {};
  rejectedIds.forEach((id) => {
    keptIds[id] = true;
  });

  const writes = [];
  let unchanged = 0;
  restaurants.forEach((restaurant) => {
    keptIds[restaurant.id] = true;
    const fields = toFirestoreFields(restaurant);
    const existing = existingById[restaurant.id];
    if (existing && sameFields(fields, existing.fields || {})) unchanged += 1;
    else writes.push({ id: restaurant.id, fields: fields });
  });

  const deactivate = existingDocuments
    .filter((document) => isActiveSheetDocument(document) && !keptIds[document.id])
    .map((document) => document.id);

  return { writes: writes, deactivate: deactivate, unchanged: unchanged };
}

// A sheet that lost half of its restaurants is far more likely to be a bad edit
// than a real change, and syncing it would take them off the map.
function isSafeToSync(restaurantCount, activeDocumentCount) {
  return restaurantCount > 0 && restaurantCount >= activeDocumentCount / 2;
}

function buildCommitBatches(plan, documentsRoot) {
  const documentName = (id) => documentsRoot + '/' + RESTAURANTS_COLLECTION + '/' + id;
  const updatedAt = [{ fieldPath: 'updatedAt', setToServerValue: 'REQUEST_TIME' }];
  const writes = plan.writes
    .map((write) => ({
      update: { name: documentName(write.id), fields: write.fields },
      updateMask: { fieldPaths: Object.keys(write.fields) },
      updateTransforms: updatedAt,
    }))
    .concat(
      plan.deactivate.map((id) => ({
        update: { name: documentName(id), fields: { active: { booleanValue: false } } },
        updateMask: { fieldPaths: ['active'] },
        updateTransforms: updatedAt,
        currentDocument: { exists: true },
      })),
    );

  const batches = [];
  for (let start = 0; start < writes.length; start += MAX_WRITES_PER_COMMIT) {
    batches.push(writes.slice(start, start + MAX_WRITES_PER_COMMIT));
  }
  return batches;
}
