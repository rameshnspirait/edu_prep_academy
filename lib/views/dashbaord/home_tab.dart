import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edu_prep_academy/routes/app_routes.dart';
import 'package:edu_prep_academy/core/constants/app_strings.dart';
import 'package:edu_prep_academy/core/theme/app_text_style.dart';
import 'package:edu_prep_academy/core/theme/theme_controller.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();
    final isDark = themeCtrl.isDarkMode.value;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 8,
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            /// ---------------- GREETING ----------------
            _GreetingSection(isDark: isDark),

            // const SizedBox(height: 20),

            /// ---------------- PROGRESS CARD ----------------
            // _ProgressCard(isDark: isDark),
            const SizedBox(height: 28),

            /// ---------------- QUICK ACTIONS ----------------
            Text(
              AppStrings.quickAccess,
              style: AppTextStyles.headingSmall(
                context,
              ).copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.05,
              ),
              children: [
                _ActionCard(
                  title: AppStrings.mockTests,
                  subtitle: 'Practice & Analyze',
                  icon: Icons.assignment_rounded,
                  color: Colors.deepPurple,
                  onTap: () => Get.toNamed(AppRoutes.mockTest),
                ),
                _ActionCard(
                  title: AppStrings.notes,
                  subtitle: 'Quick Revision',
                  icon: Icons.description_rounded,
                  color: Colors.teal,
                  onTap: () => Get.toNamed(AppRoutes.note),
                ),
                // _ActionCard(
                //   title: AppStrings.videoClasses,
                //   subtitle: 'Concept Clarity',
                //   icon: Icons.play_circle_fill_rounded,
                //   color: Colors.orange,
                //   onTap: () => Get.toNamed(AppRoutes.videoClasses),
                // ),
                _ActionCard(
                  title: AppStrings.results,
                  subtitle: 'Track Progress',
                  icon: Icons.bar_chart_rounded,
                  color: Colors.blue,
                  onTap: () => Get.toNamed(AppRoutes.results),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// GREETING
/// ------------------------------------------------------------
class _GreetingSection extends StatelessWidget {
  final bool isDark;

  const _GreetingSection({required this.isDark});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning ☀️";
    if (hour < 17) return "Good Afternoon 🌤";
    return "Good Evening 🌙";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.blueGrey.shade800, Colors.blueGrey.shade600]
              : [Colors.blue.shade400, Colors.lightBlue.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.4)
                : Colors.grey.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // ---------------- ICON / AVATAR ----------------
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? Colors.white12 : Colors.white.withOpacity(0.3),
            ),
            child: Icon(
              Icons.school_rounded,
              size: 32,
              color: isDark ? Colors.white70 : Colors.white,
            ),
          ),
          const SizedBox(width: 16),

          // ---------------- GREETING TEXT ----------------
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    color: isDark ? Colors.white70 : Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.appTagline,
                  style: AppTextStyles.headingMedium(
                    context,
                  ).copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // ---------------- OPTIONAL HERO / LOTTIE ----------------
          Icon(
            Icons.waving_hand_rounded,
            size: 28,
            color: Colors.yellowAccent.shade200,
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------------
// /// PROGRESS CARD
// /// ------------------------------------------------------------
// class _ProgressCard extends StatelessWidget {
//   final bool isDark;

//   const _ProgressCard({required this.isDark});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
//             blurRadius: 14,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child:
//       Row(
//         children: [
//           /// CIRCULAR PROGRESS
//           SizedBox(
//             height: 70,
//             width: 70,
//             child: Stack(
//               fit: StackFit.expand,
//               children: [
//                 CircularProgressIndicator(
//                   value: 0.65,
//                   strokeWidth: 7,
//                   backgroundColor: Colors.grey.shade300,
//                   valueColor: const AlwaysStoppedAnimation(
//                     AppColors.primaryBlue,
//                   ),
//                 ),
//                 Center(
//                   child: Text(
//                     "65%",
//                     style: AppTextStyles.bodyMedium(
//                       context,
//                     ).copyWith(fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(width: 20),

//           /// TEXT
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Today's Progress",
//                   style: AppTextStyles.bodyMedium(
//                     context,
//                   ).copyWith(fontWeight: FontWeight.w600),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   "2 tests • 5 videos completed",
//                   style: AppTextStyles.bodySmall(
//                     context,
//                   ).copyWith(color: isDark ? Colors.white60 : Colors.grey[600]),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

/// ------------------------------------------------------------
/// ACTION CARD
/// ------------------------------------------------------------
class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: color.withOpacity(0.08),
            border: Border.all(color: color.withOpacity(0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ICON
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 26),
              ),

              const Spacer(),

              Text(
                title,
                style: AppTextStyles.bodyMedium(
                  context,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall(
                  context,
                ).copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
