import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_prep_academy/User/views/mocks/result_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StartTestController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// ================= COLLECTION NAMES =================
  static const String mockCollection = "mock_attempts";
  static const String quizCollection = "daily_quiz_attempts";

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

  /// MODE
  bool isDailyQuiz = false;
  Map<String, dynamic>? quizData;

  static const int maxAttempts = 3;
  final args = Get.arguments ?? {};

  /// ================= INIT =================
  @override
  void onInit() {
    super.onInit();

    isDailyQuiz = args['isDailyQuiz'] ?? false;

    if (isDailyQuiz) {
      quizData = args['quizData'];
      duration = quizData?['time'] ?? 10;

      _initializeDailyQuiz(args['category'], args['quizId']);
    } else {
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

  /// ================= DAILY QUIZ INIT =================
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
          .doc(category.replaceAll("/", "-").replaceAll(" ", "_"))
          .collection('quizzes')
          .doc(quizId)
          .collection('questions')
          .get();

      questions.value = snapshot.docs.map((doc) {
        final data = doc.data();

        return {
          'question': data['question'] ?? '',
          'options': List<String>.from(data['options'] ?? []),
          'correctIndex': data['correctIndex'] ?? 0,
          'marks': data['marks'] ?? 1,
          'explanation': data['explanation'] ?? "No explanation available.",
        };
      }).toList();

      _startTimer();
    } catch (e) {
      debugPrint("Daily Quiz Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= MOCK INIT =================
  Future<void> _checkAttemptsThenInit() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final ref = _firestore
        .collection('users')
        .doc(user.uid)
        .collection(mockCollection)
        .doc(testId);

    final snap = await ref.get();
    final data = snap.data();

    final attempts = data?['attemptCount'] ?? 0;
    final Timestamp? last = data?['updatedAt'];

    attemptCount.value = attempts;

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

      questions.assignAll(
        snapshot.docs.map((doc) {
          final data = doc.data();

          return {
            'question': data['question'] ?? '',
            'options': List<String>.from(data['options'] ?? []),
            'correctIndex': data['correctIndex'] ?? 0,
            'marks': data['marks'] ?? 1,
            'explanation': data['explanation'] ?? "No explanation available.",
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

    if (isDailyQuiz) {
      await _saveDailyQuizAttempt(correct, score, autoSubmit);
    } else {
      await _saveMockAttempt(correct, score, autoSubmit);
      await _updateUserStats();
    }
  }

  /// ================= MOCK SAVE =================
  Future<void> _saveMockAttempt(int correct, int score, bool autoSubmit) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final ref = _firestore
        .collection('users')
        .doc(user.uid)
        .collection(mockCollection)
        .doc(testId);

    final snap = await ref.get();
    final data = snap.data() ?? {};

    final int attempts = (data['attemptCount'] ?? 0) + 1;

    final int totalQuestions = questions.length;
    final int wrong = totalQuestions - correct;
    final double accuracy = totalQuestions == 0
        ? 0
        : (correct / totalQuestions) * 100;

    await ref.set({
      'testId': testId,
      'testTitle': args['testTitle'] ?? '',
      'attemptCount': attempts,
      'lastScore': score,
      'lastAccuracy': accuracy,
      'correct': correct,
      'wrong': wrong,
      'totalQuestions': totalQuestions,
      'timeTaken': (duration * 60) - timeLeft.value,
      'autoSubmitted': autoSubmit,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    attemptCount.value = attempts;
    if (attempts >= maxAttempts) {
      isAttemptLimitReached.value = true;
    }
  }

  /// ================= QUIZ SAVE =================
  Future<void> _saveDailyQuizAttempt(
    int correct,
    int score,
    bool autoSubmit,
  ) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final quizId = args['quizId'] ?? "unknown";

    final ref = _firestore
        .collection('users')
        .doc(user.uid)
        .collection(quizCollection)
        .doc(quizId);

    final snap = await ref.get();
    final data = snap.data() ?? {};

    final int attempts = (data['attemptCount'] ?? 0) + 1;

    final int totalQuestions = questions.length;
    final int wrong = totalQuestions - correct;
    final double accuracy = totalQuestions == 0
        ? 0
        : (correct / totalQuestions) * 100;

    await ref.set({
      'quizId': quizId,
      'category': args['category'] ?? '',
      'attemptCount': attempts,
      'lastScore': score,
      'lastAccuracy': accuracy,
      'correct': correct,
      'wrong': wrong,
      'totalQuestions': totalQuestions,
      'timeTaken': (duration * 60) - timeLeft.value,
      'autoSubmitted': autoSubmit,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// ================= USER STATS =================
  Future<void> _updateUserStats() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection(mockCollection)
        .get();

    int totalTests = snapshot.docs.length;
    double totalAccuracy = 0;

    for (var doc in snapshot.docs) {
      totalAccuracy += (doc.data()['lastAccuracy'] ?? 0).toDouble();
    }

    double avgAccuracy = totalTests == 0 ? 0 : (totalAccuracy / totalTests);

    await _firestore.collection('users').doc(user.uid).set({
      'avgAccuracy': avgAccuracy,
      'totalTests': totalTests,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> resetTestAndCloseDialog(BuildContext context) async {
    /// Close dialog if open
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    /// Stop timer
    _timer?.cancel();

    /// Reset state
    selectedAnswers.clear();
    currentIndex.value = 0;
    timeLeft.value = duration * 60;
    isPaused.value = false;
    warningShown.value = false;

    /// If daily quiz → just go back
    if (isDailyQuiz) {
      Get.back();
      return;
    }

    /// For mock test → re-check attempt rules
    await _checkAttemptsThenInit();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
