import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    // Tunggu frame pertama selesai di-render untuk menghindari transisi yang aneh
    await Future.delayed(Duration.zero);

    final session = Supabase.instance.client.auth.currentSession;
    
    // Cek apakah widget masih ada di tree sebelum navigasi
    if (mounted) {
      if (session != null) {
        // Jika ada sesi (sudah login), langsung ke peta
        Navigator.of(context).pushReplacementNamed('/map');
      } else {
        // Jika tidak ada sesi, tetap ke peta (sebagai publik)
        Navigator.of(context).pushReplacementNamed('/map');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_outlined, size: 100, color: Colors.teal),
            SizedBox(height: 20),
            Text('Tasik Siaga', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 40),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}