import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminFaqController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final jsonController = TextEditingController();

  var isLoading = false.obs;
  var faqs = <Map<String, dynamic>>[].obs;

  /// ================= FETCH FAQ =================
  Future<void> fetchFaqs() async {
    try {
      isLoading.value = true;

      final snapshot = await _firestore
          .collection('help_support')
          .doc('faq')
          .collection('items')
          .orderBy("createdAt", descending: true)
          .get();

      faqs.value = snapshot.docs.map((doc) {
        return {"id": doc.id, ...doc.data()};
      }).toList();
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch FAQs");
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= BULK UPLOAD =================
  Future<void> uploadBulkFaq() async {
    try {
      if (jsonController.text.isEmpty) {
        Get.snackbar("Error", "Please paste JSON data");
        return;
      }

      isLoading.value = true;

      final List<dynamic> data = jsonDecode(jsonController.text);

      final batch = _firestore.batch();

      for (var item in data) {
        final docRef = _firestore
            .collection('help_support')
            .doc('faq')
            .collection('items')
            .doc();

        batch.set(docRef, {
          "question": item['question'],
          "answer": item['answer'],
          "category": item['category'] ?? "General",
          "createdAt": FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      jsonController.clear();

      Get.snackbar("Success", "FAQs uploaded successfully");

      await fetchFaqs();
    } catch (e) {
      Get.snackbar("Error", "Invalid JSON format");
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= DELETE SINGLE =================
  Future<void> deleteFaq(String id) async {
    await _firestore
        .collection('help_support')
        .doc('faq')
        .collection('items')
        .doc(id)
        .delete();

    fetchFaqs();
  }

  /// ================= DELETE ALL =================
  Future<void> deleteAllFaqs() async {
    try {
      isLoading.value = true;

      final snapshot = await _firestore
          .collection('help_support')
          .doc('faq')
          .collection('items')
          .get();

      final batch = _firestore.batch();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      Get.snackbar("Success", "All FAQs deleted");

      faqs.clear();
    } catch (e) {
      Get.snackbar("Error", "Failed to delete FAQs");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    fetchFaqs();
    super.onInit();
  }
}
