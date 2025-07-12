import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasik_siaga/screens/admin/disaster_form_screen.dart';
import 'package:tasik_siaga/screens/admin/manage_disasters_screen.dart';
import 'package:tasik_siaga/screens/admin/verification_list_screen.dart';

// Import semua layar
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
      home: const AuthChecker(),
      routes: {
        '/map': (context) => const MapScreen(),
        '/login': (context) => const AdminLoginScreen(),
        '/dashboard': (context) => const AdminDashboardScreen(),

        // Rute baru untuk admin
        '/manage-disasters': (context) => const ManageDisastersScreen(),
        '/verification-list': (context) => const VerificationListScreen(),
        '/disaster-form': (context) => const DisasterFormScreen(),
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
      future: Provider.of<AuthService>(context, listen: false).isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        } else {
          if (snapshot.data == true) {
            return const AdminDashboardScreen();
          } else {
            return const MapScreen();
          }
        }
      },
    );
  }
}
