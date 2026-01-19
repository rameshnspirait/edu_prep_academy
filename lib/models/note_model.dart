import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String id;
  final String title;
  final String thumbnail;
  final String pdfUrl;
  final DateTime createdAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.pdfUrl,
    required this.createdAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json, String docId) {
    return NoteModel(
      id: docId,
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      pdfUrl: json['pdfUrl'] ?? '',

      /// 🔥 FIX IS HERE
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }
}
