import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:tasik_siaga/models/disaster_model.dart';
import 'package:tasik_siaga/screens/admin/admin_dashboard_screen.dart';
import 'package:tasik_siaga/screens/admin/admin_login_screen.dart';
import 'package:tasik_siaga/screens/admin/disaster_form_screen.dart'; // Import form screen
import 'package:tasik_siaga/services/auth_service.dart'; // Import auth service
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
                disaster.type.displayName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_city,
                      size: 16, color: Colors.black54),
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
                  const Icon(Icons.calendar_today,
                      size: 16, color: Colors.black54),
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
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Bencana'),
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AdminDashboardScreen()),
                );
              },
            ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login Petugas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AdminLoginScreen()),
                );
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

          List<Marker> markers = (snapshot.data ?? []).map((disaster) {
            return Marker(
              width: 40.0,
              height: 40.0,
              point: LatLng(disaster.location.latitude, disaster.location.longitude),
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
              onPressed: () {},
              icon: const Icon(Icons.touch_app),
              label: const Text('Ketuk Peta untuk Lapor'),
              backgroundColor: Colors.blue,
            )
          : null,
    );
  }
}