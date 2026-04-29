import 'package:edu_prep_academy/User/views/auth/login_view.dart';
import 'package:edu_prep_academy/User/views/dashbaord/dashboard_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Optional: small loader
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          // AdminBinding().dependencies();
          return const DashboardView();
        }

        return LoginView();
      },
    );
  }
}
