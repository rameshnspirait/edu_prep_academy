import 'package:edu_prep_academy/User/core/constants/app_colors.dart';
import 'package:edu_prep_academy/User/core/constants/app_strings.dart';
import 'package:edu_prep_academy/User/core/theme/app_text_style.dart';
import 'package:edu_prep_academy/User/core/theme/theme_controller.dart';
import 'package:edu_prep_academy/User/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

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
            const SizedBox(height: 20),
            _BannerSlider(isDark: isDark),

            /// ---------------- PROGRESS CARD ----------------
            // _ProgressCard(isDark: isDark),
            const SizedBox(height: 20),

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
                  title: AppStrings.notes,
                  subtitle: 'Quick Revision',
                  icon: Icons.description_rounded,
                  color: Colors.teal,
                  onTap: () => Get.toNamed(AppRoutes.note),
                ),

                _ActionCard(
                  title: AppStrings.mockTests,
                  subtitle: 'Practice & Analyze',
                  icon: Icons.assignment_rounded,
                  color: Colors.deepPurple,
                  onTap: () => Get.toNamed(AppRoutes.mockTest),
                ),
                _ActionCard(
                  title: "Daily Quiz",
                  subtitle: 'Quick Daily Test',
                  icon: Icons.bolt_rounded,
                  color: Colors.orange,
                  onTap: () => Get.toNamed(AppRoutes.dailyQuiz),
                ),
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
      padding: const EdgeInsets.all(10),
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

class _BannerData {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;

  _BannerData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
  });
}

class _BannerCard extends StatelessWidget {
  final _BannerData data;
  final bool isDark;

  const _BannerCard({required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: data.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          /// TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.title,
                  style: AppTextStyles.headingSmall(
                    context,
                  ).copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  data.subtitle,
                  style: AppTextStyles.bodySmall(
                    context,
                  ).copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),

          /// ICON
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
            ),
            child: Icon(data.icon, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }
}

class _BannerSlider extends StatefulWidget {
  final bool isDark;
  const _BannerSlider({required this.isDark});

  @override
  State<_BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<_BannerSlider> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<_BannerData> banners = [
    _BannerData(
      title: 'SSC & Banking Mock Tests',
      subtitle: 'Latest pattern • Detailed analysis',
      icon: Icons.assignment_turned_in_rounded,
      gradient: [Color(0xFF5F2C82), Color(0xFF49A09D)],
    ),
    _BannerData(
      title: 'UPSC Concept Notes',
      subtitle: 'Static + Current Affairs',
      icon: Icons.menu_book_rounded,
      gradient: [Color(0xFF134E5E), Color(0xFF71B280)],
    ),
    _BannerData(
      title: 'Daily Practice Tests',
      subtitle: 'Improve accuracy & speed',
      icon: Icons.timer_rounded,
      gradient: [Color(0xFF283048), Color(0xFF859398)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _autoScroll();
  }

  void _autoScroll() {
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      _currentIndex = (_currentIndex + 1) % banners.length;
      _controller.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      _autoScroll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _controller,
            itemCount: banners.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (_, index) {
              return _BannerCard(data: banners[index], isDark: widget.isDark);
            },
          ),
        ),

        const SizedBox(height: 10),

        /// DOT INDICATOR
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            banners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: _currentIndex == index ? 18 : 6,
              decoration: BoxDecoration(
                color: _currentIndex == index
                    ? AppColors.primaryBlue
                    : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

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

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// ---------------- GREETING SHIMMER ----------------
          _shimmerBox(height: 110, radius: 20, context: context),

          const SizedBox(height: 20),

          /// ---------------- BANNER SHIMMER ----------------
          _shimmerBox(height: 150, radius: 20, context: context),

          const SizedBox(height: 20),

          /// ---------------- TITLE SHIMMER ----------------
          _shimmerBox(height: 20, width: 140, radius: 8, context: context),

          const SizedBox(height: 16),

          /// ---------------- GRID SHIMMER ----------------
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.05,
            ),
            itemBuilder: (context, index) {
              return _shimmerCard(context);
            },
          ),
        ],
      ),
    );
  }

  /// BOX SHIMMER
  Widget _shimmerBox({
    double height = 100,
    double? width,
    double radius = 12,
    required BuildContext context,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  /// GRID CARD SHIMMER
  Widget _shimmerCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 45,
              width: 45,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const Spacer(),
            Container(height: 14, width: 100, color: Colors.white),
            const SizedBox(height: 8),
            Container(height: 12, width: 70, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
