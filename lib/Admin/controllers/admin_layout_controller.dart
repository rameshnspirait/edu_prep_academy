import 'package:get/get.dart';

class AdminLayoutController extends GetxController {
  RxBool isSidebarOpen = true.obs;

  void toggleSidebar() {
    isSidebarOpen.value = !isSidebarOpen.value;
  }
}
