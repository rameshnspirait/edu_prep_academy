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

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          return Column(
            children: [
              // ================= CATEGORY DROPDOWN =================
              Row(
                children: [
                  DropdownButton<String>(
                    value: ctrl.selectedCategory.value.isEmpty
                        ? null
                        : ctrl.selectedCategory.value,

                    hint: const Text("Select Category"),

                    items: ctrl.categories
                        .map<DropdownMenuItem<String>>(
                          (c) => DropdownMenuItem(value: c, child: Text(c)),
                        )
                        .toList(),

                    onChanged: (v) {
                      ctrl.selectedCategory.value = v ?? '';
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ================= ADD TEST =================
              ElevatedButton(
                onPressed: ctrl.selectedCategory.value.isEmpty
                    ? null
                    : () => _showAddTestDialog(ctrl),
                child: const Text("+ Add Mock Test"),
              ),

              const SizedBox(height: 20),

              // ================= TEST LIST =================
              Expanded(
                child: ctrl.selectedCategory.value.isEmpty
                    ? const Center(child: Text("Please select category"))
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
                            return const Center(child: Text("No Tests Found"));
                          }

                          return ListView.builder(
                            itemCount: docs.length,
                            itemBuilder: (_, i) {
                              final data = docs[i].data();

                              return Card(
                                child: ListTile(
                                  title: Text(data['title'] ?? ''),

                                  subtitle: Text(
                                    "${data['questionsCount']} Questions | ${data['duration']} min",
                                  ),

                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // 🧠 OPEN QUESTIONS
                                      IconButton(
                                        icon: const Icon(Icons.quiz),
                                        onPressed: () {
                                          Get.to(
                                            () => QuestionsAdminPage(
                                              categoryId:
                                                  ctrl.selectedCategory.value,
                                              testId: docs[i].id,
                                            ),
                                          );
                                        },
                                      ),

                                      // 🗑 DELETE
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          ctrl.deleteTest(docs[i].id);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
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

  // ================= ADD TEST DIALOG =================
  void _showAddTestDialog(AdminMockTestController ctrl) {
    final title = TextEditingController();
    final duration = TextEditingController();
    final questions = TextEditingController();
    final thumbnail = TextEditingController();
    final isFree = true.obs;

    Get.dialog(
      AlertDialog(
        title: const Text("Create Mock Test"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: title,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: duration,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Duration"),
              ),
              TextField(
                controller: questions,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Questions"),
              ),
              TextField(
                controller: thumbnail,
                decoration: const InputDecoration(labelText: "Thumbnail URL"),
              ),

              const SizedBox(height: 10),

              Obx(
                () => SwitchListTile(
                  title: const Text("Free Test"),
                  value: isFree.value,
                  onChanged: (v) => isFree.value = v,
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              ctrl.addMockTest(
                title: title.text.trim(),
                duration: int.parse(duration.text),
                questionsCount: int.parse(questions.text),
                thumbnail: thumbnail.text.trim(),
                isFree: isFree.value,
              );

              Get.back();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
