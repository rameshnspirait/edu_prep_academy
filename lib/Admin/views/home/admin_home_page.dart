import 'package:edu_prep_academy/Admin/controllers/admin_layout_controller.dart';
import 'package:edu_prep_academy/Admin/controllers/admin_nav_controller.dart';
import 'package:edu_prep_academy/Admin/widgets/admin_body.dart';
import 'package:edu_prep_academy/Admin/widgets/admin_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final layoutCtrl = Get.put(AdminLayoutController());
    Get.put(AdminNavController()); // ✅ FIX (IMPORTANT)

    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      drawer: isMobile ? AdminSidebar() : null, // ✅ mobile drawer

      appBar: AppBar(
        elevation: 2,
        title: const Text("Admin Panel"),
        leading: isMobile
            ? Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              )
            : IconButton(
                icon: const Icon(Icons.menu),
                onPressed: layoutCtrl.toggleSidebar,
              ),
      ),

      body: Row(
        children: [
          /// 💻 DESKTOP SIDEBAR
          if (!isMobile)
            Obx(() {
              final isOpen = layoutCtrl.isSidebarOpen.value;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: isOpen ? 240 : 80,

                decoration: BoxDecoration(
                  color: const Color(
                    0xFF0F172A,
                  ), // ✅ solid dark (NOT transparent)
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(2, 0), // 👉 right shadow
                    ),
                  ],
                ),

                child: Stack(
                  children: [
                    /// 👉 SLIDE EFFECT
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      left: isOpen ? 0 : -100, // 🔥 slide inside
                      top: 0,
                      bottom: 0,
                      right: 0,
                      child: AdminSidebar(),
                    ),
                  ],
                ),
              );
            }),

          /// 📄 CONTENT
          const Expanded(child: AdminBody()),
        ],
      ),
    );
  }
}
