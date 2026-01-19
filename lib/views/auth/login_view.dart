import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter/services.dart';

import 'package:edu_prep_academy/controllers/auth_controller.dart';
import 'package:edu_prep_academy/core/constants/app_colors.dart';
import 'package:edu_prep_academy/core/constants/app_strings.dart';
import 'package:edu_prep_academy/core/theme/theme_controller.dart';
import 'package:edu_prep_academy/core/theme/app_text_style.dart';
import 'package:edu_prep_academy/widgets/app_button.dart';
import 'package:edu_prep_academy/widgets/app_text_field.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();
    final isDark = themeCtrl.isDarkMode.value;

    return WillPopScope(
      onWillPop: () async {
        controller.resetAuthFields();
        return true;
      },
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.grey[100],
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Obx(() {
                final isOtpSent = controller.verificationId.isNotEmpty;
                final isLocked = controller.isOtpLocked.value;

                return Column(
                  children: [
                    const SizedBox(height: 40),

                    /// ---------------- LOGO ----------------
                    Container(
                      height: 88,
                      width: 88,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                            color: Colors.black.withOpacity(0.15),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        size: 44,
                        color: AppColors.primaryBlue,
                      ),
                    ),

                    const SizedBox(height: 28),

                    /// ---------------- TITLE ----------------
                    Text(
                      isOtpSent
                          ? AppStrings.verifyOtpTitle
                          : AppStrings.welcomeTitle,
                      style: AppTextStyles.headingLarge(context),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      isOtpSent
                          ? AppStrings.verifyOtpSubtitle
                          : AppStrings.welcomeSubtitle,
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        color: isDark ? Colors.white70 : Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 36),

                    /// ---------------- CARD ----------------
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                            color: Colors.black.withOpacity(0.12),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          if (!isOtpSent) ...[
                            /// ---------------- PHONE INPUT ----------------
                            AppTextField(
                              label: AppStrings.mobileNumber,
                              controller: controller.phoneController,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              hintText: AppStrings.mobileHint,
                              prefix: SizedBox(
                                width: 48,
                                child: Center(
                                  child: Text(
                                    AppStrings.countryCode,
                                    style: AppTextStyles.bodyMedium(
                                      context,
                                    ).copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            AppButton(
                              title: AppStrings.sendOtp,
                              isLoading: controller.isLoading.value,
                              onPressed: controller.sendOtp,
                            ),
                          ] else ...[
                            /// ---------------- PIN INPUT ----------------
                            AnimatedBuilder(
                              animation: controller.shakeAnimation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(
                                    controller.shakeAnimation.value * 8,
                                    0,
                                  ),
                                  child: child,
                                );
                              },
                              child: Pinput(
                                controller: controller.otpController,
                                length: 6,
                                autofocus: true,
                                enabled: !isLocked,
                                keyboardType: TextInputType.number,
                                onCompleted: (_) {
                                  if (!isLocked) {
                                    controller.verifyOtp();
                                  } else {
                                    HapticFeedback.heavyImpact();
                                  }
                                },
                                defaultPinTheme: _pinTheme(context, isDark),
                                focusedPinTheme: _pinTheme(
                                  context,
                                  isDark,
                                  focused: true,
                                ),
                                submittedPinTheme: _pinTheme(
                                  context,
                                  isDark,
                                  submitted: true,
                                ),
                                separatorBuilder: (_) =>
                                    const SizedBox(width: 10),
                              ),
                            ),

                            const SizedBox(height: 12),

                            /// ---------------- LOCK MESSAGE ----------------
                            if (isLocked)
                              Text(
                                "Too many wrong attempts.\nTry again in ${controller.otpLockTimer.value}s",
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodySmall(
                                  context,
                                ).copyWith(color: Colors.redAccent),
                              ),

                            const SizedBox(height: 24),

                            AppButton(
                              title: AppStrings.verifyContinue,
                              isLoading: controller.isLoading.value,
                              onPressed: isLocked ? null : controller.verifyOtp,
                            ),

                            const SizedBox(height: 20),

                            /// ---------------- RESEND ----------------
                            if (!isLocked)
                              Obx(() {
                                if (!controller.canResendOtp.value) {
                                  return Text(
                                    "${AppStrings.resendOtpIn} ${controller.otpTimer.value}s",
                                    style: AppTextStyles.bodySmall(context)
                                        .copyWith(
                                          color: isDark
                                              ? Colors.white60
                                              : Colors.grey[600],
                                        ),
                                  );
                                }

                                return TextButton(
                                  onPressed: controller.resendOtp,
                                  child: Text(
                                    AppStrings.resendOtp,
                                    style: AppTextStyles.bodyMedium(context)
                                        .copyWith(
                                          color: AppColors.primaryBlue,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                );
                              }),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    if (!isOtpSent)
                      Text(
                        AppStrings.termsText,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption(context).copyWith(
                          color: isDark ? Colors.white60 : Colors.grey.shade600,
                        ),
                      ),

                    const SizedBox(height: 40),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  /// ---------------- PIN THEME ----------------
  PinTheme _pinTheme(
    BuildContext context,
    bool isDark, {
    bool focused = false,
    bool submitted = false,
  }) {
    return PinTheme(
      width: 52,
      height: 56,
      textStyle: AppTextStyles.headingMedium(context),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: focused || submitted
              ? AppColors.primaryBlue
              : Colors.grey.shade400,
          width: focused ? 2 : 1,
        ),
      ),
    );
  }
}
