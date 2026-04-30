import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ResultsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

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

      ///  LOAD ALL TESTS
      final Map<String, Map<String, dynamic>> tests = {};

      final mainSnap = await _firestore.collection('mock_tests').get();

      for (final mainDoc in mainSnap.docs) {
        final subSnap = await mainDoc.reference.collection('tests').get();

        for (final testDoc in subSnap.docs) {
          tests[testDoc.id] = {
            ...testDoc.data(),
            "testId": testDoc.id,
            "category": mainDoc.id, // SSC_GD
          };
        }
      }

      /// ✅ LOAD USER ATTEMPTS
      final attemptSnap = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('mock_attempts')
          .get();

      if (attemptSnap.docs.isEmpty) {
        error.value = "No attempts found";
        return;
      }

      for (final doc in attemptSnap.docs) {
        final attempt = doc.data();

        /// 🔥 IMPORTANT FIX HERE
        final String testId = attempt['testId'] ?? doc.id; // fallback safety

        if (!tests.containsKey(testId)) {
          print("❌ Test not found for testId: $testId");
          continue;
        }

        final test = tests[testId]!;

        final int bestScore = (attempt['bestScore'] ?? 0).toInt();

        /// 🔥 RANK CALCULATION (FIXED)
        int rank = 1;
        int totalStudents = 0;

        final usersSnap = await _firestore.collection('users').get();

        for (final userDoc in usersSnap.docs) {
          final attemptDoc = await userDoc.reference
              .collection('mock_attempts')
              .where('testId', isEqualTo: testId)
              .limit(1)
              .get();

          if (attemptDoc.docs.isNotEmpty) {
            totalStudents++;

            final score = (attemptDoc.docs.first.data()['bestScore'] ?? 0)
                .toInt();

            if (score > bestScore) {
              rank++;
            }
          }
        }

        final double percentile = totalStudents > 1
            ? ((totalStudents - rank) / totalStudents) * 100
            : 100;

        final resultItem = {
          "testId": testId,
          "testName": test['title'] ?? 'Mock Test',
          "obtainedMarks": (attempt['bestObtainedMarks'] ?? 0).toInt(),
          "totalMarks": (attempt['bestTotalMarks'] ?? test['totalMarks'] ?? 1)
              .toInt(),
          "accuracy": (attempt['bestAccuracy'] ?? 0).toInt(),
          "totalQuestions": (attempt['totalQuestions'] ?? 1).toInt(),
          "correctAnswered": (attempt['correctAnswered'] ?? 0).toInt(),
          "attempts": (attempt['attemptCount'] ?? 1).toInt(),
          "status": attempt['status'] ?? 'UNKNOWN',
          "date": attempt['updatedAt'],
          "rank": rank,
          "percentile": percentile,
          "totalStudents": totalStudents,
        };

        final groupKey = test['title'] ?? 'Mock Test';

        results.putIfAbsent(groupKey, () => []);
        results[groupKey]!.add(resultItem);
      }

      /// ✅ SORT
      results.forEach((key, value) {
        value.sort((a, b) {
          final aDate = a['date'] as Timestamp?;
          final bDate = b['date'] as Timestamp?;
          return (bDate ?? Timestamp.now()).compareTo(aDate ?? Timestamp.now());
        });
      });

      if (results.isEmpty) {
        error.value = "No data mapped (check testId mapping)";
      }
    } catch (e) {
      error.value = "Error: $e";
      print("🔥 ERROR: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
