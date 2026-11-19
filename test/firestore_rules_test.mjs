import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { before, test } from 'node:test';

const projectId = 'demo-rango-app';
const authUrl =
  'http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1/accounts:signUp?key=fake-api-key';
const documentsUrl =
  `http://127.0.0.1:8080/v1/projects/${projectId}/databases/(default)/documents`;

let account;
let otherAccount;
let visitor;

before(async () => {
  account = await createAccount();
  otherAccount = await createAccount();
  visitor = await createAnonymousUser();
});

test('an account can read and write its own session and preferences', async () => {
  const sessionPath = `users/${account.localId}/sessions/${randomUUID()}`;
  const sessionWrite = await writeDocument(sessionPath, account.idToken, {
    result: { categoryId: 'pizza' },
  });

  await assertStatus(sessionWrite, 200);

  const sessionRead = await readDocument(sessionPath, account.idToken);
  await assertStatus(sessionRead, 200);

  const userPath = `users/${account.localId}`;
  const preferences = { deliveryApp: 'ifood', notifications: true };
  const userWrite = await writeDocument(userPath, account.idToken, {
    preferences,
  });

  await assertStatus(userWrite, 200);

  const userRead = await readDocument(userPath, account.idToken);
  await assertStatus(userRead, 200);
  const userDocument = await userRead.json();
  const fields = userDocument.fields.preferences.mapValue.fields;
  assert.equal(fields.deliveryApp.stringValue, 'ifood');
  assert.equal(fields.notifications.booleanValue, true);
});

test('an account cannot access another account\'s sessions or preferences', async () => {
  const sessionWrite = await writeDocument(
    `users/${otherAccount.localId}/sessions/${randomUUID()}`,
    account.idToken,
    { result: { categoryId: 'pizza' } },
  );
  const userRead = await readDocument(
    `users/${otherAccount.localId}`,
    account.idToken,
  );

  await assertStatus(sessionWrite, 403);
  await assertStatus(userRead, 403);
});

test('an anonymous visitor cannot read or write private user data', async () => {
  const sessionPath = `users/${visitor.localId}/sessions/${randomUUID()}`;
  const sessionWrite = await writeDocument(sessionPath, visitor.idToken, {
    result: { categoryId: 'pizza' },
  });
  const userWrite = await writeDocument(
    `users/${visitor.localId}`,
    visitor.idToken,
    { preferences: { deliveryApp: 'ifood' } },
  );
  const sessionRead = await readDocument(sessionPath, visitor.idToken);
  const userRead = await readDocument(
    `users/${visitor.localId}`,
    visitor.idToken,
  );

  await assertStatus(sessionWrite, 403);
  await assertStatus(userWrite, 403);
  await assertStatus(sessionRead, 403);
  await assertStatus(userRead, 403);
});

test('unauthenticated clients cannot access private user data', async () => {
  const response = await readDocument(`users/${account.localId}`);

  await assertStatus(response, 403);
});

test('authenticated clients can read delivery links but cannot change them', async () => {
  const restaurantPath = `restaurants/${randomUUID()}`;
  const accountRead = await readDocument(restaurantPath, account.idToken);
  const visitorRead = await readDocument(restaurantPath, visitor.idToken);
  const unauthenticatedRead = await readDocument(restaurantPath);
  const restaurantWrite = await writeDocument(
    restaurantPath,
    account.idToken,
    { deliveryUrl: 'https://example.com/order' },
  );
  const visitorWrite = await writeDocument(
    restaurantPath,
    visitor.idToken,
    { deliveryUrl: 'https://example.com/order' },
  );

  await assertStatus(accountRead, 404);
  await assertStatus(visitorRead, 404);
  await assertStatus(unauthenticatedRead, 403);
  await assertStatus(restaurantWrite, 403);
  await assertStatus(visitorWrite, 403);
});

async function createAccount() {
  const email = `rango-${randomUUID()}@example.com`;

  return createAuthUser({
    email,
    password: 'Rango-test-password-123!',
  });
}

async function createAnonymousUser() {
  return createAuthUser({});
}

async function createAuthUser(credentials) {
  const response = await fetch(authUrl, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ ...credentials, returnSecureToken: true }),
  });
  const user = await response.json();

  assert.equal(response.status, 200, JSON.stringify(user));
  return user;
}

async function assertStatus(response, expectedStatus) {
  if (response.status !== expectedStatus) {
    assert.equal(response.status, expectedStatus, await response.text());
  }
}

async function readDocument(path, idToken) {
  return requestDocument('GET', path, idToken);
}

async function writeDocument(path, idToken, fields) {
  return requestDocument('PATCH', path, idToken, fields);
}

async function requestDocument(method, path, idToken, fields) {
  const headers = {};
  if (idToken != null) headers.Authorization = `Bearer ${idToken}`;

  const request = { method, headers };
  if (fields != null) {
    headers['Content-Type'] = 'application/json';
    request.body = JSON.stringify({ fields: toFirestoreFields(fields) });
  }

  return fetch(`${documentsUrl}/${path}`, request);
}

function toFirestoreFields(fields) {
  return Object.fromEntries(
    Object.entries(fields).map(([key, value]) => [key, toFirestoreValue(value)]),
  );
}

function toFirestoreValue(value) {
  if (typeof value === 'string') return { stringValue: value };
  if (typeof value === 'boolean') return { booleanValue: value };
  if (typeof value === 'number') return { integerValue: String(value) };

  return { mapValue: { fields: toFirestoreFields(value) } };
}
