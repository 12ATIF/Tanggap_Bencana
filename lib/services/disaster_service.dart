// lib/services/disaster_service.dart

import 'dart:io';
import 'package:tasik_siaga/main.dart';
import 'package:tasik_siaga/models/disaster_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DisasterService {
  Future<List<Disaster>> getDisasters() async {
    try {
      // Hapus <...> dari .select() untuk versi Supabase terbaru
      final response = await supabase.from('disasters').select();
      
      final disasters = response.map((data) => Disaster.fromMap(data)).toList();
      return disasters;
    } catch (e) {
      // Menangkap error untuk debugging jika terjadi masalah
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
    File? imageFile,
  }) async {
    try {
      String? imageUrl;
      if (imageFile != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.${imageFile.path.split('.').last}';
        final filePath = 'public/$fileName';

        await supabase.storage.from('disasterimages').upload(
              filePath,
              imageFile,
              fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
            );
            
        imageUrl = supabase.storage.from('disasterimages').getPublicUrl(filePath);
      }

      final dataToInsert = {
        'type': type,
        'latitude': latitude,
        'longitude': longitude,
        'district': district,
        'date_time': dateTime.toIso8601String(),
        'description': description,
        'image_url': imageUrl,
      };
      
      await supabase.from('disasters').insert(dataToInsert);

    } catch (e) {
      print('Error adding disaster: $e');
      throw Exception('Gagal menambahkan laporan.');
    }
  }
}