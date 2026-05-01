import 'package:edu_prep_academy/User/controllers/daily_quiz_controller.dart';
import 'package:get/get.dart';

class DailyQuizBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DailyQuizController>(() => DailyQuizController(), fenix: false);
  }
}
