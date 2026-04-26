import 'package:flutter/material.dart';
import 'package:mabar_slurd/src/feat/auth/presentation/views/login_screen.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Menunggu 3 detik lalu berpindah ke HomeScreen
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          // Gradient Background untuk memberi kesan Dark Mode keren
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E1535), // Warna ungu kebiruan tua di atas
              Color(0xFF0C091A), // Warna gelap keunguan hitam di bawah
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            
            // Ikon Gamepad dengan Efek Glow (bayangan menyala)
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFF8A51FF), // Warna ungu terang untuk base-nya
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8A51FF).withOpacity(0.5), // Glow ungu
                    spreadRadius: 8,
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.sports_esports, // Ikon bawaan Flutter paling mirip Gamepad
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Judul Aplikasi
            const Text(
              "MabarKeun",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Subjudul Tulisan Abu-abu
            const Text(
              "Find & Book Gaming Spots Near You",
              style: TextStyle(
                color: Color(0xFFA1A1AA), // Warna abu-abu yang elegan
                fontSize: 14,
              ),
            ),
            
            const Spacer(),
            
            // Indikator 3 Titik loading di bagian paling bawah
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(0.3), // redup
                const SizedBox(width: 8),
                _buildDot(0.6), // sedang
                const SizedBox(width: 8),
                _buildDot(1.0), // terang
              ],
            ),
            const SizedBox(height: 48), // Padding jarak dari titik ke ujung layar bawah
          ],
        ),
      ),
    );
  }

  // Fungsi kecu kecil untuk membuat tiap titik (dot) dengan opacity (transparansi) yang bisa diatur
  Widget _buildDot(double opacity) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: const Color(0xFF8A51FF).withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}
