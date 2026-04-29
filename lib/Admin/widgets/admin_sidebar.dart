import 'package:edu_prep_academy/Admin/controllers/admin_layout_controller.dart';
import 'package:edu_prep_academy/Admin/controllers/admin_nav_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminSidebar extends StatelessWidget {
  AdminSidebar({super.key});

  final layoutCtrl = Get.find<AdminLayoutController>();
  final navCtrl = Get.find<AdminNavController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Obx(() {
        final isOpen = layoutCtrl.isSidebarOpen.value;

        return Column(
          children: [
            /// HEADER
            SizedBox(
              height: 60,
              child: Row(
                children: [
                  IconButton(
                    onPressed: layoutCtrl.toggleSidebar,
                    icon: const Icon(Icons.menu, color: Colors.black),
                  ),
                  if (isOpen)
                    const Text("Admin", style: TextStyle(color: Colors.black)),
                ],
              ),
            ),

            const Divider(color: Colors.white24),

            /// MENU
            _menuItem(Icons.dashboard, "Dashboard", 0, isOpen),
            _menuItem(Icons.menu_book, "Notes", 1, isOpen),
            _menuItem(Icons.quiz, "Mock Tests", 2, isOpen),
          ],
        );
      }),
    );
  }

  Widget _menuItem(IconData icon, String title, int index, bool isOpen) {
    return Obx(() {
      final isActive = navCtrl.selectedIndex.value == index;

      return ListTile(
        leading: Icon(icon, color: isActive ? Colors.blue : Colors.black),
        title: isOpen
            ? Text(
                title,
                style: TextStyle(color: isActive ? Colors.blue : Colors.black),
              )
            : null,
        tileColor: isActive ? Colors.white10 : Colors.transparent,
        onTap: () {
          navCtrl.changePage(index);
        },
      );
    });
  }
}
