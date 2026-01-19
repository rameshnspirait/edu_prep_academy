import 'package:edu_prep_academy/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edu_prep_academy/controllers/start_test_controller.dart';

class StartTestView extends GetView<StartTestController> {
  StartTestView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final qIndex = controller.currentIndex.value;
          final question = controller.questions[qIndex];
          final selected = controller.selectedAnswers[qIndex];
          final correct = question['correctIndex'];

          return Column(
            children: [
              /// 🔝 PREMIUM TOP BAR
              _PremiumTopBar(
                index: qIndex + 1,
                total: controller.questions.length,
                time: controller.timeLeft.value,
                onQuit: () => _confirmQuit(context),
              ),

              /// 📄 QUESTION + OPTIONS
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _QuestionCard(
                        index: qIndex + 1,
                        text: question['question'],
                      ),

                      const SizedBox(height: 24),

                      ...List.generate(
                        question['options'].length,
                        (i) => _OptionTile(
                          label: String.fromCharCode(65 + i),
                          text: question['options'][i],
                          isSelected: selected == i,
                          isCorrect: selected != null && i == correct,
                          isWrong: selected == i && i != correct,
                          isLocked: selected != null,
                          onTap: () => controller.selectOption(i),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// 🔽 BOTTOM ACTION BAR
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selected != null
                          ? AppColors.primaryBlue
                          : Colors.grey.shade400,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: selected == null
                        ? null
                        : () {
                            if (qIndex == controller.questions.length - 1) {
                              controller.submitTest();
                            } else {
                              controller.nextQuestion();
                            }
                          },
                    child: Text(
                      qIndex == controller.questions.length - 1
                          ? 'Submit Test'
                          : 'Next Question',
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  /// ❗ QUIT CONFIRMATION
  void _confirmQuit(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Quit Test?'),
        content: const Text(
          'Your progress will be lost. Are you sure you want to quit?',
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Get.back();
              Get.back(); // Exit test
            },
            child: const Text('Quit'),
          ),
        ],
      ),
    );
  }
}

class _PremiumTopBar extends StatelessWidget {
  final int index;
  final int total;
  final int time;
  final VoidCallback onQuit;

  const _PremiumTopBar({
    required this.index,
    required this.total,
    required this.time,
    required this.onQuit,
  });

  @override
  Widget build(BuildContext context) {
    final m = time ~/ 60;
    final s = time % 60;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : AppColors.primaryBlue,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          /// QUESTION COUNT
          Text(
            'Q $index / $total',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),

          const Spacer(),

          /// TIMER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 12),

          /// QUIT BUTTON
          IconButton(
            onPressed: onQuit,
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final int index;
  final String text;

  const _QuestionCard({required this.index, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        'Q$index. $text',
        style: TextStyle(
          fontSize: 16,
          height: 1.6,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final bool isLocked;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.text,
    required this.isSelected,
    required this.isCorrect,
    required this.isWrong,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color borderColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
    Color bgColor = isDark ? Colors.grey.shade900 : Colors.white;
    Color badgeBg = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    Color badgeText = isDark ? Colors.white70 : Colors.black87;

    if (isCorrect) {
      borderColor = Colors.green;
      bgColor = Colors.green.withOpacity(0.12);
      badgeBg = Colors.green.withOpacity(0.2);
      badgeText = Colors.green;
    } else if (isWrong) {
      borderColor = Colors.red;
      bgColor = Colors.red.withOpacity(0.12);
      badgeBg = Colors.red.withOpacity(0.2);
      badgeText = Colors.red;
    } else if (isSelected) {
      borderColor = AppColors.primaryBlue;
      bgColor = AppColors.primaryBlue.withOpacity(0.12);
      badgeBg = AppColors.primaryBlue.withOpacity(0.2);
      badgeText = AppColors.primaryBlue;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: isLocked ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: borderColor.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// 🔤 OPTION BADGE (A / B / C / D)
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: badgeBg),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: badgeText,
                ),
              ),
            ),

            const SizedBox(width: 14),

            /// 📄 OPTION TEXT
            Expanded(
              child: Text(
                text,

                style: TextStyle(
                  fontSize: 15,
                  height: 1.55,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ),

            /// ✔ / ✖ ICON (AFTER LOCK)
            if (isLocked)
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Icon(
                  isCorrect
                      ? Icons.check_circle
                      : isWrong
                      ? Icons.cancel
                      : null,
                  size: 22,
                  color: isCorrect
                      ? Colors.green
                      : isWrong
                      ? Colors.red
                      : Colors.transparent,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
