import 'package:edu_prep_academy/User/controllers/mock_test_controller.dart';
import 'package:edu_prep_academy/User/controllers/start_test_controller.dart';
import 'package:edu_prep_academy/User/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StartTestView extends GetView<StartTestController> {
  const StartTestView({super.key});

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

          if (controller.questions.isEmpty) {
            return const Center(child: Text("No Questions Available"));
          }

          final qIndex = controller.currentIndex.value;

          if (qIndex >= controller.questions.length) {
            return const Center(child: Text("Something went wrong"));
          }

          final question = controller.questions[qIndex];
          final selected = controller.selectedAnswers[qIndex];
          final correct = question['correctIndex'];

          return Column(
            children: [
              _PremiumTopBar(
                index: qIndex + 1,
                total: controller.questions.length,
                time: controller.timeLeft.value,
                onQuit: () => _confirmQuit(context),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _QuestionCard(
                        index: qIndex + 1,
                        text: question['question'] ?? '',
                      ),

                      const SizedBox(height: 24),

                      ...List.generate(
                        (question['options'] as List).length,
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

  void _confirmQuit(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.5)
                    : Colors.grey.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// 🔴 ICON
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.exit_to_app_rounded,
                  color: Colors.red,
                  size: 30,
                ),
              ),

              const SizedBox(height: 16),

              /// TITLE
              Text(
                "Quit Test?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              /// DESCRIPTION
              Text(
                "Your progress will be lost.\nAre you sure you want to quit?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),

              const SizedBox(height: 20),

              /// ACTION BUTTONS
              Row(
                children: [
                  /// CANCEL
                  Expanded(
                    child: OutlinedButton(
                      onPressed: Get.back,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isDark ? Colors.white24 : Colors.grey.shade300,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// QUIT BUTTON
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();

                        /// reset test controller
                        Get.delete<StartTestController>(force: true);

                        /// refresh mock tests
                        if (Get.isRegistered<MockTestsController>()) {
                          Get.find<MockTestsController>().fetchMockTests();
                        }

                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Quit",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false, // 🔥 Prevent accidental close
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
          Text(
            'Q $index / $total',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: badgeBg),
              child: Text(
                label,
                style: TextStyle(fontWeight: FontWeight.bold, color: badgeText),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
            if (isLocked)
              Icon(
                isCorrect
                    ? Icons.check_circle
                    : isWrong
                    ? Icons.cancel
                    : null,
                color: isCorrect
                    ? Colors.green
                    : isWrong
                    ? Colors.red
                    : Colors.transparent,
              ),
          ],
        ),
      ),
    );
  }
}
