import 'dart:io';
import 'package:tasik_siaga/main.dart'; // untuk mengakses `supabase`
import 'package:tasik_siaga/models/disaster_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DisasterService {
  Future<void> addDisaster({
    required String type,
    required double latitude,
    required double longitude,
    required String district,
    required DateTime dateTime,
    required String description,
    File? imageFile, // Terima file gambar yang bisa null
  }) async {
    try {
      String? imageUrl; // Variabel untuk menyimpan URL gambar

      // 1. Proses Unggah Gambar (jika ada)
      if (imageFile != null) {
        // Buat nama file yang unik berdasarkan waktu saat ini.
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.${imageFile.path.split('.').last}';
        final filePath = 'public/$fileName'; // Path di dalam bucket

        // Unggah file ke bucket 'disaster_images'
        await supabase.storage.from('disasterimages').upload(
              filePath,
              imageFile,
              fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
            );

        // 2. Ambil URL publik dari gambar yang baru diunggah
        imageUrl = supabase.storage.from('disasterimages').getPublicUrl(filePath);
      }

      // 3. Siapkan data untuk dimasukkan ke tabel
      final dataToInsert = {
        'type': type,
        'latitude': latitude,
        'longitude': longitude,
        'district': district,
        'date_time': dateTime.toIso8601String(),
        'description': description,
        'image_url': imageUrl, // Masukkan URL gambar (bisa null jika tidak ada gambar)
      };

      // 4. Masukkan data ke tabel 'disasters'
      await supabase.from('disasters').insert(dataToInsert);

    } on PostgrestException catch (error) {
      // Tangani error spesifik dari Supabase/PostgreSQL
      print('Error inserting data: ${error.message}');
      throw Exception('Gagal menyimpan laporan: ${error.message}');
    } catch (e) {
      // Tangani error umum lainnya
      print('An unexpected error occurred: $e');
      throw Exception('Terjadi kesalahan yang tidak terduga.');
    }
  }
}