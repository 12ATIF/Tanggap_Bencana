import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import semua layar baru
import 'package:tasik_siaga/screens/splash_screen.dart';
import 'package:tasik_siaga/screens/public/map_screen.dart';
import 'package:tasik_siaga/screens/admin/admin_login_screen.dart';
import 'package:tasik_siaga/screens/admin/admin_dashboard_screen.dart';
import 'package:tasik_siaga/screens/public/report_form_screen.dart';
import 'package:tasik_siaga/services/auth_service.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tasik Siaga: Peta Bencana',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      // Logika untuk menentukan halaman awal
      home: const AuthChecker(),
      routes: {
        '/map': (context) => const MapScreen(),
        '/login': (context) => const AdminLoginScreen(),
        '/dashboard': (context) => const AdminDashboardScreen(),
        '/report': (context) => const ReportFormScreen(),
        // Tambahkan rute lain untuk verifikasi dan form admin di sini
      },
    );
  }
}

// Widget ini akan memeriksa status login dan mengarahkan pengguna
class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Kita gunakan future dari provider AuthService
      future: Provider.of<AuthService>(context, listen: false).isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Tampilkan splash screen selagi memeriksa
          return const SplashScreen();
        } else {
          if (snapshot.data == true) {
            // Jika sudah login, langsung ke dashboard admin
            return const AdminDashboardScreen();
          } else {
            // Jika tidak, ke peta publik
            return const MapScreen();
          }
        }
      },
    );
  }
}
