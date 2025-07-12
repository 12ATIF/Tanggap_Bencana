import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LatLng _center = const LatLng(-7.3278, 108.2203);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasik Siaga: Peta Bencana'),
        // Menu tiga titik akan otomatis muncul jika ada Drawer
      ),
      // PERBAIKAN: Menambahkan Drawer untuk menu
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.teal,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Legenda Peta'),
              onTap: () {
                Navigator.pop(context); // Tutup drawer
                // TODO: Tampilkan dialog legenda
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Tentang Aplikasi'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Tampilkan halaman tentang
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login Petugas'),
              onTap: () {
                Navigator.pop(context); // Tutup drawer sebelum navigasi
                Navigator.pushNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _center,
          initialZoom: 12.0,
        ),
        children: [
          // PERBAIKAN: Menambahkan errorBuilder untuk menangani masalah koneksi
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.tasik_siaga',
            errorImage: const NetworkImage('https://placehold.co/256x256/f0f0f0/ff0000?text=Peta+Gagal+Dimuat'),
            errorTileCallback: (tile, error, stackTrace) {
              // PERBAIKAN: Menggunakan tile.coordinates sebagai pengganti tile.coords
              debugPrint('Error memuat tile ${tile.coordinates}: $error');
            },
          ),
          // Tambahkan layer lain seperti PolygonLayer dan MarkerLayer di sini
        ],
      ),
      // PERBAIKAN: Menambahkan FloatingActionButton untuk lapor bencana
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/report');
        },
        tooltip: 'Lapor Bencana',
        child: const Icon(Icons.add),
      ),
    );
  }
}
