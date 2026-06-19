# MabarKeun

Aplikasi mobile untuk mencari dan booking tempat gaming (warnet / rental PS), lengkap dengan
panel admin per-warnet. Dibangun dengan **Flutter + Firebase**.

---

## Fitur

### Untuk Gamer (user)
- Cari warnet terdekat (peta + daftar), **search** per nama, dan **filter** (urutan + harga maks)
- Lihat detail warnet: foto, jam buka, fasilitas, lokasi, harga, dan **ulasan**
- Booking: pilih tanggal, jam (24 jam), durasi, **unit perangkat** (PC/Console + spek),
  dan **metode pembayaran**
- Ketersediaan unit **real-time** (unit yang sudah dibooking ditandai otomatis)
- Riwayat booking: lihat detail, **batalkan**, atau **ubah jadwal (reschedule)**
- Beri **rating & ulasan** ke warnet
- Notifikasi dari aktivitas booking sendiri

### Untuk Admin Warnet
- Dashboard **booking masuk** + statistik (total booking, hari ini, pendapatan)
- **Tandai booking selesai**
- Kelola venue: buat / edit / hapus, atur harga, label, **lokasi (GPS)**,
  **foto (upload galeri / URL)**, **jam buka**, **fasilitas**
- Kelola **perangkat per-warnet**: tambah / edit / hapus unit (kode, nama, spek, tier, tipe)

---

## Akun Demo

Login dengan akun di bawah (sudah di-seed ke project `mabar-slurd`):

| Role | Email | Password | Warnet |
|------|-------|----------|--------|
| Gamer | `gamer@mabarkeun.com` | `Gamer123` | — |
| Admin 1 | `admin@mabarkeun.com` | `Admin123` | GG Arena Demo |
| Admin 2 | `admin2@mabarkeun.com` | `Admin123` | Nexus Esports |
| Admin 3 | `admin3@mabarkeun.com` | `Admin123` | CyberShop Hub |

Tiap warnet di beranda dimiliki salah satu admin, lengkap dengan foto, jam buka, fasilitas,
lokasi, harga, dan unit perangkat — semuanya bisa diedit admin masing-masing.

**Alur coba:** login admin → kelola warnet → logout → login gamer → booking → logout →
login admin pemilik → booking muncul di dashboard, tekan **Tandai Selesai**.

> Bisa juga daftar akun baru lewat tombol **Daftar** (pilih tipe **Gamer** / **Admin Warnet**).

---

## Tech Stack

- **Flutter** (Dart) + **GetX** — state management & routing
- **Firebase** — Authentication, Cloud Firestore, Storage
- **flutter_map** + OpenStreetMap, **geolocator** / **geocoding** — peta & lokasi
- **image_picker** — pilih foto dari galeri
- Arsitektur **feature-first**: `lib/src/feat/<fitur>/presentation/...`

---

## Menjalankan

```bash
flutter pub get
flutter run
```

---

## Setup Firebase

Sebagian fitur menulis ke Firestore/Storage, jadi rules perlu di-deploy sekali oleh
pemilik project. Paling mudah lewat **Firebase Console**:

1. **Firestore Rules** — Console → Firestore Database → tab **Rules** →
   paste isi [firestore.rules](firestore.rules) → **Publish**
2. **Aktifkan Storage** — Console → Build → **Storage** → Get started →
   tab **Rules** → paste isi [storage.rules](storage.rules) → **Publish**

Atau via CLI (perlu `firebase login`):

```bash
firebase deploy --only firestore:rules,storage
```

### Seed akun & data demo

Butuh Node.js. Membuat 1 gamer + 3 admin beserta warnet & 15 unit perangkat tiap warnet:

```bash
node tool/seed_accounts.mjs
```

> Catatan: penulisan dokumen `users`/`computers`/`reviews` & upload foto hanya berhasil
> setelah rules di-deploy. Sebelum itu, deteksi admin tetap jalan via fallback kepemilikan venue.

---

## Model Data (Firestore)

```
users/{uid}
  role            : "user" | "admin"
  display_name, phone

venues/{venueId}
  name, price_per_hour, rating, badge, owner_uid
  lat, lng, address, image_url, hours, facilities[]

  computers/{id}    code, name, spec, tier, type (PC|Console)
  reviews/{id}      user_id, user_name, rating, comment, created_at

bookings/{id}
  venue_id, venue_name, user_id, computer_id, device_type
  start_time, end_time, duration_hours, total_price
  payment_method, status (active|done|cancelled), created_at
```

### Role & Admin
- **Role** disimpan di `users/{uid}.role`, dipilih saat registrasi.
- Fallback: siapa pun yang memiliki venue (`owner_uid == uid`) dianggap **admin**.
- Routing login: admin → `AdminShell`, user → `MainShell`.
- Keamanan: admin hanya bisa mengelola venue, perangkat, & booking miliknya
  (lihat [firestore.rules](firestore.rules)).
