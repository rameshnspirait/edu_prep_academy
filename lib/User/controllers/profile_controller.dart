import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_prep_academy/User/controllers/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final authCtrl = Get.find<AuthController>();

  RxBool isLoading = true.obs;

  /// USER DATA
  RxMap<String, dynamic> userData = <String, dynamic>{}.obs;

  /// STATS
  RxInt totalTests = 0.obs;
  RxDouble accuracy = 0.0.obs;
  RxInt rankPercent = 0.obs;
  RxInt userRank = 0.obs;
  RxInt bestScore = 0.obs;
  RxList<Map<String, dynamic>> recentTests = <Map<String, dynamic>>[].obs;

  ///  STREAM SUBSCRIPTION (REAL-TIME)
  StreamSubscription? _attemptsSub;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
    listenMockAttempts();
    calculateRankPosition();
    authCtrl.fetchUserData(); //  fetch user data on profile load
  }

  @override
  void onClose() {
    _attemptsSub?.cancel(); //  prevent memory leak
    super.onClose();
  }

  //================== CALCULATE USER RANK =================
  Future<void> calculateRankPosition() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'student')
        .get();

    /// 🔥 Convert to list
    List<Map<String, dynamic>> users = snapshot.docs.map((doc) {
      final data = doc.data();
      data['uid'] = doc.id;
      return data;
    }).toList();

    /// 🔥 SORT (BEST → WORST)
    users.sort((a, b) {
      double accA = (a['avgAccuracy'] ?? 0).toDouble();
      double accB = (b['avgAccuracy'] ?? 0).toDouble();

      if (accB != accA) return accB.compareTo(accA);

      int testsA = a['totalTests'] ?? 0;
      int testsB = b['totalTests'] ?? 0;

      if (testsB != testsA) return testsB.compareTo(testsA);

      int timeA = a['avgTimeTaken'] ?? 999999;
      int timeB = b['avgTimeTaken'] ?? 999999;

      if (timeA != timeB) return timeA.compareTo(timeB);

      DateTime dateA =
          (a['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
      DateTime dateB =
          (b['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now();

      return dateA.compareTo(dateB);
    });

    /// 🔥 FIND CURRENT USER POSITION
    int index = users.indexWhere((u) => u['uid'] == user.uid);

    if (index != -1) {
      userRank.value = index + 1; // 🔥 Rank starts from 1
    } else {
      userRank.value = 0;
    }
  }

  /// ================= FETCH USER =================
  Future<void> fetchUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      isLoading.value = true;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        userData.value = userDoc.data()!;
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch user profile");
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= REAL-TIME MOCK ATTEMPTS =================
  void listenMockAttempts() {
    final user = _auth.currentUser;
    if (user == null) return;

    _attemptsSub = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('mock_attempts')
        .orderBy('updatedAt', descending: true) //  latest first
        .limit(5) //  only recent 5
        .snapshots()
        .listen((snapshot) {
          totalTests.value = snapshot.docs.length;

          double totalAccuracy = 0;
          int maxScore = 0;

          List<Map<String, dynamic>> tempList = [];

          for (var doc in snapshot.docs) {
            final data = doc.data();

            /// Accuracy
            totalAccuracy += (data['lastAccuracy'] ?? 0).toDouble();

            /// Best Score
            final score = (data['lastScore'] ?? 0).toInt();
            if (score > maxScore) maxScore = score;

            ///  Store for UI
            tempList.add({
              "title": data['testTitle'] ?? "Mock Test",
              "score": score,
              "date": data['updatedAt'],
            });
          }

          /// Assign values
          recentTests.value = tempList;
          bestScore.value = maxScore;

          if (snapshot.docs.isNotEmpty) {
            accuracy.value = totalAccuracy / snapshot.docs.length;
          } else {
            accuracy.value = 0;
          }
        });
  }

  /// ================= MANUAL REFRESH =================
  Future<void> refreshProfile() async {
    await fetchUserProfile();
  }
}
