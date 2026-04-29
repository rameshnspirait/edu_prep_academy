import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final _storage = FirebaseStorage.instance;

  /// UPLOAD IMAGE
  Future<String> uploadImage(File file) async {
    final ref = _storage.ref().child(
      'thumbnails/${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  /// UPLOAD PDF
  Future<String> uploadPdf(File file) async {
    final ref = _storage.ref().child(
      'notes/${DateTime.now().millisecondsSinceEpoch}.pdf',
    );

    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }
}
