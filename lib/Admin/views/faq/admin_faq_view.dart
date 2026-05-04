import 'package:edu_prep_academy/Admin/controllers/admin_faq_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminFaqView extends StatelessWidget {
  AdminFaqView({super.key});

  final controller = Get.put(AdminFaqController());

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("FAQ Management"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () => _confirmDeleteAll(),
          ),
        ],
      ),
      body: Obx(() {
        return Column(
          children: [
            /// ================= JSON INPUT =================
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: controller.jsonController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: "Paste FAQ JSON here...",
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF1E1E1E)
                      : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            /// ================= UPLOAD BUTTON =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.uploadBulkFaq,
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Upload FAQs"),
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// ================= FAQ LIST =================
            Expanded(
              child: controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: controller.faqs.length,
                      itemBuilder: (_, i) {
                        final faq = controller.faqs[i];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          child: ListTile(
                            title: Text(faq['question'] ?? ''),
                            subtitle: Text(faq['answer'] ?? ''),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => controller.deleteFaq(faq['id']),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  /// ================= CONFIRM DELETE ALL =================
  void _confirmDeleteAll() {
    Get.defaultDialog(
      title: "Delete All FAQs",
      middleText: "Are you sure you want to delete all FAQs?",
      textConfirm: "Yes",
      textCancel: "No",
      onConfirm: () {
        Get.back();
        controller.deleteAllFaqs();
      },
    );
  }
}
