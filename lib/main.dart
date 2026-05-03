import 'package:edu_prep_academy/User/bindings/initial_bindings.dart';
import 'package:edu_prep_academy/User/controllers/auth_controller.dart';
import 'package:edu_prep_academy/User/core/theme/app_theme.dart';
import 'package:edu_prep_academy/User/core/wrapper/auth_wrapper.dart';
import 'package:edu_prep_academy/User/routes/app_pages.dart';
import 'package:edu_prep_academy/User/core/DB/hive_service.dart';
import 'package:edu_prep_academy/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Get.put(AuthController(), permanent: true);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'EduPrep Academy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialBinding: InitialBinding(),
      home: const AuthWrapper(),
      getPages: AppPages.routes,
    );
  }
}
