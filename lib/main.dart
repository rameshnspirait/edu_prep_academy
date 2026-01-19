import 'package:edu_prep_academy/bindings/initial_bindings.dart';
import 'package:edu_prep_academy/core/theme/app_theme.dart';
import 'package:edu_prep_academy/core/wrapper/auth_wrapper.dart';
import 'package:edu_prep_academy/firebase_options.dart';
import 'package:edu_prep_academy/routes/app_pages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

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
