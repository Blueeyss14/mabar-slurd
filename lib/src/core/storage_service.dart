import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Helper upload file ke Firebase Storage.
class StorageService {
  static final _storage = FirebaseStorage.instance;

  /// Upload foto venue, kembalikan URL unduhan (atau null bila gagal).
  /// Disimpan di path venues/{uid}/{timestamp}.jpg.
  static Future<String?> uploadVenueImage(String filePath) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anon';
    try {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final ref = _storage.ref('venues/$uid/$ts.jpg');
      await ref.putFile(File(filePath));
      return await ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }
}
