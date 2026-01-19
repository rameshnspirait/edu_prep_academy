import 'package:edu_prep_academy/controllers/mock_test_controller.dart';
import 'package:get/get.dart';

class MockTestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MockTestsController>(() => MockTestsController(), fenix: false);
  }
}
