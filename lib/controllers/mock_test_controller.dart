import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class MockTestsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Category title -> tests
  final RxMap<String, List<Map<String, dynamic>>> subjectTests =
      <String, List<Map<String, dynamic>>>{}.obs;

  /// testId -> attemptCount
  final RxMap<String, int> attemptCountMap = <String, int>{}.obs;

  final RxBool isLoading = true.obs;

  static const int maxAttempts = 3;

  @override
  void onInit() {
    super.onInit();
    fetchMockTests();
  }

  // =====================================================
  // MAIN FETCH
  // =====================================================
  Future<void> fetchMockTests() async {
    try {
      isLoading.value = true;

      /// ---------- LOAD USER ATTEMPTS (NEW) ----------
      await _loadUserAttempts();

      /// ---------- FETCH ACTIVE CATEGORIES ----------
      final categorySnapshot = await _firestore
          .collection('mock_categories')
          .where('isActive', isEqualTo: true)
          .get();

      final categories = categorySnapshot.docs.toList()
        ..sort((a, b) {
          final aOrder = _parseInt(a.data()['order']);
          final bOrder = _parseInt(b.data()['order']);
          return aOrder.compareTo(bOrder);
        });

      final Map<String, List<Map<String, dynamic>>> tempMap = {};

      for (final cat in categories) {
        final categoryId = cat.id;
        final categoryTitle = cat.data()['title'] ?? 'Untitled';

        /// ---------- FETCH ACTIVE TESTS ----------
        final testSnapshot = await _firestore
            .collection('mock_tests')
            .where('categoryId', isEqualTo: categoryId)
            .where('isActive', isEqualTo: true)
            .get();

        final List<Map<String, dynamic>> validTests = [];

        for (final testDoc in testSnapshot.docs) {
          final data = testDoc.data();
          final testId = testDoc.id;

          /// 🔥 CHECK IF QUESTIONS EXIST
          final questionSnapshot = await _firestore
              .collection('mock_questions')
              .where('testId', isEqualTo: testId)
              .limit(1)
              .get();

          /// ❌ Skip test if no questions
          if (questionSnapshot.docs.isEmpty) continue;

          final questionCount = _parseInt(
            data['questionCount'] ?? data['totalQuestions'],
          );

          final duration = _parseInt(
            data['duration'] ?? data['durationMinutes'],
          );

          validTests.add({
            'id': testId,
            'title': data['title'] ?? '',
            'questions': '$questionCount Questions',
            'thumbnail': data['thumbnail'] ?? '',
            'duration': duration,
            'isFree': data['isFree'] ?? true,
            'createdAt': data['createdAt'] ?? Timestamp.now(),

            /// NEW (optional UI usage)
            'attempts': attemptCountMap[testId] ?? 0,
            'isLocked': isLimitReached(testId),
          });
        }

        /// ❌ Skip category if no valid tests
        if (validTests.isEmpty) continue;

        tempMap[categoryTitle] = validTests;
      }

      subjectTests.assignAll(tempMap);
    } catch (e) {
      Get.snackbar('Error', 'Unable to load mock tests');
    } finally {
      isLoading.value = false;
    }
  }

  // =====================================================
  // LOAD USER ATTEMPTS (NEW)
  // =====================================================
  Future<void> _loadUserAttempts() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final snap = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('mock_attempts')
        .get();

    final now = DateTime.now();
    for (final doc in snap.docs) {
      final data = doc.data();
      int attempts = _parseInt(data['attemptCount']);
      final Timestamp? updatedAtTs = data['updatedAt'];
      bool shouldReset = false;
      if (attempts >= 3 && updatedAtTs != null) {
        final DateTime updatedAt = updatedAtTs.toDate();
        final diffHours = now.difference(updatedAt).inHours;
        if (diffHours >= 24) {
          shouldReset = true;
        }
      }

      /// 🔁 RESET LOGIC
      if (shouldReset) {
        await doc.reference.update({
          'attemptCount': 0,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        attemptCountMap[doc.id] = 0;
      } else {
        attemptCountMap[doc.id] = attempts;
      }
    }
  }

  // =====================================================
  // ATTEMPT LIMIT CHECK (NEW)
  // =====================================================
  bool isLimitReached(String testId) {
    final attempts = attemptCountMap[testId] ?? 0;
    return attempts >= maxAttempts;
  }

  // =====================================================
  // SAFE INT PARSER (UNCHANGED)
  // =====================================================
  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
