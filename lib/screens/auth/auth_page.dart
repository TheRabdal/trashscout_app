import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trash_scout/screens/admin/main_admin_screen.dart';
import 'package:trash_scout/screens/auth/login_screen.dart';
import 'package:trash_scout/screens/user/main_screen.dart';
import 'package:trash_scout/shared/theme/theme.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
              color: darkGreenColor,
            ));
          } else if (snapshot.hasData) {
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(snapshot.data!.uid)
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(
                    color: darkGreenColor,
                  ));
                } else if (userSnapshot.hasData &&
                    userSnapshot.data != null &&
                    userSnapshot.data!.exists) {
                  final data =
                      userSnapshot.data!.data() as Map<String, dynamic>?;
                  if (data != null && data.containsKey('role')) {
                    String role = data['role'];
                    if (role == 'admin') {
                      return AdminMainScreen();
                    } else {
                      return MainScreen();
                    }
                  } else {
                    // Field role tidak ada
                    return LoginScreen();
                  }
                } else {
                  // Dokumen user tidak ada
                  return LoginScreen();
                }
              },
            );
          } else {
            return LoginScreen();
          }
        },
      ),
    );
  }
}
