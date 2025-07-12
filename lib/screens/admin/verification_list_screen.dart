// File: lib/screens/admin/verification_list_screen.dart
import 'package:flutter/material.dart';

class VerificationListScreen extends StatelessWidget {
  const VerificationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi Laporan Warga'),
      ),
      body: const Center(
        child: Text(
          'Di sini akan ditampilkan daftar laporan dari warga yang menunggu verifikasi.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}