import 'package:edu_prep_academy/controllers/dashboard_controller.dart';
import 'package:edu_prep_academy/core/theme/theme_controller.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ThemeController(), permanent: true);
    Get.put(AuthController(), permanent: true);
    Get.put(DashboardController(), permanent: true);
  }
}
