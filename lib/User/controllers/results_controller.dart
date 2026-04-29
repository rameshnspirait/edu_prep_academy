import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ResultsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  /// categoryName -> list of test results
  final RxMap<String, List<Map<String, dynamic>>> results =
      <String, List<Map<String, dynamic>>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchResults();
  }

  // =====================================================
  // FETCH RESULTS (MATCHES mock_attempts STRUCTURE)
  // =====================================================
  Future<void> fetchResults() async {
    final user = _auth.currentUser;
    if (user == null) {
      error.value = "User not logged in";
      isLoading.value = false;
      return;
    }

    try {
      isLoading.value = true;
      error.value = '';
      results.clear();

      // ---------------- LOAD CATEGORIES ----------------
      final categorySnap = await _firestore.collection('mock_categories').get();
      final Map<String, String> categories = {
        for (final doc in categorySnap.docs)
          doc.id: (doc.data()['title'] ?? 'Other').toString(),
      };

      // ---------------- LOAD TESTS ----------------
      final testSnap = await _firestore.collection('mock_tests').get();
      final Map<String, Map<String, dynamic>> tests = {
        for (final doc in testSnap.docs)
          doc.id: {...doc.data(), "testId": doc.id},
      };

      // ---------------- LOAD USER MOCK ATTEMPTS ----------------
      final attemptSnap = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('mock_attempts')
          .get();

      for (final doc in attemptSnap.docs) {
        final attempt = doc.data();
        final String testId = doc.id;

        if (!tests.containsKey(testId)) continue;

        final test = tests[testId]!;
        final String categoryId = test['categoryId'] ?? '';
        final String categoryName = categories[categoryId] ?? 'Other';

        // ---------------- SAFE NUMBER HANDLING ----------------
        final int bestObtainedMarks = (attempt['bestObtainedMarks'] ?? 0)
            .toInt();
        final int bestTotalMarks =
            (attempt['bestTotalMarks'] ?? test['totalMarks'] ?? 1).toInt();
        final int bestScore = (attempt['bestScore'] ?? 0).toInt();
        final int bestAccuracy = (attempt['bestAccuracy'] ?? 0).toInt();
        final int attemptsCount = (attempt['attemptCount'] ?? 1).toInt();
        final String status = attempt['status'] ?? 'UNKNOWN';
        final Timestamp? updatedAt = attempt['updatedAt'];
        final int correctAnswered = attempt['correctAnswered'] ?? 0;
        final int totalQuestions = attempt['totalQuestions'] ?? 1;

        // ---------------- RANK & PERCENTILE ----------------
        final int rank = await _calculateRank(testId, bestScore);
        final int totalStudents = await _calculateTotalStudents(testId);
        final double percentile = totalStudents > 1
            ? ((totalStudents - rank) / (totalStudents - 1)) * 100
            : 100;

        final resultItem = {
          "testId": testId,
          "testName": test['title'] ?? 'Mock Test',
          "obtainedMarks": bestObtainedMarks,
          "totalMarks": bestTotalMarks,
          "accuracy": bestAccuracy,
          "totalQuestions": totalQuestions,
          "correctAnswered": correctAnswered,
          "attempts": attemptsCount,
          "status": status,
          "date": updatedAt,
          "rank": rank,
          "percentile": percentile,
          "totalStudents": totalStudents,
        };

        results.putIfAbsent(categoryName, () => []);
        results[categoryName]!.add(resultItem);
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // =====================================================
  // GLOBAL RANK CALCULATION (BASED ON bestScore)
  // =====================================================
  Future<int> _calculateRank(String testId, int bestScore) async {
    try {
      final usersSnap = await _firestore.collection('users').get();

      int higherScoreCount = 0;

      for (var userDoc in usersSnap.docs) {
        final attemptsSnap = await userDoc.reference
            .collection('mock_attempts')
            .doc(testId)
            .get();

        if (attemptsSnap.exists) {
          final score = (attemptsSnap.data()?['bestScore'] ?? 0).toInt();
          if (score > bestScore) higherScoreCount++;
        }
      }

      return higherScoreCount + 1;
    } catch (e) {
      print("Rank calculation error: $e");
      return -1;
    }
  }

  // =====================================================
  // TOTAL STUDENTS COUNT FOR THIS TEST
  // =====================================================
  Future<int> _calculateTotalStudents(String testId) async {
    final snap = await FirebaseFirestore.instance
        .collection('test_leaderboard')
        .doc(testId)
        .collection('results')
        .get();

    final totalUsers = snap.docs.length;
    return totalUsers;
  }
}
