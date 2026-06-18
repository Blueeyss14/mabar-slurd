import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  static Stream<List<Map<String, dynamic>>> getVenues() {
    return _db
        .collection('venues')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  static Future<int> getAvailableSlots(
    String venueId,
    DateTime startTime,
    DateTime endTime,
    int totalSlots,
  ) async {
    try {
      final snapshot = await _db
          .collection('bookings')
          .where('venue_id', isEqualTo: venueId)
          .where('status', isEqualTo: 'active')
          .get();

      final overlapping = snapshot.docs.where((doc) {
        final existingStart = (doc['start_time'] as Timestamp).toDate();
        final existingEnd = (doc['end_time'] as Timestamp).toDate();
        return existingStart.isBefore(endTime) &&
            existingEnd.isAfter(startTime);
      }).length;

      return totalSlots - overlapping;
    } catch (_) {
      return totalSlots;
    }
  }

  /// Kembalikan daftar id komputer yang sudah dibooking (status active) dan
  /// waktunya overlap dengan rentang [startTime]–[endTime] di sebuah venue.
  static Future<Set<String>> getBookedComputers(
    String venueId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      final snapshot = await _db
          .collection('bookings')
          .where('venue_id', isEqualTo: venueId)
          .where('status', isEqualTo: 'active')
          .get();

      return snapshot.docs
          .where((doc) {
            final data = doc.data();
            if (data['computer_id'] == null) return false;
            final existingStart = (data['start_time'] as Timestamp).toDate();
            final existingEnd = (data['end_time'] as Timestamp).toDate();
            return existingStart.isBefore(endTime) &&
                existingEnd.isAfter(startTime);
          })
          .map((doc) => doc.data()['computer_id'] as String)
          .toSet();
    } catch (_) {
      return <String>{};
    }
  }

  /// Buat booking baru. Ketersediaan slot dicek tepat sebelum menulis.
  ///
  /// Catatan: pengecekan ini memakai query koleksi (lihat [getAvailableSlots]),
  /// sehingga TIDAK bisa dibungkus Firestore transaction (transaction hanya
  /// boleh membaca dokumen tunggal, bukan menjalankan query). Akibatnya masih
  /// ada jendela race yang sangat kecil bila dua user memesan slot yang sama
  /// pada saat bersamaan. Untuk skala aplikasi ini, risiko itu dapat diterima.
  /// Solusi anti-race penuh memerlukan model "slot-lock" (satu dokumen kunci
  /// per jam per venue) yang diubah secara atomik di dalam transaction.
  static Future<bool> createBooking({
    required String venueId,
    required String venueName,
    required DateTime startTime,
    required DateTime endTime,
    required int durationHours,
    required String deviceType,
    required int totalPrice,
    required String computerId,
  }) async {
    // Pastikan komputer yang dipilih belum dibooking di rentang waktu ini.
    final booked = await getBookedComputers(venueId, startTime, endTime);
    if (booked.contains(computerId)) return false;

    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';

    await _db.collection('bookings').add({
      'venue_id': venueId,
      'venue_name': venueName,
      'user_id': userId,
      'start_time': Timestamp.fromDate(startTime),
      'end_time': Timestamp.fromDate(endTime),
      'duration_hours': durationHours,
      'device_type': deviceType,
      'computer_id': computerId,
      'total_price': totalPrice,
      'status': 'active',
      'created_at': FieldValue.serverTimestamp(),
    });

    return true;
  }

  /// Ambil riwayat booking milik user yang sedang login,
  /// diurutkan dari yang terbaru.
  ///
  /// Catatan: sengaja TIDAK memakai orderBy('created_at') di server agar tidak
  /// membutuhkan composite index Firestore, dan agar booking yang baru dibuat
  /// (created_at serverTimestamp sempat null sesaat) tetap langsung muncul.
  /// Pengurutan dilakukan di sisi klien.
  static Stream<List<Map<String, dynamic>>> getBookingHistory() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return const Stream.empty();

    return _db
        .collection('bookings')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
          list.sort((a, b) {
            final aTime = (a['created_at'] as Timestamp?)?.toDate();
            final bTime = (b['created_at'] as Timestamp?)?.toDate();
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return -1; // baru dibuat → paling atas
            if (bTime == null) return 1;
            return bTime.compareTo(aTime); // terbaru dulu
          });
          return list;
        });
  }

  /// Semua booking pada sebuah venue (untuk dashboard admin),
  /// diurutkan terbaru dulu di sisi klien.
  static Stream<List<Map<String, dynamic>>> getVenueBookings(String venueId) {
    return _db
        .collection('bookings')
        .where('venue_id', isEqualTo: venueId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
          list.sort((a, b) {
            final aTime = (a['start_time'] as Timestamp?)?.toDate();
            final bTime = (b['start_time'] as Timestamp?)?.toDate();
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            return bTime.compareTo(aTime);
          });
          return list;
        });
  }

  /// Tandai booking sebagai selesai (dipakai admin venue).
  static Future<bool> markBookingDone(String bookingId) async {
    try {
      await _db
          .collection('bookings')
          .doc(bookingId)
          .update({'status': 'done'});
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Batalkan booking: ubah status menjadi 'cancelled'.
  /// Hanya boleh untuk booking milik user yang sedang login.
  static Future<bool> cancelBooking(String bookingId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return false;

    try {
      final doc = _db.collection('bookings').doc(bookingId);
      final snapshot = await doc.get();
      if (!snapshot.exists) return false;
      if (snapshot.data()?['user_id'] != userId) return false;

      await doc.update({'status': 'cancelled'});
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Ambil data profil tambahan user (mis. nomor telepon) dari Firestore.
  static Future<Map<String, dynamic>> getUserProfile() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return {};
    try {
      final snapshot = await _db.collection('users').doc(userId).get();
      return snapshot.data() ?? {};
    } catch (_) {
      return {};
    }
  }

  /// Ambil role user yang sedang login: 'admin' atau 'user'.
  ///
  /// Dua sumber:
  /// 1. Field `role` di dokumen users/{uid} (sumber utama, diset saat daftar).
  /// 2. Fallback: bila user memiliki venue (owner_uid == uid) → dianggap admin.
  ///    Berguna ketika dokumen users belum bisa ditulis (mis. security rules
  ///    untuk koleksi users belum di-deploy), sebab admin = pemilik warnet.
  static Future<String> getCurrentUserRole() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return 'user';

    try {
      final snapshot = await _db.collection('users').doc(userId).get();
      final role = snapshot.data()?['role'] as String?;
      if (role == 'admin') return 'admin';
      if (role == 'user') return 'user';
    } catch (_) {
      // lanjut ke fallback
    }

    try {
      final venues = await _db
          .collection('venues')
          .where('owner_uid', isEqualTo: userId)
          .limit(1)
          .get();
      if (venues.docs.isNotEmpty) return 'admin';
    } catch (_) {
      // abaikan
    }

    return 'user';
  }

  /// Catat role user di Firestore (dipakai saat registrasi).
  /// Best-effort: bila gagal (mis. rules belum mengizinkan), diabaikan saja —
  /// deteksi admin masih punya fallback lewat kepemilikan venue.
  static Future<void> setUserRole(String uid, String role) async {
    try {
      await _db.collection('users').doc(uid).set({
        'role': role,
        'created_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // diabaikan
    }
  }

  /// Buat venue baru milik admin yang sedang login.
  /// Mengembalikan id dokumen baru, atau null bila gagal.
  static Future<String?> createVenue({
    required String name,
    required int pricePerHour,
    double rating = 0,
    double distance = 0,
    String? badge,
    double? lat,
    double? lng,
    String? address,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    try {
      final ref = await _db.collection('venues').add({
        'name': name.trim(),
        'price_per_hour': pricePerHour,
        'rating': rating,
        'distance': distance,
        'badge': (badge != null && badge.trim().isNotEmpty) ? badge.trim() : null,
        'owner_uid': uid,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        if (address != null && address.trim().isNotEmpty)
          'address': address.trim(),
        'created_at': FieldValue.serverTimestamp(),
      });
      return ref.id;
    } catch (_) {
      return null;
    }
  }

  // ── Perangkat (komputer/konsol) per-venue ─────────────────────────────────
  // Disimpan di subcollection venues/{venueId}/computers.
  // Field: code (mis. PC-01), name, spec, tier, type (PC/Console).

  /// Stream daftar perangkat sebuah venue (untuk admin), diurutkan per code.
  static Stream<List<Map<String, dynamic>>> getVenueComputers(String venueId) {
    return _db
        .collection('venues')
        .doc(venueId)
        .collection('computers')
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((d) => {'docId': d.id, ...d.data()})
              .toList();
          list.sort((a, b) =>
              (a['code'] as String? ?? '').compareTo(b['code'] as String? ?? ''));
          return list;
        });
  }

  /// Ambil perangkat venue sekali (untuk halaman booking).
  /// Mengembalikan list dengan key 'id' = code agar konsisten dengan booking lama.
  static Future<List<Map<String, dynamic>>> getVenueComputersOnce(
      String venueId) async {
    try {
      final snap = await _db
          .collection('venues')
          .doc(venueId)
          .collection('computers')
          .get();
      final list = snap.docs.map((d) {
        final data = d.data();
        return {
          'id': data['code'] ?? d.id,
          'docId': d.id,
          'name': data['name'] ?? data['code'] ?? d.id,
          'spec': data['spec'] ?? '-',
          'tier': data['tier'] ?? 'Reguler',
          'type': data['type'] ?? 'PC',
        };
      }).toList();
      list.sort((a, b) =>
          (a['id'] as String).compareTo(b['id'] as String));
      return list;
    } catch (_) {
      return [];
    }
  }

  static Future<bool> addComputer(
    String venueId, {
    required String code,
    required String name,
    required String spec,
    required String tier,
    required String type,
  }) async {
    try {
      await _db.collection('venues').doc(venueId).collection('computers').add({
        'code': code.trim(),
        'name': name.trim(),
        'spec': spec.trim(),
        'tier': tier,
        'type': type,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> updateComputer(
    String venueId,
    String docId, {
    required String code,
    required String name,
    required String spec,
    required String tier,
    required String type,
  }) async {
    try {
      await _db
          .collection('venues')
          .doc(venueId)
          .collection('computers')
          .doc(docId)
          .update({
        'code': code.trim(),
        'name': name.trim(),
        'spec': spec.trim(),
        'tier': tier,
        'type': type,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deleteComputer(String venueId, String docId) async {
    try {
      await _db
          .collection('venues')
          .doc(venueId)
          .collection('computers')
          .doc(docId)
          .delete();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Isi cepat 15 unit standar (PC-01..PC-12, PS5-01..03) untuk venue baru.
  static Future<bool> seedDefaultComputers(String venueId) async {
    const defaults = [
      {'code': 'PC-01', 'spec': 'i3 / GTX 1650', 'tier': 'Reguler', 'type': 'PC'},
      {'code': 'PC-02', 'spec': 'i3 / GTX 1650', 'tier': 'Reguler', 'type': 'PC'},
      {'code': 'PC-03', 'spec': 'i5 / GTX 1660', 'tier': 'Reguler', 'type': 'PC'},
      {'code': 'PC-04', 'spec': 'i5 / GTX 1660', 'tier': 'Reguler', 'type': 'PC'},
      {'code': 'PC-05', 'spec': 'i5 / RTX 3060', 'tier': 'Gaming', 'type': 'PC'},
      {'code': 'PC-06', 'spec': 'i5 / RTX 3060', 'tier': 'Gaming', 'type': 'PC'},
      {'code': 'PC-07', 'spec': 'i7 / RTX 3070', 'tier': 'Gaming', 'type': 'PC'},
      {'code': 'PC-08', 'spec': 'i7 / RTX 3070', 'tier': 'Gaming', 'type': 'PC'},
      {'code': 'PC-09', 'spec': 'i7 / RTX 4070', 'tier': 'VIP', 'type': 'PC'},
      {'code': 'PC-10', 'spec': 'i9 / RTX 4070', 'tier': 'VIP', 'type': 'PC'},
      {'code': 'PC-11', 'spec': 'i9 / RTX 4080', 'tier': 'VIP', 'type': 'PC'},
      {'code': 'PC-12', 'spec': 'i9 / RTX 4090', 'tier': 'VIP', 'type': 'PC'},
      {'code': 'PS5-01', 'spec': 'PlayStation 5', 'tier': 'Console', 'type': 'Console'},
      {'code': 'PS5-02', 'spec': 'PlayStation 5', 'tier': 'Console', 'type': 'Console'},
      {'code': 'PS5-03', 'spec': 'PlayStation 5', 'tier': 'Console', 'type': 'Console'},
    ];
    try {
      final batch = _db.batch();
      final col =
          _db.collection('venues').doc(venueId).collection('computers');
      for (final c in defaults) {
        batch.set(col.doc(), {
          'code': c['code'],
          'name': c['code'],
          'spec': c['spec'],
          'tier': c['tier'],
          'type': c['type'],
        });
      }
      await batch.commit();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Perbarui info venue. Hanya field yang dikirim yang diubah.
  static Future<bool> updateVenue({
    required String venueId,
    required String name,
    required int pricePerHour,
    String? badge,
    double? lat,
    double? lng,
    String? address,
  }) async {
    try {
      await _db.collection('venues').doc(venueId).update({
        'name': name.trim(),
        'price_per_hour': pricePerHour,
        'badge': (badge != null && badge.trim().isNotEmpty) ? badge.trim() : null,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        if (address != null && address.trim().isNotEmpty)
          'address': address.trim(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Daftar venue milik admin yang sedang login (owner_uid == uid).
  static Stream<List<Map<String, dynamic>>> getMyVenues() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return const Stream.empty();
    return _db
        .collection('venues')
        .where('owner_uid', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  /// Simpan profil user: displayName ke FirebaseAuth, nomor telepon ke Firestore.
  static Future<bool> updateUserProfile({
    required String displayName,
    required String phone,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    try {
      await user.updateDisplayName(displayName.trim());
      await _db.collection('users').doc(user.uid).set({
        'display_name': displayName.trim(),
        'phone': phone.trim(),
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (_) {
      return false;
    }
  }
}
