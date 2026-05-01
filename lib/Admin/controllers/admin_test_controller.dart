import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AdminMockTestController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ================= OBSERVABLES =================
  RxList<String> categories = <String>[].obs;
  RxString selectedCategory = ''.obs;

  RxList<Map<String, dynamic>> tests = <Map<String, dynamic>>[].obs;

  RxBool isLoading = false.obs;
  RxBool isDeleting = false.obs;
  RxString deleteMessage = "Preparing...".obs;

  // ================= INIT =================
  @override
  void onInit() {
    super.onInit();
    refreshAllData();
  }

  // =========================================================
  // 🔥 MASTER REFRESH (FIX FOR YOUR ISSUE)
  // =========================================================
  Future<void> refreshAllData() async {
    try {
      isDeleting.value = true;
      deleteMessage.value = "Preparing...";
      await fetchCategoriesFromNotes();

      if (selectedCategory.value.isEmpty && categories.isNotEmpty) {
        selectedCategory.value = categories.first;
      }

      if (selectedCategory.value.isNotEmpty) {
        await fetchTestsForCategory(selectedCategory.value);
      }
    } catch (e) {
      isDeleting.value = false;
    } finally {
      isDeleting.value = false;
    }
  }

  // =========================================================
  // 🔥 FETCH CATEGORIES
  // =========================================================
  Future<void> fetchCategoriesFromNotes() async {
    final snap = await _firestore.collection('notes').get();

    categories.value = snap.docs.map((e) => e.id).toList();
  }

  // =========================================================
  // 🔥 FETCH TESTS
  // =========================================================
  Future<void> fetchTestsForCategory(String categoryId) async {
    final snap = await _firestore
        .collection('mock_tests')
        .doc(categoryId)
        .collection('tests')
        .orderBy('createdAt', descending: true)
        .get();

    tests.value = snap.docs.map((e) => {...e.data(), 'id': e.id}).toList();
  }

  // =========================================================
  // 🔥 BULK UPLOAD (CATEGORY + TEST + QUESTIONS)
  // =========================================================
  Future<void> addBulkCategoriesQuestions(String jsonString) async {
    try {
      isLoading.value = true;

      final List data = jsonDecode(jsonString);
      final batch = _firestore.batch();

      for (var block in data) {
        final String categoryId = block['category']?.toString().trim() ?? '';

        final String testTitle = block['testTitle']?.toString() ?? '';

        final int duration =
            int.tryParse(block['duration']?.toString() ?? '0') ?? 0;

        final String thumbnail = block['thumbnail']?.toString() ?? '';

        final bool isFree = block['isFree'] is bool ? block['isFree'] : true;

        final List questions = block['questions'] ?? [];

        // ================= CATEGORY =================
        final categoryRef = _firestore.collection('mock_tests').doc(categoryId);

        batch.set(categoryRef, {
          'name': categoryId,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // ================= TEST =================
        final testRef = categoryRef.collection('tests').doc();

        batch.set(testRef, {
          'testId': testRef.id,
          'title': testTitle,
          'duration': duration,
          'thumbnail': thumbnail,
          'isFree': isFree,
          'totalQuestions': questions.length,
          'categoryId': categoryId,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // ================= QUESTIONS =================
        final questionCol = testRef.collection('questions');

        for (var q in questions) {
          final docRef = questionCol.doc();

          final rawOptions = q['options'];

          final List<String> safeOptions = rawOptions == null
              ? []
              : List<String>.from(
                  (rawOptions as List).map((e) => e.toString()),
                );

          batch.set(docRef, {
            'question': q['question']?.toString() ?? '',
            'options': safeOptions,
            'correctIndex':
                int.tryParse(q['correctIndex']?.toString() ?? '0') ?? 0,
            'explanation': q['explanation']?.toString() ?? '',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      await batch.commit();

      Get.snackbar("Success", "Bulk upload completed");

      // 🔥 FIX: REFRESH UI
      await refreshAllData();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // =========================================================
  // 🔥 DELETE ALL MOCK TESTS
  // =========================================================
  Future<void> deleteAllMockTestsCollection() async {
    try {
      isDeleting.value = true;
      deleteMessage.value = "Preparing...";

      final mockTestsRef = _firestore.collection('mock_tests');
      final categoriesSnapshot = await mockTestsRef.get();

      for (var categoryDoc in categoriesSnapshot.docs) {
        final categoryId = categoryDoc.id;

        deleteMessage.value = "Deleting $categoryId";

        final testsSnapshot = await categoryDoc.reference
            .collection('tests')
            .get();

        for (var testDoc in testsSnapshot.docs) {
          final questionsSnapshot = await testDoc.reference
              .collection('questions')
              .get();

          final batch = _firestore.batch();

          for (var q in questionsSnapshot.docs) {
            batch.delete(q.reference);
          }

          await batch.commit();

          await testDoc.reference.delete();
        }

        await categoryDoc.reference.delete();
      }

      Get.snackbar("Success", "All mock tests deleted");

      // 🔥 FIX: CLEAR STATE + REFRESH
      categories.clear();
      tests.clear();
      selectedCategory.value = '';

      await refreshAllData();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isDeleting.value = false;
    }
  }

  // =========================================================
  // 🔥 CREATE SINGLE MOCK TEST
  // =========================================================
  Future<void> addMockTest({
    required String categoryId,
    required String categoryName,
    required String title,
    required int duration,
    required int questionsCount,
    required String thumbnail,
    required bool isFree,
  }) async {
    final categoryRef = _firestore.collection('mock_tests').doc(categoryId);

    await categoryRef.set({
      'name': categoryName,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final testRef = categoryRef.collection('tests').doc();

    await testRef.set({
      'testId': testRef.id,
      'title': title,
      'duration': duration,
      'totalQuestions': questionsCount,
      'thumbnail': thumbnail,
      'isFree': isFree,
      'categoryId': categoryId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await fetchTestsForCategory(categoryId);
  }

  // =========================================================
  // 🔥 DELETE SINGLE TEST
  // =========================================================
  Future<void> deleteTest(String id) async {
    await _firestore
        .collection('mock_tests')
        .doc(selectedCategory.value)
        .collection('tests')
        .doc(id)
        .delete();

    await fetchTestsForCategory(selectedCategory.value);
  }

  // =========================================================
  // 🔥 CATEGORY CHANGE
  // =========================================================
  Future<void> changeCategory(String categoryId) async {
    selectedCategory.value = categoryId;
    await fetchTestsForCategory(categoryId);
  }
}
