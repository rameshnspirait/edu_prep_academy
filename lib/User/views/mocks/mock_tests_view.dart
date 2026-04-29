import 'package:edu_prep_academy/User/controllers/mock_test_controller.dart';
import 'package:edu_prep_academy/User/core/constants/app_colors.dart';
import 'package:edu_prep_academy/User/core/theme/app_text_style.dart';
import 'package:edu_prep_academy/User/core/theme/theme_controller.dart';
import 'package:edu_prep_academy/User/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class MockTestsView extends GetView<MockTestsController> {
  MockTestsView({super.key});

  final ThemeController themeCtrl = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    final isDark = themeCtrl.isDarkMode.value;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("Mock Tests"), centerTitle: true),

      body: Obx(() {
        if (controller.isLoading.value) {
          return _MockShimmer(isDark: isDark);
        }

        if (controller.categoryTests.isEmpty) {
          return const Center(child: Text("No mock tests available"));
        }

        final categories = controller.categoryTests.keys.toList();

        return RefreshIndicator(
          color: AppColors.primaryBlue,
          onRefresh: () async => controller.fetchMockTests(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];

              final List<Map<String, dynamic>> tests =
                  List<Map<String, dynamic>>.from(
                    controller.categoryTests[category] ?? [],
                  );

              /// 🔥 SKIP EMPTY CATEGORY
              if (tests.isEmpty) return const SizedBox();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ================= CATEGORY TITLE =================
                  Text(
                    _formatCategory(category),
                    style: AppTextStyles.headingSmall(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// ================= TEST GRID =================
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tests.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                    itemBuilder: (_, i) {
                      final test = tests[i];

                      return _TestCard(
                        title: test["title"] ?? "",
                        questions: test["questions"] ?? 0,
                        thumbnailUrl: test["thumbnail"] ?? "",
                        isDark: isDark,
                        isFree: test["isFree"] ?? true,
                        duration: test["duration"] ?? 0,
                        isLocked: test["isLocked"] ?? false,
                        uploadedAt: _safeDate(test["createdAt"]),

                        /// 🔥 IMPORTANT FIX
                        onTap: () {
                          Get.toNamed(
                            AppRoutes.startTest,
                            arguments: {
                              "categoryId": category,
                              "testId": test["id"],
                              "duration": test["duration"],
                              "testTitle": test["title"], // ✅ FIXED
                            },
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        );
      }),
    );
  }

  // =====================================================
  // FORMAT CATEGORY NAME (SSC_GD → SSC GD)
  // =====================================================
  String _formatCategory(String category) {
    return category.replaceAll("_", " ");
  }

  // =====================================================
  // SAFE DATE PARSER
  // =====================================================
  DateTime _safeDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;

    try {
      return value.toDate();
    } catch (_) {
      return DateTime.now();
    }
  }
}

//////////////////////////////////////////////////////////////////
// TEST CARD (UNCHANGED UI, ONLY LOGIC SAFE)
//////////////////////////////////////////////////////////////////

class _TestCard extends StatelessWidget {
  final String title;
  final dynamic questions;
  final String thumbnailUrl;
  final bool isDark;
  final bool isFree;
  final int duration;
  final DateTime uploadedAt;
  final VoidCallback? onTap;
  final bool isLocked;

  const _TestCard({
    required this.title,
    required this.questions,
    required this.thumbnailUrl,
    required this.isDark,
    required this.isFree,
    required this.duration,
    required this.uploadedAt,
    required this.isLocked,
    this.onTap,
  });

  void _showLockedBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryColor = isDark ? Colors.white : Colors.blueAccent;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// HANDLE
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.2)
                      : Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              /// ICON
              Icon(Icons.lock_clock_rounded, size: 50, color: primaryColor),

              const SizedBox(height: 12),

              /// TITLE
              Text(
                "Attempt Limit Reached",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),

              const SizedBox(height: 8),

              /// MESSAGE
              Text(
                "You have reached the maximum attempts for this test.\nPlease try again after 24 hours.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: subTextColor),
              ),

              const SizedBox(height: 20),

              /// BUTTON
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Got it",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final questionText = "$questions Questions";

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (isLocked) {
            _showLockedBottomSheet(context);
          } else {
            onTap?.call();
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.4)
                    : Colors.grey.withOpacity(0.18),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// IMAGE
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        thumbnailUrl.isEmpty
                            ? "https://via.placeholder.com/300"
                            : thumbnailUrl,
                        fit: BoxFit.cover,
                      ),

                      /// FREE / PAID
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isFree ? Colors.green : Colors.orange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            isFree ? "FREE" : "PAID",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      /// LOCK
                      if (isLocked)
                        Container(
                          color: Colors.black.withOpacity(0.5),
                          child: const Center(
                            child: Icon(
                              Icons.lock,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),

                      Positioned(top: 8, right: 8, child: _chip(questionText)),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: _chip("$duration min"),
                      ),
                    ],
                  ),
                ),
              ),

              /// TITLE
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),

              /// DATE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  "Uploaded: ${uploadedAt.day}/${uploadedAt.month}/${uploadedAt.year}",
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : Colors.grey,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              /// BUTTON
              Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: ElevatedButton(
                    onPressed: isLocked ? null : onTap,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: AppColors.darkTextPrimary,
                      backgroundColor: isLocked
                          ? Colors.grey
                          : Colors.blueAccent,
                    ),
                    child: Text(isLocked ? "Locked" : "Start Test"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////
// SHIMMER (UNCHANGED)
//////////////////////////////////////////////////////////////////
class _MockShimmer extends StatelessWidget {
  final bool isDark;
  const _MockShimmer({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final base = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlight = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // ✅ 2 columns
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75, // ✅ perfect card ratio
      ),
      itemBuilder: (_, __) {
        return Shimmer.fromColors(
          baseColor: base,
          highlightColor: highlight,
          direction: ShimmerDirection.ltr, // 🔥 smoother animation
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔲 IMAGE / THUMBNAIL
                Container(
                  height: 90,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 10),

                /// 📝 TITLE (2 lines effect)
                Container(
                  height: 12,
                  width: double.infinity,
                  color: Colors.white,
                ),
                const SizedBox(height: 6),
                Container(height: 12, width: 120, color: Colors.white),

                const SizedBox(height: 10),

                /// ⏱️ META INFO (duration/questions)
                Row(
                  children: [
                    Container(height: 10, width: 40, color: Colors.white),
                    const SizedBox(width: 8),
                    Container(height: 10, width: 40, color: Colors.white),
                  ],
                ),

                const Spacer(),

                /// 🔘 START BUTTON
                Container(
                  height: 36,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
