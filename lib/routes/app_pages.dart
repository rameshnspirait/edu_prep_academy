import 'package:edu_prep_academy/bindings/initial_bindings.dart';
import 'package:edu_prep_academy/bindings/mock_test_binding.dart';
import 'package:edu_prep_academy/bindings/notes_binding.dart';
import 'package:edu_prep_academy/bindings/results_binding.dart';
import 'package:edu_prep_academy/bindings/start_test_binding.dart';
import 'package:edu_prep_academy/views/auth/login_view.dart';
import 'package:edu_prep_academy/views/dashbaord/dashboard_view.dart';
import 'package:edu_prep_academy/views/mocks/mock_tests_view.dart';
import 'package:edu_prep_academy/views/mocks/start_test_view.dart';
import 'package:edu_prep_academy/views/notes/note_view.dart';
import 'package:edu_prep_academy/views/results/result_view.dart';
import 'package:get/get.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();
  static const initial = AppRoutes.login;
  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.login,
      page: () => LoginView(),
      binding: InitialBinding(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: AppRoutes.dashboard,
      page: () => DashboardView(),
      binding: InitialBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.note,
      page: () => NotesView(),
      binding: NotesBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.mockTest,
      page: () => MockTestsView(),
      binding: MockTestBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.startTest,
      page: () => StartTestView(),
      binding: StartTestBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.results,
      page: () => ResultsView(),
      binding: ResultsBinding(),
      transition: Transition.fadeIn,
    ),

    ///////Profiles Options Pages
  ];
}
