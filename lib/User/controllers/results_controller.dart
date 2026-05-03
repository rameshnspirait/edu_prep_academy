import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ResultsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  /// category -> list of tests
  final RxMap<String, List<Map<String, dynamic>>> results =
      <String, List<Map<String, dynamic>>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchResults();
  }

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

      /// ================= LOAD ALL TESTS =================
      final Map<String, Map<String, dynamic>> tests = {};

      final categoriesSnap = await _firestore.collection('mock_tests').get();

      for (final categoryDoc in categoriesSnap.docs) {
        final subTests = await categoryDoc.reference.collection('tests').get();

        for (final testDoc in subTests.docs) {
          tests[testDoc.id] = {
            ...testDoc.data(),
            "testId": testDoc.id,
            "category": categoryDoc.id,
          };
        }
      }

      /// ================= LOAD USER ATTEMPTS =================
      final attemptSnap = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('mock_attempts')
          .orderBy('updatedAt', descending: true)
          .get();

      if (attemptSnap.docs.isEmpty) {
        error.value = "No attempts found";
        return;
      }

      /// ================= CACHE ALL USERS ONCE =================
      final allUsers = await _firestore.collection('users').get();

      for (final doc in attemptSnap.docs) {
        final attempt = doc.data();
        final String testId = attempt['testId'];

        if (!tests.containsKey(testId)) continue;

        final test = tests[testId]!;

        final int userScore = (attempt['lastScore'] ?? 0).toInt();

        /// ================= RANK CALCULATION (OPTIMIZED) =================
        int rank = 1;
        int totalStudents = 0;

        for (final userDoc in allUsers.docs) {
          final snap = await userDoc.reference
              .collection('mock_attempts')
              .where('testId', isEqualTo: testId)
              .limit(1)
              .get();

          if (snap.docs.isNotEmpty) {
            totalStudents++;

            final otherScore = (snap.docs.first.data()['lastScore'] ?? 0)
                .toInt();

            if (otherScore > userScore) {
              rank++;
            }
          }
        }

        final double percentile = totalStudents > 1
            ? ((totalStudents - rank) / totalStudents) * 100
            : 100;

        /// ================= FINAL DATA =================
        final resultItem = {
          "testId": testId,
          "testName": attempt['testTitle'] ?? test['title'],
          "category": test['category'],

          /// 🔥 IMPORTANT FIXED FIELDS
          "obtainedMarks": (attempt['correct'] ?? 0),
          "totalMarks": (attempt['totalQuestions'] ?? 1),

          "accuracy": (attempt['lastAccuracy'] ?? 0).toDouble(),
          "totalQuestions": (attempt['totalQuestions'] ?? 1),
          "correctAnswered": (attempt['correct'] ?? 0),

          "attempts": (attempt['attemptCount'] ?? 1),
          "timeTaken": (attempt['timeTaken'] ?? 0),

          "date": attempt['updatedAt'],

          "rank": rank,
          "percentile": percentile,
          "totalStudents": totalStudents,
        };

        /// ================= GROUP BY CATEGORY =================
        final String category = test['category'] ?? "General";

        results.putIfAbsent(category, () => []);
        results[category]!.add(resultItem);
      }

      /// ================= SORT BY DATE =================
      results.forEach((key, value) {
        value.sort((a, b) {
          final aDate = a['date'] as Timestamp?;
          final bDate = b['date'] as Timestamp?;
          return (bDate ?? Timestamp.now()).compareTo(aDate ?? Timestamp.now());
        });
      });

      if (results.isEmpty) {
        error.value = "No mapped data found";
      }
    } catch (e) {
      error.value = "Error: $e";
      print("🔥 ERROR: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
