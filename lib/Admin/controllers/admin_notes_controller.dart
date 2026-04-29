import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_prep_academy/Admin/data/models/notes_model.dart';
import 'package:get/get.dart';

class AdminNotesController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ---------------- STATE ----------------
  RxList<String> categories = <String>[].obs;
  RxList<AdminNoteModel> notes = <AdminNoteModel>[].obs;

  RxString selectedCategory = ''.obs;

  RxBool isLoading = false.obs;
  RxBool isUploading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  /// ---------------- LOAD CATEGORIES ----------------
  Future<void> loadCategories() async {
    try {
      isLoading.value = true;

      final snapshot = await _firestore.collection('notes').get();

      categories.value = snapshot.docs.map((doc) => doc.id).toList();

      if (categories.isNotEmpty) {
        selectedCategory.value = categories.first;
        await loadNotes();
      }
    } catch (e) {
      print("Error loading categories: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// ---------------- CREATE CATEGORY ----------------
  Future<void> createCategory(String categoryName) async {
    if (categoryName.trim().isEmpty) {
      Get.snackbar("Error", "Category name required");
      return;
    }

    try {
      await _firestore.collection('notes').doc(categoryName).set({
        'createdAt': FieldValue.serverTimestamp(),
      });

      await loadCategories();

      Get.snackbar("Success", "Category created");
    } catch (e) {
      print("Create category error: $e");
    }
  }

  /// ---------------- LOAD NOTES ----------------
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

  /// ---------------- URL VALIDATION ----------------
  bool _isValidUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && uri.hasAbsolutePath;
  }

  /// ---------------- ADD NOTE ----------------
  Future<void> addNote(
    String title,
    String content,
    String pdfUrl,
    String thumbnailUrl,
  ) async {
    if (selectedCategory.value.isEmpty) {
      Get.snackbar("Error", "Select category");
      return;
    }

    if (title.isEmpty ||
        content.isEmpty ||
        pdfUrl.isEmpty ||
        thumbnailUrl.isEmpty) {
      Get.snackbar("Error", "All fields required");
      return;
    }

    if (!_isValidUrl(pdfUrl) || !_isValidUrl(thumbnailUrl)) {
      Get.snackbar("Invalid URL", "Enter valid URLs");
      return;
    }

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

  /// ---------------- UPDATE NOTE ----------------
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

  /// ---------------- DELETE NOTE ----------------
  Future<void> deleteNote(String id) async {
    try {
      await _firestore
          .collection('notes')
          .doc(selectedCategory.value)
          .collection('items')
          .doc(id)
          .delete();

      await loadNotes();

      Get.snackbar("Deleted", "Note deleted");
    } catch (e) {
      print("Delete error: $e");
    }
  }
}
