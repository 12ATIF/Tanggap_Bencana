import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

enum DisasterType {
  banjir('Banjir', Colors.blue),
  longsor('Tanah Longsor', Colors.brown),
  gempa('Gempa Bumi', Colors.orange),
  kebakaran('Kebakaran Hutan', Colors.red),
  putingBeliung('Puting Beliung', Colors.grey);

  const DisasterType(this.displayName, this.color);
  final String displayName;
  final Color color;
}

class Disaster {
  final String id;
  final DisasterType type;
  final LatLng location;
  final String district;
  final DateTime dateTime;
  final String description;
  final String? imageUrl;

  Disaster({
    required this.id,
    required this.type,
    required this.location,
    required this.district,
    required this.dateTime,
    required this.description,
    this.imageUrl,
  });

  // Diubah dari fromFirestore menjadi fromMap
  factory Disaster.fromMap(Map<String, dynamic> data) {
    return Disaster(
      id: data['id'] as String,
      type: DisasterType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => DisasterType.banjir,
      ),
      location: LatLng(data['latitude'] as double, data['longitude'] as double),
      district: data['district'] ?? '',
      dateTime: DateTime.parse(data['date_time'] as String),
      description: data['description'] ?? '',
      imageUrl: data['image_url'],
    );
  }

  // Diubah dari toFirestore menjadi toMap
  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'district': district,
      'date_time': dateTime.toIso8601String(),
      'description': description,
      'image_url': imageUrl,
    };
  }
}