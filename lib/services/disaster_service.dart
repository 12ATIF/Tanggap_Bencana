import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tasik_siaga/models/disaster_model.dart';

class DisasterService {
  // Buat koneksi (referensi) ke koleksi 'disasters' di database Cloud Firestore
  final CollectionReference _disasterCollection =
      FirebaseFirestore.instance.collection('disasters');

  /// Mengambil semua data bencana DARI FIREBASE.
  Future<List<Disaster>> getDisasters() async {
    try {
      // Mengambil snapshot dari koleksi
      QuerySnapshot snapshot = await _disasterCollection.orderBy('dateTime', descending: true).get();
      // Mengubah setiap dokumen menjadi objek Disaster dan mengembalikannya sebagai list
      return snapshot.docs.map((doc) => Disaster.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error mengambil data dari Firestore: $e');
      return []; // Kembalikan list kosong jika terjadi error
    }
  }

  /// Mengirim data bencana baru KE FIREBASE.
  Future<bool> submitDisaster(Disaster newDisaster) async {
    try {
      // Menambahkan dokumen baru ke koleksi. Firestore akan membuat ID unik secara otomatis.
      await _disasterCollection.add(newDisaster.toFirestore());
      print('Data baru berhasil ditambahkan ke Firestore');
      return true;
    } catch (e) {
      print('Terjadi kesalahan saat menyimpan data ke Firestore: $e');
      return false; // Mengembalikan false jika gagal
    }
  }
}