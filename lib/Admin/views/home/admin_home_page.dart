import 'package:edu_prep_academy/Admin/controllers/admin_layout_controller.dart';
import 'package:edu_prep_academy/Admin/widgets/admin_body.dart';
import 'package:edu_prep_academy/Admin/widgets/admin_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final layoutCtrl = Get.put(AdminLayoutController());

    return Scaffold(
      appBar: AppBar(title: const Text("Admin Panel")),
      body: Obx(() {
        return Row(
          children: [
            /// 🔥 SIDEBAR
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: layoutCtrl.isSidebarOpen.value ? 220 : 70,
              child: AdminSidebar(),
            ),

            /// 🔥 MAIN CONTENT
            const Expanded(child: AdminBody()),
          ],
        );
      }),
    );
  }
}
