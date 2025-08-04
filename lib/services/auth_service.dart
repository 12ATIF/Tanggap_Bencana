import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tasik_siaga/main.dart';

final supabase = Supabase.instance.client;

class AuthService with ChangeNotifier {
  bool _isAdminLoggedIn = supabase.auth.currentSession != null;

  bool get isAdminLoggedIn => _isAdminLoggedIn;

  // Fungsi untuk login
  Future<bool> login(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        _isAdminLoggedIn = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      // Tangani error, misalnya kredensial salah
      print('Error login: $e');
      return false;
    }
  }

  // Fungsi untuk mengecek apakah sudah login
  Future<bool> isLoggedIn() async {
    // Sesi sudah ditangani oleh Supabase secara otomatis
    _isAdminLoggedIn = supabase.auth.currentSession != null;
    notifyListeners();
    return _isAdminLoggedIn;
  }

  // Fungsi untuk logout
  Future<void> logout() async {
    await supabase.auth.signOut();
    _isAdminLoggedIn = false;
    notifyListeners();
  }
}