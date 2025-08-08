import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tasik_siaga/models/disaster_model.dart';
import 'package:tasik_siaga/services/disaster_service.dart';
import 'package:geocoding/geocoding.dart';

class DisasterFormScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const DisasterFormScreen({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<DisasterFormScreen> createState() => _DisasterFormScreenState();
}

class _DisasterFormScreenState extends State<DisasterFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _disasterService = DisasterService();
  final _picker = ImagePicker();

  DisasterType? _selectedType;
  final _districtController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  List<File> _imageFiles = [];
  bool _isLoading = false;
  bool _isGeocoding = true;

  @override
  void initState() {
    super.initState();
    _getAddressFromCoordinates();
  }

  Future<void> _getAddressFromCoordinates() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        widget.latitude,
        widget.longitude,
      );
      if (mounted && placemarks.isNotEmpty) {
        final p = placemarks.first;
        final district = p.subLocality ?? p.locality ?? 'Lokasi tidak dikenal';
        final fullAddress = "${p.street ?? ''}, ${p.subLocality ?? ''}, ${p.locality ?? ''}";
        setState(() {
          _districtController.text = district;
          _descriptionController.text = "Telah terjadi bencana di sekitar area $fullAddress.";
        });
      }
    } catch (e) {
      print("Error saat mencari alamat: $e");
      if (mounted) {
        setState(() {
          _districtController.text = "Gagal mendapatkan nama lokasi";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeocoding = false;
        });
      }
    }
  }

  Future<void> _pickMultiImage() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _imageFiles = pickedFiles.map((xfile) => File(xfile.path)).toList();
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; });
    try {
      await _disasterService.addDisaster(
        type: _selectedType!.name,
        latitude: widget.latitude,
        longitude: widget.longitude,
        district: _districtController.text,
        description: _descriptionController.text,
        dateTime: DateTime.now(),
        imageFiles: _imageFiles, // Sekarang parameter ini sudah dikenali
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Laporan berhasil ditambahkan!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan laporan: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) { setState(() { _isLoading = false; }); }
    }
  }
  
  @override
  void dispose() {
    _districtController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Laporan Bencana')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Lokasi: ${widget.latitude.toStringAsFixed(5)}, ${widget.longitude.toStringAsFixed(5)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<DisasterType>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Jenis Bencana', border: OutlineInputBorder()),
                items: DisasterType.values.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type.displayName));
                }).toList(),
                onChanged: (value) => setState(() => _selectedType = value),
                validator: (value) => value == null ? 'Jenis bencana harus dipilih' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _districtController,
                decoration: InputDecoration(
                  labelText: 'Kecamatan',
                  border: const OutlineInputBorder(),
                  suffixIcon: _isGeocoding ? const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.0)),
                  ) : null,
                ),
                readOnly: _isGeocoding,
                validator: (value) => value == null || value.isEmpty ? 'Kecamatan harus diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Deskripsi Kejadian', border: OutlineInputBorder()),
                maxLines: 4,
                validator: (value) => value == null || value.isEmpty ? 'Deskripsi harus diisi' : null,
              ),
              const SizedBox(height: 24),
              const Text("Dokumentasi Foto", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _pickMultiImage,
                icon: const Icon(Icons.add_a_photo_outlined),
                label: const Text('Pilih Beberapa Gambar'),
              ),
              const SizedBox(height: 12),
              if (_imageFiles.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _imageFiles.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(_imageFiles[index], fit: BoxFit.cover),
                    );
                  },
                ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _submitForm,
                      icon: const Icon(Icons.send),
                      label: const Text('Kirim Laporan'),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
