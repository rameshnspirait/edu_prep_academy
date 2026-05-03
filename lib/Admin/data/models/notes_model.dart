import 'package:cloud_firestore/cloud_firestore.dart';

class AdminNoteModel {
  final String id;
  final String title;
  final String content;
  final String thumbnail;
  final String pdfUrl;
  final bool isFree; // ✅ NEW FIELD
  final DateTime createdAt;

  AdminNoteModel({
    required this.id,
    required this.title,
    required this.content,
    this.thumbnail = '',
    this.pdfUrl = '',
    this.isFree = true, // ✅ default FREE (important)
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// ================= FROM FIRESTORE =================
  factory AdminNoteModel.fromJson(Map<String, dynamic> json, String id) {
    return AdminNoteModel(
      id: id,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      pdfUrl: json['pdfUrl'] ?? '',

      /// ✅ HANDLE OLD DATA SAFELY
      isFree: json['isFree'] ?? true,

      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// ================= TO FIRESTORE =================
  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "content": content,
      "thumbnail": thumbnail,
      "pdfUrl": pdfUrl,

      /// ✅ SAVE FIELD
      "isFree": isFree,

      "createdAt": createdAt,
    };
  }

  /// ================= COPY WITH (PRO LEVEL) =================
  AdminNoteModel copyWith({
    String? title,
    String? content,
    String? thumbnail,
    String? pdfUrl,
    bool? isFree,
    DateTime? createdAt,
  }) {
    return AdminNoteModel(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      thumbnail: thumbnail ?? this.thumbnail,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      isFree: isFree ?? this.isFree,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
