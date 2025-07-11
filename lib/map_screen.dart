import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LatLng _center = LatLng(-7.3278, 108.2203);
  DistrictInfo? _selectedDistrictInfo;
  List<Polygon> _polygons = [];
  List<Marker> _markers = [];

  final Map<String, DistrictInfo> _disasterData = {
    'cihideung': DistrictInfo(
      name: 'Kecamatan Cihideung',
      disasters: [
        'Banjir - 15 Maret 2023: Meluapnya sungai Cihideung merendam 50 rumah.',
        'Kebakaran - 02 Juni 2023: Kebakaran melanda area pasar, 10 kios hangus.',
      ],
      markerPoint: LatLng(-7.325, 108.225),
    ),
    'kawalu': DistrictInfo(
      name: 'Kecamatan Kawalu',
      disasters: [
        'Tanah Longsor - 11 Januari 2024: Longsor di tebing jalan utama, lalu lintas terputus.',
        'Angin Kencang - 20 Februari 2024: Puluhan atap rumah warga rusak.',
      ],
      markerPoint: LatLng(-7.355, 108.215),
    ),
    'tamansari': DistrictInfo(
      name: 'Kecamatan Tamansari',
      disasters: [
        'Kekeringan - 05 September 2023: Sumber air warga mengering selama 2 bulan.',
      ],
      markerPoint: LatLng(-7.385, 108.255),
    ),
  };

  @override
  void initState() {
    super.initState();
    _buildMapLayers();
  }

  void _buildMapLayers() {
    final List<Polygon> polygons = [];
    final List<Marker> markers = [];

    final List<LatLng> cihideungCoords = [
      LatLng(-7.32, 108.21), LatLng(-7.31, 108.23),
      LatLng(-7.33, 108.24), LatLng(-7.34, 108.22),
    ];
    final List<LatLng> kawaluCoords = [
      LatLng(-7.35, 108.20), LatLng(-7.34, 108.22),
      LatLng(-7.36, 108.23), LatLng(-7.37, 108.21),
    ];
    final List<LatLng> tamansariCoords = [
      LatLng(-7.38, 108.24), LatLng(-7.37, 108.26),
      LatLng(-7.39, 108.27), LatLng(-7.40, 108.25),
    ];

    polygons.add(_createPolygon(cihideungCoords, Colors.blue));
    polygons.add(_createPolygon(kawaluCoords, Colors.green));
    polygons.add(_createPolygon(tamansariCoords, Colors.red));
    
    _disasterData.forEach((key, value) {
      markers.add(_createMarker(key, value.markerPoint));
    });

    setState(() {
      _polygons = polygons;
      _markers = markers;
    });
  }
  
  Polygon _createPolygon(List<LatLng> points, Color color) {
    return Polygon(
      points: points,
      color: color.withOpacity(0.3),
      borderColor: color,
      borderStrokeWidth: 2,
    );
  }

  Marker _createMarker(String districtId, LatLng point) {
    return Marker(
      width: 80.0,
      height: 80.0,
      point: point,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedDistrictInfo = _disasterData[districtId];
          });
        },
        child: const Icon(
          Icons.location_pin,
          color: Colors.redAccent,
          size: 40.0,
        ),
      ),
    );
  }

  void _closeInfoPanel() {
    setState(() {
      _selectedDistrictInfo = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Bencana (OpenStreetMap)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 12.0,
              onTap: (_, __) => _closeInfoPanel(), // Tutup panel jika peta di tap
            ),
            children: [
              // Layer untuk menampilkan peta dasar dari OpenStreetMap
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app', // Ganti dengan nama package Anda
              ),
              // Layer untuk menampilkan poligon kecamatan
              PolygonLayer(polygons: _polygons),
              // Layer untuk menampilkan marker yang bisa di-tap
              MarkerLayer(markers: _markers),
            ],
          ),
          if (_selectedDistrictInfo != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: DisasterInfoPanel(
                districtInfo: _selectedDistrictInfo!,
                onClose: _closeInfoPanel,
              ),
            ),
        ],
      ),
    );
  }
}

// Model data untuk informasi kecamatan
class DistrictInfo {
  final String name;
  final List<String> disasters;
  final LatLng markerPoint; // Tambahkan titik untuk marker

  DistrictInfo({
    required this.name,
    required this.disasters,
    required this.markerPoint,
  });
}

// Widget untuk menampilkan panel informasi di bawah
// (Tidak ada perubahan pada file ini)
class DisasterInfoPanel extends StatelessWidget {
  final DistrictInfo districtInfo;
  final VoidCallback onClose;

  const DisasterInfoPanel({
    super.key,
    required this.districtInfo,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  districtInfo.name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Riwayat Bencana Tercatat:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: districtInfo.disasters.isEmpty
                  ? const Center(child: Text('Tidak ada data bencana tercatat.'))
                  : ListView.builder(
                      itemCount: districtInfo.disasters.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: Colors.teal.shade50,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                            title: Text(districtInfo.disasters[index]),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}