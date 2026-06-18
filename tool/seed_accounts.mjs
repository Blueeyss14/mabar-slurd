// Seed akun demo MabarKeun ke Firebase (Auth + Firestore) via REST API.
//
// Jalankan: node tool/seed_accounts.mjs
//
// Membuat/menyesuaikan:
//   - gamer@mabarkeun.com / Gamer123  (role user)
//   - admin@mabarkeun.com / Admin123  (role admin + 1 venue contoh)
//
// Catatan: API key di bawah adalah Web API key publik (sama dengan yang ada di
// lib/firebase_options.dart), bukan rahasia. Penulisan dokumen `users` bisa
// ditolak bila security rules untuk koleksi users belum di-deploy — deteksi
// admin tetap jalan lewat fallback kepemilikan venue.

const API_KEY = 'AIzaSyAjpMiJbV5nTTVaQcFTH-70metGeWfh73I';
const PROJECT = 'mabar-slurd';
const AUTH = 'https://identitytoolkit.googleapis.com/v1/accounts';
const FS = `https://firestore.googleapis.com/v1/projects/${PROJECT}/databases/(default)/documents`;
const H = { 'Content-Type': 'application/json' };

async function ensureAccount(email, password, displayName) {
  let res = await fetch(`${AUTH}:signUp?key=${API_KEY}`, {
    method: 'POST', headers: H,
    body: JSON.stringify({ email, password, returnSecureToken: true }),
  });
  let data = await res.json();
  let isNew = true;
  if (data.error) {
    if (data.error.message === 'EMAIL_EXISTS') {
      isNew = false;
      res = await fetch(`${AUTH}:signInWithPassword?key=${API_KEY}`, {
        method: 'POST', headers: H,
        body: JSON.stringify({ email, password, returnSecureToken: true }),
      });
      data = await res.json();
      if (data.error) throw new Error('signIn: ' + JSON.stringify(data.error));
    } else throw new Error('signUp: ' + JSON.stringify(data.error));
  }
  if (displayName && isNew) {
    await fetch(`${AUTH}:update?key=${API_KEY}`, {
      method: 'POST', headers: H,
      body: JSON.stringify({ idToken: data.idToken, displayName, returnSecureToken: false }),
    });
  }
  return { idToken: data.idToken, uid: data.localId, isNew };
}

async function tryStep(label, fn) {
  try { const r = await fn(); console.log(`  OK   ${label}${r ? ' -> ' + r : ''}`); }
  catch (e) { console.log(`  SKIP ${label}: ${e.message}`); }
}

async function setUserDoc(idToken, uid, role, displayName) {
  const url = `${FS}/users/${uid}?updateMask.fieldPaths=role&updateMask.fieldPaths=display_name`;
  const res = await fetch(url, {
    method: 'PATCH',
    headers: { ...H, Authorization: `Bearer ${idToken}` },
    body: JSON.stringify({ fields: {
      role: { stringValue: role },
      display_name: { stringValue: displayName },
    } }),
  });
  const d = await res.json();
  if (d.error) throw new Error(d.error.status || d.error.message);
}

async function myVenues(idToken, ownerUid) {
  const res = await fetch(`${FS}:runQuery`, {
    method: 'POST',
    headers: { ...H, Authorization: `Bearer ${idToken}` },
    body: JSON.stringify({ structuredQuery: {
      from: [{ collectionId: 'venues' }],
      where: { fieldFilter: { field: { fieldPath: 'owner_uid' }, op: 'EQUAL', value: { stringValue: ownerUid } } },
    } }),
  });
  const d = await res.json();
  if (d.error) throw new Error(JSON.stringify(d.error));
  return (d || []).filter((x) => x.document).map((x) => ({
    path: x.document.name,
    fields: x.document.fields || {},
  }));
}

// Lengkapi venue demo: koordinat (Jakarta), foto, jam buka, fasilitas.
async function patchVenueDemo(idToken, venuePath) {
  const masks = ['lat', 'lng', 'address', 'image_url', 'hours', 'facilities']
    .map((f) => `updateMask.fieldPaths=${f}`)
    .join('&');
  const url = `https://firestore.googleapis.com/v1/${venuePath}?${masks}`;
  const res = await fetch(url, {
    method: 'PATCH',
    headers: { ...H, Authorization: `Bearer ${idToken}` },
    body: JSON.stringify({ fields: {
      lat: { doubleValue: -6.200000 },
      lng: { doubleValue: 106.816666 },
      address: { stringValue: 'Jl. Sudirman No. 1, Jakarta Pusat (demo)' },
      image_url: { stringValue:
        'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=800&q=80' },
      hours: { stringValue: '10:00 - 24:00' },
      facilities: { arrayValue: { values: [
        { stringValue: 'AC' },
        { stringValue: 'WiFi' },
        { stringValue: 'Toilet' },
        { stringValue: 'Kantin' },
        { stringValue: 'Parkir' },
      ] } },
    } }),
  });
  const d = await res.json();
  if (d.error) throw new Error(d.error.status || d.error.message);
}

async function createVenue(idToken, ownerUid, name, price) {
  const res = await fetch(`${FS}/venues`, {
    method: 'POST',
    headers: { ...H, Authorization: `Bearer ${idToken}` },
    body: JSON.stringify({ fields: {
      name: { stringValue: name },
      price_per_hour: { integerValue: String(price) },
      rating: { doubleValue: 4.7 },
      distance: { doubleValue: 1.2 },
      badge: { stringValue: 'Populer' },
      owner_uid: { stringValue: ownerUid },
    } }),
  });
  const d = await res.json();
  if (d.error) throw new Error(d.error.status || d.error.message);
  return d.name.split('/').pop();
}

const DEFAULT_COMPUTERS = [
  { code: 'PC-01', spec: 'i3 / GTX 1650', tier: 'Reguler', type: 'PC' },
  { code: 'PC-02', spec: 'i3 / GTX 1650', tier: 'Reguler', type: 'PC' },
  { code: 'PC-03', spec: 'i5 / GTX 1660', tier: 'Reguler', type: 'PC' },
  { code: 'PC-04', spec: 'i5 / GTX 1660', tier: 'Reguler', type: 'PC' },
  { code: 'PC-05', spec: 'i5 / RTX 3060', tier: 'Gaming', type: 'PC' },
  { code: 'PC-06', spec: 'i5 / RTX 3060', tier: 'Gaming', type: 'PC' },
  { code: 'PC-07', spec: 'i7 / RTX 3070', tier: 'Gaming', type: 'PC' },
  { code: 'PC-08', spec: 'i7 / RTX 3070', tier: 'Gaming', type: 'PC' },
  { code: 'PC-09', spec: 'i7 / RTX 4070', tier: 'VIP', type: 'PC' },
  { code: 'PC-10', spec: 'i9 / RTX 4070', tier: 'VIP', type: 'PC' },
  { code: 'PC-11', spec: 'i9 / RTX 4080', tier: 'VIP', type: 'PC' },
  { code: 'PC-12', spec: 'i9 / RTX 4090', tier: 'VIP', type: 'PC' },
  { code: 'PS5-01', spec: 'PlayStation 5', tier: 'Console', type: 'Console' },
  { code: 'PS5-02', spec: 'PlayStation 5', tier: 'Console', type: 'Console' },
  { code: 'PS5-03', spec: 'PlayStation 5', tier: 'Console', type: 'Console' },
];

async function computerCount(idToken, venuePath) {
  const res = await fetch(`https://firestore.googleapis.com/v1/${venuePath}/computers`, {
    headers: { ...H, Authorization: `Bearer ${idToken}` },
  });
  const d = await res.json();
  if (d.error) throw new Error(d.error.status || d.error.message);
  return (d.documents || []).length;
}

async function addComputer(idToken, venuePath, c) {
  const res = await fetch(
    `https://firestore.googleapis.com/v1/${venuePath}/computers`,
    {
      method: 'POST',
      headers: { ...H, Authorization: `Bearer ${idToken}` },
      body: JSON.stringify({ fields: {
        code: { stringValue: c.code },
        name: { stringValue: c.code },
        spec: { stringValue: c.spec },
        tier: { stringValue: c.tier },
        type: { stringValue: c.type },
      } }),
    },
  );
  const d = await res.json();
  if (d.error) throw new Error(d.error.status || d.error.message);
}

async function seedComputers(idToken, venuePath) {
  const n = await computerCount(idToken, venuePath);
  if (n > 0) return `sudah ada ${n} unit, skip`;
  for (const c of DEFAULT_COMPUTERS) {
    await addComputer(idToken, venuePath, c);
  }
  return `${DEFAULT_COMPUTERS.length} unit ditambahkan`;
}

(async () => {
  console.log('GAMER (gamer@mabarkeun.com / Gamer123)');
  const gamer = await ensureAccount('gamer@mabarkeun.com', 'Gamer123', 'Gamer Demo');
  console.log(`  auth OK uid=${gamer.uid} new=${gamer.isNew}`);
  await tryStep('set role=user', () => setUserDoc(gamer.idToken, gamer.uid, 'user', 'Gamer Demo'));

  console.log('ADMIN (admin@mabarkeun.com / Admin123)');
  const admin = await ensureAccount('admin@mabarkeun.com', 'Admin123', 'Admin Warnet');
  console.log(`  auth OK uid=${admin.uid} new=${admin.isNew}`);
  await tryStep('set role=admin', () => setUserDoc(admin.idToken, admin.uid, 'admin', 'Admin Warnet'));

  let venues = [];
  await tryStep('cek venue admin', async () => {
    venues = await myVenues(admin.idToken, admin.uid);
    return `${venues.length} venue`;
  });
  if (venues.length === 0) {
    await tryStep('buat venue GG Arena Demo',
        () => createVenue(admin.idToken, admin.uid, 'GG Arena Demo', 15));
    await tryStep('muat ulang venue', async () => {
      venues = await myVenues(admin.idToken, admin.uid);
      return `${venues.length} venue`;
    });
  }

  // Lengkapi venue demo: lokasi, foto, jam buka, fasilitas.
  if (venues.length > 0) {
    await tryStep('lengkapi venue demo (lokasi/foto/jam/fasilitas)',
        () => patchVenueDemo(admin.idToken, venues[0].path));
    await tryStep('seed perangkat venue demo (15 unit + spek)',
        () => seedComputers(admin.idToken, venues[0].path));
  }

  console.log('\nSelesai. Login pakai akun di atas.');
})().catch((e) => { console.error('FATAL:', e.message); process.exit(1); });
