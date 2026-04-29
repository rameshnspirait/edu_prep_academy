import 'package:edu_prep_academy/Admin/views/dashboard/admin_dashboard_page.dart';
import 'package:edu_prep_academy/Admin/views/mock/mock_test_admin_page.dart';
import 'package:edu_prep_academy/Admin/views/notes/notes_admin_page.dart';
import 'package:edu_prep_academy/Admin/views/questions/questions_admin_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_nav_controller.dart';

class AdminBody extends StatelessWidget {
  const AdminBody({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AdminNavController>();

    return Obx(() {
      switch (ctrl.selectedIndex.value) {
        case 0:
          return const AdminDashboard();
        case 1:
          return const NotesAdminPage();
        case 2:
          return const AdminMockTestPage();
        default:
          return const AdminDashboard();
      }
    });
  }
}
