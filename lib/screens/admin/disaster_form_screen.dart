import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tasik_siaga/models/disaster_model.dart';
import 'package:tasik_siaga/services/disaster_service.dart';
import 'package:geocoding/geocoding.dart'; // <-- 1. Import package geocoding

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

  DisasterType? _selectedType;
  final _districtController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;
  bool _isGeocoding = true; // <-- 2. State untuk loading pencarian alamat

  @override
  void initState() {
    super.initState();
    // 3. Panggil fungsi untuk mencari alamat saat halaman dibuka
    _getAddressFromCoordinates();
  }

  /// Mengambil alamat dari koordinat (Reverse Geocoding)
  Future<void> _getAddressFromCoordinates() async {
    try {
      // Menggunakan package geocoding untuk mencari placemark (detail alamat)
      List<Placemark> placemarks = await placemarkFromCoordinates(
        widget.latitude,
        widget.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        // Kita isi field Kecamatan dari data 'subLocality' atau 'locality'
        // Anda bisa menyesuaikan ini dengan data lain jika perlu
        final district = placemark.subLocality ?? placemark.locality ?? 'Tidak Ditemukan';
        
        // Buat alamat lengkap untuk deskripsi awal
        final fullAddress = "${placemark.street}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.subAdministrativeArea}";

        setState(() {
          _districtController.text = district;
          // Kita juga bisa memberikan deskripsi awal
          _descriptionController.text = "Telah terjadi bencana di sekitar $fullAddress.";
        });
      }
    } catch (e) {
      print("Error saat mencari alamat: $e");
      // Jika gagal, set default text
      setState(() {
         _districtController.text = "Gagal mendapatkan nama kecamatan";
      });
    } finally {
      // Hentikan loading setelah selesai
      setState(() {
        _isGeocoding = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() { _isLoading = true; });
    try {
      await _disasterService.addDisaster(
        type: _selectedType!.name,
        latitude: widget.latitude,
        longitude: widget.longitude,
        district: _districtController.text,
        description: _descriptionController.text,
        dateTime: DateTime.now(),
        imageFile: _imageFile,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laporan bencana berhasil dikirim!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim laporan: $e'),
            backgroundColor: Colors.red,
          ),
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
      appBar: AppBar(
        title: const Text('Form Laporan Bencana'),
      ),
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
                decoration: const InputDecoration(
                  labelText: 'Jenis Bencana',
                  border: OutlineInputBorder(),
                ),
                items: DisasterType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() { _selectedType = value; });
                },
                validator: (value) => value == null ? 'Jenis bencana harus dipilih' : null,
              ),
              const SizedBox(height: 16),
              // 4. Perbarui TextFormField untuk Kecamatan
              TextFormField(
                controller: _districtController,
                decoration: InputDecoration(
                  labelText: 'Kecamatan',
                  border: const OutlineInputBorder(),
                  // Tampilkan loading indicator saat alamat sedang dicari
                  suffixIcon: _isGeocoding ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ) : null,
                ),
                validator: (value) => value == null || value.isEmpty ? 'Kecamatan harus diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Kejadian',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) => value == null || value.isEmpty ? 'Deskripsi harus diisi' : null,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: Text(_imageFile == null ? 'Pilih Gambar (Opsional)' : 'Ganti Gambar'),
              ),
              const SizedBox(height: 12),
              if (_imageFile != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    _imageFile!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _submitForm,
                      icon: const Icon(Icons.send),
                      label: const Text('Kirim Laporan'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}