import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/profile_controller.dart';
import '../../core/constants/app_colors.dart';

class PerformanceView extends GetView<ProfileController> {
  const PerformanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("My Performance"),
        centerTitle: true,
        elevation: 6,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.refreshProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _overviewCard(context, isDark),
                const SizedBox(height: 20),
                _statsGrid(context, isDark),
                const SizedBox(height: 20),
                _recentTests(context, isDark),
              ],
            ),
          ),
        );
      }),
    );
  }

  /// ================= OVERVIEW =================
  Widget _overviewCard(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue,
            AppColors.primaryBlue.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.2),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Overall Accuracy",
            style: TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 6),

          Obx(
            () => Text(
              "${controller.accuracy.value.toStringAsFixed(1)}%",
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 14),

          /// 🔥 RANK (UPDATED)
          Obx(() {
            final rank = controller.userRank.value;

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(medal, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      "Rank $rank",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  "in Tests",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  /// ================= GRID =================
  Widget _statsGrid(BuildContext context, bool isDark) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      children: [
        _statTile(
          context,
          "Total Tests",
          "${controller.totalTests.value}",
          isDark,
        ),
        _statTile(
          context,
          "Accuracy",
          "${controller.accuracy.value.toStringAsFixed(1)}%",
          isDark,
        ),
        _statTile(context, "Rank", "Rank ${controller.userRank.value}", isDark),
        _statTile(
          context,
          "Best Score",
          "${controller.bestScore.value}%",
          isDark,
        ),
      ],
    );
  }

  Widget _statTile(
    BuildContext context,
    String title,
    String value,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.4)
                : Colors.grey.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// ================= RECENT TESTS =================
  Widget _recentTests(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Recent Tests",
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),

        Obx(() {
          if (controller.recentTests.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text("No tests attempted yet"),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.recentTests.length,
            itemBuilder: (_, i) {
              final test = controller.recentTests[i];

              final score = test['score'] ?? 0;

              /// 🎯 Dynamic color based on performance
              Color scoreColor;
              if (score >= 80) {
                scoreColor = Colors.green;
              } else if (score >= 50) {
                scoreColor = Colors.orange;
              } else {
                scoreColor = Colors.red;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.35)
                          : Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    /// ICON
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.analytics_outlined,
                        color: AppColors.primaryBlue,
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// TITLE + DATE
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            test['title'] ?? "Mock Test",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),

                          /// Optional Date
                          Text(
                            test['date'] != null
                                ? (test['date'] as Timestamp)
                                      .toDate()
                                      .toString()
                                      .substring(0, 10)
                                : "",
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// SCORE
                    Text(
                      "$score%",
                      style: TextStyle(
                        color: scoreColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ],
    );
  }
}
