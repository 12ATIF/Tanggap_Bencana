import 'dart:math';

import 'package:latlong2/latlong.dart';
import 'package:tasik_siaga/models/disaster_model.dart';

class DisasterService {
  // --- DATA SIMULASI (PENGGANTI BACKEND) ---
  static final List<Disaster> _disasters = [
    Disaster(
      id: '1',
      type: DisasterType.banjir,
      location: const LatLng(-7.339, 108.217),
      district: 'Cihideung',
      dateTime: DateTime.now().subtract(const Duration(days: 2)),
      description: 'Banjir setinggi 50 cm di area pemukiman akibat luapan sungai.',
    ),
    Disaster(
      id: '2',
      type: DisasterType.longsor,
      location: const LatLng(-7.351, 108.235),
      district: 'Kawalu',
      dateTime: DateTime.now().subtract(const Duration(hours: 10)),
      description: 'Longsor kecil menutup sebagian jalan desa.',
    ),
    Disaster(
      id: '3',
      type: DisasterType.kebakaran,
      location: const LatLng(-7.320, 108.225),
      district: 'Tawang',
      dateTime: DateTime.now().subtract(const Duration(days: 1)),
      description: 'Kebakaran melanda area pasar, penyebab masih diselidiki.',
    ),
  ];
  // -----------------------------------------

  // Mengambil semua data bencana (simulasi panggilan API)
  Future<List<Disaster>> getDisasters() async {
    // Memberi jeda 1 detik untuk simulasi loading jaringan
    await Future.delayed(const Duration(seconds: 1));
    return _disasters;
  }

  // Mengirim data bencana baru (simulasi panggilan API)
  Future<bool> submitDisaster(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));

    try {
      final newDisaster = Disaster(
        id: Random().nextInt(1000).toString(), // ID acak
        type: data['type'],
        location: data['location'],
        district: data['district'],
        dateTime: data['dateTime'],
        description: data['description'],
      );
      _disasters.add(newDisaster);
      return true; // Berhasil
    } catch (e) {
      print('Error saat submit: $e');
      return false; // Gagal
    }
  }
}