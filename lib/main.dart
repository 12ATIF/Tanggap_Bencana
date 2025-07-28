import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:tasik_siaga/firebase_options.dart';
import 'package:tasik_siaga/screens/admin/admin_dashboard_screen.dart';
import 'package:tasik_siaga/screens/admin/admin_login_screen.dart';
import 'package:tasik_siaga/screens/admin/disaster_form_screen.dart';
import 'package:tasik_siaga/screens/admin/manage_disasters_screen.dart';
import 'package:tasik_siaga/screens/admin/verification_list_screen.dart';
import 'package:tasik_siaga/screens/public/map_screen.dart';
import 'package:tasik_siaga/services/auth_service.dart';

void main() async {
  // Pastikan semua widget siap sebelum menjalankan kode async
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Jalankan aplikasi dengan provider untuk AuthService
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
      title: 'Tasik Siaga',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // AuthChecker akan menjadi halaman utama untuk memeriksa status login
      home: const AuthChecker(),
      routes: {
        '/map': (context) => const MapScreen(),
        '/login': (context) => const AdminLoginScreen(),
        '/dashboard': (context) => const AdminDashboardScreen(),
        '/manage-disasters': (context) => const ManageDisastersScreen(),
        '/verification-list': (context) => const VerificationListScreen(),
        '/disaster-form': (context) => const DisasterFormScreen(),
      },
    );
  }
}

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return FutureBuilder<bool>(
          future: authService.isLoggedIn(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.data == true) {
              // Jika sudah login, arahkan ke dashboard admin
              return const AdminDashboardScreen();
            }
            // Jika tidak, arahkan ke peta publik
            return const MapScreen();
          },
        );
      },
    );
  }
}