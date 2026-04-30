import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AdminMockTestController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxList<String> categories = <String>[].obs;
  RxString selectedCategory = ''.obs;

  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategoriesFromNotes();
  }

  // ================= FETCH FROM NOTES =================
  Future<void> fetchCategoriesFromNotes() async {
    final snap = await _firestore.collection('notes').get();

    categories.value = snap.docs.map((e) => e.id).toList();

    if (categories.isNotEmpty) {
      selectedCategory.value = categories.first;
    }
  }

  // ================= CREATE MOCK TEST =================
  Future<void> addMockTest({
    required String categoryId,
    required String categoryName,
    required String title,
    required int duration,
    required int questionsCount,
    required String thumbnail,
    required bool isFree,
  }) async {
    try {
      final categoryRef = _firestore.collection('mock_tests').doc(categoryId);

      /// ✅ STEP 1: CREATE CATEGORY (IF NOT EXISTS)
      await categoryRef.set({
        'name': categoryName,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // 🔥 IMPORTANT (won’t overwrite)

      /// ✅ STEP 2: ADD TEST INSIDE SUBCOLLECTION
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
    } catch (e) {
      print("Error: $e");
    }
  }

  // ================= DELETE TEST =================
  Future<void> deleteTest(String id) async {
    await _firestore
        .collection('mock_tests')
        .doc(selectedCategory.value)
        .collection('tests')
        .doc(id)
        .delete();
  }
}
