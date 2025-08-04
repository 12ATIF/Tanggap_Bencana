import 'dart:io';
import 'package:tasik_siaga/main.dart'; // untuk mengakses `supabase`
import 'package:tasik_siaga/models/disaster_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DisasterService {
  Future<List<Disaster>> getDisasters() async {
    try {
      // Menggunakan variabel 'supabase' (huruf kecil)
      final response = await supabase.from('disasters').select();
      final disasters = (response as List)
          .map((data) => Disaster.fromMap(data))
          .toList();
      return disasters;
    } on PostgrestException catch (error) {
      print('Error fetching data: ${error.message}');
      throw Exception('Gagal mengambil data bencana: ${error.message}');
    } catch (e) {
      print('An unexpected error occurred: $e');
      throw Exception('Terjadi kesalahan yang tidak terduga.');
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

        // Menggunakan variabel 'supabase' (huruf kecil)
        await supabase.storage.from('disasterimages').upload(
              filePath,
              imageFile,
              fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
            );
        
        // Menggunakan variabel 'supabase' (huruf kecil)
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
      
      // Menggunakan variabel 'supabase' (huruf kecil)
      await supabase.from('disasters').insert(dataToInsert);

    } on PostgrestException catch (error) {
      print('Error inserting data: ${error.message}');
      throw Exception('Gagal menyimpan laporan: ${error.message}');
    } catch (e) {
      print('An unexpected error occurred: $e');
      throw Exception('Terjadi kesalahan yang tidak terduga.');
    }
  }
}