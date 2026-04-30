import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_questions_controller.dart';

class QuestionsAdminPage extends StatelessWidget {
  final String categoryId;
  final String testId;

  const QuestionsAdminPage({
    super.key,
    required this.categoryId,
    required this.testId,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(AdminQuestionsController());

    ctrl.init(category: categoryId, test: testId);

    return Scaffold(
      appBar: AppBar(title: const Text("Questions")),

      body: Column(
        children: [
          /// ADD BUTTON
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _addDialog(ctrl),
                    child: const Text("+ Add Question"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _bulkDialog(ctrl),
                    child: const Text("Bulk Upload"),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _confirmDeleteAll(ctrl),
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                label: const Text(
                  "Delete All",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),

          /// LIST
          Expanded(
            child: Obx(() {
              if (ctrl.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (ctrl.questions.isEmpty) {
                return const Center(child: Text("No Questions Found"));
              }

              return ListView.builder(
                itemCount: ctrl.questions.length,
                itemBuilder: (_, i) {
                  final q = ctrl.questions[i];

                  final options = List<String>.from(q['options'] ?? []);

                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(q['question']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int j = 0; j < options.length; j++)
                            Text("${['A', 'B', 'C', 'D'][j]}. ${options[j]}"),

                          const SizedBox(height: 5),

                          Text(
                            "Correct: ${['A', 'B', 'C', 'D'][q['correctIndex']]}",
                            style: const TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => ctrl.deleteQuestion(q['id']),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  //=================== DELETE ALL CONFIRMATION =================
  void _confirmDeleteAll(AdminQuestionsController ctrl) {
    Get.dialog(
      AlertDialog(
        title: const Text("Delete All Questions"),
        content: const Text("Are you sure? This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await ctrl.deleteAllQuestions();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  //=================== BULK UPLOAD DIALOG =================
  void _bulkDialog(AdminQuestionsController ctrl) {
    final jsonCtrl = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text("Bulk Upload Questions"),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: jsonCtrl,
            maxLines: 15,
            decoration: const InputDecoration(
              hintText: "Paste JSON here...",
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              Get.back();

              Get.dialog(
                const Center(child: CircularProgressIndicator()),
                barrierDismissible: false,
              );

              await ctrl.addBulkQuestions(jsonCtrl.text);

              Get.back(); // close loader
            },
            child: const Text("Upload"),
          ),
        ],
      ),
    );
  }

  // ================= ADD DIALOG =================
  void _addDialog(AdminQuestionsController ctrl) {
    final question = TextEditingController();
    final a = TextEditingController();
    final b = TextEditingController();
    final c = TextEditingController();
    final d = TextEditingController();
    final explanation = TextEditingController();
    final correct = 0.obs;

    Get.dialog(
      AlertDialog(
        title: const Text("Add Question"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: question,
                decoration: const InputDecoration(labelText: "Question"),
              ),
              TextField(
                controller: a,
                decoration: const InputDecoration(labelText: "Option A"),
              ),
              TextField(
                controller: b,
                decoration: const InputDecoration(labelText: "Option B"),
              ),
              TextField(
                controller: c,
                decoration: const InputDecoration(labelText: "Option C"),
              ),
              TextField(
                controller: d,
                decoration: const InputDecoration(labelText: "Option D"),
              ),
              TextField(
                controller: explanation,
                decoration: const InputDecoration(labelText: "Explanation"),
              ),

              const SizedBox(height: 10),

              Obx(
                () => DropdownButton<int>(
                  value: correct.value,
                  items: const [
                    DropdownMenuItem(value: 0, child: Text("A")),
                    DropdownMenuItem(value: 1, child: Text("B")),
                    DropdownMenuItem(value: 2, child: Text("C")),
                    DropdownMenuItem(value: 3, child: Text("D")),
                  ],
                  onChanged: (v) => correct.value = v!,
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              ctrl.addQuestion(
                question: question.text,
                options: [a.text, b.text, c.text, d.text],
                correctIndex: correct.value,
                explanation: explanation.text,
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
