import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasik_siaga/services/auth_service.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await authService.logout();
              // Kembali ke peta publik setelah logout
              Navigator.of(context).pushNamedAndRemoveUntil('/map', (route) => false);
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildDashboardItem(
            context,
            icon: Icons.data_usage,
            label: 'Kelola Data Bencana',
            onTap: () {
              // Navigasi ke halaman kelola data
            },
          ),
          _buildDashboardItem(
            context,
            icon: Icons.verified_user,
            label: 'Verifikasi Laporan',
            onTap: () {
              // Navigasi ke halaman verifikasi
            },
          ),
          _buildDashboardItem(
            context,
            icon: Icons.add_circle,
            label: 'Tambah Data Baru',
            onTap: () {
              // Navigasi ke halaman form tambah data
            },
          ),
          _buildDashboardItem(
            context,
            icon: Icons.bar_chart,
            label: 'Statistik',
            onTap: () {
              // Navigasi ke halaman statistik
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardItem(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.teal),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
