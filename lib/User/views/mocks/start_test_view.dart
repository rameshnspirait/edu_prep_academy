import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edu_prep_academy/User/controllers/start_test_controller.dart';

class StartTestView extends StatelessWidget {
  final ctrl = Get.put(StartTestController());

  StartTestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mock Test"),
        actions: [
          Obx(
            () => Padding(
              padding: const EdgeInsets.all(12),
              child: Center(
                child: Text(
                  "${ctrl.timeLeft.value ~/ 60}:${(ctrl.timeLeft.value % 60).toString().padLeft(2, '0')}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),

      /// 📌 QUESTION PALETTE DRAWER
      endDrawer: _questionPalette(),

      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final q = ctrl.questions[ctrl.currentIndex.value];

        return Column(
          children: [
            _progressBar(),

            /// QUESTION
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Q${ctrl.currentIndex.value + 1}. ${q['question']}",
                style: const TextStyle(fontSize: 16),
              ),
            ),

            /// OPTIONS
            Expanded(
              child: ListView.builder(
                itemCount: q['options'].length,
                itemBuilder: (_, i) {
                  return Obx(() {
                    final selected =
                        ctrl.selectedAnswers[ctrl.currentIndex.value] == i;

                    return GestureDetector(
                      onTap: () => ctrl.selectOption(i),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selected
                                ? Colors.green
                                : Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: selected ? Colors.green.shade50 : Colors.white,
                        ),
                        child: Text(q['options'][i]),
                      ),
                    );
                  });
                },
              ),
            ),

            _bottomBar(context),
          ],
        );
      }),
    );
  }

  // ================= PROGRESS =================
  Widget _progressBar() {
    return Obx(
      () => LinearProgressIndicator(
        value: (ctrl.currentIndex.value + 1) / ctrl.questions.length,
      ),
    );
  }

  // ================= BOTTOM BAR =================
  Widget _bottomBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: ctrl.currentIndex.value > 0
                ? () => ctrl.currentIndex.value--
                : null,
            child: const Text("Previous"),
          ),

          ElevatedButton(
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
            child: const Text("Palette"),
          ),

          ElevatedButton(
            onPressed: () {
              if (ctrl.currentIndex.value == ctrl.questions.length - 1) {
                _showSubmitDialog();
              } else {
                ctrl.nextQuestion();
              }
            },
            child: Obx(
              () => Text(
                ctrl.currentIndex.value == ctrl.questions.length - 1
                    ? "Submit"
                    : "Next",
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= PALETTE =================
  Widget _questionPalette() {
    return Drawer(
      child: Obx(() {
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ctrl.questions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (_, i) {
            final isSelected = ctrl.currentIndex.value == i;
            final isAnswered = ctrl.selectedAnswers.containsKey(i);

            Color color = Colors.grey.shade300;

            if (isSelected) {
              color = Colors.blue;
            } else if (isAnswered) {
              color = Colors.green;
            }

            return GestureDetector(
              onTap: () {
                ctrl.currentIndex.value = i;
                Get.back();
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text("${i + 1}"),
              ),
            );
          },
        );
      }),
    );
  }

  // ================= SUBMIT DIALOG =================
  void _showSubmitDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text("Submit Test"),
        content: const Text("Are you sure you want to submit the test?"),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Get.back();
              ctrl.submitTest();
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }
}
