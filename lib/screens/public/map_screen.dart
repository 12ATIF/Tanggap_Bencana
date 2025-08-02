import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:tasik_siaga/models/disaster_model.dart';
import 'package:tasik_siaga/screens/admin/disaster_form_screen.dart'; // Import form screen
import 'package:tasik_siaga/services/auth_service.dart'; // Import auth service
import 'package:tasik_siaga/services/disaster_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LatLng _center = const LatLng(-7.3278, 108.2203);
  final DisasterService _disasterService = DisasterService();
  final MapController _mapController = MapController();
  
  late Future<List<Disaster>> _disastersFuture;

  @override
  void initState() {
    super.initState();
    _fetchDisasters();
  }

  void _fetchDisasters() {
    setState(() {
      _disastersFuture = _disasterService.getDisasters();
    });
  }

  // Fungsi untuk navigasi ke form dan menangani hasilnya
  void _navigateToForm(LatLng tappedPoint) async {
    // Navigasi ke form dan tunggu hasilnya
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DisasterFormScreen(selectedPoint: tappedPoint),
      ),
    );

    // Jika hasilnya 'true' (artinya form berhasil disubmit), perbarui data di peta
    if (result == true) {
      _fetchDisasters();
    }
  }

  void _showDisasterDetails(BuildContext context, Disaster disaster) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                disaster.type.displayName, // Menggunakan getter yang baru dibuat
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: disaster.type.color, // Menggunakan getter yang baru dibuat
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_city, size: 16, color: Colors.black54),
                  const SizedBox(width: 4),
                  Text(
                    disaster.district,
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.black54),
                  const SizedBox(width: 4),
                  Text(
                    '${disaster.dateTime.day}/${disaster.dateTime.month}/${disaster.dateTime.year} - ${disaster.dateTime.hour}:${disaster.dateTime.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                disaster.description,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Menggunakan `Consumer` untuk mendapatkan status login
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasik Siaga: Peta Bencana'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchDisasters,
            tooltip: 'Perbarui Data',
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login Petugas'),
              onTap: () {
                Navigator.pop(context); // Tutup drawer
                Navigator.pushNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Disaster>>(
        future: _disastersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Tetap tampilkan peta kosong jika tidak ada data
          }
          
          List<Marker> markers = (snapshot.data ?? []).map((disaster) {
            return Marker(
              width: 40.0,
              height: 40.0,
              point: disaster.location,
              child: GestureDetector(
                onTap: () => _showDisasterDetails(context, disaster),
                child: Tooltip(
                  message: disaster.type.displayName,
                  child: Icon(
                    Icons.location_on,
                    color: disaster.type.color,
                    size: 40.0,
                  ),
                ),
              ),
            );
          }).toList();

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 12.0,
              // Menambahkan fungsi onTap
              onTap: (tapPosition, point) {
                // Cek apakah admin sudah login
                if (authService.isAdminLoggedIn) {
                  // Jika ya, navigasi ke form
                  _navigateToForm(point);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.tasik_siaga',
              ),
              MarkerLayer(markers: markers),
            ],
          );
        },
      ),
      // Menambahkan floating action button untuk info jika admin login
      floatingActionButton: authService.isAdminLoggedIn
          ? FloatingActionButton.extended(
              onPressed: () {},
              icon: const Icon(Icons.touch_app),
              label: const Text('Ketuk Peta untuk Lapor'),
              backgroundColor: Colors.teal,
            )
          : null,
    );
  }
}