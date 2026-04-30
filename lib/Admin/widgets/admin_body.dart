import 'package:edu_prep_academy/Admin/views/dashboard/admin_dashboard_page.dart';
import 'package:edu_prep_academy/Admin/views/mock/mock_test_admin_page.dart';
import 'package:edu_prep_academy/Admin/views/notes/notes_admin_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_nav_controller.dart';

class AdminBody extends StatelessWidget {
  const AdminBody({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AdminNavController>();

    return Container(
      color: const Color(0xFFF1F5F9), // 🔥 light background
      child: Obx(() {
        Widget page;

        switch (ctrl.selectedIndex.value) {
          case 0:
            page = const AdminDashboard();
            break;
          case 1:
            page = const NotesAdminPage();
            break;
          case 2:
            page = const AdminMockTestPage();
            break;
          default:
            page = const AdminDashboard();
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: page,
          ),
        );
      }),
    );
  }
}
