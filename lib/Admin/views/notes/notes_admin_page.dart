import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_notes_controller.dart';

class NotesAdminPage extends StatelessWidget {
  const NotesAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(AdminNotesController());

    final width = MediaQuery.of(context).size.width;

    /// 🔥 RESPONSIVE GRID COUNT
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= HEADER =================
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                const Text(
                  "Notes Management",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                Wrap(
                  spacing: 10,
                  children: [
                    _primaryButton(
                      title: "+ Category",
                      onTap: () => _addCategoryDialog(ctrl, context),
                    ),
                    _primaryButton(
                      title: "+ Add Note",
                      onTap: () {
                        if (ctrl.selectedCategory.value.isEmpty) {
                          Get.snackbar("Error", "Select category first");
                          return;
                        }
                        _addNoteDialog(ctrl, context);
                      },
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 15),

            /// ================= DROPDOWN =================
            Obx(
              () => Container(
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
                    onChanged: (val) {
                      ctrl.selectedCategory.value = val!;
                      ctrl.loadNotes();
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// ================= NOTES =================
            Expanded(
              child: Obx(() {
                if (ctrl.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (ctrl.selectedCategory.value.isEmpty) {
                  return _emptyState("Select a category");
                }

                if (ctrl.notes.isEmpty) {
                  return _emptyState("No notes available");
                }

                return GridView.builder(
                  itemCount: ctrl.notes.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: width < 600 ? 10 : 16,
                    mainAxisSpacing: width < 600 ? 10 : 16,
                    childAspectRatio: width < 600 ? 1.1 : 1.2,
                  ),
                  itemBuilder: (_, index) {
                    final note = ctrl.notes[index];
                    return _noteCard(ctrl, note, width);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ================= NOTE CARD =================
  Widget _noteCard(AdminNotesController ctrl, dynamic note, double width) {
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
              note.thumbnail,
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
                  note.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  note.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
                  icon: const Icon(Icons.edit, size: 18),
                  onPressed: () => _editNoteDialog(ctrl, note),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  onPressed: () => ctrl.deleteNote(note.id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= BUTTON =================
  Widget _primaryButton({required String title, required VoidCallback onTap}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onTap,
      child: Text(title),
    );
  }

  // ================= EMPTY =================
  Widget _emptyState(String text) {
    return Center(
      child: Text(text, style: const TextStyle(color: Colors.grey)),
    );
  }

  // ================= DIALOGS =================
  void _addCategoryDialog(AdminNotesController ctrl, BuildContext context) {
    final controller = TextEditingController();

    Get.dialog(
      Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width < 600
              ? double.infinity
              : 400,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Create New Category",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: "Enter category name (e.g. Reasoning, Math)",
                  helperText: "This will group your notes",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (controller.text.trim().isEmpty) {
                      Get.snackbar("Error", "Category name required");
                      return;
                    }

                    ctrl.createCategory(controller.text.trim());
                    Get.back();
                  },
                  child: const Text("Create Category"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addNoteDialog(AdminNotesController ctrl, BuildContext context) {
    final title = TextEditingController();
    final content = TextEditingController();
    final pdf = TextEditingController();
    final thumb = TextEditingController();

    Get.dialog(
      Dialog(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width < 600
                ? double.infinity
                : 420,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Add New Note",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: title,
                  decoration: const InputDecoration(
                    hintText: "Enter note title (e.g. SSC GD Math Notes)",
                    helperText: "Visible to students",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: content,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: "Short description about this note",
                    helperText: "Explain what students will learn",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: pdf,
                  decoration: const InputDecoration(
                    hintText: "Paste PDF URL (Google Drive / Firebase)",
                    helperText: "Must be a valid downloadable link",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: thumb,
                  decoration: const InputDecoration(
                    hintText: "Thumbnail image URL",
                    helperText: "Used for preview image",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (title.text.isEmpty ||
                          content.text.isEmpty ||
                          pdf.text.isEmpty) {
                        Get.snackbar(
                          "Error",
                          "Please fill all required fields",
                        );
                        return;
                      }

                      ctrl.addNote(
                        title.text.trim(),
                        content.text.trim(),
                        pdf.text.trim(),
                        thumb.text.trim(),
                      );

                      Get.back();
                    },
                    child: const Text("Save Note"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _editNoteDialog(AdminNotesController ctrl, dynamic note) {
    final title = TextEditingController(text: note.title);
    final content = TextEditingController(text: note.content);
    final pdf = TextEditingController(text: note.pdfUrl);
    final thumb = TextEditingController(text: note.thumbnail);

    Get.dialog(
      Dialog(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                "Edit Note",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: title,
                decoration: const InputDecoration(
                  hintText: "Update title",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: content,
                decoration: const InputDecoration(
                  hintText: "Update description",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: pdf,
                decoration: const InputDecoration(
                  hintText: "Update PDF URL",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: thumb,
                decoration: const InputDecoration(
                  hintText: "Update thumbnail",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ctrl.updateNote(
                      note.id,
                      title.text,
                      content.text,
                      pdf.text,
                      thumb.text,
                    );
                    Get.back();
                  },
                  child: const Text("Update Note"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
