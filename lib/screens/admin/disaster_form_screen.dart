import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

class DisasterFormScreen extends StatefulWidget {
  const DisasterFormScreen({super.key});

  @override
  State<DisasterFormScreen> createState() => _DisasterFormScreenState();
}

class _DisasterFormScreenState extends State<DisasterFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // State untuk data form
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedDisasterType;
  String? _selectedDistrict;
  LatLng? _selectedPoint;
  final List<XFile> _images = [];

  // Controller untuk menampilkan koordinat
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lonController = TextEditingController();

  // Data dummy untuk dropdown
  final List<String> _disasterTypes = ['Banjir', 'Tanah Longsor', 'Kebakaran', 'Angin Kencang', 'Kekeringan'];
  final List<String> _districts = ['Cihideung', 'Kawalu', 'Tamansari', 'Tawang', 'Bungursari', 'Indihiang', 'Mangkubumi', 'Cipedes', 'Purbaratu', 'Bebedahan'];

  @override
  void dispose() {
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  // --- FUNGSI UNTUK INPUT DATA ---

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
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
      initialTime: _selectedTime ?? TimeOfDay.now(),
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
      _latController.text = point.latitude.toStringAsFixed(6);
      _lonController.text = point.longitude.toStringAsFixed(6);
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _images.add(image);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Data Bencana'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Simpan',
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                if (_selectedPoint == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Silakan pilih titik koordinat pada peta.')),
                  );
                  return;
                }
                // TODO: Tambahkan logika untuk menyimpan data ke API
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data berhasil divalidasi. Proses simpan...')),
                );
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ... (Input Tanggal, Waktu, Jenis Bencana, Kecamatan tetap sama)
              // ... (Salin dari kode sebelumnya jika perlu)
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Kejadian',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(_selectedDate == null ? 'Pilih Tanggal' : "${_selectedDate!.toLocal()}".split(' ')[0]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Waktu Kejadian',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(_selectedTime == null ? 'Pilih Waktu' : _selectedTime!.format(context)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedDisasterType,
                decoration: const InputDecoration(labelText: 'Jenis Bencana', border: OutlineInputBorder(), prefixIcon: Icon(Icons.warning)),
                items: _disasterTypes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => _selectedDisasterType = val),
                validator: (v) => v == null ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedDistrict,
                decoration: const InputDecoration(labelText: 'Kecamatan', border: OutlineInputBorder(), prefixIcon: Icon(Icons.map)),
                items: _districts.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => _selectedDistrict = val),
                validator: (v) => v == null ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Deskripsi', border: OutlineInputBorder(), alignLabelWithHint: true),
                maxLines: 4,
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 24),

              // --- INPUT TITIK KOORDINAT FUNGSIONAL ---
              const Text('Pilih Titik Koordinat Pada Peta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: _selectedPoint ?? const LatLng(-7.3278, 108.2203),
                    initialZoom: 13.0,
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
                            width: 80,
                            height: 80,
                            child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _latController, decoration: const InputDecoration(labelText: 'Latitude', border: OutlineInputBorder()), readOnly: true)),
                  const SizedBox(width: 16),
                  Expanded(child: TextFormField(controller: _lonController, decoration: const InputDecoration(labelText: 'Longitude', border: OutlineInputBorder()), readOnly: true)),
                ],
              ),
              const SizedBox(height: 24),

              // --- UPLOAD DOKUMENTASI FUNGSIONAL ---
              const Text('Dokumentasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    if (_images.isNotEmpty)
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _images.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Image.file(File(_images[index].path), width: 100, height: 100, fit: BoxFit.cover),
                            );
                          },
                        ),
                      ),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.add_a_photo),
                        label: const Text('Tambah Foto'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
