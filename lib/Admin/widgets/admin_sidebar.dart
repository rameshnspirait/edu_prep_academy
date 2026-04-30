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
    return Obx(() {
      final isOpen = layoutCtrl.isSidebarOpen.value;

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            /// 🔝 HEADER
            Row(
              children: [
                IconButton(
                  onPressed: layoutCtrl.toggleSidebar,
                  icon: const Icon(Icons.menu, color: Colors.white),
                ),
                if (isOpen)
                  const Text(
                    "Admin",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            /// MENU ITEMS
            _menuItem(Icons.dashboard, "Dashboard", 0, isOpen),
            _menuItem(Icons.menu_book, "Notes", 1, isOpen),
            _menuItem(Icons.quiz, "Mock Tests", 2, isOpen),

            const Spacer(),

            /// LOGOUT (optional)
            if (isOpen)
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {},
              ),
          ],
        ),
      );
    });
  }

  Widget _menuItem(IconData icon, String title, int index, bool isOpen) {
    return Obx(() {
      final isActive = navCtrl.selectedIndex.value == index;

      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => navCtrl.changePage(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              // color: isActive
              //     ? Colors.blue.withOpacity(0.2)
              //     : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, color: isActive ? Colors.blue : Colors.white70),
                if (isOpen) ...[
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      color: isActive ? Colors.blue : Colors.white,
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }
}
