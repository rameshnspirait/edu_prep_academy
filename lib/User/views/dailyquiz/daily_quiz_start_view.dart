import 'package:edu_prep_academy/User/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edu_prep_academy/User/views/mocks/start_test_view.dart';
import 'package:edu_prep_academy/User/controllers/start_test_controller.dart';

class DailyQuizStartView extends StatelessWidget {
  final Map<String, dynamic> data;
  final String quizId;
  final String category;

  const DailyQuizStartView({
    super.key,
    required this.data,
    required this.quizId,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      /// ================= APP BAR =================
      appBar: AppBar(
        elevation: 8,
        title: const Text("Daily Quiz"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// ================= TOP CARD =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title
                  Text(
                    data['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// Tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "DAILY QUIZ",
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// Info Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoTile(
                        Icons.help_outline,
                        "${data['totalQuestions']} Questions",
                      ),
                      _infoTile(
                        Icons.timer_outlined,
                        "${data['time']} Minutes",
                      ),
                      _infoTile(Icons.bar_chart, "Medium"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ================= INSTRUCTIONS =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Instructions",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text("• Total Questions: As per quiz"),
                  Text("• Each question carries 1 mark"),
                  Text("• No negative marking"),
                  Text("• Do not refresh or exit during test"),
                ],
              ),
            ),

            const Spacer(),

            /// ================= START BUTTON =================
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.primaryBlue, // always active for start
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  /// 🔥 OPEN SAME MOCK TEST UI
                  Get.to(
                    () => StartTestView(),
                    binding: BindingsBuilder(() {
                      Get.put(StartTestController());
                    }),
                    arguments: {
                      'isDailyQuiz': true,
                      'quizData': data,
                      'quizId': quizId,
                      'category': category,
                    },
                  );
                },
                child: const Text(
                  "Start Quiz",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= SMALL INFO TILE =================
  Widget _infoTile(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blue),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
