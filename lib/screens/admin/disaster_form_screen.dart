import 'dart:io';// Diperlukan untuk tipe data 'File'
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Untuk memilih gambar
import 'package:latlong2/latlong.dart';
import 'package:tasik_siaga/models/disaster_model.dart';
import 'package:tasik_siaga/services/disaster_service.dart';

class DisasterFormScreen extends StatefulWidget {
  final LatLng selectedPoint;

  const DisasterFormScreen({super.key, required this.selectedPoint});

  @override
  State<DisasterFormScreen> createState() => _DisasterFormScreenState();
}

class _DisasterFormScreenState extends State<DisasterFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _disasterService = DisasterService();
  final _descriptionController = TextEditingController();

  // State untuk data form
  DisasterType? _selectedDisasterType;
  String? _selectedDistrict;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  File? _imageFile; // State untuk menyimpan file gambar yang dipilih

  // State untuk UI
  bool _isLoading = false;
  late LatLng _selectedPoint;

  // Instance ImagePicker
  final ImagePicker _picker = ImagePicker();

  // Daftar kecamatan (sesuaikan jika perlu)
  final List<String> _districts = [
    'Bungursari', 'Cibeureum', 'Cihideung', 'Cipedes', 'Indihiang',
    'Kawalu', 'Mangkubumi', 'Purbaratu', 'Tamansari', 'Tawang'
  ];

  @override
  void initState() {
    super.initState();
    _selectedPoint = widget.selectedPoint;
    _selectedDistrict = _districts.first; // Set nilai default
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  // Fungsi untuk memilih gambar dari galeri
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Fungsi untuk menampilkan Date Picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Fungsi untuk menampilkan Time Picker
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

  // Fungsi utama untuk submit form
  Future<void> _submitForm() async {
    // Validasi form
    if (_formKey.currentState!.validate()) {
      if (_selectedDisasterType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan pilih jenis bencana')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      String? imageUrl;
      // Langkah 1: Upload gambar jika ada yang dipilih
      if (_imageFile != null) {
        imageUrl = await _disasterService.uploadImage(_imageFile!);
        if (imageUrl == null) {
          // Jika upload gagal, hentikan proses dan tampilkan error
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal mengupload gambar. Silakan coba lagi.')),
          );
          setState(() {
            _isLoading = false;
          });
          return; // Hentikan eksekusi
        }
      }

      // Gabungkan tanggal dan waktu yang dipilih
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // Langkah 2: Buat objek Disaster dengan data dari form, termasuk URL gambar
      final newDisaster = Disaster(
        id: '', // ID akan di-generate oleh Supabase
        type: _selectedDisasterType!,
        location: _selectedPoint,
        district: _selectedDistrict!,
        dateTime: dateTime,
        description: _descriptionController.text,
        imageUrl: imageUrl, // Masukkan URL gambar (bisa null jika tidak ada gambar)
      );

      // Langkah 3: Kirim objek ke service untuk disimpan ke database
      bool success = await _disasterService.submitDisaster(newDisaster);

      // Tampilkan feedback berdasarkan hasil submit
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Data bencana berhasil ditambahkan'
                : 'Gagal menambahkan data. Terjadi kesalahan.'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        if (success) {
          Navigator.of(context).pop(true); // Kembali ke halaman sebelumnya dan beri sinyal sukses
        }
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulir Data Bencana'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Input Tanggal dan Waktu
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Tanggal',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text('${_selectedDate.toLocal()}'.split(' ')[0]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectTime(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Waktu',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.access_time),
                          ),
                          child: Text(_selectedTime.format(context)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Dropdown Jenis Bencana
                DropdownButtonFormField<DisasterType>(
                  value: _selectedDisasterType,
                  decoration: const InputDecoration(
                    labelText: 'Jenis Bencana',
                    border: OutlineInputBorder(),
                  ),
                  items: DisasterType.values.map((DisasterType type) {
                    return DropdownMenuItem<DisasterType>(
                      value: type,
                      child: Text(type.name[0].toUpperCase() + type.name.substring(1)),
                    );
                  }).toList(),
                  onChanged: (DisasterType? newValue) {
                    setState(() {
                      _selectedDisasterType = newValue;
                    });
                  },
                  validator: (value) => value == null ? 'Pilih jenis bencana' : null,
                ),
                const SizedBox(height: 16),

                // Dropdown Kecamatan
                DropdownButtonFormField<String>(
                  value: _selectedDistrict,
                  decoration: const InputDecoration(
                    labelText: 'Kecamatan',
                    border: OutlineInputBorder(),
                  ),
                  items: _districts.map((String district) {
                    return DropdownMenuItem<String>(
                      value: district,
                      child: Text(district),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedDistrict = newValue;
                    });
                  },
                  validator: (value) => value == null ? 'Pilih kecamatan' : null,
                ),
                const SizedBox(height: 16),

                // Input Deskripsi
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Deskripsi tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Widget Upload Gambar
                Text('Upload Gambar (Opsional)', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _imageFile == null
                      ? const Center(child: Text('Belum ada gambar dipilih'))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Pilih Gambar dari Galeri'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 24),

                // Tombol Submit
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                        )
                      : const Text('Submit Data Bencana'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}