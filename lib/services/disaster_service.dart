import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tasik_siaga/models/disaster_model.dart';

class DisasterService {
  final _supabase = Supabase.instance.client;

  /// Mengambil semua data bencana DARI SUPABASE.
  Future<List<Disaster>> getDisasters() async {
    try {
      final response = await _supabase.from('disasters').select().order('date_time', ascending: false);
      // Konversi list of maps ke list of disasters
      return response.map((item) => Disaster.fromMap(item)).toList();
    } catch (e) {
      print('Error mengambil data dari Supabase: $e');
      return []; // Kembalikan list kosong jika terjadi error
    }
  }

  /// ---- FUNGSI BARU UNTUK UPLOAD GAMBAR ----
  Future<String?> uploadImage(File imageFile) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.${imageFile.path.split('.').last}';
      
      // Upload file ke bucket 'disaster_images'
      await _supabase.storage.from('disaster_images').upload(
        fileName,
        imageFile,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      // Ambil URL publik dari file yang baru diupload
      final publicUrl = _supabase.storage.from('disaster_images').getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      print('Error mengupload gambar: $e');
      return null;
    }
  }

  /// Mengirim data bencana baru KE SUPABASE.
  Future<bool> submitDisaster(Disaster newDisaster) async {
    try {
      // Konversi objek Disaster ke Map sebelum dikirim
      await _supabase.from('disasters').insert(newDisaster.toMap());
      print('Data baru berhasil ditambahkan ke Supabase');
      return true;
    } catch (e) {
      print('Terjadi kesalahan saat menyimpan data ke Supabase: $e');
      return false; // Mengembalikan false jika gagal
    }
  }
}