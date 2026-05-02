import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  RxBool isLoading = true.obs;

  /// USER DATA
  RxMap<String, dynamic> userData = <String, dynamic>{}.obs;

  /// STATS
  RxInt totalTests = 0.obs;
  RxDouble accuracy = 0.0.obs;
  RxInt rankPercent = 0.obs;

  ///  STREAM SUBSCRIPTION (REAL-TIME)
  StreamSubscription? _attemptsSub;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
    listenMockAttempts(); //  real-time updates
  }

  @override
  void onClose() {
    _attemptsSub?.cancel(); //  prevent memory leak
    super.onClose();
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

      /// OPTIONAL STATIC RANK (can be dynamic later)
      rankPercent.value = 12;
    } catch (e) {
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
        .snapshots()
        .listen((snapshot) {
          totalTests.value = snapshot.docs.length;

          double totalAccuracy = 0;

          for (var doc in snapshot.docs) {
            final data = doc.data();

            totalAccuracy += (data['lastAccuracy'] ?? 0).toDouble();
          }

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
