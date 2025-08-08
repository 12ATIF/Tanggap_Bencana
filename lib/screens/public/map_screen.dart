import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:tasik_siaga/models/disaster_model.dart';
import 'package:tasik_siaga/screens/admin/disaster_form_screen.dart';
import 'package:tasik_siaga/services/auth_service.dart';
import 'package:tasik_siaga/services/disaster_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LatLng _center = const LatLng(-7.330, 108.222);
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

  void _navigateToForm(LatLng tappedPoint) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DisasterFormScreen(
          latitude: tappedPoint.latitude,
          longitude: tappedPoint.longitude,
        ),
      ),
    );

    if (result == true) {
      _fetchDisasters();
    }
  }

  // --- PERUBAHAN UTAMA DI FUNGSI INI ---
  void _showDisasterDetails(BuildContext context, Disaster disaster) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Agar bottom sheet bisa lebih tinggi
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
              // Bagian informasi teks (tidak berubah)
              Text(
                disaster.type.displayName,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: disaster.type.color),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_city, size: 16, color: Colors.black54),
                  const SizedBox(width: 4),
                  Text(disaster.district, style: const TextStyle(fontSize: 16, color: Colors.black54)),
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
              Text(disaster.description, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),

              // --- BAGIAN BARU UNTUK MENAMPILKAN GAMBAR ---
              if (disaster.imageUrls.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Dokumentasi Foto:",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100, // Tentukan tinggi area gambar
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: disaster.imageUrls.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                disaster.imageUrls[index],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                // Tampilkan loading indicator saat gambar dimuat
                                loadingBuilder: (context, child, progress) {
                                  return progress == null ? child : const Center(child: CircularProgressIndicator());
                                },
                                // Tampilkan ikon error jika gambar gagal dimuat
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Bencana Tasikmalaya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchDisasters,
            tooltip: 'Perbarui Data',
          ),
          if (authService.isAdminLoggedIn)
            IconButton(
              icon: const Icon(Icons.dashboard),
              tooltip: 'Dashboard',
              onPressed: () => Navigator.of(context).pushNamed('/dashboard'),
            ),
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
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/login');
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
          final disasters = snapshot.data ?? [];
          final markers = disasters.map((disaster) {
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
              onTap: (tapPosition, point) {
                if (authService.isAdminLoggedIn) {
                  _navigateToForm(point);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              MarkerLayer(markers: markers),
            ],
          );
        },
      ),
      floatingActionButton: authService.isAdminLoggedIn
          ? FloatingActionButton.extended(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Ketuk lokasi di peta untuk menambahkan laporan.'),
                ));
              },
              icon: const Icon(Icons.add_location_alt_outlined),
              label: const Text('Tambah Laporan'),
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }
}
