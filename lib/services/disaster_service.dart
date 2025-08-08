import 'dart:io';
import 'package:tasik_siaga/main.dart';
import 'package:tasik_siaga/models/disaster_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DisasterService {
  Future<List<Disaster>> getDisasters() async {
    try {
      final response = await supabase.from('disasters').select();
      final disasters = response.map((data) => Disaster.fromMap(data)).toList();
      return disasters;
    } catch (e) {
      print('Error fetching disasters: $e');
      throw Exception('Gagal memuat data bencana.');
    }
  }

  Future<void> addDisaster({
    required String type,
    required double latitude,
    required double longitude,
    required String district,
    required DateTime dateTime,
    required String description,
    // --- PERUBAHAN UTAMA DI SINI ---
    // Terima List<File>, bukan lagi satu File
    List<File>? imageFiles,
  }) async {
    try {
      List<String> imageUrls = [];

      // Lakukan perulangan untuk mengunggah setiap file jika ada
      if (imageFiles != null && imageFiles.isNotEmpty) {
        for (var file in imageFiles) {
          final fileName = '${DateTime.now().millisecondsSinceEpoch}-${file.path.split('/').last}';
          final filePath = 'public/$fileName';

          await supabase.storage.from('disasterimages').upload(
                filePath,
                file,
                fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
              );
              
          final imageUrl = supabase.storage.from('disasterimages').getPublicUrl(filePath);
          imageUrls.add(imageUrl);
        }
      }

      final dataToInsert = {
        'type': type,
        'latitude': latitude,
        'longitude': longitude,
        'district': district,
        'date_time': dateTime.toIso8601String(),
        'description': description,
        // Kirim list URL ke Supabase (nama kolom harus sama dengan di database: 'image_urls')
        'image_urls': imageUrls,
      };
      
      await supabase.from('disasters').insert(dataToInsert);

    } catch (e) {
      print('Error adding disaster: $e');
      throw Exception('Gagal menambahkan laporan.');
    }
  }
}
