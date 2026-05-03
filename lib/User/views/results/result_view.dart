import 'package:edu_prep_academy/User/controllers/results_controller.dart';
import 'package:edu_prep_academy/User/core/constants/app_colors.dart';
import 'package:edu_prep_academy/User/core/theme/app_text_style.dart';
import 'package:edu_prep_academy/User/core/theme/theme_controller.dart';
import 'package:edu_prep_academy/User/views/results/analytics_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class ResultsView extends GetView<ResultsController> {
  ResultsView({super.key});

  final themeCtrl = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    final isDark = themeCtrl.isDarkMode.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Results"),
        centerTitle: true,
        elevation: 6,
      ),
      body: Obx(() {
        /// 🔥 LOADING
        if (controller.isLoading.value) {
          return _ResultsShimmer(isDark: isDark);
        }

        /// ❌ ERROR
        if (controller.error.isNotEmpty) {
          return _ErrorState(
            message: controller.error.value,
            onRetry: controller.fetchResults,
          );
        }

        /// 🚫 EMPTY STATE (UPDATED)
        if (controller.results.isEmpty) {
          return _EmptyState(
            isDark: isDark,
            onRefresh: controller.fetchResults,
          );
        }

        /// ✅ DATA
        return RefreshIndicator(
          onRefresh: controller.fetchResults,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: controller.results.entries.map((entry) {
              final categoryName = entry.key;
              final tests = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CategoryHeader(title: categoryName),
                  const SizedBox(height: 12),
                  ...tests.map(
                    (test) => _TestResultCard(data: test, isDark: isDark),
                  ),
                  const SizedBox(height: 28),
                ],
              );
            }).toList(),
          ),
        );
      }),
    );
  }
}

//////////////////////////////////////////////////////////////////
// 🔥 PREMIUM EMPTY STATE
//////////////////////////////////////////////////////////////////
class _EmptyState extends StatelessWidget {
  final bool isDark;
  final VoidCallback onRefresh;

  const _EmptyState({required this.isDark, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),

          Icon(
            Icons.bar_chart_rounded,
            size: 80,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),

          const SizedBox(height: 16),

          Center(
            child: Text(
              "No Results Yet",
              style: AppTextStyles.headingSmall(
                context,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 8),

          Center(
            child: Text(
              "Start attempting tests to see your performance here",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall(
                context,
              ).copyWith(color: Colors.grey),
            ),
          ),

          const SizedBox(height: 20),

          /// 🔥 CTA BUTTON
          Center(
            child: ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text("Refresh"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////
//  ERROR STATE (BONUS)
//////////////////////////////////////////////////////////////////
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 70, color: Colors.red),
          const SizedBox(height: 10),
          Text(message),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text("Refresh")),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////
// SHIMMER (UNCHANGED)
//////////////////////////////////////////////////////////////////
class _ResultsShimmer extends StatelessWidget {
  final bool isDark;
  const _ResultsShimmer({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (_, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
            highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
            child: Container(
              height: 20,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: List.generate(2, (_) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Shimmer.fromColors(
                  baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                  highlightColor: isDark
                      ? Colors.grey[700]!
                      : Colors.grey[100]!,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

List<Widget> _buildBadges(Map data) {
  List<Widget> badges = [];

  final accuracy = (data['accuracy'] ?? 0).toDouble();
  final time = (data['timeTaken'] ?? 0);
  final attempts = (data['attempts'] ?? 1);
  final rank = (data['rank'] ?? 999);

  /// 🥇 TOPPER
  if (rank == 1) {
    badges.add(_badge("🥇 Topper", Colors.amber));
  }

  /// 🎯 HIGH ACCURACY
  if (accuracy >= 80) {
    badges.add(_badge("🎯 Accurate", Colors.green));
  }

  /// ⚡ FAST SOLVER (example < 30 sec)
  if (time > 0 && time < 30) {
    badges.add(_badge("⚡ Fast", Colors.blue));
  }

  /// 🔁 CONSISTENT
  if (attempts >= 3) {
    badges.add(_badge("🔥 Consistent", Colors.deepPurple));
  }

  return badges;
}

Widget _badge(String text, Color color) {
  return Container(
    margin: const EdgeInsets.only(right: 6, top: 6),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
    ),
  );
}

//////////////////////////////////////////////////////////////////
// REMAINING CODE (UNCHANGED)
//////////////////////////////////////////////////////////////////

class _CategoryHeader extends StatelessWidget {
  final String title;
  const _CategoryHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 28,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: AppTextStyles.headingSmall(
            context,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _TestResultCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isDark;

  const _TestResultCard({required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final int obtainedMarks = data['obtainedMarks'] ?? 0;
    final int totalMarks = data['totalMarks'] ?? 1;
    final int attempts = data['attempts'] ?? 1;

    final double percentScore = totalMarks == 0
        ? 0.0
        : obtainedMarks / totalMarks;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Get.to(() => AnalyticsPage(testId: data['testId']));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['testName'] ?? 'Mock Test',
              style: AppTextStyles.headingSmall(
                context,
              ).copyWith(fontWeight: FontWeight.bold),
            ),

            /// 🔥 BADGES HERE
            const SizedBox(height: 6),
            Wrap(children: _buildBadges(data)),

            const SizedBox(height: 10),
            LinearProgressIndicator(value: percentScore),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatText("Score", "$obtainedMarks / $totalMarks"),
                _StatText(
                  "Accuracy",
                  "${(percentScore * 100).toStringAsFixed(1)}%",
                ),
                _StatText("Attempts", "$attempts"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatText extends StatelessWidget {
  final String label;
  final String value;

  const _StatText(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption(context)),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.bodySmall(
            context,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
