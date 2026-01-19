import 'package:edu_prep_academy/controllers/results_controller.dart';
import 'package:edu_prep_academy/core/constants/app_colors.dart';
import 'package:edu_prep_academy/services/result_pdf_service.dart';
import 'package:edu_prep_academy/views/results/analytics_view.dart';
import 'package:edu_prep_academy/core/theme/app_text_style.dart';
import 'package:edu_prep_academy/core/theme/theme_controller.dart';
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
        if (controller.isLoading.value) {
          return _ResultsShimmer(isDark: isDark);
        }

        if (controller.error.isNotEmpty) {
          return Center(
            child: Text(
              controller.error.value,
              style: AppTextStyles.bodyMedium(
                context,
              ).copyWith(color: Colors.red),
            ),
          );
        }

        if (controller.results.isEmpty) {
          return RefreshIndicator(
            color: AppColors.primaryBlue,
            onRefresh: controller.fetchResults,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.bar_chart, size: 80, color: Colors.grey),
                  SizedBox(height: 12),
                  Text("No attempts found"),
                ],
              ),
            ),
          );
        }

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

/// ---------------- SHIMMER ----------------
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

/// ---------------- CATEGORY HEADER ----------------
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

/// ---------------- TEST RESULT CARD ----------------
class _TestResultCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isDark;

  const _TestResultCard({required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final int obtainedMarks = data['obtainedMarks'] ?? 0;
    final int totalMarks = data['totalMarks'] ?? 1;
    final int attempts = data['attempts'] ?? 1;
    final int rank = data['rank'] ?? -1;

    final double percentScore = totalMarks == 0
        ? 0.0
        : obtainedMarks / totalMarks;

    Color progressColor() {
      if (percentScore >= 0.8) return Colors.green;
      if (percentScore >= 0.5) return Colors.orange;
      return Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.45)
                : Colors.grey.withOpacity(0.18),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            children: [
              Expanded(
                child: Text(
                  data['testName'] ?? 'Mock Test',
                  style: AppTextStyles.headingSmall(
                    context,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              if (rank != -1 && rank <= 50)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.amber, Colors.orange],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "TOPPER",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          /// PROGRESS
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentScore,
              minHeight: 8,
              backgroundColor: isDark
                  ? Colors.grey.shade800
                  : Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor()),
            ),
          ),
          const SizedBox(height: 10),

          /// STATS
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

          const SizedBox(height: 14),

          /// ACTION BUTTONS
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        Get.to(() => AnalyticsPage(testId: data['testId'])),
                    icon: const Icon(Icons.analytics_outlined, size: 18),
                    label: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text("Analytics", style: TextStyle(fontSize: 13)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: OutlinedButton.icon(
                    onPressed: () => ResultPdfService.generate(data),
                    icon: const Icon(Icons.download, size: 18),
                    label: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Download PDF",
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ---------------- SMALL STAT TEXT ----------------
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
