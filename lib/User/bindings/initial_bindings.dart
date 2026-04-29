import 'package:edu_prep_academy/User/controllers/auth_controller.dart';
import 'package:edu_prep_academy/User/controllers/dashboard_controller.dart';
import 'package:edu_prep_academy/User/core/theme/theme_controller.dart';
import 'package:get/get.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ThemeController(), permanent: true);
    Get.put(AuthController(), permanent: true);
    Get.put(DashboardController(), permanent: true);
  }
}
