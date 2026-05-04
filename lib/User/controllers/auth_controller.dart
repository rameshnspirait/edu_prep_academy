import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController extends GetxController {
  /// ---------------- INSTANCES ----------------
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// ---------------- TEXT CONTROLLERS ----------------
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  /// ---------------- STATES ----------------
  var isLoading = false.obs;
  var isLoginMode = true.obs;

  var name = "".obs;
  var email = "".obs;

  /// ---------------- ERROR STATES ----------------
  var nameError = RxnString();
  var emailError = RxnString();
  var passwordError = RxnString();

  /// ---------------- VALIDATE LIVE ----------------
  void validateNameLive(String value) {
    if (value.trim().isEmpty) {
      nameError.value = "Full name is required";
    } else if (value.length < 3) {
      nameError.value = "Minimum 3 characters";
    } else {
      nameError.value = null;
    }
  }

  void validateEmailLive(String value) {
    if (value.trim().isEmpty) {
      emailError.value = "Email is required";
    } else if (!GetUtils.isEmail(value.trim())) {
      emailError.value = "Invalid email";
    } else {
      emailError.value = null;
    }
  }

  void validatePasswordLive(String value) {
    if (value.isEmpty) {
      passwordError.value = "Password required";
    } else if (value.length < 6) {
      passwordError.value = "Min 6 characters";
    } else {
      passwordError.value = null;
    }
  }

  /// ---------------- VALIDATION ----------------
  String? validateName(String value) {
    if (value.trim().isEmpty) return "Full name is required";
    if (value.length < 3) return "Name must be at least 3 characters";
    return null;
  }

  String? validateEmail(String value) {
    if (value.trim().isEmpty) return "Email is required";

    if (!GetUtils.isEmail(value.trim())) {
      return "Enter a valid email";
    }
    return null;
  }

  String? validatePassword(String value) {
    if (value.isEmpty) return "Password is required";
    if (value.length < 6) return "Password must be at least 6 characters";
    return null;
  }

  /// ---------------- SWITCH MODE ----------------
  void toggleAuthMode() {
    isLoginMode.value = !isLoginMode.value;
    resetForm();
  }

  /// ---------------- FETCH USER ----------------
  Future<void> fetchUserData() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        name.value = doc['name'] ?? "User";
        email.value = doc['email'] ?? "";
      }
    } catch (_) {
      Get.snackbar("Error", "Failed to load profile");
    }
  }

  /// ---------------- EMAIL AUTH ----------------
  Future<void> submit() async {
    final nameError = validateName(nameController.text);
    final emailError = validateEmail(emailController.text);
    final passError = validatePassword(passwordController.text);

    /// Validate fields
    if (!isLoginMode.value && nameError != null) {
      Get.snackbar("Validation", nameError);
      return;
    }
    if (emailError != null) {
      Get.snackbar("Validation", emailError);
      return;
    }
    if (passError != null) {
      Get.snackbar("Validation", passError);
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

        await _firestore.collection('users').doc(user.uid).set({
          "name": nameController.text.trim(),
          "email": emailController.text.trim(),
          "role": "student",
          "coins": 0,
          "createdAt": FieldValue.serverTimestamp(),
        });

        Get.snackbar("Success", "Account Created");
      }
      await fetchUserData();
      resetForm();
      Get.offAllNamed('/dashboard');
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", _handleAuthError(e));
    } catch (_) {
      Get.snackbar("Error", "Something went wrong");
    } finally {
      isLoading.value = false;
    }
  }

  /// ---------------- GOOGLE SIGN IN ----------------
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        Get.snackbar("Cancelled", "Google sign-in cancelled");
        return;
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      final user = userCredential.user!;

      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (!doc.exists) {
        await _firestore.collection('users').doc(user.uid).set({
          "name": user.displayName ?? "",
          "email": user.email,
          "role": "student",
          "coins": 0,
          "createdAt": FieldValue.serverTimestamp(),
        });
      }
      await fetchUserData();

      Get.offAllNamed('/dashboard');
    } catch (_) {
      Get.snackbar("Error", "Google Sign-In failed");
    } finally {
      isLoading.value = false;
    }
  }

  /// ---------------- LOGOUT ----------------
  Future<void> logout() async {
    try {
      isLoading.value = true;

      await _auth.signOut();

      try {
        await _googleSignIn.signOut();
      } catch (_) {}

      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar("Error", "Logout failed");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> showLogoutDialog() async {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.logout_rounded,
                size: 50,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 12),

              const Text(
                "Logout Confirmation",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              const Text(
                "Are you sure you want to logout from your account?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Get.back(); // close dialog
                        logout(); // call actual logout
                      },
                      child: const Text("Logout"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  //================Reset Form=============
  void resetForm() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();

    /// reset validation errors
    nameError.value = null;
    emailError.value = null;
    passwordError.value = null;
  }

  /// ---------------- ERROR HANDLER ----------------
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return "No user found with this email";
      case 'wrong-password':
        return "Incorrect password";
      case 'email-already-in-use':
        return "Email already registered";
      case 'invalid-email':
        return "Invalid email format";
      case 'weak-password':
        return "Password is too weak";
      case 'network-request-failed':
        return "Check your internet connection";
      case 'invalid-credential':
        return "Invalid email or password";
      default:
        return "Authentication failed";
    }
  }
}
