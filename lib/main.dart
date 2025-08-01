import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tasik_siaga/screens/admin/admin_dashboard_screen.dart';
import 'package:tasik_siaga/screens/admin/admin_login_screen.dart';
// import 'package:tasik_siaga/screens/admin/disaster_form_screen.dart'; // Hapus import ini
import 'package:tasik_siaga/screens/admin/manage_disasters_screen.dart';
import 'package:tasik_siaga/screens/admin/verification_list_screen.dart';
import 'package:tasik_siaga/screens/public/map_screen.dart';
import 'package:tasik_siaga/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://lkohdqxauytmwvhnxnnf.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imxrb2hkcXhhdXl0bXd2aG54bm5mIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQxMDA3MTYsImV4cCI6MjA2OTY3NjcxNn0.GS35xyr1zgRA7OE5OrO7SKXUPZ2mcrj-QP9TDXnIWpI',
  );

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
      home: const AuthChecker(),
      routes: {
        '/map': (context) => const MapScreen(),
        '/login': (context) => const AdminLoginScreen(),
        '/dashboard': (context) => const AdminDashboardScreen(),
        '/manage-disasters': (context) => const ManageDisastersScreen(),
        '/verification-list': (context) => const VerificationListScreen(),
        // --- HAPUS RUTE DI BAWAH INI ---
        // '/disaster-form': (context) => const DisasterFormScreen(), 
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
            // Jika sudah login, arahkan ke PETA (bukan dashboard)
            // agar bisa langsung memilih lokasi.
            return const MapScreen();
          },
        );
      },
    );
  }
}