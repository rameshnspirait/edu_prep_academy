import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_prep_academy/User/views/profile/help_support_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class HelpSupportController extends GetxController {
  RxBool isLoading = false.obs;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final RxList<Map<String, dynamic>> tickets = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, String>> faqs = <Map<String, String>>[].obs;
  final RxList<Map<String, dynamic>> userTickets = <Map<String, dynamic>>[].obs;

  /// ================= STATE =================
  final RxList<String> categories = <String>[].obs;
  final RxList<String> priorities = <String>[].obs;

  final RxString selectedCategory = ''.obs;
  final RxString selectedPriority = ''.obs;
  //==================CONTROLLER METHODS===================
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  @override
  void onInit() {
    loadDummyFaqs();
    loadConfig();
    fetchUserTickets();
    super.onInit();
  }

  /// ================= LOAD CONFIG =================
  Future<void> loadConfig() async {
    try {
      final doc = await _firestore
          .collection('help_support')
          .doc('config')
          .collection('settings')
          .doc('main')
          .get();

      if (doc.exists) {
        final data = doc.data() ?? {};

        categories.value = List<String>.from(data['categories'] ?? []);
        priorities.value = List<String>.from(data['priorities'] ?? []);

        ///  SET DEFAULT VALUES
        if (categories.isNotEmpty) {
          selectedCategory.value = categories.first;
        }

        if (priorities.isNotEmpty) {
          selectedPriority.value = priorities.first;
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load config");
    }
  }

  /// ================= CREATE TICKET =================
  Future<void> submitTicket() async {
    if (titleCtrl.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter a title for your ticket",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (descCtrl.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please provide a description of your issue",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      final user = _auth.currentUser;
      if (user == null) return;

      final docRef = _firestore
          .collection('help_support')
          .doc('tickets')
          .collection('items')
          .doc();

      await docRef.set({
        "ticketId": docRef.id,
        "userId": user.uid,
        "title": titleCtrl.text.trim(),
        "description": descCtrl.text.trim(),
        "category": selectedCategory.value,
        "priority": selectedPriority.value,
        "status": "open",
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });

      /// ✅ CLEAR FORM
      titleCtrl.clear();
      descCtrl.clear();

      /// ✅ REFRESH TICKETS LIST
      await fetchUserTickets();

      /// ✅ SUCCESS MESSAGE
      Get.snackbar(
        "Success",
        "Ticket submitted successfully",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      /// ✅ NAVIGATE BACK (Help & Support)
      Get.off(() => HelpSupportView());
      // OR if you want force:
      // Get.off(() => HelpSupportView());
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to submit ticket",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void loadDummyFaqs() {
    isLoading.value = true;

    faqs.assignAll([
      {
        "question": "How do I reset my password?",
        "answer":
            "Go to Login screen → click Forgot Password → enter registered mobile number → verify OTP → set new password.",
        "category": "Account",
      },
      {
        "question": "How to download notes for offline use?",
        "answer":
            "Open any PDF note → click download icon → it will be saved in 'Downloaded Notes' section.",
        "category": "Downloads",
      },
      {
        "question": "Why is my mock test locked?",
        "answer":
            "Some tests are premium. You need subscription or admin access to unlock them.",
        "category": "Tests",
      },
      {
        "question": "How is my rank calculated?",
        "answer":
            "Rank is calculated based on accuracy, speed, and overall test performance compared with other users.",
        "category": "Performance",
      },
      {
        "question": "How to change app theme?",
        "answer":
            "Go to Profile → Toggle Dark Mode switch → theme will change instantly.",
        "category": "App Settings",
      },
      {
        "question": "Can I retake a mock test?",
        "answer":
            "Yes, but some tests have attempt limits (usually 3 attempts per 24 hours).",
        "category": "Tests",
      },
    ]);

    isLoading.value = false;
  }

  /// ================= STATE =================

  /// ================= CREATE TICKET =================
  Future<void> createTicket({
    required String title,
    required String description,
    required String category,
    required String priority,
  }) async {
    try {
      isLoading.value = true;

      final user = _auth.currentUser;
      if (user == null) return;

      final docRef = _firestore
          .collection('help_support')
          .doc('tickets')
          .collection('items')
          .doc();

      await docRef.set({
        "ticketId": docRef.id,
        "userId": user.uid,
        "userEmail": user.email ?? "",
        "title": title,
        "description": description,
        "category": category,
        "priority": priority,

        "status": "open",

        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });

      await fetchUserTickets();
    } catch (e) {
      Get.snackbar("Error", "Failed to create ticket: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= FETCH USER TICKETS =================
  Future<void> fetchUserTickets() async {
    try {
      isLoading.value = true;

      final user = _auth.currentUser;
      if (user == null) return;

      final snapshot = await _firestore
          .collection('help_support')
          .doc('tickets')
          .collection('items')
          .where("userId", isEqualTo: user.uid)
          .get();

      userTickets.value = snapshot.docs.map((doc) {
        final data = doc.data();
        return {"ticketId": doc.id, ...data};
      }).toList();
    } catch (e) {
      Get.snackbar("Error", "Failed to load tickets: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= UPDATE STATUS (ADMIN) =================
  Future<void> updateTicketStatus({
    required String ticketId,
    required String status, // open, in_progress, resolved, closed
  }) async {
    try {
      await _firestore
          .collection('help_support')
          .doc('tickets')
          .collection('items')
          .doc(ticketId)
          .update({
            "status": status,
            "updatedAt": FieldValue.serverTimestamp(),
          });

      await fetchUserTickets();
    } catch (e) {
      Get.snackbar("Error", "Failed to update status");
    }
  }

  /// ================= DELETE TICKET =================
  Future<void> deleteTicket(String ticketId) async {
    try {
      await _firestore
          .collection('help_support')
          .doc('tickets')
          .collection('items')
          .doc(ticketId)
          .delete();

      tickets.removeWhere((t) => t["ticketId"] == ticketId);
    } catch (e) {
      Get.snackbar("Error", "Failed to delete ticket");
    }
  }

  /// ================= REFRESH =================
  Future<void> refreshTickets() async {
    await fetchUserTickets();
  }
}
