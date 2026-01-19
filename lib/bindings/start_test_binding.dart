import 'package:edu_prep_academy/controllers/start_test_controller.dart';
import 'package:get/get.dart';

class StartTestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StartTestController>(() => StartTestController(), fenix: false);
  }
}
