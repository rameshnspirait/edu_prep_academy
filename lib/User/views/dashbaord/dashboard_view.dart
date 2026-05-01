import 'package:edu_prep_academy/User/controllers/dashboard_controller.dart';
import 'package:edu_prep_academy/User/controllers/mock_test_controller.dart';
import 'package:edu_prep_academy/User/controllers/notes_controller.dart';
import 'package:edu_prep_academy/User/controllers/profile_controller.dart';
import 'package:edu_prep_academy/User/views/dashbaord/home_tab.dart';
import 'package:edu_prep_academy/User/views/profile/profile_view.dart';
import 'package:edu_prep_academy/User/views/mocks/mock_tests_view.dart';
import 'package:edu_prep_academy/User/views/notes/note_view.dart';
import 'package:edu_prep_academy/User/widgets/custom_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        switch (controller.currentIndex.value) {
          case 0:
            return const HomeTab();
          case 1:
            Get.put(NotesController());
            return NotesView();
          case 2:
            Get.put(MockTestsController());
            return MockTestsView();
          case 3:
            Get.delete<ProfileController>();
            Get.put(ProfileController());
            return const ProfileView();
          default:
            return const HomeTab();
        }
      }),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }
}
