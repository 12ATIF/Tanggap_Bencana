import 'package:flutter/material.dart';

class ManageDisastersScreen extends StatelessWidget {
  const ManageDisastersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Data Bencana'),
      ),
      body: const Center(
        child: Text(
          'Di sini akan ditampilkan daftar bencana yang sudah dipublikasikan.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

