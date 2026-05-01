import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_prep_academy/User/views/mocks/result_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StartTestController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// ================= STATE =================
  final RxList<Map<String, dynamic>> questions = <Map<String, dynamic>>[].obs;
  final RxInt currentIndex = 0.obs;
  final RxInt timeLeft = 0.obs;
  final RxBool isLoading = true.obs;
  final RxBool isPaused = false.obs;
  final RxBool warningShown = false.obs;
  final RxMap<int, int> selectedAnswers = <int, int>{}.obs;

  final RxInt attemptCount = 0.obs;
  final RxBool isAttemptLimitReached = false.obs;

  Timer? _timer;

  late String testId;
  late String categoryId;
  late int duration;

  ///  MODE
  bool isDailyQuiz = false;
  Map<String, dynamic>? quizData;

  static const int maxAttempts = 3;

  /// ================= INIT =================
  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments ?? {};

    isDailyQuiz = args['isDailyQuiz'] ?? false;

    if (isDailyQuiz) {
      /// ===== DAILY QUIZ =====
      quizData = args['quizData'];
      duration = quizData?['time'] ?? 10;

      _initializeDailyQuiz(args['category'], args['quizId']);
    } else {
      /// ===== MOCK TEST =====
      if (!args.containsKey('testId') ||
          !args.containsKey('duration') ||
          !args.containsKey('categoryId')) {
        Get.back();
        return;
      }

      testId = args['testId'];
      duration = args['duration'];
      categoryId = args['categoryId'];

      _checkAttemptsThenInit();
    }
  }

  String formatCategoryId(String name) {
    return name.trim().replaceAll("/", "-").replaceAll(" ", "_");
  }

  /// ================= DAILY QUIZ =================
  void _initializeDailyQuiz(String? categoryId, String? quizId) {
    _timer?.cancel();

    selectedAnswers.clear();
    currentIndex.value = 0;
    isPaused.value = false;
    warningShown.value = false;

    timeLeft.value = duration * 60;

    _loadDailyQuiz(category: categoryId ?? '', quizId: quizId ?? '');
  }

  Future<void> _loadDailyQuiz({
    required String category,
    required String quizId,
  }) async {
    try {
      isLoading.value = true;

      final snapshot = await _firestore
          .collection('daily_quizzes')
          .doc(formatCategoryId(category)) // ✅ FIXED
          .collection('quizzes')
          .doc(quizId)
          .collection('questions')
          .get();

      if (snapshot.docs.isEmpty) {
        debugPrint("❌ No questions found");
        return;
      }

      questions.value = snapshot.docs.map((doc) {
        final data = doc.data();

        return {
          'question': data['question'] ?? '',
          'options': List<String>.from(data['options'] ?? []),
          'correctIndex': data['correctIndex'] ?? 0,
          'marks': data['marks'] ?? 1,
        };
      }).toList();

      _startTimer();
    } catch (e) {
      debugPrint("Daily Quiz Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= MOCK TEST =================
  Future<void> _checkAttemptsThenInit() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final ref = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('mock_attempts')
        .doc(testId);

    final snap = await ref.get();
    final data = snap.data();

    final attempts = data?['attemptCount'] ?? 0;
    final Timestamp? last = data?['updatedAt'];

    attemptCount.value = attempts;

    ///  24H LOCK LOGIC
    if (attempts >= maxAttempts && last != null) {
      final diff = DateTime.now().difference(last.toDate());

      if (diff.inHours < 24) {
        isAttemptLimitReached.value = true;
        isLoading.value = false;

        Get.snackbar(
          "Limit Reached",
          "Try again after ${24 - diff.inHours} hours",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    isAttemptLimitReached.value = false;
    _initializeMockTest();
  }

  void _initializeMockTest() {
    _timer?.cancel();

    selectedAnswers.clear();
    currentIndex.value = 0;
    isPaused.value = false;
    warningShown.value = false;

    timeLeft.value = duration * 60;

    _loadMockTest();
  }

  Future<void> _loadMockTest() async {
    try {
      isLoading.value = true;

      final snapshot = await _firestore
          .collection('mock_tests')
          .doc(categoryId)
          .collection('tests')
          .doc(testId)
          .collection('questions')
          .orderBy('createdAt')
          .get();

      if (snapshot.docs.isEmpty) {
        Get.back();
        return;
      }

      questions.assignAll(
        snapshot.docs.map((doc) {
          final data = doc.data();

          return {
            'question': data['question'] ?? '',
            'options': List<String>.from(data['options'] ?? []),
            'correctIndex': data['correctIndex'] ?? 0,
            'marks': data['marks'] ?? 1,
          };
        }).toList(),
      );

      _startTimer();
    } catch (e) {
      debugPrint("Mock Test Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= TIMER =================
  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isPaused.value) return;

      if (timeLeft.value <= 0) {
        timer.cancel();
        submitTest(autoSubmit: true);
      } else {
        timeLeft.value--;
      }
    });
  }

  /// ================= ANSWERS =================
  void selectOption(int optionIndex) {
    selectedAnswers[currentIndex.value] = optionIndex;
  }

  void nextQuestion() {
    if (currentIndex.value < questions.length - 1) {
      currentIndex.value++;
    }
  }

  /// ================= SUBMIT =================
  Future<void> submitTest({bool autoSubmit = false}) async {
    _timer?.cancel();

    int correct = 0;

    for (int i = 0; i < questions.length; i++) {
      if (selectedAnswers[i] == questions[i]['correctIndex']) {
        correct++;
      }
    }

    final score = ((correct / questions.length) * 100).round();

    /// 🎯 RESULT
    Get.dialog(
      ResultDialog(
        score: score,
        correct: correct,
        total: questions.length,
        obtainedMarks: correct.toDouble(),
        totalMarks: questions.length.toDouble(),
      ),
      barrierDismissible: false,
    );

    /// 🔥 SAVE ONLY FOR MOCK TEST
    if (!isDailyQuiz) {
      await _saveAttempt(correct, score, autoSubmit);
    }
  }

  /// ================= SAVE ATTEMPT =================
  Future<void> _saveAttempt(int correct, int score, bool autoSubmit) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final ref = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('mock_attempts')
        .doc(testId);

    final snap = await ref.get();
    final data = snap.data() ?? {};

    final int attempts = (data['attemptCount'] ?? 0) + 1;

    await ref.set({
      'testId': testId,
      'attemptCount': attempts,
      'lastScore': score,
      'correct': correct,
      'autoSubmitted': autoSubmit,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    /// 🔥 UPDATE LOCAL STATE
    attemptCount.value = attempts;

    if (attempts >= maxAttempts) {
      isAttemptLimitReached.value = true;
    }
  }

  /// ================= RESET =================
  Future<void> resetTestAndCloseDialog(BuildContext context) async {
    if (Get.isDialogOpen ?? false) {
      Navigator.pop(context);
    }

    /// Daily Quiz → Exit
    if (isDailyQuiz) {
      Get.back();
      return;
    }

    /// Re-check attempts before restart
    await _checkAttemptsThenInit();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
