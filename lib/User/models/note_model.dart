import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String id;
  final String title;
  final String thumbnail;
  final String pdfUrl;
  final DateTime createdAt;

  /// 🔥 NEW FIELD
  final bool isFree;

  NoteModel({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.pdfUrl,
    required this.createdAt,
    required this.isFree,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json, String docId) {
    return NoteModel(
      id: docId,
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      pdfUrl: json['pdfUrl'] ?? '',

      /// ✅ SAFE DATE HANDLING
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),

      /// 🔥 DEFAULT FREE IF NOT PRESENT
      isFree: json['isFree'] ?? true,
    );
  }
}
