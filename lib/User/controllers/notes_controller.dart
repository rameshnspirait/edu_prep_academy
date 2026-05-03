import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_prep_academy/User/core/DB/hive_service.dart';
import 'package:edu_prep_academy/User/core/DB/pdf_download_service.dart';
import 'package:edu_prep_academy/User/core/DB/pdf_model.dart';
import 'package:get/get.dart';
import '../models/note_model.dart';

class NotesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxBool isInitialLoading = true.obs;
  final RxBool isLoadingMore = false.obs;

  final RxMap<String, List<NoteModel>> subjectNotes =
      <String, List<NoteModel>>{}.obs;

  final Map<String, DocumentSnapshot?> _lastDocs = {};
  final int pageSize = 6;

  @override
  void onInit() {
    super.onInit();
    fetchInitialNotes();
  }

  /// INITIAL LOAD
  Future<void> fetchInitialNotes() async {
    try {
      isInitialLoading.value = true;

      final subjects = await _firestore.collection('notes').get();

      for (final subject in subjects.docs) {
        final snap = await subject.reference
            .collection('items')
            .orderBy('createdAt', descending: true)
            .limit(pageSize)
            .get();

        subjectNotes[subject.id.replaceAll('_', ' ')] = snap.docs
            .map((e) => NoteModel.fromJson(e.data(), e.id))
            .toList();

        if (snap.docs.isNotEmpty) {
          _lastDocs[subject.id] = snap.docs.last;
        }
      }
    } finally {
      isInitialLoading.value = false;
    }
  }

  /// LOAD MORE
  Future<void> loadMore() async {
    if (isLoadingMore.value) return;
    isLoadingMore.value = true;

    try {
      for (final entry in subjectNotes.entries) {
        final subjectId = entry.key.replaceAll(' ', '_');
        final lastDoc = _lastDocs[subjectId];

        if (lastDoc == null) continue;

        final snap = await _firestore
            .collection('notes')
            .doc(subjectId)
            .collection('items')
            .orderBy('createdAt', descending: true)
            .startAfterDocument(lastDoc)
            .limit(pageSize)
            .get();

        if (snap.docs.isNotEmpty) {
          subjectNotes[entry.key]!.addAll(
            snap.docs.map((e) => NoteModel.fromJson(e.data(), e.id)),
          );
          subjectNotes.refresh();
          _lastDocs[subjectId] = snap.docs.last;
        }
      }
    } finally {
      isLoadingMore.value = false;
    }
  }

  //============================Notes Downlod Logic============================
  final RxList<PdfModel> downloadedPdfs = <PdfModel>[].obs;
  final RxBool isDownloading = false.obs;

  void loadPdfs(String userId) {
    downloadedPdfs.assignAll(HiveService.getAllPdfs(userId));
  }

  Future<void> downloadPdf({
    required String id,
    required String title,
    required String url,
    required String userId,
  }) async {
    if (HiveService.isDownloaded(userId, id)) {
      Get.snackbar("Already Downloaded", "Open from Downloads");
      return;
    }

    isDownloading.value = true;

    final path = await PdfDownloadService.downloadPdf(
      url: url,
      fileName: title,
    );

    isDownloading.value = false;

    if (path != null) {
      final pdf = PdfModel(
        id: id,
        title: title,
        filePath: path,
        downloadedAt: DateTime.now(),
      );

      await HiveService.savePdf(userId, pdf);
      loadPdfs(userId);

      Get.snackbar("Success", "PDF Downloaded");
    } else {
      Get.snackbar("Error", "Download failed");
    }
  }

  void deletePdf(String id, String userId) async {
    final pdf = HiveService.getPdf(userId, id);

    if (pdf != null) {
      File(pdf.filePath).deleteSync();
      await HiveService.deletePdf(userId, id);
      loadPdfs(userId);
    }
  }
}
