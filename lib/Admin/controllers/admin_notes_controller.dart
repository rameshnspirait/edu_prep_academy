import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_prep_academy/Admin/data/models/notes_model.dart';
import 'package:get/get.dart';

class AdminNotesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ================= STATE =================
  RxList<String> categories = <String>[].obs;
  RxList<AdminNoteModel> notes = <AdminNoteModel>[].obs;

  RxString selectedCategory = ''.obs;

  RxBool isLoading = false.obs;
  RxBool isUploading = false.obs;
  RxBool isDeleting = false.obs;

  RxString deleteMessage = "Preparing...".obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  // =========================================================
  // 🔥 DELETE EVERYTHING (NOTES + MOCK TESTS)
  // =========================================================
  Future<void> deleteEverything() async {
    try {
      isDeleting.value = true;
      deleteMessage.value = "Starting cleanup...";

      /// ================= DELETE NOTES =================
      final notesCategories = await _firestore.collection('notes').get();

      for (var categoryDoc in notesCategories.docs) {
        final categoryId = categoryDoc.id;

        deleteMessage.value = "Deleting notes: $categoryId";

        final notesRef = categoryDoc.reference.collection('items');
        final notesSnapshot = await notesRef.get();

        WriteBatch batch = _firestore.batch();
        int count = 0;

        for (var doc in notesSnapshot.docs) {
          batch.delete(doc.reference);
          count++;

          if (count == 450) {
            await batch.commit();
            batch = _firestore.batch();
            count = 0;
          }
        }

        if (count > 0) await batch.commit();

        await categoryDoc.reference.delete();
      }

      /// ================= DELETE MOCK TESTS =================
      final mockCategories = await _firestore.collection('mock_tests').get();

      for (var categoryDoc in mockCategories.docs) {
        final testsSnapshot = await categoryDoc.reference
            .collection('tests')
            .get();

        for (var testDoc in testsSnapshot.docs) {
          final questionsSnapshot = await testDoc.reference
              .collection('questions')
              .get();

          WriteBatch batch = _firestore.batch();
          int count = 0;

          /// delete questions
          for (var q in questionsSnapshot.docs) {
            batch.delete(q.reference);
            count++;

            if (count == 450) {
              await batch.commit();
              batch = _firestore.batch();
              count = 0;
            }
          }

          if (count > 0) await batch.commit();

          await testDoc.reference.delete();
        }

        await categoryDoc.reference.delete();
      }

      Get.snackbar("Success", "All data deleted");

      /// 🔥 REFRESH UI
      await loadCategories();
    } catch (e) {
      Get.snackbar("Error", "Delete failed");
      print(e);
    } finally {
      isDeleting.value = false;
    }
  }

  // =========================================================
  // 🔥 BULK UPLOAD NOTES
  // =========================================================
  Future<void> bulkUploadAll(String jsonString) async {
    try {
      isUploading.value = true;

      final List data = jsonDecode(jsonString);
      final batch = _firestore.batch();

      for (var categoryItem in data) {
        final String categoryName = categoryItem['category']?.toString() ?? '';

        final categoryRef = _firestore.collection('notes').doc(categoryName);

        batch.set(categoryRef, {
          'name': categoryName,
          'createdAt': FieldValue.serverTimestamp(),
        });

        final List notesList = categoryItem['notes'] ?? [];

        for (var note in notesList) {
          final noteRef = categoryRef.collection('items').doc();

          batch.set(noteRef, {
            'id': noteRef.id,
            'title': note['title'] ?? '',
            'content': note['content'] ?? '',
            'pdfUrl': note['pdfUrl'] ?? '',
            'thumbnail': note['thumbnail'] ?? '',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      await batch.commit();

      Get.snackbar("Success", "Bulk upload completed");

      /// 🔥 REFRESH UI AFTER UPLOAD
      await loadCategories();
    } catch (e) {
      Get.snackbar("Error", "Upload failed");
      print(e);
    } finally {
      isUploading.value = false;
    }
  }

  // =========================================================
  // 🔥 LOAD CATEGORIES
  // =========================================================
  Future<void> loadCategories() async {
    try {
      isLoading.value = true;

      final snapshot = await _firestore.collection('notes').get();

      categories.value = snapshot.docs.map((e) => e.id).toList();

      if (categories.isNotEmpty) {
        selectedCategory.value = categories.first;
        await loadNotes();
      } else {
        notes.clear();
        selectedCategory.value = '';
      }
    } catch (e) {
      print("Load categories error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // =========================================================
  // 🔥 LOAD NOTES
  // =========================================================
  Future<void> loadNotes() async {
    if (selectedCategory.value.isEmpty) return;

    try {
      isLoading.value = true;

      final snapshot = await _firestore
          .collection('notes')
          .doc(selectedCategory.value)
          .collection('items')
          .orderBy('createdAt', descending: true)
          .get();

      notes.value = snapshot.docs.map((doc) {
        final data = doc.data();
        return AdminNoteModel(
          id: doc.id,
          title: data['title'] ?? '',
          content: data['content'] ?? '',
          thumbnail: data['thumbnail'] ?? '',
          pdfUrl: data['pdfUrl'] ?? '',
        );
      }).toList();
    } catch (e) {
      print("Load notes error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // =========================================================
  // 🔥 ADD NOTE
  // =========================================================
  Future<void> addNote(
    String title,
    String content,
    String pdfUrl,
    String thumbnailUrl,
  ) async {
    try {
      isUploading.value = true;

      await _firestore
          .collection('notes')
          .doc(selectedCategory.value)
          .collection('items')
          .add({
            'title': title,
            'content': content,
            'pdfUrl': pdfUrl,
            'thumbnail': thumbnailUrl,
            'createdAt': FieldValue.serverTimestamp(),
          });

      await loadNotes();
      Get.snackbar("Success", "Note added");
    } catch (e) {
      print("Add note error: $e");
    } finally {
      isUploading.value = false;
    }
  }

  // =========================================================
  // 🔥 UPDATE NOTE
  // =========================================================
  Future<void> updateNote(
    String id,
    String title,
    String content,
    String pdfUrl,
    String thumbnailUrl,
  ) async {
    try {
      isUploading.value = true;

      await _firestore
          .collection('notes')
          .doc(selectedCategory.value)
          .collection('items')
          .doc(id)
          .update({
            'title': title,
            'content': content,
            'pdfUrl': pdfUrl,
            'thumbnail': thumbnailUrl,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      await loadNotes();
      Get.snackbar("Success", "Note updated");
    } catch (e) {
      print("Update error: $e");
    } finally {
      isUploading.value = false;
    }
  }

  // =========================================================
  // 🔥 DELETE NOTE
  // =========================================================
  Future<void> deleteNote(String id) async {
    try {
      await _firestore
          .collection('notes')
          .doc(selectedCategory.value)
          .collection('items')
          .doc(id)
          .delete();

      await loadNotes();
      Get.snackbar("Deleted", "Note removed");
    } catch (e) {
      print("Delete error: $e");
    }
  }
}
