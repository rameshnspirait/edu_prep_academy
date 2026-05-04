import 'package:edu_prep_academy/User/controllers/feedback_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FeedbackView extends StatelessWidget {
  FeedbackView({super.key});
  final controller = Get.put(FeedbackController());

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Feedback"),
        centerTitle: true,
        elevation: 8,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔵 HEADER
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.indigo, Colors.blue],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [
                  Icon(Icons.feedback, color: Colors.white, size: 40),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Help us improve your experience",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// ⭐ RATING
            _sectionTitle("Rate Your Experience"),
            const SizedBox(height: 10),

            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  return IconButton(
                    onPressed: () => controller.rating.value = starIndex,
                    icon: Icon(
                      Icons.star,
                      size: 32,
                      color: controller.rating.value >= starIndex
                          ? Colors.amber
                          : Colors.grey,
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 20),

            /// 😊 EMOJI SELECTOR
            _sectionTitle("How do you feel?"),
            const SizedBox(height: 10),

            Obx(
              () => Wrap(
                spacing: 10,
                children: ["😡", "😕", "😐", "😊", "😍"].map((emoji) {
                  final isSelected = controller.selectedEmoji.value == emoji;

                  return GestureDetector(
                    onTap: () => controller.selectedEmoji.value = emoji,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 24)),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            /// 📂 CATEGORY
            _sectionTitle("Category"),
            const SizedBox(height: 10),

            Obx(
              () => Wrap(
                spacing: 8,
                children: controller.categories.map((cat) {
                  final isSelected = controller.selectedCategory.value == cat;

                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: Colors.blue,
                    checkmarkColor: Colors.white,
                    onSelected: (_) => controller.selectedCategory.value = cat,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : null,
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            /// 📝 MESSAGE
            _sectionTitle("Your Feedback"),
            const SizedBox(height: 10),

            TextField(
              controller: controller.messageCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Write your feedback...",
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

            const SizedBox(height: 30),

            /// 🚀 SUBMIT
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.submitFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Submit Feedback",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
