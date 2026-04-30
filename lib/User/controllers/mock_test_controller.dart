import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MockTestsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// category -> tests
  final RxMap<String, List<Map<String, dynamic>>> categoryTests =
      <String, List<Map<String, dynamic>>>{}.obs;

  final RxBool isLoading = true.obs;

  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    fetchMockTests();
  }

  // ================= FETCH TESTS =================
  Future<void> fetchMockTests() async {
    try {
      isLoading.value = true;

      final Map<String, List<Map<String, dynamic>>> temp = {};

      final categorySnap = await _firestore.collection('mock_tests').get();

      for (final categoryDoc in categorySnap.docs) {
        final categoryId = categoryDoc.id;
        print(categoryId);

        final testSnap = await _firestore
            .collection('mock_tests')
            .doc(categoryId)
            .collection('tests')
            .orderBy('createdAt', descending: true)
            .get();

        if (testSnap.docs.isEmpty) continue;

        final List<Map<String, dynamic>> tests = [];

        for (final doc in testSnap.docs) {
          final data = doc.data();

          /// 🔥 ATTEMPT LOGIC
          final attemptData = await _getAttemptData(categoryId, doc.id);

          tests.add({
            'id': doc.id,
            'categoryId': categoryId,
            'title': data['title'] ?? '',
            'thumbnail': data['thumbnail'] ?? '',
            'duration': data['duration'] ?? 0,
            'isFree': data['isFree'] ?? true,
            'questions': data['questionsCount'] ?? 0,
            'createdAt': data['createdAt'] ?? Timestamp.now(),

            /// 🔒 LOCK SYSTEM
            'isLocked': attemptData['isLocked'],
            'lockMessage': attemptData['message'],
          });
        }

        temp[categoryId] = tests;
      }

      categoryTests.assignAll(temp);
    } catch (e) {
      print("Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ================= ATTEMPT CHECK =================
  Future<Map<String, dynamic>> _getAttemptData(
    String categoryId,
    String testId,
  ) async {
    try {
      if (userId.isEmpty) {
        return {'isLocked': true, 'message': 'Login required'};
      }

      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('mock_attempts') // ✅ FIXED (consistent)
          .doc(testId)
          .get();

      if (!doc.exists) {
        return {'isLocked': false, 'message': ''};
      }

      final data = doc.data()!;

      int count = data['attemptCount'] ?? 0;
      Timestamp? last = data['updatedAt'];

      /// ✅ Allow if less than 3 attempts
      if (count < 3) {
        return {'isLocked': false, 'message': ''};
      }

      /// ⏳ Check 24-hour cooldown
      if (last != null) {
        final lastTime = last.toDate();
        final now = DateTime.now();

        final diff = now.difference(lastTime);

        /// ✅ AUTO UNLOCK AFTER 24H
        if (diff.inHours >= 24) {
          return {'isLocked': false, 'message': ''};
        } else {
          final remaining = 24 - diff.inHours;

          return {'isLocked': true, 'message': "Try again in $remaining hrs"};
        }
      }

      return {'isLocked': false, 'message': ''};
    } catch (e) {
      print("Attempt error: $e");
      return {'isLocked': false, 'message': ''};
    }
  }

  // ================= START TEST =================
  Future<void> startTest(String testId) async {
    if (userId.isEmpty) return;

    final ref = _firestore
        .collection('users')
        .doc(userId)
        .collection('mock_attempts') // ✅ FIXED (same collection)
        .doc(testId);

    final doc = await ref.get();

    int count = 1;

    if (doc.exists) {
      final data = doc.data()!;
      int oldCount = data['attemptCount'] ?? 0;
      Timestamp? last = data['updatedAt'];

      if (last != null) {
        final diff = DateTime.now().difference(last.toDate()).inHours;

        /// 🔥 AUTO RESET AFTER 24H
        if (diff >= 24) {
          count = 1;
        } else {
          count = oldCount + 1;
        }
      }
    }

    await ref.set({
      'attemptCount': count,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    /// 🔄 refresh UI
    fetchMockTests();
  }
}
