import 'package:edu_prep_academy/User/controllers/auth_controller.dart';
import 'package:edu_prep_academy/User/controllers/profile_controller.dart';
import 'package:edu_prep_academy/User/core/constants/app_colors.dart';
import 'package:edu_prep_academy/User/core/constants/app_strings.dart';
import 'package:edu_prep_academy/User/core/theme/theme_controller.dart';
import 'package:edu_prep_academy/User/routes/app_routes.dart';
import 'package:edu_prep_academy/User/views/profile/my_test_attempt_view.dart';
import 'package:edu_prep_academy/User/views/profile/widget/profile_shimmer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final themeCtrl = Get.find<ThemeController>();
    final authCtrl = Get.find<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        elevation: 4,
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const ProfileShimmer()
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// ================= HEADER =================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryBlue,
                            AppColors.primaryBlue.withOpacity(0.85),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          /// Avatar
                          CircleAvatar(
                            radius: 42,
                            backgroundColor: Colors.white,
                            child: Text(
                              user?.phoneNumber
                                      ?.replaceAll("+91", "")
                                      .substring(0, 1) ??
                                  "U",
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          /// Phone
                          Text(
                            user?.phoneNumber ?? AppStrings.defaultUser,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 6),

                          const Text(
                            "Preparing for Competitive Exams",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(height: 16),

                          /// STATS
                          Obx(
                            () => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _stat(
                                  "Tests",
                                  "${controller.totalTests.value}",
                                ),
                                _stat(
                                  "Accuracy",
                                  "${controller.accuracy.value.toStringAsFixed(1)}%",
                                ),
                                _rankBadge(controller.userRank.value),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    /// ================= LEARNING =================
                    _section("Learning & Performance"),
                    _card(
                      icon: Icons.analytics_outlined,
                      title: "My Performance",
                      subtitle: "Score, accuracy & rank",
                      onTap: () => Get.toNamed(AppRoutes.performance),
                    ),
                    // _card(
                    //   icon: Icons.assignment_turned_in_outlined,
                    //   title: "My Test Attempts",
                    //   subtitle: "Previous mock results",
                    //   onTap: () => Get.to(() => MyTestAttemptView()),
                    // ),
                    _card(
                      icon: Icons.picture_as_pdf_outlined,
                      title: "Downloaded Notes",
                      subtitle: "Offline PDFs",
                    ),
                    _card(
                      icon: Icons.bookmark_border,
                      title: "Saved Questions",
                      subtitle: "Revise later",
                    ),

                    const SizedBox(height: 24),

                    /// ================= SETTINGS =================
                    _section("Account & Preferences"),
                    _card(
                      icon: Icons.school_outlined,
                      title: "Exam Preferences",
                      subtitle: "SSC, Banking, UPSC, CAT",
                    ),
                    _card(
                      icon: Icons.dark_mode_rounded,
                      title: AppStrings.darkMode,
                      subtitle: "Light / Dark theme",
                      trailing: Obx(
                        () => Switch(
                          value: themeCtrl.isDarkMode.value,
                          onChanged: themeCtrl.toggleTheme,
                          activeColor: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                    _card(
                      icon: Icons.settings,
                      title: "App Settings",
                      subtitle: "Notifications & permissions",
                      onTap: () => Get.toNamed(AppRoutes.settings),
                    ),

                    const SizedBox(height: 24),

                    /// ================= SUPPORT =================
                    _section("Support"),
                    _card(
                      icon: Icons.help_outline,
                      title: "Help & Support",
                      subtitle: "FAQs & contact",
                      onTap: () => Get.toNamed(AppRoutes.helpSupport),
                    ),
                    _card(
                      icon: Icons.feedback_outlined,
                      title: "Feedback",
                      subtitle: "Help us improve",
                      onTap: () => Get.toNamed(AppRoutes.feedback),
                    ),
                    _card(
                      icon: Icons.share_outlined,
                      title: "Share App",
                      subtitle: "Invite friends",
                    ),

                    const SizedBox(height: 24),

                    /// ================= LOGOUT =================
                    _card(
                      icon: Icons.logout,
                      title: AppStrings.logout,
                      subtitle: "Sign out of account",
                      iconColor: AppColors.accentOrange,
                      onTap: () async => await authCtrl.logout(),
                    ),

                    const SizedBox(height: 30),

                    Center(
                      child: Text(
                        AppStrings.appVersion,
                        style: TextStyle(
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

/// ================= STAT =================
Widget _stat(String title, String value) {
  return Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
    ],
  );
}

/// ================= PREMIUM RANK BADGE =================
Widget _rankBadge(int rank) {
  String medal;

  if (rank == 1) {
    medal = "🥇";
  } else if (rank == 2) {
    medal = "🥈";
  } else if (rank == 3) {
    medal = "🥉";
  } else {
    medal = "🏅";
  }

  return Column(
    children: [
      /// Top Row (Medal + Rank)
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(medal, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            "Rank $rank",
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),

      const SizedBox(height: 2),

      /// Subtitle
      const Text(
        "in Tests",
        style: TextStyle(
          fontSize: 11,
          color: Colors.white70,
          fontWeight: FontWeight.w400,
        ),
      ),
    ],
  );
}

/// ================= SECTION =================
Widget _section(String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
    ),
  );
}

/// ================= CARD =================
Widget _card({
  required IconData icon,
  required String title,
  String? subtitle,
  Color? iconColor,
  VoidCallback? onTap,
  Widget? trailing,
}) {
  return Builder(
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.4)
                      : Colors.grey.withOpacity(0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (iconColor ?? AppColors.primaryBlue).withOpacity(
                      0.12,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? AppColors.primaryBlue,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
        ),
      );
    },
  );
}
