import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController extends GetxController {
  /// ---------------- INSTANCES ----------------
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ---------------- TEXT CONTROLLERS ----------------
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  /// ---------------- STATES ----------------
  var isLoading = false.obs;
  var isLoginMode = true.obs;

  var name = "".obs;
  var email = "".obs;

  // var totalTests = 0.obs;
  // var accuracy = 0.0.obs;
  // var userRank = 0.obs;

  /// ---------------- SWITCH MODE ----------------
  void toggleAuthMode() {
    isLoginMode.value = !isLoginMode.value;
    clearFields();
  }

  void clearFields() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
  }

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      isLoading.value = true;

      final uid = FirebaseAuth.instance.currentUser!.uid;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        name.value = doc['name'] ?? "User";
        email.value = doc['email'] ?? "";
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load profile");
    } finally {
      isLoading.value = false;
    }
  }

  /// ---------------- EMAIL AUTH ----------------
  Future<void> submit() async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        (!isLoginMode.value && nameController.text.isEmpty)) {
      Get.snackbar("Error", "Please fill all fields");
      return;
    }

    try {
      isLoading.value = true;

      if (isLoginMode.value) {
        /// LOGIN
        await _auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        Get.snackbar("Success", "Login Successful");
      } else {
        /// REGISTER
        final userCred = await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        final user = userCred.user!;

        /// Save in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          "name": nameController.text.trim(),
          "email": emailController.text.trim(),
          "role": "student",
          "coins": 0,
          "createdAt": DateTime.now(),
        });

        Get.snackbar("Success", "Account Created");
      }

      Get.offAllNamed('/dashboard');
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.message ?? "Auth Failed");
    } finally {
      isLoading.value = false;
    }
  }

  /// ---------------- GOOGLE SIGN IN ----------------
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      final user = userCredential.user!;

      /// Save user
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          "name": user.displayName ?? "",
          "email": user.email,
          "role": "student",
          "coins": 0,
          "createdAt": DateTime.now(),
        });
      }

      Get.offAllNamed('/dashboard');
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// ---------------- LOGOUT ----------------

  Future<void> logout() async {
    try {
      isLoading.value = true;

      await _auth.signOut();

      /// SAFE GOOGLE LOGOUT
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
