import 'package:cloud_firestore/cloud_firestore.dart';

class AdminNoteModel {
  final String id;
  final String title;
  final String content;
  final String thumbnail;
  final String pdfUrl;
  final DateTime createdAt;

  AdminNoteModel({
    required this.id,
    required this.title,
    required this.content,
    this.thumbnail = '', // ✅ default value
    this.pdfUrl = '', // ✅ default value
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// FROM FIRESTORE
  factory AdminNoteModel.fromJson(Map<String, dynamic> json, String id) {
    return AdminNoteModel(
      id: id,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      pdfUrl: json['pdfUrl'] ?? '',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// TO FIRESTORE
  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "content": content,
      "thumbnail": thumbnail,
      "pdfUrl": pdfUrl,
      "createdAt": createdAt,
    };
  }
}
