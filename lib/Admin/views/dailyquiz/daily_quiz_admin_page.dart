import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edu_prep_academy/Admin/controllers/admin_daily_quiz_controller.dart';

class AdminDailyQuizPage extends StatelessWidget {
  const AdminDailyQuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(AdminDailyQuizController());
    final width = MediaQuery.of(context).size.width;

    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1100;

    int crossAxisCount = 4;
    if (isMobile) crossAxisCount = 1;
    if (isTablet) crossAxisCount = 2;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 20,
            vertical: 16,
          ),
          child: Obx(() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ================= HEADER =================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Daily Quiz Management",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Manage daily quizzes",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    // _primaryButton(
                    //   title: "+ Add Quiz",
                    //   onTap: () => _showAddQuizDialog(ctrl),
                    // ),
                    const SizedBox(width: 10),
                    _primaryButton(
                      title: "Bulk Upload",
                      onTap: () => _bulkDialog(ctrl),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// ================= CATEGORY =================
                _categoryDropdown(ctrl),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _deleteAll(ctrl),
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                      label: const Text(
                        "Delete All",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),

                /// ================= LIST =================
                Expanded(
                  child: ctrl.selectedCategory.value.isEmpty
                      ? _empty("Select category")
                      : StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('daily_quizzes')
                              .doc(
                                ctrl.formatCategoryId(
                                  ctrl.selectedCategory.value,
                                ),
                              )
                              .collection('quizzes')
                              .orderBy('createdAt', descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final docs = snapshot.data!.docs;

                            if (docs.isEmpty) {
                              return _empty("No quizzes found");
                            }

                            return GridView.builder(
                              itemCount: docs.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: isMobile ? 1.05 : 1.2,
                                  ),
                              itemBuilder: (_, i) {
                                final data = docs[i].data();

                                return _quizCard(
                                  ctrl,
                                  docs[i].id,
                                  data,
                                  isMobile,
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ================= CATEGORY =================
  Widget _categoryDropdown(AdminDailyQuizController ctrl) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: ctrl.selectedCategory.value.isEmpty
              ? null
              : ctrl.selectedCategory.value,
          hint: const Text("Select Category"),
          isExpanded: true,
          items: ctrl.categories
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) => ctrl.selectedCategory.value = v ?? '',
        ),
      ),
    );
  }

  // ================= QUIZ CARD =================
  Widget _quizCard(
    AdminDailyQuizController ctrl,
    String id,
    Map data,
    bool isMobile,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Container(
            height: isMobile ? 100 : 120,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: const Center(child: Icon(Icons.quiz, size: 40)),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Text(data['title'] ?? ''),
                Text(
                  "${data['totalQuestions']} Q • ${data['time']} min",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => ctrl.deleteQuiz(id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= ADD QUIZ =================
  // void _showAddQuizDialog(AdminDailyQuizController ctrl) {
  //   final title = TextEditingController();
  //   final time = TextEditingController();
  //   final questions = TextEditingController();

  //   Get.dialog(
  //     AlertDialog(
  //       title: const Text("Add Daily Quiz"),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           _input(title, "Title"),
  //           _input(time, "Time (min)", isNumber: true),
  //           _input(questions, "Questions", isNumber: true),
  //         ],
  //       ),
  //       actions: [
  //         ElevatedButton(
  //           onPressed: () {
  //             ctrl.addQuiz(
  //               title: title.text,
  //               time: int.parse(time.text),
  //               questions: int.parse(questions.text),
  //             );
  //             Get.back();
  //           },
  //           child: const Text("Save"),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // ================= BULK =================
  void _bulkDialog(AdminDailyQuizController ctrl) {
    final jsonCtrl = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text("Bulk JSON Upload"),
        content: TextField(
          controller: jsonCtrl,
          maxLines: 15,
          decoration: const InputDecoration(
            hintText: "Paste JSON",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.back();
              ctrl.bulkUpload(jsonCtrl.text);
            },
            child: const Text("Upload"),
          ),
        ],
      ),
    );
  }

  void _deleteAll(AdminDailyQuizController ctrl) {
    ctrl.deleteAllCategories();
  }

  Widget _primaryButton({required String title, VoidCallback? onTap}) {
    return ElevatedButton(onPressed: onTap, child: Text(title));
  }

  Widget _empty(String text) {
    return Center(child: Text(text));
  }

  Widget _input(TextEditingController c, String hint, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(hintText: hint),
      ),
    );
  }
}
