import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_prep_academy/User/controllers/daily_quiz_controller.dart';
import 'package:edu_prep_academy/User/views/dailyquiz/daily_quiz_start_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

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

          /// CATEGORY HEADER
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
              return _categoryShimmer(isDark);
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
                        ),
                        child: Center(
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.white70 : Colors.black87),
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

          /// QUIZ HEADER
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
                  /// 🔄 SHIMMER LOADING
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _quizShimmer(isDark);
                  }

                  /// ❌ EMPTY
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _EmptyQuizState(isDark: isDark);
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

//////////////////////////////////////////////////////////////////
// 🟡 CATEGORY SHIMMER
//////////////////////////////////////////////////////////////////

Widget _categoryShimmer(bool isDark) {
  return SizedBox(
    height: 50,
    child: ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(width: 10),
      itemBuilder: (_, __) {
        return Shimmer.fromColors(
          baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
          child: Container(
            width: 80,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        );
      },
    ),
  );
}

//////////////////////////////////////////////////////////////////
// 🟡 QUIZ SHIMMER (MATCHES CARD UI)
//////////////////////////////////////////////////////////////////

Widget _quizShimmer(bool isDark) {
  final base = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
  final highlight = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: 5,
    itemBuilder: (_, __) {
      return Shimmer.fromColors(
        baseColor: base,
        highlightColor: highlight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(height: 10, width: 120, color: Colors.white),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 32,
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

//////////////////////////////////////////////////////////////////
// ❌ EMPTY STATE
//////////////////////////////////////////////////////////////////

class _EmptyQuizState extends StatelessWidget {
  final bool isDark;

  const _EmptyQuizState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final sub = isDark ? Colors.white60 : Colors.black54;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_outlined, size: 80, color: sub),
          const SizedBox(height: 12),
          Text(
            "No Quizzes Available",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Try another category",
            style: TextStyle(fontSize: 12, color: sub),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////
// ✅ ORIGINAL CARD (UNCHANGED)
//////////////////////////////////////////////////////////////////

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
      ),
      child: Row(
        children: [
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                const SizedBox(height: 6),
                Text("$questions Questions • $time Min"),
              ],
            ),
          ),
          ElevatedButton(onPressed: onTap, child: const Text("Start")),
        ],
      ),
    );
  }
}
