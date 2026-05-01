import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MockTestsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// category -> tests
  final RxMap<String, List<Map<String, dynamic>>> categoryTests =
      <String, List<Map<String, dynamic>>>{}.obs;

  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;

  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  /// pagination cursor per category
  final Map<String, DocumentSnapshot> _lastDocs = {};

  /// scroll controller for pagination
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    fetchMockTests();

    /// infinite scroll listener
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        fetchMockTests(loadMore: true);
      }
    });
  }

  // ================= FETCH TESTS =================
  Future<void> fetchMockTests({bool loadMore = false}) async {
    try {
      if (loadMore) {
        isLoadingMore.value = true;
      } else {
        isLoading.value = true;
      }

      final Map<String, List<Map<String, dynamic>>> temp = loadMore
          ? Map.from(categoryTests)
          : {};

      /// ✅ FETCH ALL ATTEMPTS ONCE
      final attemptsMap = await _getAllAttempts();

      final categorySnap = await _firestore.collection('mock_tests').get();

      for (final categoryDoc in categorySnap.docs) {
        final categoryId = categoryDoc.id;

        Query query = _firestore
            .collection('mock_tests')
            .doc(categoryId)
            .collection('tests')
            .orderBy('createdAt', descending: true)
            .limit(10);

        /// pagination support
        if (loadMore && _lastDocs.containsKey(categoryId)) {
          query = query.startAfterDocument(_lastDocs[categoryId]!);
        }

        final testSnap = await query.get();

        if (testSnap.docs.isEmpty) continue;

        /// save last document
        _lastDocs[categoryId] = testSnap.docs.last;

        final List<Map<String, dynamic>> tests =
            loadMore && temp.containsKey(categoryId) ? temp[categoryId]! : [];

        for (final doc in testSnap.docs) {
          final data = doc.data() as Map<String, dynamic>;

          /// ✅ FAST LOCAL ATTEMPT CHECK
          final attemptData = _getAttemptFromCache(attemptsMap, doc.id);

          tests.add({
            'id': doc.id,
            'categoryId': categoryId,
            'title': data['title'] ?? '',
            'thumbnail': data['thumbnail'] ?? '',
            'duration': data['duration'] ?? 0,
            'isFree': data['isFree'] ?? true,
            'questions': data['questionsCount'] ?? 0,
            'createdAt': data['createdAt'] ?? Timestamp.now(),
            'isLocked': attemptData['isLocked'],
            'lockMessage': attemptData['message'],
          });
        }

        temp[categoryId] = tests;
      }

      categoryTests.assignAll(temp);
    } catch (e) {
      print("Fetch error: $e");
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // ================= FETCH ALL ATTEMPTS =================
  Future<Map<String, dynamic>> _getAllAttempts() async {
    if (userId.isEmpty) return {};

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('mock_attempts')
        .get();

    final Map<String, dynamic> attempts = {};

    for (var doc in snapshot.docs) {
      attempts[doc.id] = doc.data();
    }

    return attempts;
  }

  // ================= LOCAL ATTEMPT CHECK =================
  Map<String, dynamic> _getAttemptFromCache(
    Map<String, dynamic> attemptsMap,
    String testId,
  ) {
    if (!attemptsMap.containsKey(testId)) {
      return {'isLocked': false, 'message': ''};
    }

    final data = attemptsMap[testId];

    int count = data['attemptCount'] ?? 0;
    Timestamp? last = data['updatedAt'];

    /// allow if < 3
    if (count < 3) {
      return {'isLocked': false, 'message': ''};
    }

    /// 24h cooldown
    if (last != null) {
      final diff = DateTime.now().difference(last.toDate());

      if (diff.inHours >= 24) {
        return {'isLocked': false, 'message': ''};
      } else {
        final remaining = 24 - diff.inHours;
        return {'isLocked': true, 'message': "Try again in $remaining hrs"};
      }
    }

    return {'isLocked': false, 'message': ''};
  }

  // ================= START TEST =================
  Future<void> startTest(String testId) async {
    if (userId.isEmpty) return;

    /// ONLY NAVIGATE (no attempt increment here)
    Get.toNamed('/start-test', arguments: {'testId': testId});
  }

  // ================= INCREASE ATTEMPT (CALL AFTER SUBMIT) =================
  Future<void> increaseAttempt(String testId) async {
    if (userId.isEmpty) return;

    final ref = _firestore
        .collection('users')
        .doc(userId)
        .collection('mock_attempts')
        .doc(testId);

    final doc = await ref.get();

    int count = 1;

    if (doc.exists) {
      final data = doc.data()!;
      int oldCount = data['attemptCount'] ?? 0;
      Timestamp? last = data['updatedAt'];

      if (last != null) {
        final diff = DateTime.now().difference(last.toDate()).inHours;

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

    /// refresh UI instantly
    fetchMockTests();
  }
}
