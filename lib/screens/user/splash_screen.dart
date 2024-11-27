import 'package:flutter/material.dart';
import 'package:trash_scout/screens/auth/auth_page.dart';
import 'package:trash_scout/shared/theme/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2000), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AuthPage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 300),
              width: 120,
              height: 205,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/app_logo.png'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
