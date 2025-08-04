import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tasik_siaga/services/disaster_service.dart';

class DisasterFormScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const DisasterFormScreen({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  _DisasterFormScreenState createState() => _DisasterFormScreenState();
}

class _DisasterFormScreenState extends State<DisasterFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _disasterService = DisasterService();

  final _typeController = TextEditingController();
  final _districtController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  File? _imageFile;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _disasterService.addDisaster(
          type: _typeController.text,
          latitude: widget.latitude,
          longitude: widget.longitude,
          district: _districtController.text,
          dateTime: _selectedDate,
          description: _descriptionController.text,
          imageFile: _imageFile,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Laporan berhasil ditambahkan!')),
        );
        Navigator.of(context).pop(true); // Kirim sinyal sukses
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan laporan: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _typeController.dispose();
    _districtController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Laporan Bencana')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Lokasi: ${widget.latitude.toStringAsFixed(5)}, ${widget.longitude.toStringAsFixed(5)}'),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _typeController,
                      decoration: const InputDecoration(labelText: 'Jenis Bencana (e.g., Banjir, Longsor)'),
                      validator: (value) => value!.isEmpty ? 'Jenis bencana tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _districtController,
                      decoration: const InputDecoration(labelText: 'Kecamatan'),
                       validator: (value) => value!.isEmpty ? 'Kecamatan tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Deskripsi Singkat'),
                      maxLines: 3,
                       validator: (value) => value!.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Pilih Gambar'),
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
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Kirim Laporan'),
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