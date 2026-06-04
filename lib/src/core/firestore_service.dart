import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  static Stream<List<Map<String, dynamic>>> getVenues() {
    return _db.collection('venues').snapshots().map(
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
      // Hanya pakai equality filter di Firestore, overlap dicek client-side
      // supaya tidak butuh composite index
      final snapshot = await _db
          .collection('bookings')
          .where('venue_id', isEqualTo: venueId)
          .where('status', isEqualTo: 'active')
          .get();

      final overlapping = snapshot.docs.where((doc) {
        final existingStart = (doc['start_time'] as Timestamp).toDate();
        final existingEnd = (doc['end_time'] as Timestamp).toDate();
        return existingStart.isBefore(endTime) && existingEnd.isAfter(startTime);
      }).length;

      return totalSlots - overlapping;
    } catch (_) {
      // Jika gagal cek (misal permission), anggap semua slot masih tersedia
      return totalSlots;
    }
  }

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
    final available =
        await getAvailableSlots(venueId, startTime, endTime, totalSlots);
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
}
