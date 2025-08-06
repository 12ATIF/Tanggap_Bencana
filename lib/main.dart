import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <-- Pastikan provider diimpor
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tasik_siaga/screens/admin/admin_dashboard_screen.dart';
import 'package:tasik_siaga/screens/admin/admin_login_screen.dart';
import 'package:tasik_siaga/screens/admin/manage_disasters_screen.dart';
import 'package:tasik_siaga/screens/admin/verification_list_screen.dart';
import 'package:tasik_siaga/screens/public/map_screen.dart';
import 'package:tasik_siaga/screens/splash_screen.dart'; 
import 'package:tasik_siaga/services/auth_service.dart'; // <-- Pastikan AuthService diimpor

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://lrswmuayxrigdpslwbof.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imxyc3dtdWF5eHJpZ2Rwc2x3Ym9mIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQyNjg1NTksImV4cCI6MjA2OTg0NDU1OX0.jif1Rhyo5LJXW_KMD6ENC7VDWBdOTKwyFDf7Gw7ebMA',
  );

  // Bungkus MyApp dengan Provider di sini
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: const MyApp(),
    ),
  );
}

final supabase = Supabase.instance.client;

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
      // Mulai dari SplashScreen untuk alur yang benar
      home: const SplashScreen(), 
      routes: {
        '/map': (context) => const MapScreen(),
        '/login': (context) => const AdminLoginScreen(),
        '/dashboard': (context) => const AdminDashboardScreen(),
        '/manage-disasters': (context) => const ManageDisastersScreen(),
        '/verification-list': (context) => const VerificationListScreen(),
      },
    );
  }
}