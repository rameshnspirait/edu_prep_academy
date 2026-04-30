import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  RxBool isLoading = true.obs;

  /// USER BASIC DATA
  RxMap<String, dynamic> userData = <String, dynamic>{}.obs;

  /// STATS
  RxInt totalTests = 0.obs;
  RxDouble accuracy = 0.0.obs;
  RxInt rankPercent = 0.obs; // optional (static or future logic)

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final user = _auth.currentUser;

    if (user == null) return;

    try {
      isLoading.value = true;

      /// ✅ 1. FETCH USER BASIC INFO
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        userData.value = userDoc.data()!;
      }

      /// ✅ 2. FETCH MOCK ATTEMPTS SUBCOLLECTION
      final attemptsSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('mock_attempts')
          .get();

      totalTests.value = attemptsSnapshot.docs.length;

      /// ✅ 3. CALCULATE ACCURACY
      double totalAccuracy = 0;

      for (var doc in attemptsSnapshot.docs) {
        final data = doc.data();

        totalAccuracy += (data['lastAccuracy'] ?? 0).toDouble();
      }

      if (attemptsSnapshot.docs.isNotEmpty) {
        accuracy.value = totalAccuracy / attemptsSnapshot.docs.length;
      } else {
        accuracy.value = 0;
      }

      /// ✅ OPTIONAL RANK (STATIC FOR NOW)
      rankPercent.value = 12;
    } catch (e) {
      print("Profile error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
