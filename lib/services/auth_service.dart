import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Kelas ini akan menangani semua yang berhubungan dengan otentikasi admin
class AuthService with ChangeNotifier {
  bool _isAdminLoggedIn = false;

  bool get isAdminLoggedIn => _isAdminLoggedIn;

  // Fungsi untuk login
  Future<bool> login(String email, String password) async {
    // --- Simulasi Panggilan API ---
    // Di sini Anda akan memanggil API Anda untuk verifikasi login
    // Contoh: final response = await http.post(Uri.parse('YOUR_API/admin/login'), ...);
    await Future.delayed(const Duration(seconds: 1)); // Menunggu 1 detik

    if (email == 'admin@tasiksiaga.com' && password == 'password123') {
      final prefs = await SharedPreferences.getInstance();
      // Simpan token atau penanda login
      await prefs.setString('admin_token', 'dummy_token_12345');
      _isAdminLoggedIn = true;
      notifyListeners(); // Memberi tahu widget yang mendengarkan bahwa ada perubahan
      return true;
    }
    return false;
  }

  // Fungsi untuk mengecek apakah sudah login
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    // Cek apakah token ada
    final token = prefs.getString('admin_token');
    if (token != null) {
      _isAdminLoggedIn = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  // Fungsi untuk logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    // Hapus token
    await prefs.remove('admin_token');
    _isAdminLoggedIn = false;
    notifyListeners();
  }
}
