import 'package:edu_prep_academy/User/controllers/auth_controller.dart';
import 'package:edu_prep_academy/User/core/theme/app_text_style.dart';
import 'package:edu_prep_academy/User/core/theme/theme_controller.dart';
import 'package:edu_prep_academy/User/widgets/app_button.dart';
import 'package:edu_prep_academy/User/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthView extends StatelessWidget {
  AuthView({super.key});
  final isDark = Get.find<ThemeController>().isDarkMode.value;
  final controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Obx(() {
              final isLogin = controller.isLoginMode.value;

              return Column(
                children: [
                  const SizedBox(height: 40),

                  /// LOGO
                  Container(
                    height: 88,
                    width: 88,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      size: 44,
                      color: Colors.blue,
                    ),
                  ),

                  const SizedBox(height: 28),

                  /// TITLE
                  Text(
                    isLogin ? "Welcome Back" : "Create Account",
                    style: AppTextStyles.headingLarge(context),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    isLogin ? "Login to continue" : "Register to get started",
                    style: AppTextStyles.bodyMedium(context),
                  ),

                  const SizedBox(height: 36),

                  /// CARD
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        /// NAME (REGISTER ONLY)
                        if (!isLogin)
                          Column(
                            children: [
                              AppTextField(
                                hintText: "John Doe",
                                label: "Full Name",
                                controller: controller.nameController,
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),

                        /// EMAIL
                        AppTextField(
                          hintText: "john.doe@example.com",
                          label: "Email",
                          controller: controller.emailController,
                        ),

                        const SizedBox(height: 20),

                        /// PASSWORD
                        AppTextField(
                          hintText: "••••••••",
                          label: "Password",
                          controller: controller.passwordController,
                          obscureText: true,
                        ),

                        const SizedBox(height: 24),

                        /// MAIN BUTTON
                        AppButton(
                          title: isLogin ? "Login" : "Register",
                          isLoading: controller.isLoading.value,
                          onPressed: controller.submit,
                        ),

                        const SizedBox(height: 16),

                        /// GOOGLE
                        OutlinedButton.icon(
                          onPressed: controller.signInWithGoogle,
                          icon: const Icon(Icons.g_mobiledata),
                          label: const Text("Continue with Google"),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// SWITCH LOGIN / REGISTER
                  TextButton(
                    onPressed: controller.toggleAuthMode,
                    child: Text(
                      isLogin
                          ? "Don't have an account? Register"
                          : "Already have an account? Login",
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
