import 'package:edu_prep_academy/controllers/auth_controller.dart';
import 'package:edu_prep_academy/core/constants/app_colors.dart';
import 'package:edu_prep_academy/core/constants/app_strings.dart';
import 'package:edu_prep_academy/core/theme/theme_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

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
        elevation: 6,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            children: [
              /// ---------------- PROFILE HEADER ----------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryBlue,
                      AppColors.primaryBlue.withOpacity(0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
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
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: Colors.white,
                      child: Text(
                        user?.phoneNumber
                                ?.replaceAll("+91", "")
                                .substring(0, 1) ??
                            "U",
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      user?.phoneNumber ?? AppStrings.defaultUser,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.profileRole,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              /// ---------------- PROFILE OPTIONS ----------------
              _ProfileOptionsSection(
                isDark: isDark,
                themeCtrl: themeCtrl,
                authCtrl: authCtrl,
              ),

              const SizedBox(height: 40),

              /// ---------------- APP INFO ----------------
              Text(
                AppStrings.appVersion,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------- PROFILE OPTIONS SECTION ----------------
class _ProfileOptionsSection extends StatelessWidget {
  final bool isDark;
  final ThemeController themeCtrl;
  final AuthController authCtrl;

  const _ProfileOptionsSection({
    required this.isDark,
    required this.themeCtrl,
    required this.authCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> options = [
      {
        "icon": Icons.dark_mode_rounded,
        "title": AppStrings.darkMode,
        "trailing": Obx(
          () => Switch(
            value: themeCtrl.isDarkMode.value,
            onChanged: themeCtrl.toggleTheme,
            activeColor: AppColors.primaryBlue,
          ),
        ),
      },
      {
        "icon": Icons.menu_book_rounded,
        "title": "My Courses",
        "route": "/myCourses",
      },
      {
        "icon": Icons.help_outline_rounded,
        "title": "Help & Support",
        "route": "/helpSupport",
      },
      {
        "icon": Icons.feedback_outlined,
        "title": "Feedback",
        "route": "/feedback",
      },
      {
        "icon": Icons.settings_rounded,
        "title": "Settings",
        "route": "/settings",
      },
      {
        "icon": Icons.logout,
        "title": AppStrings.logout,
        "iconColor": AppColors.accentOrange,
        "action": () async => await authCtrl.logout(),
      },
    ];

    return Column(
      children: options.map((opt) {
        return Column(
          children: [
            _ProfileOptionCard(
              icon: opt["icon"],
              title: opt["title"],
              iconColor: opt["iconColor"],
              onTap:
                  opt["action"] ??
                  () {
                    // if (opt["route"] != null) Get.toNamed(opt["route"]);
                  },
              trailingWidget: opt["trailing"],
            ),
            const SizedBox(height: 12),
          ],
        );
      }).toList(),
    );
  }
}

/// ---------------- PROFILE OPTION CARD ----------------
class _ProfileOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? iconColor;
  final VoidCallback? onTap;
  final Widget? trailingWidget;

  const _ProfileOptionCard({
    required this.icon,
    required this.title,
    this.iconColor,
    this.onTap,
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor ?? AppColors.primaryBlue, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              if (trailingWidget != null) trailingWidget!,
            ],
          ),
        ),
      ),
    );
  }
}
