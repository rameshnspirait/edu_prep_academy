import 'dart:convert';

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

  //==================DELETE ALL QUESTIONS ==================
  Future<void> deleteAllQuestions() async {
    try {
      final colRef = FirebaseFirestore.instance
          .collection('mock_tests')
          .doc(categoryId)
          .collection('tests')
          .doc(testId)
          .collection('questions');

      final snapshot = await colRef.get();

      final batch = FirebaseFirestore.instance.batch();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      Get.snackbar("Success", "All questions deleted");

      fetchQuestions(); // refresh UI
    } catch (e) {
      Get.snackbar("Error", "Failed to delete questions");
    }
  }

  //================ ADD BULK QUESTIONS =================
  Future<void> addBulkQuestions(String jsonString) async {
    try {
      final List data = List.from((jsonDecode(jsonString) as List));

      final batch = FirebaseFirestore.instance.batch();

      final colRef = FirebaseFirestore.instance
          .collection('mock_tests')
          .doc(categoryId)
          .collection('tests')
          .doc(testId)
          .collection('questions');

      for (var item in data) {
        final doc = colRef.doc();

        batch.set(doc, {
          'id': doc.id,
          'question': item['question'],
          'options': item['options'],
          'correctIndex': item['correctIndex'],
          'explanation': item['explanation'],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      Get.snackbar("Success", "Bulk questions added");

      fetchQuestions(); // refresh list
    } catch (e) {
      Get.snackbar("Error", "Invalid JSON or failed upload");
      print(e);
    }
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
