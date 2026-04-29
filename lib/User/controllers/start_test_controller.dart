import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_prep_academy/User/views/mocks/result_dialog.dart';
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
  late String categoryId; // ✅ NEW
  late int duration;

  static const int maxAttempts = 3;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

    if (args == null ||
        !args.containsKey('testId') ||
        !args.containsKey('duration') ||
        !args.containsKey('categoryId')) {
      Get.back();
      return;
    }

    testId = args['testId'];
    duration = args['duration'];
    categoryId = args['categoryId']; // ✅ FIXED

    _checkAttemptsThenInit();
  }

  // ================= ATTEMPT CHECK =================
  Future<void> _checkAttemptsThenInit() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('mock_attempts')
        .doc(testId);

    final snap = await docRef.get();
    final data = snap.data();

    final attempts = data?['attemptCount'] ?? 0;
    final Timestamp? last = data?['updatedAt'];

    attemptCount.value = attempts;

    /// ✅ 24H LOGIC
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

    /// ✅ ALLOW TEST
    isAttemptLimitReached.value = false;
    _initializeTest();
  }

  // ================= INIT =================
  void _initializeTest() {
    _timer?.cancel();

    selectedAnswers.clear();
    currentIndex.value = 0;
    isPaused.value = false;
    warningShown.value = false;

    timeLeft.value = duration * 60;

    _loadTest();
  }

  // ================= LOAD QUESTIONS =================
  Future<void> _loadTest() async {
    try {
      isLoading.value = true;

      final snapshot = await _firestore
          .collection('mock_tests')
          .doc(categoryId) // ✅ FIXED
          .collection('tests')
          .doc(testId)
          .collection('questions')
          .orderBy('createdAt')
          .get();

      /// ❗ SAFETY CHECK
      if (snapshot.docs.isEmpty) {
        isLoading.value = false;

        Get.snackbar(
          "Error",
          "No questions found for this test",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );

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
            'explanation': data['explanation'] ?? '',
            'marks': data['marks'] ?? 1,
          };
        }).toList(),
      );

      _startTimer();
    } catch (e) {
      print("Error loading questions: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ================= TIMER =================
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

  // ================= ANSWERS =================
  void selectOption(int optionIndex) {
    selectedAnswers[currentIndex.value] = optionIndex;
  }

  void nextQuestion() {
    if (currentIndex.value < questions.length - 1) {
      currentIndex.value++;
    }
  }

  // ================= SUBMIT =================
  Future<void> submitTest({bool autoSubmit = false}) async {
    _timer?.cancel();

    double obtainedMarks = 0;
    double totalMarks = 0;
    int correctAnswered = 0;
    int wrongAnswered = 0;

    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      final double marks = (q['marks'] ?? 1).toDouble();
      totalMarks += marks;

      if (selectedAnswers.containsKey(i)) {
        if (selectedAnswers[i] == q['correctIndex']) {
          obtainedMarks += marks;
          correctAnswered++;
        } else {
          wrongAnswered++;
        }
      }
    }

    final int score = totalMarks == 0
        ? 0
        : ((obtainedMarks / totalMarks) * 100).round();

    final double accuracy = questions.isEmpty
        ? 0
        : (correctAnswered / questions.length) * 100;

    final int timeTaken = (duration * 60) - timeLeft.value;

    final status = score >= 80
        ? 'EXCELLENT'
        : score >= 50
        ? 'GOOD'
        : 'FAILED';

    /// 🎯 RESULT DIALOG
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

    /// 💾 SAVE
    await _saveAttempt(
      obtainedMarks,
      totalMarks,
      correctAnswered,
      wrongAnswered,
      score,
      accuracy,
      timeTaken,
      status,
      autoSubmit,
    );

    attemptCount.value++;
    isAttemptLimitReached.value = attemptCount.value >= maxAttempts;
  }

  // ================= SAVE ATTEMPT =================
  Future<void> _saveAttempt(
    double obtainedMarks,
    double totalMarks,
    int correctAnswered,
    int wrongAnswered,
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
      'correctAnswered': correctAnswered,
      'wrongAnswered': wrongAnswered,
      'autoSubmitted': autoSubmit,
      'updatedAt': FieldValue.serverTimestamp(), // ✅ IMPORTANT
    };

    if (isNewBest || !snap.exists) {
      updateData.addAll({
        'bestObtainedMarks': obtainedMarks,
        'bestTotalMarks': totalMarks,
        'bestScore': score,
        'bestAccuracy': accuracy,
        'bestTimeTaken': timeTaken,
        'status': status,
      });
    }

    if (!snap.exists) {
      updateData['createdAt'] = FieldValue.serverTimestamp();
    }

    await userAttemptRef.set(updateData, SetOptions(merge: true));

    final attemptHistoryRef = userAttemptRef.collection('history').doc();

    await attemptHistoryRef.set({
      'score': score,
      'accuracy': accuracy,
      'correctAnswered': correctAnswered,
      'wrongAnswered': wrongAnswered,
      'timeTaken': timeTaken,
      'status': status,
      'autoSubmitted': autoSubmit,
      'submittedAt': FieldValue.serverTimestamp(),
    });
  }

  // ================= RESET =================
  Future<void> resetTestAndCloseDialog(BuildContext context) async {
    if (isAttemptLimitReached.value) return;

    if (Get.isDialogOpen ?? false) Navigator.pop(context);

    _initializeTest();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
