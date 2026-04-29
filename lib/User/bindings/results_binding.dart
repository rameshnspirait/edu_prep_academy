import 'package:edu_prep_academy/User/controllers/results_controller.dart';
import 'package:get/get.dart';

class ResultsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResultsController>(() => ResultsController(), fenix: false);
  }
}
