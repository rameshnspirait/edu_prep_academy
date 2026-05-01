import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

/// ================= CONTROLLER =================
class DailyQuizController extends GetxController {
  final firestore = FirebaseFirestore.instance;

  RxString selectedCategory = ''.obs;
  RxList<String> categories = <String>[].obs;

  @override
  void onInit() {
    fetchCategories();
    super.onInit();
  }

  /// FETCH CATEGORIES
  void fetchCategories() async {
    final snap = await firestore.collection('daily_quizzes').get();

    categories.value = snap.docs.map((e) => formatCategoryName(e.id)).toList();

    if (categories.isNotEmpty) {
      selectedCategory.value = categories.first;
    }
  }

  String formatCategoryName(String id) {
    return id.replaceAll("_", " ");
  }

  String formatCategoryId(String name) {
    return name.replaceAll(" ", "_");
  }

  /// FETCH QUIZZES
  Stream<QuerySnapshot> getQuizStream() {
    if (selectedCategory.value.isEmpty) {
      return const Stream.empty();
    }

    return firestore
        .collection('daily_quizzes')
        .doc(formatCategoryId(selectedCategory.value))
        .collection('quizzes')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
