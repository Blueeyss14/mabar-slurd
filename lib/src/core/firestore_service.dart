import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Penanda internal bahwa slot sudah terkunci di tengah transaksi.
class _SlotTaken implements Exception {}

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  /// Daftar id "slot-lock" per jam untuk sebuah perangkat di rentang waktu.
  ///
  /// Tiap jam dipetakan ke satu dokumen kunci dengan id deterministik
  /// `{computerId}_{yyyyMMddHH}`. Karena id-nya tetap, dua transaksi yang
  /// mengincar jam yang sama akan menulis dokumen yang sama → Firestore
  /// menjamin hanya satu yang berhasil (anti-race sungguhan).
  static List<String> _hourlySlotIds(
    String computerId,
    DateTime start,
    DateTime end,
  ) {
    final ids = <String>[];
    var cur = DateTime(start.year, start.month, start.day, start.hour);
    while (cur.isBefore(end)) {
      final stamp = '${cur.year.toString().padLeft(4, '0')}'
          '${cur.month.toString().padLeft(2, '0')}'
          '${cur.day.toString().padLeft(2, '0')}'
          '${cur.hour.toString().padLeft(2, '0')}';
      ids.add('${computerId}_$stamp');
      cur = cur.add(const Duration(hours: 1));
    }
    return ids;
  }

  /// Lepas (hapus) semua slot-lock milik sebuah booking. Best-effort:
  /// kalau gagal (mis. rules belum deploy / kunci tak ada) diabaikan saja,
  /// sehingga tidak menggagalkan pembatalan / penandaan selesai.
  static Future<void> _releaseSlots(Map<String, dynamic> data) async {
    final venueId = data['venue_id'] as String?;
    final computerId = data['computer_id'] as String?;
    final start = data['start_time'];
    final end = data['end_time'];
    if (venueId == null ||
        computerId == null ||
        start is! Timestamp ||
        end is! Timestamp) {
      return;
    }
    try {
      final locksCol =
          _db.collection('venues').doc(venueId).collection('slot_locks');
      final batch = _db.batch();
      for (final id
          in _hourlySlotIds(computerId, start.toDate(), end.toDate())) {
        batch.delete(locksCol.doc(id));
      }
      await batch.commit();
    } catch (_) {
      // diabaikan
    }
  }

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

      final result = snapshot.docs
          .where((doc) {
            final data = doc.data();
            if (data['computer_id'] == null) return false;
            final start = data['start_time'];
            final end = data['end_time'];
            if (start is! Timestamp || end is! Timestamp) return false;
            final existingStart = start.toDate();
            final existingEnd = end.toDate();
            return existingStart.isBefore(endTime) &&
                existingEnd.isAfter(startTime);
          })
          .map((doc) => doc.data()['computer_id'] as String)
          .toSet();
      return result;
    } catch (_) {
      return <String>{};
    }
  }

  /// Buat booking baru secara atomik dengan model "slot-lock".
  ///
  /// Anti-race: tiap jam yang dipesan dikunci lewat satu dokumen
  /// `venues/{venueId}/slot_locks/{computerId}_{jam}` di dalam Firestore
  /// transaction. Karena id kunci deterministik, dua user yang memesan slot
  /// sama bersamaan tidak bisa dua-duanya berhasil — transaction yang kalah
  /// akan retry, melihat kunci sudah ada, lalu gagal (return null).
  ///
  /// Pre-check [getBookedComputers] tetap dijalankan agar booking lama yang
  /// belum punya slot-lock (mis. data seed) tetap dihormati.
  /// Return bookingId jika berhasil, null jika slot bentrok / gagal.
  static Future<String?> createBooking({
    required String venueId,
    required String venueName,
    required DateTime startTime,
    required DateTime endTime,
    required int durationHours,
    required String deviceType,
    required int totalPrice,
    required String computerId,
    String paymentMethod = 'Bayar di Tempat',
  }) async {
    // Pre-check kompatibilitas untuk booking lama tanpa slot-lock.
    final booked = await getBookedComputers(venueId, startTime, endTime);
    if (booked.contains(computerId)) return null;

    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    final isPaidOnCreation = paymentMethod == 'Bayar di Tempat';

    final locksCol =
        _db.collection('venues').doc(venueId).collection('slot_locks');
    final bookingRef = _db.collection('bookings').doc();
    final slotIds = _hourlySlotIds(computerId, startTime, endTime);

    final bookingData = <String, dynamic>{
      'venue_id': venueId,
      'venue_name': venueName,
      'user_id': userId,
      'start_time': Timestamp.fromDate(startTime),
      'end_time': Timestamp.fromDate(endTime),
      'duration_hours': durationHours,
      'device_type': deviceType,
      'computer_id': computerId,
      'total_price': totalPrice,
      'payment_method': paymentMethod,
      'payment_status': isPaidOnCreation ? 'paid' : 'pending',
      'status': 'active',
      'created_at': FieldValue.serverTimestamp(),
    };

    try {
      await _db.runTransaction((tx) async {
        // Semua READ harus mendahului semua WRITE dalam satu transaction.
        for (final id in slotIds) {
          final snap = await tx.get(locksCol.doc(id));
          if (snap.exists) throw _SlotTaken();
        }
        // Kunci tiap jam + tulis dokumen booking secara atomik.
        for (final id in slotIds) {
          tx.set(locksCol.doc(id), {
            'booking_id': bookingRef.id,
            'computer_id': computerId,
            'user_id': userId,
            'start_time': Timestamp.fromDate(startTime),
            'end_time': Timestamp.fromDate(endTime),
          });
        }
        tx.set(bookingRef, bookingData);
      });
      return bookingRef.id;
    } on _SlotTaken {
      // Bentrok beneran: slot sudah dikunci user lain.
      return null;
    } catch (_) {
      // Transaksi slot-lock gagal karena alasan lain (mis. security rules
      // slot_locks belum di-deploy). Jangan blokir user: fallback ke tulis
      // booking langsung (tanpa kunci, jendela race kecil seperti versi lama).
      try {
        await bookingRef.set(bookingData);
        return bookingRef.id;
      } catch (_) {
        return null;
      }
    }
  }

  static Future<void> markPaymentPaid(String bookingId) async {
    await _db
        .collection('bookings')
        .doc(bookingId)
        .update({'payment_status': 'paid'});
  }

  /// Ubah jadwal booking (reschedule) secara atomik.
  ///
  /// Slot-lock lama dilepas dan slot baru dikunci di dalam satu transaction,
  /// dengan mengecualikan kunci milik booking ini sendiri. Pre-check query
  /// tetap dijalankan untuk menghormati booking lama tanpa slot-lock.
  /// Hanya pemilik booking (dijaga rules).
  static Future<bool> rescheduleBooking({
    required String bookingId,
    required String venueId,
    required String computerId,
    required DateTime startTime,
    required DateTime endTime,
    required int durationHours,
    required int totalPrice,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return false;

    try {
      // Pre-check kompatibilitas: bentrok dengan booking lain (abaikan diri).
      final snapshot = await _db
          .collection('bookings')
          .where('venue_id', isEqualTo: venueId)
          .where('status', isEqualTo: 'active')
          .get();
      final bentrok = snapshot.docs.any((doc) {
        if (doc.id == bookingId) return false; // abaikan diri sendiri
        final data = doc.data();
        if (data['computer_id'] != computerId) return false;
        final start = data['start_time'];
        final end = data['end_time'];
        if (start is! Timestamp || end is! Timestamp) return false;
        final s = start.toDate();
        final e = end.toDate();
        return s.isBefore(endTime) && e.isAfter(startTime);
      });
      if (bentrok) return false;

      final bookingRef = _db.collection('bookings').doc(bookingId);
      final locksCol =
          _db.collection('venues').doc(venueId).collection('slot_locks');
      final newSlotIds = _hourlySlotIds(computerId, startTime, endTime);

      final updateData = <String, dynamic>{
        'start_time': Timestamp.fromDate(startTime),
        'end_time': Timestamp.fromDate(endTime),
        'duration_hours': durationHours,
        'total_price': totalPrice,
        'computer_id': computerId,
      };

      try {
        await _db.runTransaction((tx) async {
          // READS dulu.
          final bookingSnap = await tx.get(bookingRef);
          if (!bookingSnap.exists) throw _SlotTaken();
          final data = bookingSnap.data() as Map<String, dynamic>;
          final oldStart = (data['start_time'] as Timestamp?)?.toDate();
          final oldEnd = (data['end_time'] as Timestamp?)?.toDate();
          final oldComputerId = data['computer_id'] as String? ?? computerId;

          for (final id in newSlotIds) {
            final snap = await tx.get(locksCol.doc(id));
            if (snap.exists) {
              final owner =
                  (snap.data() as Map<String, dynamic>)['booking_id'];
              if (owner != bookingId) throw _SlotTaken();
            }
          }

          // WRITES: lepas kunci lama, pasang kunci baru, perbarui booking.
          if (oldStart != null && oldEnd != null) {
            for (final id
                in _hourlySlotIds(oldComputerId, oldStart, oldEnd)) {
              tx.delete(locksCol.doc(id));
            }
          }
          for (final id in newSlotIds) {
            tx.set(locksCol.doc(id), {
              'booking_id': bookingId,
              'computer_id': computerId,
              'user_id': userId,
              'start_time': Timestamp.fromDate(startTime),
              'end_time': Timestamp.fromDate(endTime),
            });
          }
          tx.update(bookingRef, updateData);
        });
        return true;
      } on _SlotTaken {
        // Bentrok beneran dengan slot user lain.
        return false;
      } catch (_) {
        // Slot-lock tak bisa diakses (mis. rules belum deploy). Pre-check di
        // atas sudah memastikan tak bentrok, jadi lanjut update biasa.
        await bookingRef.update(updateData);
        return true;
      }
    } catch (_) {
      return false;
    }
  }

  /// Ambil riwayat booking milik user yang sedang login,
  /// diurutkan berdasarkan waktu sesi (start_time) — terbaru/akan datang dulu.
  ///
  /// Catatan: sengaja TIDAK memakai orderBy di server agar tidak membutuhkan
  /// composite index Firestore, dan agar booking yang baru dibuat (created_at
  /// serverTimestamp sempat null sesaat) tetap langsung muncul. Pengurutan
  /// dilakukan di sisi klien.
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
            // Utama: urutkan dari waktu sesi terbaru/akan datang ke yang lama.
            final aStart = (a['start_time'] as Timestamp?)?.toDate();
            final bStart = (b['start_time'] as Timestamp?)?.toDate();
            if (aStart != null && bStart != null && aStart != bStart) {
              return bStart.compareTo(aStart);
            }
            // Penyeimbang: kalau waktu sesi sama/null, pakai waktu dibuat.
            final aCreated = (a['created_at'] as Timestamp?)?.toDate();
            final bCreated = (b['created_at'] as Timestamp?)?.toDate();
            if (aCreated == null && bCreated == null) return 0;
            if (aCreated == null) return -1; // baru dibuat → paling atas
            if (bCreated == null) return 1;
            return bCreated.compareTo(aCreated);
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
  /// Sekalian melepas slot-lock agar jam tersebut bebas lagi.
  static Future<bool> markBookingDone(String bookingId) async {
    try {
      final docRef = _db.collection('bookings').doc(bookingId);
      final snapshot = await docRef.get();
      if (!snapshot.exists) return false;

      await docRef.update({'status': 'done'});
      await _releaseSlots(snapshot.data()!); // best-effort
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Batalkan booking: ubah status menjadi 'cancelled' dan lepas slot-lock.
  /// Hanya boleh untuk booking milik user yang sedang login.
  static Future<bool> cancelBooking(String bookingId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return false;

    try {
      final docRef = _db.collection('bookings').doc(bookingId);
      final snapshot = await docRef.get();
      if (!snapshot.exists) return false;
      final data = snapshot.data();
      if (data?['user_id'] != userId) return false;

      await docRef.update({'status': 'cancelled'});
      await _releaseSlots(data!); // best-effort
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

  static Future<void> savePreferredPayment(String method) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).set(
      {'preferred_payment': method},
      SetOptions(merge: true),
    );
  }

  static Future<String?> getPreferredPayment() async {
    final profile = await getUserProfile();
    return profile['preferred_payment'] as String?;
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
    String? imageUrl,
    String? hours,
    List<String>? facilities,
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
        if (imageUrl != null && imageUrl.trim().isNotEmpty)
          'image_url': imageUrl.trim(),
        if (hours != null && hours.trim().isNotEmpty) 'hours': hours.trim(),
        if (facilities != null) 'facilities': facilities,
        'created_at': FieldValue.serverTimestamp(),
      });
      // Warnet baru langsung diisi 15 unit standar agar siap menerima booking.
      // Admin bisa edit/hapus/tambah sesuai kondisi warnet aslinya.
      await seedDefaultComputers(ref.id);
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
    String? imageUrl,
    String? hours,
    List<String>? facilities,
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
        if (imageUrl != null) 'image_url': imageUrl.trim(),
        if (hours != null) 'hours': hours.trim(),
        if (facilities != null) 'facilities': facilities,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Cek apakah user yang login pernah booking di venue ini (untuk gate review).
  static Future<bool> hasUserBooked(String venueId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final snap = await _db
        .collection('bookings')
        .where('venue_id', isEqualTo: venueId)
        .where('user_id', isEqualTo: user.uid)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  // ── Ulasan (rating + komentar) per-venue ──────────────────────────────────
  // Disimpan di subcollection venues/{venueId}/reviews.

  /// Kirim ulasan untuk sebuah venue. user_id diikat ke akun yang login.
  /// Setelah tersimpan, rata-rata rating venue diperbarui agar konsisten.
  static Future<String?> addReview(
    String venueId, {
    required int rating,
    required String comment,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'Kamu belum login.';
    try {
      final reviewsCol =
          _db.collection('venues').doc(venueId).collection('reviews');
      await reviewsCol.add({
        'user_id': user.uid,
        'user_name': user.displayName ?? 'Pengguna',
        'rating': rating,
        'comment': comment.trim(),
        'created_at': FieldValue.serverTimestamp(),
      });

      // Best-effort: hitung ulang rata-rata & jumlah ulasan ke dokumen venue.
      try {
        final all = await reviewsCol.get();
        final ratings = all.docs
            .map((d) => (d.data()['rating'] as num?)?.toDouble() ?? 0)
            .toList();
        if (ratings.isNotEmpty) {
          final avg = ratings.reduce((a, b) => a + b) / ratings.length;
          await _db.collection('venues').doc(venueId).update({
            'rating': double.parse(avg.toStringAsFixed(1)),
            'rating_count': ratings.length,
          });
        }
      } catch (_) {}
      return null; // null = sukses
    } catch (e) {
      return 'Gagal mengirim ulasan: $e';
    }
  }

  /// Ambil ulasan sebuah venue (terbaru dulu, diurutkan klien).
  static Future<List<Map<String, dynamic>>> getVenueReviews(
      String venueId) async {
    try {
      final snap = await _db
          .collection('venues')
          .doc(venueId)
          .collection('reviews')
          .get();
      final list =
          snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
      list.sort((a, b) {
        final at = (a['created_at'] as Timestamp?)?.toDate();
        final bt = (b['created_at'] as Timestamp?)?.toDate();
        if (at == null && bt == null) return 0;
        if (at == null) return -1;
        if (bt == null) return 1;
        return bt.compareTo(at);
      });
      return list;
    } catch (_) {
      return [];
    }
  }

  /// Hapus venue (beserta dokumennya). Hanya admin pemilik (dijaga rules).
  static Future<bool> deleteVenue(String venueId) async {
    try {
      await _db.collection('venues').doc(venueId).delete();
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

  /// Simpan profil user: displayName + foto ke FirebaseAuth, telepon & foto ke Firestore.
  static Future<bool> updateUserProfile({
    required String displayName,
    required String phone,
    String? photoUrl,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    try {
      await user.updateDisplayName(displayName.trim());
      if (photoUrl != null) await user.updatePhotoURL(photoUrl);
      await _db.collection('users').doc(user.uid).set({
        'display_name': displayName.trim(),
        'phone': phone.trim(),
        if (photoUrl != null) 'photo_url': photoUrl,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Ubah email akun. Memerlukan login yang masih segar; jika gagal karena
  /// 'requires-recent-login', kembalikan kode itu agar UI bisa minta re-login.
  static Future<String> updateEmail(String newEmail) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'no-user';
    try {
      await user.verifyBeforeUpdateEmail(newEmail.trim());
      return 'verify-sent';
    } on FirebaseAuthException catch (e) {
      return e.code;
    } catch (_) {
      return 'error';
    }
  }
}
