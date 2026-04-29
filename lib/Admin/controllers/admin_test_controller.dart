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
    required String title,
    required int duration,
    required int questionsCount,
    required String thumbnail,
    required bool isFree,
  }) async {
    if (selectedCategory.value.isEmpty) return;

    await _firestore
        .collection('mock_tests')
        .doc(selectedCategory.value)
        .collection('tests')
        .add({
          'title': title,
          'duration': duration,
          'questionsCount': questionsCount,
          'thumbnail': thumbnail,
          'isFree': isFree,
          'createdAt': FieldValue.serverTimestamp(),
        });
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
