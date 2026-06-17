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
    required int totalSlots,
  }) async {
    final available = await getAvailableSlots(
      venueId,
      startTime,
      endTime,
      totalSlots,
    );
    if (available <= 0) return false;

    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';

    await _db.collection('bookings').add({
      'venue_id': venueId,
      'venue_name': venueName,
      'user_id': userId,
      'start_time': Timestamp.fromDate(startTime),
      'end_time': Timestamp.fromDate(endTime),
      'duration_hours': durationHours,
      'device_type': deviceType,
      'total_price': totalPrice,
      'status': 'active',
      'created_at': FieldValue.serverTimestamp(),
    });

    return true;
  }

  /// Ambil riwayat booking milik user yang sedang login,
  /// diurutkan dari yang terbaru.
  static Stream<List<Map<String, dynamic>>> getBookingHistory() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return const Stream.empty();

    return _db
        .collection('bookings')
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return {'id': doc.id, ...data};
          }).toList(),
        );
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
}
