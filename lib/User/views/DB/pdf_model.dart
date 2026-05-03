import 'package:hive/hive.dart';

part 'pdf_model.g.dart';

@HiveType(typeId: 1)
class PdfModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String filePath;

  @HiveField(3)
  DateTime downloadedAt;

  PdfModel({
    required this.id,
    required this.title,
    required this.filePath,
    required this.downloadedAt,
  });
}
