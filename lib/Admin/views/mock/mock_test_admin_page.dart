import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edu_prep_academy/Admin/controllers/admin_test_controller.dart';
import 'package:edu_prep_academy/Admin/views/questions/questions_admin_page.dart';

class AdminMockTestPage extends StatelessWidget {
  const AdminMockTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(AdminMockTestController());
    final width = MediaQuery.of(context).size.width;

    /// 🔥 RESPONSIVE GRID
    int crossAxisCount = 1;
    if (width > 1200) {
      crossAxisCount = 4;
    } else if (width > 900) {
      crossAxisCount = 3;
    } else if (width > 600) {
      crossAxisCount = 2;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: Padding(
        padding: EdgeInsets.all(width < 600 ? 12 : 20),
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ================= HEADER =================
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                runSpacing: 10,
                children: [
                  const Text(
                    "Mock Test Management",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  Wrap(
                    spacing: 10,
                    children: [
                      _primaryButton(
                        title: "+ Add Test",
                        onTap: ctrl.selectedCategory.value.isEmpty
                            ? null
                            : () => _showAddTestDialog(ctrl, context),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 15),

              /// ================= CATEGORY =================
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
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
                    onChanged: (v) {
                      ctrl.selectedCategory.value = v ?? '';
                    },
                  ),
                ),
              ),

              const SizedBox(height: 15),

              /// ================= LIST =================
              Expanded(
                child: ctrl.selectedCategory.value.isEmpty
                    ? _empty("Please select category")
                    : StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('mock_tests')
                            .doc(ctrl.selectedCategory.value)
                            .collection('tests')
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
                            return _empty("No tests found");
                          }

                          return GridView.builder(
                            itemCount: docs.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: width < 600 ? 10 : 16,
                                  mainAxisSpacing: width < 600 ? 10 : 16,
                                  childAspectRatio: width < 600 ? 1.1 : 1.2,
                                ),
                            itemBuilder: (_, i) {
                              final data = docs[i].data();
                              return _testCard(
                                ctrl,
                                docs[i].id,
                                data,
                                context,
                                width,
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
    );
  }

  // ================= TEST CARD =================
  Widget _testCard(
    AdminMockTestController ctrl,
    String id,
    Map<String, dynamic> data,
    BuildContext context,
    double width,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(blurRadius: 6, color: Colors.black.withOpacity(0.05)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// IMAGE
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              data['thumbnail'] ?? '',
              height: width < 600 ? 90 : 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const SizedBox(height: 90, child: Icon(Icons.image)),
            ),
          ),

          /// TEXT
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "${data['questionsCount']} Questions • ${data['duration']} min",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          const Spacer(),

          /// ACTIONS
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.quiz),
                onPressed: () {
                  Get.to(
                    () => QuestionsAdminPage(
                      categoryId: ctrl.selectedCategory.value,
                      testId: id,
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => ctrl.deleteTest(id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= BUTTON =================
  Widget _primaryButton({required String title, VoidCallback? onTap}) {
    return ElevatedButton(onPressed: onTap, child: Text(title));
  }

  // ================= EMPTY =================
  Widget _empty(String text) {
    return Center(
      child: Text(text, style: const TextStyle(color: Colors.grey)),
    );
  }

  // ================= ADD TEST =================
  void _showAddTestDialog(AdminMockTestController ctrl, BuildContext context) {
    final title = TextEditingController();
    final duration = TextEditingController();
    final questions = TextEditingController();
    final thumbnail = TextEditingController();
    final isFree = true.obs;

    Get.dialog(
      Dialog(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width < 600
                ? double.infinity
                : 420,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  "Create Mock Test",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: title,
                  decoration: const InputDecoration(
                    hintText: "Enter test title",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: duration,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "Duration (minutes)",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: questions,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "Number of questions",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: thumbnail,
                  decoration: const InputDecoration(
                    hintText: "Thumbnail URL",
                    border: OutlineInputBorder(),
                  ),
                ),

                Obx(
                  () => SwitchListTile(
                    title: const Text("Free Test"),
                    value: isFree.value,
                    onChanged: (v) => isFree.value = v,
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final dur = int.tryParse(duration.text) ?? 0;
                      final ques = int.tryParse(questions.text) ?? 0;

                      if (title.text.isEmpty || dur == 0 || ques == 0) {
                        Get.snackbar("Error", "Fill all fields correctly");
                        return;
                      }

                      ctrl.addMockTest(
                        title: title.text.trim(),
                        duration: dur,
                        questionsCount: ques,
                        thumbnail: thumbnail.text.trim(),
                        isFree: isFree.value,
                      );

                      Get.back();
                    },
                    child: const Text("Save Test"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
