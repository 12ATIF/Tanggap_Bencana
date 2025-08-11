import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:tasik_siaga/models/disaster_model.dart';
import 'package:tasik_siaga/screens/admin/disaster_form_screen.dart';
import 'package:tasik_siaga/services/auth_service.dart';
import 'package:tasik_siaga/services/disaster_service.dart';
import 'package:geocoding/geocoding.dart';

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

  void _showDisasterDetails(BuildContext context, Disaster disaster) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, controller) {
            String fullAddress = 'Memuat alamat...';

            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                Future<void> getAddress() async {
                  try {
                    List<Placemark> placemarks = await placemarkFromCoordinates(
                      disaster.location.latitude,
                      disaster.location.longitude,
                    );
                    if (placemarks.isNotEmpty) {
                      final p = placemarks.first;
                      fullAddress = [
                        p.street,
                        p.subLocality,
                        p.locality,
                        p.subAdministrativeArea
                      ]
                          .where((s) => s != null && s.isNotEmpty)
                          .join(', ');
                    } else {
                      fullAddress = 'Alamat tidak ditemukan.';
                    }
                  } catch (e) {
                    fullAddress = 'Gagal memuat alamat.';
                  }
                  if (mounted) {
                    setModalState(() {});
                  }
                }

                if (fullAddress == 'Memuat alamat...') {
                  getAddress();
                }

                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: ListView(
                    controller: controller,
                    children: [
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(20)),
                        child: disaster.imageUrls.isNotEmpty
                            ? Image.network(
                                disaster.imageUrls.first,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  height: 200,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.location_pin,
                                      size: 80, color: Colors.grey),
                                ),
                              )
                            : Container(
                                height: 200,
                                color: Colors.teal[50],
                                child: Icon(Icons.shield_outlined,
                                    size: 80, color: Colors.teal[200]),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              disaster.type.displayName,
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              disaster.district,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black54),
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            _buildInfoRow(Icons.location_on_outlined, fullAddress),
                            _buildInfoRow(
                              Icons.calendar_today_outlined,
                              '${disaster.dateTime.day}/${disaster.dateTime.month}/${disaster.dateTime.year} - ${disaster.dateTime.hour}:${disaster.dateTime.minute.toString().padLeft(2, '0')}',
                            ),
                            _buildInfoRow(
                                Icons.info_outline, disaster.description),
                            const SizedBox(height: 16),
                            if (disaster.imageUrls.length > 1) ...[
                              const Text(
                                "Dokumentasi Foto",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 100,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: disaster.imageUrls.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        child: Image.network(
                                          disaster.imageUrls[index],
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ]
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.teal, size: 24),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
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
      drawer: authService.isAdminLoggedIn
          ? null
          : Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const DrawerHeader(
                    decoration: BoxDecoration(color: Colors.teal),
                    child: Text('Menu',
                        style: TextStyle(color: Colors.white, fontSize: 24)),
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
                  content:
                      Text('Ketuk lokasi di peta untuk menambahkan laporan.'),
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