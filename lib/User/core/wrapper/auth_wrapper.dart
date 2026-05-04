import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_prep_academy/Admin/bindings/admin_binding.dart';
import 'package:edu_prep_academy/Admin/views/home/admin_home_page.dart';
import 'package:edu_prep_academy/User/core/DB/hive_service.dart';
import 'package:edu_prep_academy/User/views/auth/auth_view.dart';
import 'package:edu_prep_academy/User/views/dashbaord/dashboard_view.dart';
import 'package:edu_prep_academy/User/views/home/home_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        /// ⏳ AUTH LOADING
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        ///  NOT LOGGED IN
        if (!authSnapshot.hasData) {
          return AuthView();
        }

        final user = authSnapshot.data!;

        ///  STEP 1: FETCH USER ROLE
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: HomeShimmer());
            }

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return const Scaffold(
                body: Center(child: Text("User data not found")),
              );
            }

            final data = userSnapshot.data!.data() as Map<String, dynamic>;
            final role = data['role'] ?? 'student';

            ///  STEP 2: OPEN HIVE USER BOX
            return FutureBuilder(
              future: HiveService.openUserBox(user.uid),
              builder: (context, hiveSnapshot) {
                if (hiveSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(body: HomeShimmer());
                }

                ///  STEP 3: ROLE BASED NAVIGATION
                if (role == 'admin') {
                  AdminBinding().dependencies();
                  return const AdminHomePage();
                } else {
                  return const DashboardView();
                }
              },
            );
          },
        );
      },
    );
  }
}
