import 'package:edu_prep_academy/Admin/controllers/admin_dashboard_controller.dart';
import 'package:edu_prep_academy/Admin/controllers/admin_layout_controller.dart';
import 'package:edu_prep_academy/Admin/controllers/admin_questions_controller.dart';
import 'package:edu_prep_academy/Admin/controllers/admin_test_controller.dart';
import 'package:edu_prep_academy/User/controllers/daily_quiz_controller.dart';
import 'package:get/get.dart';
import '../controllers/admin_nav_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AdminNavController());
    Get.put(AdminLayoutController());
    Get.put(AdminMockTestController());
    Get.put(AdminQuestionsController());
    Get.put(AdminDashboardController());
    Get.put(DailyQuizController());
  }
}
