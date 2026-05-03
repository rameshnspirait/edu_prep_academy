import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_prep_academy/User/core/DB/hive_service.dart';
import 'package:edu_prep_academy/User/core/DB/pdf_download_service.dart';
import 'package:edu_prep_academy/User/core/DB/pdf_model.dart';
import 'package:flutter/material.dart';
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

  Future<void> loadPdfs(String userId) async {
    final pdfs = await HiveService.getAllPdfs(userId);
    downloadedPdfs.assignAll(pdfs);
  }

  Future<void> downloadPdf({
    required String id,
    required String title,
    required String url,
    required String userId,
  }) async {
    if (HiveService.isDownloaded(userId, id)) {
      Get.snackbar(
        "Already Downloaded",
        "Open from Downloads",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
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

      Get.snackbar(
        "Success",
        "PDF Downloaded",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar("Error", "Download failed");
    }
  }

  Future<void> deletePdf(String id, String userId) async {
    final pdf = await HiveService.getPdf(userId, id);

    if (pdf == null) return;

    try {
      final file = File(pdf.filePath);

      /// 🔥 SAFE FILE DELETE
      if (await file.exists()) {
        await file.delete();
      }

      /// 🔥 REMOVE FROM HIVE
      await HiveService.deletePdf(userId, id);

      /// 🔥 RELOAD LIST
      await loadPdfs(userId);
    } catch (e) {
      debugPrint("Delete PDF error: $e");
    }
  }
}
