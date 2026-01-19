import 'package:edu_prep_academy/controllers/auth_controller.dart';
import 'package:edu_prep_academy/core/constants/app_colors.dart';
import 'package:edu_prep_academy/core/constants/app_strings.dart';
import 'package:edu_prep_academy/core/theme/theme_controller.dart';
import 'package:edu_prep_academy/routes/app_routes.dart';
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= PROFILE HEADER =================
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
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 14,
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
                  const SizedBox(height: 6),
                  const Text(
                    "Preparing for Competitive Exams",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 14),

                  /// QUICK STATS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      _ProfileStat(title: "Tests", value: "42"),
                      _ProfileStat(title: "Accuracy", value: "68%"),
                      _ProfileStat(title: "Rank", value: "Top 12%"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// ================= LEARNING SECTION =================
            _SectionTitle("Learning & Performance"),
            _ProfileOptionCard(
              icon: Icons.analytics_outlined,
              title: "My Performance",
              subtitle: "Score, accuracy & rank",
              // onTap: () => Get.toNamed(AppRoutes.performance),
            ),
            _ProfileOptionCard(
              icon: Icons.assignment_turned_in_outlined,
              title: "My Test Attempts",
              subtitle: "Previous mock results",
            ),
            _ProfileOptionCard(
              icon: Icons.picture_as_pdf_outlined,
              title: "Downloaded Notes",
              subtitle: "Offline PDFs",
            ),
            _ProfileOptionCard(
              icon: Icons.bookmark_border,
              title: "Saved Questions",
              subtitle: "Revise later",
            ),

            const SizedBox(height: 24),

            /// ================= ACCOUNT SECTION =================
            _SectionTitle("Account & Preferences"),
            _ProfileOptionCard(
              icon: Icons.school_outlined,
              title: "Exam Preferences",
              subtitle: "SSC, Banking, UPSC, CAT",
            ),
            _ProfileOptionCard(
              icon: Icons.dark_mode_rounded,
              title: AppStrings.darkMode,
              subtitle: "Light / Dark theme",
              trailingWidget: Obx(
                () => Switch(
                  value: themeCtrl.isDarkMode.value,
                  onChanged: themeCtrl.toggleTheme,
                  activeColor: AppColors.primaryBlue,
                ),
              ),
            ),
            _ProfileOptionCard(
              icon: Icons.settings_rounded,
              title: "App Settings",
              subtitle: "Notifications & permissions",
              onTap: () => Get.toNamed(AppRoutes.settings),
            ),

            const SizedBox(height: 24),

            /// ================= SUPPORT SECTION =================
            _SectionTitle("Support"),
            _ProfileOptionCard(
              icon: Icons.help_outline_rounded,
              title: "Help & Support",
              subtitle: "FAQs & contact",
              onTap: () => Get.toNamed(AppRoutes.helpSupport),
            ),
            _ProfileOptionCard(
              icon: Icons.feedback_outlined,
              title: "Feedback",
              subtitle: "Help us improve",
              onTap: () => Get.toNamed(AppRoutes.feedback),
            ),
            _ProfileOptionCard(
              icon: Icons.share_outlined,
              title: "Share App",
              subtitle: "Invite friends",
            ),

            const SizedBox(height: 24),

            /// ================= LOGOUT =================
            _ProfileOptionCard(
              icon: Icons.logout,
              title: AppStrings.logout,
              subtitle: "Sign out of account",
              iconColor: AppColors.accentOrange,
              onTap: () async => await authCtrl.logout(),
            ),

            const SizedBox(height: 40),

            Center(
              child: Text(
                AppStrings.appVersion,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ================= SECTION TITLE =================
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}

/// ================= PROFILE STAT =================
class _ProfileStat extends StatelessWidget {
  final String title;
  final String value;
  const _ProfileStat({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
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
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}

/// ================= OPTION CARD =================
class _ProfileOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final VoidCallback? onTap;
  final Widget? trailingWidget;

  const _ProfileOptionCard({
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    this.onTap,
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
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
                    ? Colors.black.withOpacity(0.35)
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
                  color: (iconColor ?? AppColors.primaryBlue).withOpacity(0.12),
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
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                  ],
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
