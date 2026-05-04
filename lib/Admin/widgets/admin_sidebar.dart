import 'package:edu_prep_academy/User/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edu_prep_academy/Admin/controllers/admin_layout_controller.dart';
import 'package:edu_prep_academy/Admin/controllers/admin_nav_controller.dart';

class AdminSidebar extends StatelessWidget {
  AdminSidebar({super.key});

  final layoutCtrl = Get.find<AdminLayoutController>();
  final navCtrl = Get.find<AdminNavController>();
  final authCtrl = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isOpen = layoutCtrl.isSidebarOpen.value;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: isOpen ? 230 : 75,
        decoration: BoxDecoration(
          color: Colors.white, // ✅ LIGHT BACKGROUND
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(2, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),

            /// ================= HEADER =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  if (isOpen) ...[
                    const SizedBox(width: 6),

                    /// AVATAR
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.blue,
                      child: Text("R", style: TextStyle(color: Colors.white)),
                    ),

                    const SizedBox(width: 10),

                    /// NAME + ROLE
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Ramesh",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "Admin",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            /// DIVIDER
            Divider(color: Colors.grey.shade300, thickness: 1),

            const SizedBox(height: 10),

            /// ================= MENU =================
            _menuItem(Icons.dashboard, "Dashboard", 0, isOpen),
            _menuItem(Icons.menu_book, "Notes", 1, isOpen),
            _menuItem(Icons.quiz, "Mock Tests", 2, isOpen),
            _menuItem(Icons.quiz, "Daily Quiz", 3, isOpen),
            _menuItem(Icons.help_outline, "FAQ", 4, isOpen),

            const Spacer(),

            /// ================= LOGOUT =================
            Padding(
              padding: const EdgeInsets.all(10),
              child: _logoutTile(isOpen),
            ),
          ],
        ),
      );
    });
  }

  // ================= MENU ITEM =================
  Widget _menuItem(IconData icon, String title, int index, bool isOpen) {
    return Obx(() {
      final isActive = navCtrl.selectedIndex.value == index;

      return InkWell(
        onTap: () => navCtrl.changePage(index),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.blue.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isActive
                ? const Border(left: BorderSide(color: Colors.blue, width: 3))
                : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: isActive ? Colors.blue : Colors.black54),

              if (isOpen) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isActive ? Colors.blue : Colors.black87,
                      fontWeight: isActive
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  // ================= LOGOUT =================
  Widget _logoutTile(bool isOpen) {
    return InkWell(
      onTap: () async {
        await authCtrl.logout();
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.logout, color: Colors.red),

            if (isOpen) ...[
              const SizedBox(width: 10),
              const Text("Logout", style: TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
