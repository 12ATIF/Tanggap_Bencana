import 'package:flutter/material.dart';

class DisasterFormScreen extends StatefulWidget {
  const DisasterFormScreen({super.key});

  @override
  State<DisasterFormScreen> createState() => _DisasterFormScreenState();
}

class _DisasterFormScreenState extends State<DisasterFormScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedDisasterType;
  String? _selectedDistrict;

  // Data dummy untuk dropdown, nantinya bisa diambil dari API
  final List<String> _disasterTypes = ['Banjir', 'Tanah Longsor', 'Kebakaran', 'Angin Kencang', 'Kekeringan'];
  final List<String> _districts = ['Cihideung', 'Kawalu', 'Tamansari', 'Tawang', 'Bungursari', 'Indihiang', 'Mangkubumi', 'Cipedes', 'Purbaratu', 'Bebedahan'];

  // Fungsi untuk menampilkan date picker
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

  // Fungsi untuk menampilkan time picker
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
              // Input Tanggal dan Waktu
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

              // Dropdown Jenis Bencana
              DropdownButtonFormField<String>(
                value: _selectedDisasterType,
                decoration: const InputDecoration(
                  labelText: 'Jenis Bencana',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.warning_amber_rounded),
                ),
                items: _disasterTypes.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedDisasterType = newValue;
                  });
                },
                validator: (value) => value == null ? 'Jenis bencana harus diisi' : null,
              ),
              const SizedBox(height: 16),

              // Dropdown Kecamatan
              DropdownButtonFormField<String>(
                value: _selectedDistrict,
                decoration: const InputDecoration(
                  labelText: 'Kecamatan',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                ),
                items: _districts.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedDistrict = newValue;
                  });
                },
                 validator: (value) => value == null ? 'Kecamatan harus diisi' : null,
              ),
              const SizedBox(height: 16),

              // Kolom Teks Deskripsi
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Kejadian',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  hintText: 'Jelaskan detail kejadian bencana di sini...',
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

              // Placeholder untuk Peta Mini
              const Text('Input Titik Koordinat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('Widget Peta Mini Akan Ditampilkan di Sini'),
                ),
              ),
               const SizedBox(height: 24),

              // Placeholder untuk Upload Gambar
              const Text('Dokumentasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    onPressed: () { /* TODO: Implement image picker */ },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Upload Foto'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black87
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
