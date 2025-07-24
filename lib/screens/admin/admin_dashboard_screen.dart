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
              Navigator.pushNamed(context, '/manage-disasters');
            },
          ),
          _buildDashboardItem(
            context,
            icon: Icons.verified_user,
            label: 'Verifikasi Laporan',
            onTap: () {
              Navigator.pushNamed(context, '/verification-list');
            },
          ),
          _buildDashboardItem(
            context,
            icon: Icons.add_circle,
            label: 'Tambah Data Baru',
            onTap: () {
              // INI BAGIAN YANG SEHARUSNYA BERFUNGSI
              Navigator.pushNamed(context, '/disaster-form');
            },
          ),
          _buildDashboardItem(
            context,
            icon: Icons.bar_chart,
            label: 'Statistik',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Halaman Statistik belum tersedia.')),
              );
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
