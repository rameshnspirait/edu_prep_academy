import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_notes_controller.dart';

class NotesAdminPage extends StatelessWidget {
  const NotesAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(AdminNotesController());

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// ================= CATEGORY ROW =================
            Row(
              children: [
                /// DROPDOWN
                Expanded(
                  child: Obx(
                    () => DropdownButtonFormField<String>(
                      hint: const Text("Select Category"),
                      value: ctrl.selectedCategory.value.isEmpty
                          ? null
                          : ctrl.selectedCategory.value,
                      items: ctrl.categories
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (val) {
                        ctrl.selectedCategory.value = val!;
                        ctrl.loadNotes();
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                /// ADD CATEGORY
                ElevatedButton(
                  onPressed: () => _addCategoryDialog(ctrl),
                  child: const Text("+ Category"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// ================= ADD NOTE =================
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  if (ctrl.selectedCategory.value.isEmpty) {
                    Get.snackbar("Error", "Select category first");
                    return;
                  }
                  _addNoteDialog(ctrl);
                },
                child: const Text("+ Add Note"),
              ),
            ),

            const SizedBox(height: 20),

            /// ================= NOTES LIST =================
            Expanded(
              child: Obx(() {
                if (ctrl.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (ctrl.selectedCategory.value.isEmpty) {
                  return const Center(child: Text("Select a category"));
                }

                if (ctrl.notes.isEmpty) {
                  return const Center(child: Text("No notes available"));
                }

                return ListView.builder(
                  itemCount: ctrl.notes.length,
                  itemBuilder: (_, index) {
                    final note = ctrl.notes[index];

                    return Card(
                      child: ListTile(
                        leading: Image.network(
                          note.thumbnail,
                          width: 50,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image),
                        ),
                        title: Text(note.title),
                        subtitle: Text(
                          note.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        /// ACTIONS
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editNoteDialog(ctrl, note),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => ctrl.deleteNote(note.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= ADD CATEGORY =================
  void _addCategoryDialog(AdminNotesController ctrl) {
    final controller = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text("Create Category"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Category Name"),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              ctrl.createCategory(controller.text);
              Get.back();
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  /// ================= ADD NOTE =================
  void _addNoteDialog(AdminNotesController ctrl) {
    final title = TextEditingController();
    final content = TextEditingController();
    final pdf = TextEditingController();
    final thumb = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text("Add Note"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: title,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: content,
                decoration: const InputDecoration(labelText: "Content"),
              ),
              TextField(
                controller: pdf,
                decoration: const InputDecoration(labelText: "PDF URL"),
              ),
              TextField(
                controller: thumb,
                decoration: const InputDecoration(labelText: "Thumbnail URL"),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              ctrl.addNote(title.text, content.text, pdf.text, thumb.text);
              Get.back();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  /// ================= EDIT NOTE =================
  void _editNoteDialog(AdminNotesController ctrl, note) {
    final title = TextEditingController(text: note.title);
    final content = TextEditingController(text: note.content);
    final pdf = TextEditingController(text: note.pdfUrl);
    final thumb = TextEditingController(text: note.thumbnail);

    Get.dialog(
      AlertDialog(
        title: const Text("Edit Note"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: title),
              TextField(controller: content),
              TextField(controller: pdf),
              TextField(controller: thumb),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
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
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }
}
