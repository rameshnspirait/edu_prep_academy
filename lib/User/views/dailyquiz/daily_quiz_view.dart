import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_prep_academy/User/controllers/daily_quiz_controller.dart';
import 'package:edu_prep_academy/User/views/dailyquiz/daily_quiz_start_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DailyQuizView extends StatelessWidget {
  DailyQuizView({super.key});

  final ctrl = Get.put(DailyQuizController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 8,
        title: const Text("Daily Quiz"),
        centerTitle: true,
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),

          ///  CATEGORY HEADER
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Categories",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),

          const SizedBox(height: 8),

          /// ================= CATEGORY =================
          Obx(() {
            if (ctrl.categories.isEmpty) {
              return const SizedBox(
                height: 60,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            return SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: ctrl.categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final cat = ctrl.categories[i];

                  return Obx(() {
                    final isSelected = ctrl.selectedCategory.value == cat;

                    return GestureDetector(
                      onTap: () => ctrl.selectedCategory.value = cat,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF4A90E2),
                                    Color(0xFF357ABD),
                                  ],
                                )
                              : null,
                          color: isSelected
                              ? null
                              : (isDark
                                    ? Colors.grey[850]
                                    : Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.white70 : Colors.black87),
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  });
                },
              ),
            );
          }),

          const SizedBox(height: 16),

          ///  QUIZ HEADER
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Available Quizzes",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),

          const SizedBox(height: 10),

          /// ================= QUIZ LIST =================
          Expanded(
            child: Obx(() {
              return StreamBuilder<QuerySnapshot>(
                key: ValueKey(ctrl.selectedCategory.value),
                stream: ctrl.getQuizStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: 5,
                      itemBuilder: (_, __) => _shimmerCard(isDark),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No quizzes found"));
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    itemBuilder: (_, i) {
                      final data = docs[i].data() as Map<String, dynamic>;
                      final quizId = docs[i].id;
                      final category = ctrl.selectedCategory.value;

                      return _PremiumQuizCard(
                        title: data['title'] ?? '',
                        questions:
                            data['questions'] ?? data['totalQuestions'] ?? 0,
                        time: data['time'] ?? 0,
                        isDark: isDark,
                        onTap: () {
                          Get.to(
                            () => DailyQuizStartView(
                              data: data,
                              quizId: quizId,
                              category: category,
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// ================= PREMIUM CARD =================
class _PremiumQuizCard extends StatelessWidget {
  final String title;
  final int questions;
  final int time;
  final bool isDark;
  final VoidCallback onTap;

  const _PremiumQuizCard({
    required this.title,
    required this.questions,
    required this.time,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: isDark
            ? null
            : const LinearGradient(colors: [Color(0xFFF8FBFF), Colors.white]),
        color: isDark ? Colors.grey[900] : null,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.4)
                : Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          /// ICON
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.quiz, color: Colors.white),
          ),

          const SizedBox(width: 14),

          /// TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "$questions Questions • $time Min",
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          /// BUTTON
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: onTap,
            child: const Text("Start"),
          ),
        ],
      ),
    );
  }
}

/// ================= SHIMMER =================
Widget _shimmerCard(bool isDark) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    height: 90,
    decoration: BoxDecoration(
      color: isDark ? Colors.grey[800] : Colors.grey.shade300,
      borderRadius: BorderRadius.circular(16),
    ),
  );
}
