// Seed akun + warnet demo MabarKeun ke Firebase (Auth + Firestore) via REST API.
//
// Jalankan: node tool/seed_accounts.mjs
//
// Membuat:
//   - 1 akun gamer (user biasa)
//   - 3 akun admin, masing-masing punya 1 warnet lengkap (foto, jam buka,
//     fasilitas, lokasi, 15 unit perangkat + spek)
//
// Catatan: API key di bawah = Web API key publik (sama dgn lib/firebase_options.dart),
// bukan rahasia. Penulisan dokumen `users` (role) & subcollection `computers`
// hanya berhasil bila security rules sudah di-deploy. Sebelum deploy, langkah
// itu otomatis di-skip; deteksi admin tetap jalan via kepemilikan venue.

const API_KEY = 'AIzaSyAjpMiJbV5nTTVaQcFTH-70metGeWfh73I';
const PROJECT = 'mabar-slurd';
const AUTH = 'https://identitytoolkit.googleapis.com/v1/accounts';
const FS = `https://firestore.googleapis.com/v1/projects/${PROJECT}/databases/(default)/documents`;
const H = { 'Content-Type': 'application/json' };

const IMG = {
  gg: 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=800&q=80',
  nexus: 'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=800&q=80',
  cyber: 'https://images.unsplash.com/photo-1593305841991-05c297ba4575?w=800&q=80',
};

// Daftar admin + warnet dummy.
const ADMINS = [
  {
    email: 'admin@mabarkeun.com', pass: 'Admin123', name: 'Admin GG Arena',
    venue: {
      name: 'GG Arena Demo', price: 15, rating: 4.8, badge: 'Populer',
      lat: -6.200000, lng: 106.816666,
      address: 'Jl. Sudirman No. 1, Jakarta Pusat',
      image: IMG.gg, hours: '10:00 - 24:00',
      facilities: ['AC', 'WiFi', 'Toilet', 'Kantin', 'Parkir'],
    },
  },
  {
    email: 'admin2@mabarkeun.com', pass: 'Admin123', name: 'Admin Nexus',
    venue: {
      name: 'Nexus Esports', price: 20, rating: 4.6, badge: null,
      lat: -6.214600, lng: 106.845100,
      address: 'Jl. Gatot Subroto, Jakarta Selatan',
      image: IMG.nexus, hours: '09:00 - 23:00',
      facilities: ['AC', 'WiFi', 'Snack', 'Smoking Area'],
    },
  },
  {
    email: 'admin3@mabarkeun.com', pass: 'Admin123', name: 'Admin CyberShop',
    venue: {
      name: 'CyberShop Hub', price: 25, rating: 4.9, badge: 'Baru',
      lat: -6.175110, lng: 106.865036,
      address: 'Jl. M.H. Thamrin, Jakarta Pusat',
      image: IMG.cyber, hours: '24 Jam',
      facilities: ['AC', 'WiFi', 'Toilet', 'Kantin', 'Parkir', 'Mushola'],
    },
  },
];

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
  try { const r = await fn(); console.log(`  OK   ${label}${r ? ' -> ' + r : ''}`); return r; }
  catch (e) { console.log(`  SKIP ${label}: ${e.message}`); return null; }
}

function venueFields(ownerUid, v) {
  const f = {
    name: { stringValue: v.name },
    price_per_hour: { integerValue: String(v.price) },
    rating: { doubleValue: v.rating },
    distance: { doubleValue: 0 },
    owner_uid: { stringValue: ownerUid },
    lat: { doubleValue: v.lat },
    lng: { doubleValue: v.lng },
    address: { stringValue: v.address },
    image_url: { stringValue: v.image },
    hours: { stringValue: v.hours },
    facilities: { arrayValue: { values: v.facilities.map((x) => ({ stringValue: x })) } },
  };
  if (v.badge) f.badge = { stringValue: v.badge };
  return f;
}

async function setUserRole(idToken, uid, role, name) {
  const url = `${FS}/users/${uid}?updateMask.fieldPaths=role&updateMask.fieldPaths=display_name`;
  const res = await fetch(url, { method: 'PATCH',
    headers: { ...H, Authorization: `Bearer ${idToken}` },
    body: JSON.stringify({ fields: { role: { stringValue: role }, display_name: { stringValue: name } } }) });
  const d = await res.json();
  if (d.error) throw new Error(d.error.status || d.error.message);
}

async function myVenues(idToken, ownerUid) {
  const res = await fetch(`${FS}:runQuery`, { method: 'POST',
    headers: { ...H, Authorization: `Bearer ${idToken}` },
    body: JSON.stringify({ structuredQuery: {
      from: [{ collectionId: 'venues' }],
      where: { fieldFilter: { field: { fieldPath: 'owner_uid' }, op: 'EQUAL', value: { stringValue: ownerUid } } },
    } }) });
  const d = await res.json();
  if (d.error) throw new Error(JSON.stringify(d.error));
  return (d || []).filter((x) => x.document).map((x) => ({
    path: x.document.name, fields: x.document.fields || {},
  }));
}

async function createVenue(idToken, ownerUid, v) {
  const res = await fetch(`${FS}/venues`, { method: 'POST',
    headers: { ...H, Authorization: `Bearer ${idToken}` },
    body: JSON.stringify({ fields: venueFields(ownerUid, v) }) });
  const d = await res.json();
  if (d.error) throw new Error(d.error.status || d.error.message);
  return d.name; // full path
}

async function patchVenue(idToken, path, ownerUid, v) {
  const fields = venueFields(ownerUid, v);
  const masks = Object.keys(fields).map((k) => `updateMask.fieldPaths=${k}`).join('&');
  const res = await fetch(`https://firestore.googleapis.com/v1/${path}?${masks}`, {
    method: 'PATCH', headers: { ...H, Authorization: `Bearer ${idToken}` },
    body: JSON.stringify({ fields }) });
  const d = await res.json();
  if (d.error) throw new Error(d.error.status || d.error.message);
}

async function computerCount(idToken, path) {
  const res = await fetch(`https://firestore.googleapis.com/v1/${path}/computers`, {
    headers: { ...H, Authorization: `Bearer ${idToken}` } });
  const d = await res.json();
  if (d.error) throw new Error(d.error.status || d.error.message);
  return (d.documents || []).length;
}

async function seedComputers(idToken, path) {
  const n = await computerCount(idToken, path);
  if (n > 0) return `sudah ${n} unit, skip`;
  for (const c of DEFAULT_COMPUTERS) {
    const res = await fetch(`https://firestore.googleapis.com/v1/${path}/computers`, {
      method: 'POST', headers: { ...H, Authorization: `Bearer ${idToken}` },
      body: JSON.stringify({ fields: {
        code: { stringValue: c.code }, name: { stringValue: c.code },
        spec: { stringValue: c.spec }, tier: { stringValue: c.tier }, type: { stringValue: c.type },
      } }) });
    const d = await res.json();
    if (d.error) throw new Error(d.error.status || d.error.message);
  }
  return `${DEFAULT_COMPUTERS.length} unit ditambahkan`;
}

// ── Helpers untuk booking & review dummy ─────────────────────────────────────

async function bookingExists(idToken, venueId, userId) {
  const res = await fetch(`${FS}:runQuery`, { method: 'POST',
    headers: { ...H, Authorization: `Bearer ${idToken}` },
    body: JSON.stringify({ structuredQuery: {
      from: [{ collectionId: 'bookings' }],
      where: { compositeFilter: { op: 'AND', filters: [
        { fieldFilter: { field: { fieldPath: 'venue_id' }, op: 'EQUAL', value: { stringValue: venueId } } },
        { fieldFilter: { field: { fieldPath: 'user_id' }, op: 'EQUAL', value: { stringValue: userId } } },
      ]}},
      limit: 1,
    }}) });
  const d = await res.json();
  return (d || []).some((x) => x.document);
}

async function _createBooking(idToken, userId, venueId, venueName, computerId, startIso, endIso, hours, price, method, status) {
  const res = await fetch(`${FS}/bookings`, { method: 'POST',
    headers: { ...H, Authorization: `Bearer ${idToken}` },
    body: JSON.stringify({ fields: {
      venue_id:       { stringValue: venueId },
      venue_name:     { stringValue: venueName },
      user_id:        { stringValue: userId },
      computer_id:    { stringValue: computerId },
      device_type:    { stringValue: 'Gaming' },
      start_time:     { timestampValue: startIso },
      end_time:       { timestampValue: endIso },
      duration_hours: { integerValue: String(hours) },
      total_price:    { integerValue: String(price) },
      payment_method: { stringValue: method },
      payment_status: { stringValue: 'paid' },
      status:         { stringValue: status },
    }}) });
  const d = await res.json();
  if (d.error) throw new Error(d.error.status || d.error.message);
  return d.name.split('/').pop();
}

async function addBooking(idToken, userId, venueId, venueName, computerId, startIso, endIso, hours, price, method) {
  const already = await bookingExists(idToken, venueId, userId);
  if (already) return 'sudah ada, skip';
  return _createBooking(idToken, userId, venueId, venueName, computerId, startIso, endIso, hours, price, method, 'done');
}

async function addBookingActive(idToken, userId, venueId, venueName, computerId, startIso, endIso, hours, price, method) {
  // Booking aktif boleh lebih dari satu (berbeda venue/waktu), cukup cek duplikat per waktu
  return _createBooking(idToken, userId, venueId, venueName, computerId, startIso, endIso, hours, price, method, 'active');
}

async function reviewExists(idToken, venuePath, userId) {
  const res = await fetch(`${FS}:runQuery`, { method: 'POST',
    headers: { ...H, Authorization: `Bearer ${idToken}` },
    body: JSON.stringify({ structuredQuery: {
      from: [{ collectionId: 'reviews', allDescendants: false }],
      where: { fieldFilter: { field: { fieldPath: 'user_id' }, op: 'EQUAL', value: { stringValue: userId } } },
      limit: 1,
    }}) });
  // query hanya di subcollection venue tertentu perlu parent path — pakai list
  const listRes = await fetch(`https://firestore.googleapis.com/v1/${venuePath}/reviews`, {
    headers: { ...H, Authorization: `Bearer ${idToken}` } });
  const listD = await listRes.json();
  return (listD.documents || []).some((d) => d.fields?.user_id?.stringValue === userId);
}

async function addReview(idToken, venuePath, userId, userName, rating, comment) {
  const already = await reviewExists(idToken, venuePath, userId);
  if (already) return 'sudah ada, skip';
  const res = await fetch(`https://firestore.googleapis.com/v1/${venuePath}/reviews`, {
    method: 'POST', headers: { ...H, Authorization: `Bearer ${idToken}` },
    body: JSON.stringify({ fields: {
      user_id:    { stringValue: userId },
      user_name:  { stringValue: userName },
      rating:     { integerValue: String(rating) },
      comment:    { stringValue: comment },
      created_at: { timestampValue: new Date(Date.now() - 86400000 * Math.floor(Math.random() * 10 + 1)).toISOString() },
    }}) });
  const d = await res.json();
  if (d.error) throw new Error(d.error.status || d.error.message);
  return 'OK';
}

// Dummy users + riwayat booking + ulasan mereka
const DUMMY_USERS = [
  { email: 'gamer2@mabarkeun.com', pass: 'Gamer123', name: 'Rizky Pratama' },
  { email: 'gamer3@mabarkeun.com', pass: 'Gamer123', name: 'Budi Santoso' },
  { email: 'gamer4@mabarkeun.com', pass: 'Gamer123', name: 'Siti Aulia' },
];

// Ulasan per venue: [rating, komentar, nama user (akan diisi dari DUMMY_USERS index)]
const VENUE_REVIEWS = {
  'GG Arena Demo': [
    [5, 'PC-nya kenceng banget, nyaman main di sini! Recommended buat gaming marathon.', 0],
    [4, 'Tempatnya bersih dan sejuk, harganya worth it.', 1],
    [5, 'Koneksi stabil, staff ramah. Bakal balik lagi!', 2],
  ],
  'Nexus Esports': [
    [5, 'Spek PC-nya tinggi, cocok banget buat esport. Kursinya juga enak.', 0],
    [4, 'Lumayan, tempatnya agak rame tapi tetap nyaman.', 2],
  ],
  'CyberShop Hub': [
    [5, '24 jam mantap! Sering main malem di sini, aman dan nyaman.', 1],
    [4, 'PS5-nya keren, gamenya banyak dan lengkap.', 0],
    [5, 'Recommended banget buat nge-warnet sama temen-temen!', 2],
  ],
};

(async () => {
  // ── Akun gamer utama ──────────────────────────────────────────────────────
  console.log('GAMER (gamer@mabarkeun.com / Gamer123)');
  const gamer = await ensureAccount('gamer@mabarkeun.com', 'Gamer123', 'Gamer Demo');
  console.log(`  auth OK uid=${gamer.uid}`);
  await tryStep('set role=user', () => setUserRole(gamer.idToken, gamer.uid, 'user', 'Gamer Demo'));

  // ── Admin + venue ─────────────────────────────────────────────────────────
  const venueMap = {}; // name -> { path, id }
  for (const a of ADMINS) {
    console.log(`\nADMIN ${a.email} / ${a.pass}  ->  ${a.venue.name}`);
    const adm = await ensureAccount(a.email, a.pass, a.name);
    console.log(`  auth OK uid=${adm.uid}`);
    await tryStep('set role=admin', () => setUserRole(adm.idToken, adm.uid, 'admin', a.name));

    let venues = await myVenues(adm.idToken, adm.uid);
    let target = venues.find((x) => x.fields?.name?.stringValue === a.venue.name);
    if (target) {
      await tryStep('perbarui data warnet', () => patchVenue(adm.idToken, target.path, adm.uid, a.venue));
    } else {
      const path = await tryStep('buat warnet', () => createVenue(adm.idToken, adm.uid, a.venue));
      if (path) target = { path };
    }
    if (target) {
      await tryStep('seed 15 perangkat + spek', () => seedComputers(adm.idToken, target.path));
      const venueId = target.path.split('/').pop();
      venueMap[a.venue.name] = { path: target.path, id: venueId };
    }
  }

  // ── Dummy users + booking lama + ulasan ───────────────────────────────────
  console.log('\n── Dummy Users + Booking + Ulasan ──');
  const dummyAccounts = [];
  for (const u of DUMMY_USERS) {
    console.log(`\nUSER ${u.email}`);
    const acc = await ensureAccount(u.email, u.pass, u.name);
    console.log(`  auth OK uid=${acc.uid}`);
    await tryStep('set role=user', () => setUserRole(acc.idToken, acc.uid, 'user', u.name));
    dummyAccounts.push({ ...acc, name: u.name });
  }

  // Untuk setiap venue, seed booking lama (done) + booking aktif + ulasan
  const venueEntries = Object.entries(venueMap);
  for (const [venueName, { path, id }] of venueEntries) {
    const reviews = VENUE_REVIEWS[venueName] || [];
    for (const [rating, comment, userIdx] of reviews) {
      const acc = dummyAccounts[userIdx];
      if (!acc) continue;

      // Booking lama: 3-5 hari lalu, 2 jam, sudah done
      const start = new Date(Date.now() - 86400000 * (3 + userIdx));
      start.setHours(14, 0, 0, 0);
      const end = new Date(start.getTime() + 2 * 3600000);

      await tryStep(
        `booking selesai ${acc.name} @ ${venueName}`,
        () => addBooking(
          acc.idToken, acc.uid, id, venueName,
          'PC-05', start.toISOString(), end.toISOString(),
          2, 30, 'Bayar di Tempat',
        ),
      );

      await tryStep(
        `ulasan ${acc.name} @ ${venueName} (${rating}★)`,
        () => addReview(acc.idToken, path, acc.uid, acc.name, rating, comment),
      );
    }

    // Booking aktif hari ini: mulai 2 jam dari sekarang, 3 jam
    const nowPlus2h = new Date(Date.now() + 2 * 3600000);
    nowPlus2h.setMinutes(0, 0, 0);
    const activeEnd = new Date(nowPlus2h.getTime() + 3 * 3600000);
    const activeAcc = dummyAccounts[0]; // Rizky Pratama booking aktif
    if (activeAcc) {
      await tryStep(
        `booking aktif ${activeAcc.name} @ ${venueName}`,
        () => addBookingActive(
          activeAcc.idToken, activeAcc.uid, id, venueName,
          'PC-07', nowPlus2h.toISOString(), activeEnd.toISOString(),
          3, 45, 'GoPay',
        ),
      );
    }

    // Booking besok: user gamer utama
    const tomorrow = new Date(Date.now() + 86400000);
    tomorrow.setHours(19, 0, 0, 0);
    const tomorrowEnd = new Date(tomorrow.getTime() + 2 * 3600000);
    await tryStep(
      `booking besok gamer @ ${venueName}`,
      () => addBookingActive(
        gamer.idToken, gamer.uid, id, venueName,
        'PC-09', tomorrow.toISOString(), tomorrowEnd.toISOString(),
        2, 30, 'QRIS',
      ),
    );
  }

  console.log('\nSelesai. Lihat README untuk daftar akun.');
})().catch((e) => { console.error('FATAL:', e.message); process.exit(1); });
