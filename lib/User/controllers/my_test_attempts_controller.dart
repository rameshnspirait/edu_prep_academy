// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:get/get.dart';

// class MyTestAttemptsController extends GetxController {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final String uid = FirebaseAuth.instance.currentUser!.uid;

//   /// ================= STATE =================
//   var isLoading = true.obs;
//   var attempts = <Map<String, dynamic>>[].obs;

//   /// ================= ANALYTICS =================
//   var userRank = 0.obs;
//   var averageAccuracy = 0.0.obs;
//   var totalAttempts = 0.obs;
//   var bestScore = 0.obs;

//   /// ================= CHART =================
//   var accuracyTrend = <double>[].obs;

//   /// ================= WEAK TOPICS =================
//   var weakTests = <String>[].obs;

//   /// ================= ERROR =================
//   var error = "".obs;

//   StreamSubscription? _subscription;

//   @override
//   void onInit() {
//     super.onInit();
//     fetchAttempts();
//   }

//   @override
//   void onClose() {
//     _subscription?.cancel(); // ✅ prevent memory leak
//     super.onClose();
//   }

//   /// ================= FETCH =================
//   void fetchAttempts() {
//     isLoading.value = true;
//     error.value = "";

//     _subscription?.cancel(); // cancel previous

//     _subscription = _firestore
//         .collection('users')
//         .doc(uid)
//         .collection('mock_attempts')
//         .orderBy('updatedAt', descending: true)
//         .snapshots()
//         .listen(
//           (snapshot) {
//             final data = snapshot.docs.map((doc) {
//               final d = doc.data();

//               return {
//                 "testId": d['testId'] ?? "",
//                 "testName": d['testTitle'] ?? "Mock Test",

//                 /// 🔥 IMPORTANT: UI compatible keys
//                 "obtainedMarks": d['lastScore'] ?? 0,
//                 "totalMarks": d['totalQuestions'] ?? 0,
//                 "accuracy": (d['lastAccuracy'] ?? 0).toDouble(),

//                 "correct": d['correct'] ?? 0,
//                 "wrong": d['wrong'] ?? 0,
//                 "attemptCount": d['attemptCount'] ?? 1,
//                 "timeTaken": d['timeTaken'] ?? 0,
//                 "updatedAt": d['updatedAt'] ?? Timestamp.now(),
//               };
//             }).toList();

//             attempts.assignAll(data);

//             _calculateAnalytics();

//             isLoading.value = false;
//           },
//           onError: (e) {
//             error.value = "Failed to load attempts";
//             isLoading.value = false;
//           },
//         );
//   }

//   /// ================= ANALYTICS =================
//   void _calculateAnalytics() {
//     if (attempts.isEmpty) return;

//     totalAttempts.value = attempts.length;

//     double totalAcc = 0;
//     int maxScore = 0;

//     List<double> trend = [];
//     List<String> weak = [];

//     for (var a in attempts) {
//       final acc = (a['accuracy'] ?? 0).toDouble();
//       final score = (a['obtainedMarks'] ?? 0) as int;

//       totalAcc += acc;
//       trend.add(acc);

//       if (score > maxScore) maxScore = score;

//       /// 🔥 Weak detection (<50%)
//       if (acc < 50) {
//         weak.add(a['testName']);
//       }
//     }

//     averageAccuracy.value = totalAcc / attempts.length;
//     bestScore.value = maxScore;
//     accuracyTrend.assignAll(trend.take(10).toList());
//     weakTests.assignAll(weak.toSet().toList());

//     _calculateRank();
//   }

//   /// ================= RANK =================
//   void _calculateRank() {
//     final acc = averageAccuracy.value;

//     /// 🎯 MOCK RANK LOGIC (Replace with leaderboard later)
//     if (acc >= 85) {
//       userRank.value = 1;
//     } else if (acc >= 75) {
//       userRank.value = 5;
//     } else if (acc >= 65) {
//       userRank.value = 15;
//     } else if (acc >= 50) {
//       userRank.value = 30;
//     } else {
//       userRank.value = 50;
//     }
//   }

//   /// ================= REFRESH =================
//   Future<void> refreshAttempts() async {
//     fetchAttempts();
//   }

//   /// ================= HELPERS =================
//   String formatDate(Timestamp timestamp) {
//     final date = timestamp.toDate();
//     return "${date.day}/${date.month}/${date.year}";
//   }
// }
