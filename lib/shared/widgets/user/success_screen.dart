import 'package:flutter/material.dart';
import 'package:trash_scout/screens/user/main_screen.dart';
import 'package:trash_scout/shared/theme/theme.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2500), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        margin: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 200,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                child: Image.asset(
                  'assets/success_icon.png',
                  width: double.infinity,
                  height: 255,
                ),
              ),
              SizedBox(height: 11),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Anda Pahlawan ',
                      style: boldTextStyle.copyWith(
                        color: blackColor,
                        fontSize: 30,
                      ),
                    ),
                    TextSpan(
                      text: 'Bumi!',
                      style: boldTextStyle.copyWith(
                        color: darkGreenColor,
                        fontSize: 30,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 11),
              Text(
                'Terima Kasih! Laporan anda sangat\nberperan penting bagi kebersihan bumi ini',
                style: regularTextStyle.copyWith(
                  color: darkGreyColor,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
