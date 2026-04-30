import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_notes_controller.dart';

class NotesAdminPage extends StatelessWidget {
  const NotesAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(AdminNotesController());
    final width = MediaQuery.of(context).size.width;

    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1100;

    int crossAxisCount = 4;
    if (isMobile) crossAxisCount = 1;
    if (isTablet) crossAxisCount = 2;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 24,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ================= HEADER =================
              isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Notes Management",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Manage your notes easily",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _primaryButton(
                              "Category",
                              Icons.category,
                              () => _addCategoryDialog(ctrl, context),
                            ),
                            _primaryButton("Add Note", Icons.add, () {
                              if (ctrl.selectedCategory.value.isEmpty) {
                                Get.snackbar("Error", "Select category first");
                                return;
                              }
                              _addNoteDialog(ctrl, context);
                            }),
                          ],
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
                              "Notes Management",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Manage categories and notes",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        Wrap(
                          spacing: 10,
                          children: [
                            _primaryButton(
                              "Add Category",
                              Icons.category,
                              () => _addCategoryDialog(ctrl, context),
                            ),
                            _primaryButton("Add Note", Icons.add, () {
                              if (ctrl.selectedCategory.value.isEmpty) {
                                Get.snackbar("Error", "Select category first");
                                return;
                              }
                              _addNoteDialog(ctrl, context);
                            }),
                          ],
                        ),
                      ],
                    ),

              const SizedBox(height: 16),

              /// ================= DROPDOWN =================
              Obx(
                () => Container(
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
              ),

              const SizedBox(height: 16),

              /// ================= NOTES =================
              Expanded(
                child: Obx(() {
                  if (ctrl.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (ctrl.selectedCategory.value.isEmpty) {
                    return _empty("Select category");
                  }

                  if (ctrl.notes.isEmpty) {
                    return _empty("No notes available");
                  }

                  return GridView.builder(
                    itemCount: ctrl.notes.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: isMobile ? 1.05 : 1.2,
                    ),
                    itemBuilder: (_, i) {
                      final note = ctrl.notes[i];
                      return _card(ctrl, note);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= NOTE CARD =================
  Widget _card(AdminNotesController ctrl, dynamic note) {
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
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Image.network(
              note.thumbnail,
              height: 110,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 110,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Text(
                  note.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 5),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => _editNoteDialog(ctrl, note),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                onPressed: () => ctrl.deleteNote(note.id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= BUTTON =================
  Widget _primaryButton(String text, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _empty(String text) {
    return Center(
      child: Text(text, style: const TextStyle(color: Colors.grey)),
    );
  }

  // ================= DIALOGS =================
  void _addCategoryDialog(AdminNotesController ctrl, BuildContext context) {
    final c = TextEditingController();

    Get.dialog(
      Dialog(
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Create Category"),
              TextField(controller: c),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  ctrl.createCategory(c.text);
                  Get.back();
                },
                child: const Text("Create"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addNoteDialog(AdminNotesController ctrl, BuildContext context) {
    final t = TextEditingController();
    final c = TextEditingController();
    final p = TextEditingController();
    final th = TextEditingController();

    Get.dialog(
      Dialog(
        child: SingleChildScrollView(
          child: Container(
            width: 380,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: t,
                  decoration: const InputDecoration(hintText: "Title"),
                ),
                TextField(
                  controller: c,
                  decoration: const InputDecoration(hintText: "Content"),
                ),
                TextField(
                  controller: p,
                  decoration: const InputDecoration(hintText: "PDF URL"),
                ),
                TextField(
                  controller: th,
                  decoration: const InputDecoration(hintText: "Thumbnail"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    ctrl.addNote(t.text, c.text, p.text, th.text);
                    Get.back();
                  },
                  child: const Text("Save"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _editNoteDialog(AdminNotesController ctrl, dynamic note) {
    final t = TextEditingController(text: note.title);
    final c = TextEditingController(text: note.content);
    final p = TextEditingController(text: note.pdfUrl);
    final th = TextEditingController(text: note.thumbnail);

    Get.dialog(
      Dialog(
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: t),
              TextField(controller: c),
              TextField(controller: p),
              TextField(controller: th),
              ElevatedButton(
                onPressed: () {
                  ctrl.updateNote(note.id, t.text, c.text, p.text, th.text);
                  Get.back();
                },
                child: const Text("Update"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
