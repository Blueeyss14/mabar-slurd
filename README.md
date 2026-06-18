# MabarKeun

Aplikasi cari & booking tempat gaming (warnet/rental PS) berbasis Flutter + Firebase.

## 🔑 Akun Demo (untuk dicoba teman-teman)

Sudah di-seed ke Firebase project `mabar-slurd`. Tinggal login pakai akun di bawah:

| Role | Email | Password | Warnet yang dikelola |
|------|-------|----------|----------------------|
| 🎮 **Gamer (user)** | `gamer@mabarkeun.com` | `Gamer123` | — (cari tempat, booking, riwayat) |
| 🛠️ **Admin 1** | `admin@mabarkeun.com` | `Admin123` | GG Arena Demo |
| 🛠️ **Admin 2** | `admin2@mabarkeun.com` | `Admin123` | Nexus Esports |
| 🛠️ **Admin 3** | `admin3@mabarkeun.com` | `Admin123` | CyberShop Hub |

Setiap warnet yang tampil di beranda user **dimiliki salah satu admin** di atas, lengkap dengan
foto, jam buka, fasilitas, lokasi, harga, dan 15 unit perangkat — semuanya **bisa diedit** admin
masing-masing lewat tab **Venue Saya**.

Alur coba: login **admin** lihat/kelola warnet → logout → login **gamer** → booking salah satu
warnet → logout → login **admin** pemiliknya → booking muncul di tab Booking, bisa **Tandai Selesai**.

> Daftar akun baru juga bisa lewat tombol **Daftar**, ada pilihan tipe akun **Gamer** / **Admin Warnet**.

## 🧰 Tech Stack

- **Flutter** (Dart) + **GetX** (state management)
- **Firebase**: Authentication, Cloud Firestore
- **flutter_map** + OpenStreetMap, geolocator/geocoding (peta & lokasi)
- Clean Architecture (feature-first: `lib/src/feat/<fitur>/presentation/...`)
- Codegen: Freezed, json_serializable

## 🚀 Menjalankan

```bash
flutter pub get
flutter run
```

## 👤 Role & Admin

- Admin bisa kelola tiap warnetnya: **info & harga**, **perangkat per-unit**
  (PC/Console + spek), **lokasi** (GPS), **foto** (URL), **jam buka**, dan **fasilitas**.
- **Role** disimpan di `users/{uid}.role` (`user` / `admin`), dipilih saat registrasi.
- Sebagai fallback, siapa pun yang **memiliki venue** (`venues.owner_uid == uid`)
  otomatis dianggap **admin** — jadi admin = pemilik warnet.
- Routing setelah login: admin → `AdminShell`, user → `MainShell`.

### Seed ulang akun demo

Butuh Node.js. Skrip akan membuat/menyesuaikan akun demo + venue contoh:

```bash
node tool/seed_accounts.mjs
```

### Catatan security rules

File [`firestore.rules`](firestore.rules) sudah role-aware (admin hanya bisa
kelola venue & booking miliknya). Untuk mengaktifkannya di server, deploy sekali:

```bash
firebase deploy --only firestore:rules
```

Sebelum di-deploy, penulisan dokumen `users` (role) mungkin ditolak server — itu
sebabnya deteksi admin memakai fallback kepemilikan venue agar demo tetap jalan.
