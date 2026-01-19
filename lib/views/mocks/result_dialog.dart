import 'package:edu_prep_academy/controllers/mock_test_controller.dart';
import 'package:edu_prep_academy/controllers/start_test_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResultDialog extends StatelessWidget {
  final int score; // %
  final int correct;
  final int total;
  final double obtainedMarks;
  final double totalMarks;

  const ResultDialog({
    super.key,
    required this.score,
    required this.correct,
    required this.total,
    required this.obtainedMarks,
    required this.totalMarks,
  });

  @override
  Widget build(BuildContext context) {
    late Color color;
    late IconData icon;
    late String title;
    late String subtitle;

    if (score >= 80) {
      color = Colors.green.shade600;
      icon = Icons.emoji_events;
      title = 'Congratulations 🎉';
      subtitle = 'Outstanding performance!';
    } else if (score >= 50) {
      color = Colors.orange.shade600;
      icon = Icons.thumb_up_alt;
      title = 'Good Job 👍';
      subtitle = 'You are improving, keep practicing!';
    } else {
      color = Colors.red.shade600;
      icon = Icons.sentiment_dissatisfied;
      title = 'Better Luck Next Time';
      subtitle = 'Practice more and try again!';
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Theme.of(context).dialogBackgroundColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.95), color.withOpacity(0.75)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: Colors.white.withOpacity(0.25),
                    child: Icon(icon, size: 42, color: Colors.white),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// SCORE
            Text(
              "$score%",
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Accuracy Score",
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 20),

            /// STATS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _StatRow(
                    label: "Correct Answers",
                    value: "$correct / $total",
                  ),
                  _StatRow(
                    label: "Marks Obtained",
                    value:
                        "${obtainedMarks.toStringAsFixed(1)} / ${totalMarks.toStringAsFixed(1)}",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            /// ACTION BUTTONS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: color),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        final controller = Get.find<MockTestsController>();
                        controller.fetchMockTests();
                        Get.back(); // close dialog
                        Get.back(); // exit test
                      },
                      child: Text(
                        'Exit',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Obx(() {
                      final controller = Get.find<StartTestController>();
                      final disabled = controller.isAttemptLimitReached.value;

                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: disabled ? Colors.grey : color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => disabled
                            ? () {}
                            : controller.resetTestAndCloseDialog(context),
                        child: Text(
                          disabled ? 'Retry Limit Reached' : 'Retry',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
