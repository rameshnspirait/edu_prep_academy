import 'package:edu_prep_academy/User/views/DB/pdf_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static bool _initialized = false;

  /// 🔥 INIT HIVE (CALL IN MAIN)
  static Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();

    /// register adapter
    Hive.registerAdapter(PdfModelAdapter());

    _initialized = true;
  }

  /// 🔥 OPEN USER BOX
  static Future<Box<PdfModel>> openUserBox(String userId) async {
    final boxName = 'pdfs_$userId';

    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<PdfModel>(boxName);
    }

    return await Hive.openBox<PdfModel>(boxName);
  }

  /// 🔥 GET USER BOX (MUST BE OPENED FIRST)
  static Box<PdfModel> _getBox(String userId) {
    final boxName = 'pdfs_$userId';

    if (!Hive.isBoxOpen(boxName)) {
      throw Exception("Hive box not opened for user: $userId");
    }

    return Hive.box<PdfModel>(boxName);
  }

  /// 🔥 SAVE PDF
  static Future<void> savePdf(String userId, PdfModel pdf) async {
    final box = _getBox(userId);
    await box.put(pdf.id, pdf);
  }

  /// 🔥 GET ALL PDFs
  static List<PdfModel> getAllPdfs(String userId) {
    final box = _getBox(userId);
    return box.values.toList();
  }

  /// 🔥 GET SINGLE PDF
  static PdfModel? getPdf(String userId, String id) {
    final box = _getBox(userId);
    return box.get(id);
  }

  /// 🔥 DELETE PDF
  static Future<void> deletePdf(String userId, String id) async {
    final box = _getBox(userId);
    await box.delete(id);
  }

  /// 🔥 CHECK DOWNLOADED
  static bool isDownloaded(String userId, String id) {
    final boxName = 'pdfs_$userId';

    if (!Hive.isBoxOpen(boxName)) return false;

    final box = Hive.box<PdfModel>(boxName);
    return box.containsKey(id);
  }
}
