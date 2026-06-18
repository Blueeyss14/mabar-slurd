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

async function venueCount(idToken, ownerUid) {
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
  return (d || []).filter((x) => x.document).length;
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

(async () => {
  console.log('GAMER (gamer@mabarkeun.com / Gamer123)');
  const gamer = await ensureAccount('gamer@mabarkeun.com', 'Gamer123', 'Gamer Demo');
  console.log(`  auth OK uid=${gamer.uid} new=${gamer.isNew}`);
  await tryStep('set role=user', () => setUserDoc(gamer.idToken, gamer.uid, 'user', 'Gamer Demo'));

  console.log('ADMIN (admin@mabarkeun.com / Admin123)');
  const admin = await ensureAccount('admin@mabarkeun.com', 'Admin123', 'Admin Warnet');
  console.log(`  auth OK uid=${admin.uid} new=${admin.isNew}`);
  await tryStep('set role=admin', () => setUserDoc(admin.idToken, admin.uid, 'admin', 'Admin Warnet'));

  let n = 0;
  await tryStep('cek venue admin', async () => { n = await venueCount(admin.idToken, admin.uid); return `${n} venue`; });
  if (n === 0) {
    await tryStep('buat venue GG Arena Demo', () => createVenue(admin.idToken, admin.uid, 'GG Arena Demo', 15));
  } else {
    console.log('  SKIP buat venue (sudah ada)');
  }

  console.log('\nSelesai. Login pakai akun di atas.');
})().catch((e) => { console.error('FATAL:', e.message); process.exit(1); });
