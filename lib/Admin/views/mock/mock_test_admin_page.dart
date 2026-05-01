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

    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1100;

    int crossAxisCount = 4;
    if (isMobile) crossAxisCount = 1;
    if (isTablet) crossAxisCount = 2;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: Stack(
        children: [
          SafeArea(
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
                    isMobile
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Mock Test Management",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "Manage and organize your tests",
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _primaryButton(
                                        title: "+ Add Test",
                                        onTap:
                                            ctrl.selectedCategory.value.isEmpty
                                            ? null
                                            : () => _showAddTestDialog(
                                                ctrl,
                                                context,
                                              ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _primaryButton(
                                        title: "Bulk Upload",
                                        onTap:
                                            ctrl.selectedCategory.value.isEmpty
                                            ? null
                                            : () => _bulkTestDialog(ctrl),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Mock Test Management",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Manage and organize your tests",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              _primaryButton(
                                title: "+ Add Test",
                                onTap: ctrl.selectedCategory.value.isEmpty
                                    ? null
                                    : () => _showAddTestDialog(ctrl, context),
                              ),
                            ],
                          ),
                    const SizedBox(height: 16),

                    /// ================= CATEGORY =================
                    Container(
                      width: double.infinity,
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
                              .map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(c)),
                              )
                              .toList(),
                          onChanged: (v) {
                            ctrl.selectedCategory.value = v ?? '';
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: .end,
                      children: [
                        TextButton.icon(
                          onPressed: () => _deleteAllTests(ctrl),
                          icon: const Icon(
                            Icons.delete_forever,
                            color: Colors.red,
                          ),
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
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 12,
                                        childAspectRatio: isMobile ? 1.05 : 1.2,
                                      ),
                                  itemBuilder: (_, i) {
                                    final data = docs[i].data();
                                    return _testCard(
                                      ctrl,
                                      docs[i].id,
                                      data,
                                      context,
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

          /// LOADING OVERLAY
          Obx(() {
            if (!ctrl.isDeleting.value) return const SizedBox();

            return Container(
              color: Colors.black.withOpacity(0.4),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Obx(
                    () => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 12),
                        Text(
                          ctrl.deleteMessage.value,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await ctrl.refreshAllData();
        },
        child: Icon(Icons.refresh),
      ),
    );
  }

  // ================= DELETE ALL TESTS =================
  void _deleteAllTests(AdminMockTestController ctrl) {
    Get.dialog(
      AlertDialog(
        title: const Text("Delete All Tests"),
        content: const Text("Are you sure?"),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await ctrl.deleteAllMockTestsCollection();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  /// ================ BULK UPLOAD DIALOG =================
  void _bulkTestDialog(AdminMockTestController ctrl) {
    final jsonCtrl = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text("Bulk Upload Tests"),
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
              Get.back(); // ✅ close first

              await ctrl.addBulkCategoriesQuestions(jsonCtrl.text);

              // close loader
            },
            child: const Text("Upload"),
          ),
        ],
      ),
    );
  }

  // ================= TEST CARD =================
  Widget _testCard(
    AdminMockTestController ctrl,
    String id,
    Map<String, dynamic> data,
    BuildContext context,
    bool isMobile,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(blurRadius: 8, color: Colors.black.withOpacity(0.05)),
        ],
      ),
      child: Column(
        children: [
          /// IMAGE
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Image.network(
              data['thumbnail'] ?? '',
              height: isMobile ? 100 : 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: isMobile ? 100 : 120,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image),
              ),
            ),
          ),

          /// CONTENT
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Text(
                  data['title'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  "${data['totalQuestions']} Questions • ${data['duration']} min",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          const Spacer(),

          /// ACTIONS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.quiz, size: 18),
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
                  icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                  onPressed: () => ctrl.deleteTest(id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= BUTTON =================
  Widget _primaryButton({required String title, VoidCallback? onTap}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(title),
    );
  }

  // ================= EMPTY =================
  Widget _empty(String text) {
    return Center(
      child: Text(text, style: const TextStyle(color: Colors.grey)),
    );
  }

  // ================= DIALOG =================
  void _showAddTestDialog(AdminMockTestController ctrl, BuildContext context) {
    final title = TextEditingController();
    final duration = TextEditingController();
    final questions = TextEditingController();
    final thumbnail = TextEditingController();
    final isFree = true.obs;

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  "Create Mock Test",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                _input(title, "Test Title"),
                _input(duration, "Duration (minutes)", isNumber: true),
                _input(questions, "Number of questions", isNumber: true),
                _input(thumbnail, "Thumbnail URL"),

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
                        categoryId: ctrl.selectedCategory.value,
                        categoryName: ctrl.categories.firstWhere(
                          (c) => c == ctrl.selectedCategory.value,
                          orElse: () => '',
                        ),
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

  Widget _input(TextEditingController c, String hint, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
