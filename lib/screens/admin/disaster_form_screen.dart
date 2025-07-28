import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:tasik_siaga/models/disaster_model.dart';
import 'package:tasik_siaga/services/disaster_service.dart';

class DisasterFormScreen extends StatefulWidget {
  const DisasterFormScreen({super.key});

  @override
  State<DisasterFormScreen> createState() => _DisasterFormScreenState();
}

class _DisasterFormScreenState extends State<DisasterFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mapController = MapController();
  final _descriptionController = TextEditingController();
  final _disasterService = DisasterService();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  DisasterType? _selectedDisasterType;
  String? _selectedDistrict;
  LatLng? _selectedPoint;
  final List<File> _images = [];
  bool _isLoading = false;

  final List<String> _districts = [
    'Bungursari', 'Cibeureum', 'Cihideung', 'Cipedes', 'Indihiang',
    'Kawalu', 'Mangkubumi', 'Purbaratu', 'Tamansari', 'Tawang'
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }
  
  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _selectedPoint = point;
    });
    _mapController.move(point, _mapController.camera.zoom);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPoint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih titik koordinat pada peta.')),
      );
      return;
    }

    setState(() { _isLoading = true; });

    final dateTime = DateTime(
      _selectedDate.year, _selectedDate.month, _selectedDate.day,
      _selectedTime.hour, _selectedTime.minute
    );

    // Buat objek Disaster dari data form
    final newDisaster = Disaster(
      id: '', // ID akan dibuat otomatis oleh Firestore
      type: _selectedDisasterType!,
      location: _selectedPoint!,
      district: _selectedDistrict!,
      dateTime: dateTime,
      description: _descriptionController.text,
      // imageUrl: null, // Logic untuk upload gambar butuh Firebase Storage
    );
    
    // Kirim objek ke service
    bool success = await _disasterService.submitDisaster(newDisaster);

    setState(() { _isLoading = false; });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data bencana berhasil disimpan online.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); 
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyimpan data. Coba lagi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI LENGKAP DARI SEBELUMNYA, TIDAK ADA PERUBAHAN TAMPILAN
    // ... (kode UI dari jawaban sebelumnya bisa langsung disalin ke sini)
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulir Data Bencana'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: CircularProgressIndicator(color: Colors.white),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _submitForm,
              tooltip: 'Simpan Data',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ... (Kode widget form lengkap dari jawaban sebelumnya)
                // Tanggal & Waktu
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Tanggal', border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(DateFormat('dd MMMM yyyy').format(_selectedDate)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectTime(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Waktu', border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.access_time),
                          ),
                          child: Text(_selectedTime.format(context)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Jenis Bencana
                DropdownButtonFormField<DisasterType>(
                  value: _selectedDisasterType,
                  decoration: const InputDecoration(labelText: 'Jenis Bencana', border: OutlineInputBorder()),
                  items: DisasterType.values.map((type) => DropdownMenuItem(value: type, child: Text(type.displayName))).toList(),
                  onChanged: (value) => setState(() => _selectedDisasterType = value),
                  validator: (value) => value == null ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                // Kecamatan
                DropdownButtonFormField<String>(
                  value: _selectedDistrict,
                  decoration: const InputDecoration(labelText: 'Kecamatan', border: OutlineInputBorder()),
                  items: _districts.map((district) => DropdownMenuItem(value: district, child: Text(district))).toList(),
                  onChanged: (value) => setState(() => _selectedDistrict = value),
                  validator: (value) => value == null ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                // Deskripsi
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Deskripsi', border: OutlineInputBorder()),
                  maxLines: 4,
                  validator: (value) => (value == null || value.isEmpty) ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 24),
                // Peta
                const Text("Pilih Lokasi di Peta", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 300,
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: const LatLng(-7.3278, 108.2203),
                      initialZoom: 12.0,
                      onTap: _onMapTap,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.tasik_siaga',
                      ),
                      if (_selectedPoint != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _selectedPoint!,
                              child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}