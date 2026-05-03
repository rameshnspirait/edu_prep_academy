import 'package:get/get.dart';
import 'package:edu_prep_academy/User/core/DB/hive_service.dart';
import 'package:edu_prep_academy/User/core/DB/pdf_model.dart';

class DownloadedNotesController extends GetxController {
  var downloadedPdfs = <PdfModel>[].obs;

  Future<void> loadPdfs(String userId) async {
    downloadedPdfs.value = await HiveService.getAllPdfs(userId);
  }
}
