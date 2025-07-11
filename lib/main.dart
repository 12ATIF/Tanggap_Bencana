import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// Catatan Penting:
// 1. Hapus package `google_maps_flutter` dan tambahkan `flutter_map` dan `latlong2`
//    di file pubspec.yaml Anda:
//
//    dependencies:
//      flutter:
//        sdk: flutter
//      flutter_map: ^6.1.0 // Gunakan versi terbaru
//      latlong2: ^0.9.0    // Gunakan versi terbaru
//
// 2. TIDAK PERLU API KEY. Hapus konfigurasi API Key dari file Android & iOS jika ada.
//
// 3. Jalankan `flutter pub get` di terminal.

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tasik Siaga',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const MapScreen(),
      },
    );
  }
}