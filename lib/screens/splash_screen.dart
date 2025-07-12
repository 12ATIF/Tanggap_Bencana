import 'dart:async';
import 'package:flutter/material.dart';

// File ini sudah tidak digunakan lagi dalam alur AuthChecker,
// tetapi diperbaiki untuk mencegah crash jika dipanggil di tempat lain.
// Logika navigasi utama kini ditangani oleh AuthChecker di main.dart.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Timer tidak lagi dibutuhkan karena navigasi dikontrol oleh AuthChecker
  // @override
  // void initState() {
  //   super.initState();
  //   Timer(const Duration(seconds: 3), () {
  //     // PERBAIKAN: Cek apakah widget masih ada di tree sebelum navigasi
  //     if (mounted) {
  //        // Logika navigasi lama dipindahkan ke AuthChecker
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.teal,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_outlined, size: 100, color: Colors.white),
            SizedBox(height: 20),
            Text(
              'Tasik Siaga',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Peta Informasi Bencana Tasikmalaya',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
