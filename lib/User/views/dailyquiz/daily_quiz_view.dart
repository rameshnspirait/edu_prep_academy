import 'package:edu_prep_academy/User/views/dailyquiz/daily_quiz_start_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DailyQuizView extends StatelessWidget {
  DailyQuizView({super.key});

  final RxString selectedCategory = 'Quantitative Aptitude'.obs;

  final List<String> categories = [
    'Quantitative Aptitude',
    'Reasoning Ability',
    'English Grammar',
    'Current Affairs',
    'General Knowledge',
  ];

  final Map<String, List<Map<String, dynamic>>> dailyQuizzes = {
    'Quantitative Aptitude': [
      {'title': 'Daily Speed Math', 'questions': 10, 'time': 10},
    ],
    'Reasoning Ability': [
      {'title': 'Logic Challenge', 'questions': 15, 'time': 15},
    ],
    'English Grammar': [
      {'title': 'Grammar Booster', 'questions': 10, 'time': 12},
    ],
    'Current Affairs': [
      {'title': 'Today News Quiz', 'questions': 20, 'time': 10},
    ],
    'General Knowledge': [
      {'title': 'GK Daily Shot', 'questions': 15, 'time': 12},
    ],
  };

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
        children: [
          /// ================= CATEGORY SELECTOR =================
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: categories.length,
              itemBuilder: (_, i) {
                final cat = categories[i];
                final isSelected = selectedCategory.value == cat;

                return GestureDetector(
                  onTap: () => selectedCategory.value = cat,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(
                      right: 10,
                      top: 10,
                      bottom: 10,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue
                          : isDark
                          ? Colors.grey[850]
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey.shade300,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : isDark
                              ? Colors.white70
                              : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          /// ================= QUIZ LIST =================
          Expanded(
            child: Obx(() {
              final quizzes = dailyQuizzes[selectedCategory.value] ?? [];

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: quizzes.length,
                itemBuilder: (_, i) {
                  final q = quizzes[i];

                  return _DailyQuizCard(
                    title: q['title'],
                    questions: q['questions'],
                    time: q['time'],
                    onTap: () {
                      Get.to(() => DailyQuizStartView(data: q));
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

class _DailyQuizCard extends StatelessWidget {
  final String title;
  final int questions;
  final int time;
  final VoidCallback onTap;

  const _DailyQuizCard({
    required this.title,
    required this.questions,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.today, color: Colors.blue),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$questions Questions • $time Min",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          ElevatedButton(onPressed: onTap, child: const Text("Start")),
        ],
      ),
    );
  }
}
