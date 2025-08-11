import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tasik_siaga/models/disaster_model.dart';
import 'package:tasik_siaga/screens/admin/disaster_form_screen.dart';
import 'package:tasik_siaga/services/disaster_service.dart';

class ManageDisastersScreen extends StatefulWidget {
  const ManageDisastersScreen({super.key});

  @override
  State<ManageDisastersScreen> createState() => _ManageDisastersScreenState();
}

class _ManageDisastersScreenState extends State<ManageDisastersScreen> {
  final DisasterService _disasterService = DisasterService();
  late Future<List<Disaster>> _disastersFuture;

  @override
  void initState() {
    super.initState();
    _loadDisasters();
  }

  void _loadDisasters() {
    setState(() {
      _disastersFuture = _disasterService.getDisasters();
    });
  }

  void _navigateToForm([Disaster? disaster]) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DisasterFormScreen(
          disaster: disaster,
          latitude: disaster?.location.latitude ?? 0,
          longitude: disaster?.location.longitude ?? 0,
        ),
      ),
    );

    if (result == true) {
      _loadDisasters();
    }
  }

  Future<void> _deleteDisaster(String id) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus laporan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _disasterService.deleteDisaster(id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Laporan berhasil dihapus'),
              backgroundColor: Colors.green),
        );
        _loadDisasters();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal menghapus laporan: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Data Bencana'),
      ),
      body: FutureBuilder<List<Disaster>>(
        future: _disastersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada data bencana.'));
          }
          final disasters = snapshot.data!;
          return ListView.builder(
            itemCount: disasters.length,
            itemBuilder: (context, index) {
              final disaster = disasters[index];
              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(disaster.type.displayName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '${disaster.district}\n${DateFormat('dd MMM yyyy, HH:mm').format(disaster.dateTime)}',
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _navigateToForm(disaster),
                        tooltip: 'Update',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteDisaster(disaster.id),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}