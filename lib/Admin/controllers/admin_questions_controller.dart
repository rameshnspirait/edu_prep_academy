import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AdminQuestionsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxList<Map<String, dynamic>> questions = <Map<String, dynamic>>[].obs;
  RxBool isLoading = false.obs;

  late String categoryId;
  late String testId;

  // ================= INIT =================
  void init({required String category, required String test}) {
    categoryId = category;
    testId = test;
    fetchQuestions();
  }

  // ================= FETCH =================
  Future<void> fetchQuestions() async {
    isLoading.value = true;

    final snap = await _firestore
        .collection('mock_tests')
        .doc(categoryId)
        .collection('tests')
        .doc(testId)
        .collection('questions')
        .orderBy('createdAt', descending: true)
        .get();

    questions.value = snap.docs.map((e) => {...e.data(), 'id': e.id}).toList();

    isLoading.value = false;
  }

  // ================= ADD QUESTION =================
  Future<void> addQuestion({
    required String question,
    required List<String> options,
    required int correctIndex,
    String? explanation,
  }) async {
    await _firestore
        .collection('mock_tests')
        .doc(categoryId)
        .collection('tests')
        .doc(testId)
        .collection('questions')
        .add({
          "question": question,
          "options": options,
          "correctIndex": correctIndex,
          "explanation": explanation ?? '',
          "createdAt": FieldValue.serverTimestamp(),
        });

    fetchQuestions();
  }

  // ================= DELETE =================
  Future<void> deleteQuestion(String id) async {
    await _firestore
        .collection('mock_tests')
        .doc(categoryId)
        .collection('tests')
        .doc(testId)
        .collection('questions')
        .doc(id)
        .delete();

    fetchQuestions();
  }
}
