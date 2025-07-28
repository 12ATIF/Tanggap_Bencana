import 'package:cloud_firestore/cloud_firestore.dart';
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

  // FUNGSI BARU: Mengubah data dari dokumen Firestore menjadi objek Disaster
  factory Disaster.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    GeoPoint point = data['location'] as GeoPoint;
    Timestamp timestamp = data['dateTime'] as Timestamp;

    return Disaster(
      id: doc.id,
      type: DisasterType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => DisasterType.banjir, // Default value
      ),
      location: LatLng(point.latitude, point.longitude),
      district: data['district'] ?? '',
      dateTime: timestamp.toDate(),
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'],
    );
  }

  // FUNGSI BARU: Mengubah objek Disaster menjadi format Map untuk disimpan ke Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'type': type.name,
      'location': GeoPoint(location.latitude, location.longitude),
      'district': district,
      'dateTime': Timestamp.fromDate(dateTime),
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}