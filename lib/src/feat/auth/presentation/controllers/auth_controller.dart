import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mabar_slurd/src/feat/common/presentation/views/main_shell.dart'; // Sesuaikan rute ke Shell Utama
import 'package:mabar_slurd/src/feat/auth/presentation/views/login_screen.dart';

class AuthController extends GetxController {
  // Inisialisasi instance Firebase Auth untuk koneksi ke server
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // RxBool untuk loading state (indikator loading di tombol)
  var isLoading = false.obs;

  // ==========================================
  // LOGIKA REGISTRASI PENGGUNA BARU
  // ==========================================
  Future<void> registerUser(String email, String password, {String username = ''}) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      _showSnackbar('Peringatan', 'Email dan password tidak boleh kosong, Slurd!', Colors.orange);
      return;
    }

    try {
      isLoading.value = true;

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (username.trim().isNotEmpty) {
        await credential.user?.updateDisplayName(username.trim());
      }

      _showSnackbar('Sukses', 'Akun berhasil dibuat! Silakan masuk.', Colors.green);
      
      // Mengarahkan pengguna langsung ke halaman Login
      Get.offAll(() => const LoginScreen());
    } on FirebaseAuthException catch (e) {
      // Kita cek kode error-nya secara manual
      String errorMessage;

      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Email sudah dipakai, Slurd! Ganti email lain.';
          break;
        case 'weak-password':
          errorMessage = 'Password terlalu cupu (lemah), minimal 6 karakter.';
          break;
        case 'invalid-email':
          errorMessage = 'Format email kamu salah, periksa lagi.';
          break;
        default:
          errorMessage = 'Error Firebase: ${e.message}'; // Biar kelihatan error aslinya kalau belum terdaftar di switch
      }
      
      _showSnackbar('Gagal Registrasi', errorMessage, Colors.red);
    } catch (e) {
      _showSnackbar('Error', 'Terjadi masalah koneksi tidak terduga.', Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================
  // LOGIKA LOGIN PENGGUNA (ANTI CRASH)
  // ==========================================
  Future<void> loginUser(String email, String password) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      _showSnackbar('Peringatan', 'Email dan password harus diisi, Slurd!', Colors.orange);
      return;
    }

    try {
      isLoading.value = true;

      // Proses autentikasi ke Firebase
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      _showSnackbar('Berhasil', 'Selamat datang kembali di Mabar Slurd!', Colors.green);

      // Pindah ke MainShell dan hapus history stack
      Get.offAll(() => const MainShell());
    } on FirebaseAuthException catch (e) {
      // Penanganan error login yang spesifik agar tidak memicu crash
      String errorMessage = 'Email atau kata sandi salah, Slurd!';
      
      if (e.code == 'user-not-found') {
        errorMessage = 'Akun belum terdaftar! Silakan buat akun dulu.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Kata sandi yang kamu masukkan salah.';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'Kredensial salah atau akun tidak ditemukan.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Format alamat email salah.';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'Akun ini telah dinonaktifkan oleh admin.';
      }

      _showSnackbar('Gagal Masuk', errorMessage, Colors.red);
    } catch (e) {
      _showSnackbar('Error', 'Gagal terhubung ke server Firebase.', Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================
  // LOGIKA LOGOUT PENGGUNA
  // ==========================================
  Future<void> logoutUser() async {
    await _auth.signOut();
    _showSnackbar('Info', 'Kamu telah keluar dari aplikasi.', Colors.blue);
    Get.offAll(() => const LoginScreen());
  }

  // Helper fungsi pengaman Snackbar GetX
  void _showSnackbar(String title, String message, Color color) {
    // Memastikan context GetX sudah siap sebelum merender Snackbar overlay
    if (Get.context != null) {
      Get.snackbar(
        title,
        message,
        backgroundColor: color.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.info_outline, color: Colors.white),
      );
    }
  }
}