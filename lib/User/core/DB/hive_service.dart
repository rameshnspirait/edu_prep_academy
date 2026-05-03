import 'package:edu_prep_academy/User/core/DB/pdf_model.dart';
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
  static Future<Box<PdfModel>> _getBox(String userId) async {
    final boxName = 'pdfs_$userId';

    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<PdfModel>(boxName);
    }

    /// 🔥 AUTO OPEN IF CLOSED
    return await Hive.openBox<PdfModel>(boxName);
  }

  /// 🔥 SAVE PDF
  static Future<void> savePdf(String userId, PdfModel pdf) async {
    final box = await _getBox(userId);
    await box.put(pdf.id, pdf);
  }

  /// 🔥 GET ALL PDFs
  static Future<List<PdfModel>> getAllPdfs(String userId) async {
    final box = await _getBox(userId);
    return box.values.toList();
  }

  /// 🔥 GET SINGLE PDF
  static Future<PdfModel?> getPdf(String userId, String id) async {
    final box = await _getBox(userId);
    return box.get(id);
  }

  /// 🔥 DELETE PDF
  static Future<void> deletePdf(String userId, String id) async {
    final box = await _getBox(userId);
    await box.delete(id);
  }

  /// 🔥 CHECK DOWNLOADED
  static bool isDownloaded(String userId, String id) {
    final boxName = 'pdfs_$userId';

    if (!Hive.isBoxOpen(boxName)) return false;

    final box = Hive.box<PdfModel>(boxName);
    return box.containsKey(id);
  }

  static Future<void> clearUserPdfs(String userId) async {
    final boxName = 'pdfs_$userId';

    try {
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box<PdfModel>(boxName);

        /// 🔥 Clear all stored PDFs
        await box.clear();

        /// 🔥 Close box
        await box.close();
      }
    } catch (e) {
      print("Error clearing PDF Hive box: $e");
    }
  }
}
