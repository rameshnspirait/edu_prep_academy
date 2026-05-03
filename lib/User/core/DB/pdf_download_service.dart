import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class PdfDownloadService {
  static Future<String?> downloadPdf({
    required String url,
    required String fileName,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();

      final filePath = "${dir.path}/$fileName.pdf";

      await Dio().download(url, filePath);

      return filePath;
    } catch (e) {
      print("Download error: $e");
      return null;
    }
  }
}
