import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_prep_academy/views/mocks/result_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StartTestController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
  late int duration; // in minutes
  static const int maxAttempts = 3;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args == null ||
        !args.containsKey('testId') ||
        !args.containsKey('duration')) {
      Get.back();
      return;
    }

    testId = args['testId'];
    duration = args['duration'];
    _checkAttemptsThenInit();
  }

  Future<void> _checkAttemptsThenInit() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('mock_attempts')
        .doc(testId);

    final snap = await docRef.get();
    final attempts = snap.data()?['attemptCount'] ?? 0;

    attemptCount.value = attempts;
    isAttemptLimitReached.value = attempts >= maxAttempts;

    if (!isAttemptLimitReached.value) {
      _initializeTest();
    }
  }

  void _initializeTest() {
    _timer?.cancel();
    selectedAnswers.clear();
    currentIndex.value = 0;
    isPaused.value = false;
    warningShown.value = false;
    timeLeft.value = duration * 60;
    _loadTest();
  }

  Future<void> _loadTest() async {
    try {
      isLoading.value = true;
      final snapshot = await _firestore
          .collection('mock_questions')
          .where('testId', isEqualTo: testId)
          .get();

      questions.assignAll(snapshot.docs.map((e) => e.data()).toList());
      _startTimer();
    } finally {
      isLoading.value = false;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isPaused.value) return;

      if (timeLeft.value == 60 && !warningShown.value) {
        warningShown.value = true;
        Get.snackbar('⏰ 1 Minute Left', 'Please review your answers');
      }

      if (timeLeft.value <= 0) {
        timer.cancel();
        submitTest(autoSubmit: true);
      } else {
        timeLeft.value--;
      }
    });
  }

  void selectOption(int optionIndex) {
    selectedAnswers[currentIndex.value] = optionIndex;
  }

  void nextQuestion() {
    if (currentIndex.value < questions.length - 1) {
      currentIndex.value++;
    }
  }

  Future<void> submitTest({bool autoSubmit = false}) async {
    _timer?.cancel();

    double obtainedMarks = 0;
    double totalMarks = 0;
    int correctAnswered = 0;

    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      final double marks = (q['marks'] ?? 1).toDouble();
      totalMarks += marks;

      if (selectedAnswers[i] == q['correctIndex']) {
        obtainedMarks += marks;
        correctAnswered++;
      }
    }

    final int score = totalMarks == 0
        ? 0
        : ((obtainedMarks / totalMarks) * 100).round();
    final double accuracy = questions.isEmpty
        ? 0
        : (correctAnswered / questions.length) * 100;
    final int timeTaken = (duration * 60) - timeLeft.value; // seconds
    final status = score >= 80
        ? 'EXCELLENT'
        : score >= 50
        ? 'GOOD'
        : 'FAILED';

    Get.dialog(
      ResultDialog(
        score: score,
        correct: correctAnswered,
        total: questions.length,
        obtainedMarks: obtainedMarks,
        totalMarks: totalMarks,
      ),
      barrierDismissible: false,
    );

    await _saveAttempt(
      obtainedMarks,
      totalMarks,
      correctAnswered,
      score,
      accuracy,
      timeTaken,
      status,
      autoSubmit,
    );

    // Update attempt limit
    attemptCount.value++;
    isAttemptLimitReached.value = attemptCount.value >= maxAttempts;
  }

  Future<void> _saveAttempt(
    double obtainedMarks,
    double totalMarks,
    int correctAnswered,
    int score,
    double accuracy,
    int timeTaken,
    String status,
    bool autoSubmit,
  ) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userAttemptRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('mock_attempts')
        .doc(testId);

    final snap = await userAttemptRef.get();
    final data = snap.data() ?? {};

    final int attempts = (data['attemptCount'] ?? 0) + 1;
    final double prevBestMarks = (data['bestObtainedMarks'] ?? 0).toDouble();
    final double prevBestAccuracy = (data['bestAccuracy'] ?? 0).toDouble();

    bool isNewBest =
        obtainedMarks > prevBestMarks ||
        (obtainedMarks == prevBestMarks && accuracy > prevBestAccuracy);

    final Map<String, dynamic> updateData = {
      'testId': testId,
      'attemptCount': attempts,
      'totalQuestions': questions.length,
      'lastAttemptScore': score,
      'lastAccuracy': accuracy,
      'lastTimeTaken': timeTaken,
      "correctAnswered": correctAnswered,
      'autoSubmitted': autoSubmit,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (isNewBest || !snap.exists) {
      updateData.addAll({
        'bestObtainedMarks': obtainedMarks,
        'bestTotalMarks': totalMarks,
        'bestScore': score,
        'bestAccuracy': accuracy,
        "correctAnswered": correctAnswered,
        'status': status,
      });

      // 🔥 Update centralized leaderboard
      final leaderboardRef = _firestore
          .collection('test_leaderboard')
          .doc(testId)
          .collection('results')
          .doc(user.uid);

      await leaderboardRef.set({
        'score': score,
        'accuracy': accuracy,
        'timeTaken': timeTaken,
        'submittedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    if (!snap.exists) {
      updateData['createdAt'] = FieldValue.serverTimestamp();
    }

    await userAttemptRef.set(updateData, SetOptions(merge: true));
  }

  Future<void> resetTestAndCloseDialog(BuildContext context) async {
    if (isAttemptLimitReached.value) return;

    if (Get.isDialogOpen ?? false) Navigator.pop(context); // close dialog

    _initializeTest();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
