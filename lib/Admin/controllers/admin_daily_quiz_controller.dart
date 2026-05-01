import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AdminDailyQuizController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var categories = <String>[].obs;
  var selectedCategory = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  void fetchCategories() async {
    final snap = await _firestore.collection('notes').get();
    categories.value = snap.docs
        .map((e) => e['name'].toString())
        .toSet()
        .toList();
  }

  // Future<void> addQuiz({
  //   required String title,
  //   required int time,
  //   required int questions,
  // }) async {
  //   await _firestore
  //       .collection('daily_quizzes')
  //       .doc(selectedCategory.value)
  //       .collection('quizzes')
  //       .add({
  //         'title': title,
  //         'time': time,
  //         'questions': questions,
  //         'createdAt': FieldValue.serverTimestamp(),
  //       });
  // }

  void deleteQuiz(String id) {
    _firestore
        .collection('daily_quizzes')
        .doc(selectedCategory.value)
        .collection('quizzes')
        .doc(id)
        .delete();
  }

  String formatCategoryId(String name) {
    return name.trim().replaceAll("/", "-").replaceAll(" ", "_");
  }

  Future<void> deleteAllCategories() async {
    try {
      final firestore = FirebaseFirestore.instance;

      final categorySnap = await firestore.collection('daily_quizzes').get();

      WriteBatch batch = firestore.batch();
      int count = 0;

      for (var categoryDoc in categorySnap.docs) {
        final quizSnap = await categoryDoc.reference
            .collection('quizzes')
            .get();

        for (var quizDoc in quizSnap.docs) {
          final questionSnap = await quizDoc.reference
              .collection('questions')
              .get();

          /// 🔥 DELETE QUESTIONS
          for (var q in questionSnap.docs) {
            batch.delete(q.reference);
            count++;

            if (count >= 450) {
              await batch.commit();
              batch = firestore.batch();
              count = 0;
            }
          }

          /// 🔥 DELETE QUIZ
          batch.delete(quizDoc.reference);
          count++;
        }

        /// 🔥 DELETE CATEGORY DOC
        batch.delete(categoryDoc.reference);
        count++;
      }

      /// FINAL COMMIT
      if (count > 0) {
        await batch.commit();
      }

      Get.snackbar("Success", "All categories deleted 🚀");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> bulkUpload(String jsonString) async {
    try {
      final firestore = FirebaseFirestore.instance;

      final List data = json.decode(jsonString);

      WriteBatch batch = firestore.batch();
      int batchCount = 0;

      for (var categoryData in data) {
        final String rawCategoryName = categoryData['category'];

        /// ✅ SANITIZE (IMPORTANT)
        final String categoryName = rawCategoryName
            .trim()
            .replaceAll("/", "-")
            .replaceAll(" ", "_");

        /// 🔥 USE CATEGORY NAME AS DOC ID
        final categoryRef = firestore
            .collection('daily_quizzes')
            .doc(categoryName);

        batch.set(categoryRef, {
          'name': rawCategoryName, // original name (for UI)
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        batchCount++;

        /// 🔥 QUIZZES
        for (var quiz in categoryData['quizzes']) {
          final String quizId = quiz['quizId'];

          final quizRef = categoryRef.collection('quizzes').doc(quizId);

          batch.set(quizRef, {
            'title': quiz['title'],
            'time': quiz['time'],
            'totalQuestions': quiz['questions'].length,
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

          batchCount++;

          /// 🔥 QUESTIONS
          for (var q in quiz['questions']) {
            final questionRef = quizRef
                .collection('questions')
                .doc(q['questionId']);

            batch.set(questionRef, {
              'question': q['question'],
              'options': q['options'],
              'explanation': q['explanation'] ?? '',
              'correctIndex': q['correctIndex'],
              'createdAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));

            batchCount++;

            /// 🚨 FIRESTORE LIMIT SAFE
            if (batchCount >= 450) {
              await batch.commit();
              batch = firestore.batch();
              batchCount = 0;
            }
          }
        }
      }

      /// FINAL COMMIT
      if (batchCount > 0) {
        await batch.commit();
      }

      Get.snackbar("Success", "Bulk upload completed 🚀");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
}
