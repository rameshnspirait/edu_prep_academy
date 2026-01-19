import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_prep_academy/controllers/dashboard_controller.dart';
import 'package:edu_prep_academy/core/constants/app_colors.dart';
import 'package:edu_prep_academy/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:edu_prep_academy/widgets/custom_snackbar.dart';
import '../widgets/custom_alert_dialog.dart';

class AuthController extends GetxController with SingleGetTickerProviderMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// ---------------- TEXT CONTROLLERS ----------------
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  /// ---------------- STATE ----------------
  final isLoading = false.obs;
  final verificationId = ''.obs;

  /// ---------------- OTP RESEND TIMER ----------------
  final otpTimer = 30.obs;
  final canResendOtp = false.obs;
  Timer? _resendTimer;

  /// ---------------- OTP FAILURE & LOCK ----------------
  final otpFailures = 0.obs;
  final isOtpLocked = false.obs;
  final otpLockTimer = 0.obs;
  Timer? _lockTimer;

  /// ---------------- SHAKE ANIMATION ----------------
  late AnimationController shakeController;
  late Animation<double> shakeAnimation;

  @override
  void onInit() {
    super.onInit();

    shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -1, end: 1), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 1),
    ]).animate(shakeController);
  }

  /// ---------------- SEND OTP ----------------
  Future<void> sendOtp() async {
    final phone = phoneController.text.trim();

    /// ❌ EMPTY
    if (phone.isEmpty) {
      CustomSnackbar.show(
        title: 'Error',
        message: 'Please enter your mobile number',
        type: SnackbarType.error,
      );
      return;
    }

    /// ❌ INVALID LENGTH
    if (phone.length != 10) {
      CustomSnackbar.show(
        title: 'Invalid Number',
        message: 'Mobile number must be 10 digits',
        type: SnackbarType.warning,
      );
      return;
    }

    isLoading.value = true;

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: '+91$phone',

        /// AUTO VERIFY
        verificationCompleted: (credential) async {
          await _auth.signInWithCredential(credential);
        },

        /// FIREBASE ERRORS
        verificationFailed: (FirebaseAuthException e) {
          isLoading.value = false;

          String message = 'OTP verification failed';

          if (e.code == 'invalid-phone-number') {
            message = 'Invalid mobile number';
          } else if (e.code == 'too-many-requests') {
            message = 'Too many attempts. Try again later';
          } else if (e.message != null) {
            message = e.message!;
          }

          CustomSnackbar.show(
            title: 'Error',
            message: message,
            type: SnackbarType.error,
          );
        },

        /// OTP SENT
        codeSent: (id, _) {
          verificationId.value = id;
          startResendTimer();
          isLoading.value = false;

          CustomSnackbar.show(
            title: 'OTP Sent',
            message: 'OTP has been sent to your mobile number',
            type: SnackbarType.success,
          );
        },

        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (_) {
      isLoading.value = false;
      CustomSnackbar.show(
        title: 'Error',
        message: 'Something went wrong. Please try again',
        type: SnackbarType.error,
      );
    }
  }

  /// ---------------- VERIFY OTP ----------------
  Future<void> verifyOtp() async {
    if (isOtpLocked.value) {
      CustomSnackbar.show(
        title: 'OTP Locked',
        message: 'Try again in ${otpLockTimer.value}s',
        type: SnackbarType.warning,
      );
      return;
    }

    if (otpController.text.length != 6) {
      onOtpError();
      return;
    }

    try {
      isLoading.value = true;

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: otpController.text,
      );

      // ✅ Sign in user
      final userCredential = await _auth.signInWithCredential(credential);

      final user = userCredential.user;
      if (user == null) return;

      // ✅ Save user to Firestore
      await _saveUserToFirestore(user);

      /// SUCCESS
      otpFailures.value = 0;
      isOtpLocked.value = false;
      otpController.clear();

      CustomSnackbar.show(
        title: 'Success',
        message: 'OTP verified successfully',
        type: SnackbarType.success,
      );

      Get.offAllNamed(AppRoutes.dashboard);
    } on FirebaseAuthException {
      onOtpError();
    } finally {
      isLoading.value = false;
    }
  }

  ///Save Users data to firebase firestore
  Future<void> _saveUserToFirestore(User user) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    final docSnap = await docRef.get();

    if (!docSnap.exists) {
      await docRef.set({
        'uid': user.uid,
        'phone': user.phoneNumber,
        'role': 'student',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// ---------------- OTP ERROR ----------------
  void onOtpError() {
    otpFailures.value++;

    /// 🔊 HAPTIC
    HapticFeedback.heavyImpact();

    /// 🔁 SHAKE
    shakeController.forward(from: 0);

    /// 🔄 CLEAR
    otpController.clear();

    CustomSnackbar.show(
      title: 'Invalid OTP',
      message: 'Please enter the correct OTP',
      type: SnackbarType.error,
    );

    /// 🔒 LOCK AFTER 3 FAILURES
    if (otpFailures.value >= 3) {
      lockOtp();
    }
  }

  /// ---------------- LOCK OTP ----------------
  void lockOtp() {
    isOtpLocked.value = true;
    otpLockTimer.value = 30;

    CustomSnackbar.show(
      title: 'OTP Locked',
      message: 'Too many failed attempts. Try again in 30 seconds',
      type: SnackbarType.warning,
    );

    _lockTimer?.cancel();
    _lockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      otpLockTimer.value--;

      if (otpLockTimer.value <= 0) {
        timer.cancel();
        isOtpLocked.value = false;
        otpFailures.value = 0;
      }
    });
  }

  /// ---------------- RESEND TIMER ----------------
  void startResendTimer() {
    otpTimer.value = 30;
    canResendOtp.value = false;

    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      otpTimer.value--;
      if (otpTimer.value == 0) {
        timer.cancel();
        canResendOtp.value = true;
      }
    });
  }

  /// ---------------- RESEND OTP ----------------
  void resendOtp() {
    if (!canResendOtp.value) return;
    sendOtp();
  }

  /// ---------------- RESET ----------------
  void resetAuthFields() {
    phoneController.clear();
    otpController.clear();
    verificationId.value = '';
    otpFailures.value = 0;
    isOtpLocked.value = false;
    otpLockTimer.value = 0;
  }

  /// ---------------- LOGOUT ----------------
  Future<void> logout() async {
    final confirmed = await CustomAlertDialog.showConfirmation(
      confirmColor: AppColors.errorRed,
      title: 'Confirm Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Yes',
      cancelText: 'No',
    );

    if (!confirmed) return;

    // 🔥 DELETE DASHBOARD CONTROLLER
    if (Get.isRegistered<DashboardController>()) {
      Get.delete<DashboardController>(force: true);
    }

    await _auth.signOut();
    resetAuthFields();

    CustomSnackbar.show(
      title: 'Logged out',
      message: 'You have been logged out successfully',
      type: SnackbarType.info,
    );

    // 🚀 Remove all routes
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    shakeController.dispose();
    _resendTimer?.cancel();
    _lockTimer?.cancel();
    super.onClose();
  }
}
