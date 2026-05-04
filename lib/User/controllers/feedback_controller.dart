import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FeedbackController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final messageCtrl = TextEditingController();

  var rating = 0.obs;
  var selectedCategory = "General".obs;
  var selectedEmoji = "😊".obs;
  var isLoading = false.obs;

  final categories = ["General", "Bug", "UI/UX", "Content", "Performance"];

  Future<void> submitFeedback() async {
    if (rating.value == 0) {
      Get.snackbar("Error", "Please give a rating");
      return;
    }

    if (messageCtrl.text.isEmpty) {
      Get.snackbar("Error", "Please write feedback");
      return;
    }

    try {
      isLoading.value = true;

      final user = _auth.currentUser;
      if (user == null) return;

      final docRef = _firestore
          .collection('feedback')
          .doc('items')
          .collection('data')
          .doc();

      await docRef.set({
        "feedbackId": docRef.id,
        "userId": user.uid,
        "rating": rating.value,
        "message": messageCtrl.text.trim(),
        "category": selectedCategory.value,
        "emoji": selectedEmoji.value,
        "createdAt": FieldValue.serverTimestamp(),
      });

      /// clear
      rating.value = 0;
      messageCtrl.clear();

      Get.back();

      Get.snackbar(
        "Thank You ❤️",
        "Your feedback helps us improve!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to submit feedback");
    } finally {
      isLoading.value = false;
    }
  }
}
