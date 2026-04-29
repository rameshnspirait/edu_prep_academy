import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_prep_academy/Admin/data/models/admin_question_model.dart';
import 'package:edu_prep_academy/Admin/data/models/admin_test_model.dart';

class TestRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ================= COLLECTIONS =================

  CollectionReference get _tests => _firestore.collection('tests');

  /// ================= TEST =================

  /// CREATE TEST
  Future<String> createTest(AdminTestModel test) async {
    final doc = await _tests.add(test.toJson());
    return doc.id;
  }

  /// GET ALL TESTS
  Future<List<AdminTestModel>> getTests() async {
    final snapshot = await _tests.orderBy('createdAt', descending: true).get();

    return snapshot.docs.map((doc) {
      return AdminTestModel.fromJson(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();
  }

  /// DELETE TEST
  Future<void> deleteTest(String testId) async {
    await _tests.doc(testId).delete();
  }

  /// ================= QUESTIONS =================

  CollectionReference _questions(String testId) {
    return _tests.doc(testId).collection('questions');
  }

  /// ADD QUESTION
  Future<void> addQuestion(String testId, AdminQuestionModel question) async {
    await _questions(testId).add(question.toJson());
  }

  /// GET QUESTIONS
  Future<List<Map<String, dynamic>>> getQuestions(String testId) async {
    final snapshot = await _questions(
      testId,
    ).orderBy('createdAt', descending: false).get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  /// DELETE QUESTION
  Future<void> deleteQuestion(String testId, String qId) async {
    await _questions(testId).doc(qId).delete();
  }

  /// UPDATE QUESTION (🔥 NEW - IMPORTANT)
  Future<void> updateQuestion(
    String testId,
    String qId,
    AdminQuestionModel question,
  ) async {
    await _questions(testId).doc(qId).update(question.toJson());
  }

  /// ================= BULK =================

  /// OPTIONAL: DELETE ALL QUESTIONS (for reset)
  Future<void> deleteAllQuestions(String testId) async {
    final snapshot = await _questions(testId).get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
