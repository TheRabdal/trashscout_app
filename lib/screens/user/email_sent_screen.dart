import 'package:flutter/material.dart';
import 'package:trash_scout/screens/auth/login_screen.dart';
import 'package:trash_scout/shared/theme/theme.dart';
import 'package:trash_scout/shared/widgets/user/custom_button.dart';

class EmailSentScreen extends StatefulWidget {
  const EmailSentScreen({super.key});

  @override
  State<EmailSentScreen> createState() => _EmailSentScreenState();
}

class _EmailSentScreenState extends State<EmailSentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 80),
                  width: double.infinity,
                  height: 287,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/email_sent_icon.png',
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 80),
              Text(
                'Anda mendapat email dari kami',
                style: boldTextStyle.copyWith(
                  color: blackColor,
                  fontSize: 28,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Kami baru saja mengirimi link untuk mereset kata sandi ke alamat email anda',
                style: regularTextStyle.copyWith(
                  color: lightGreyColor,
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Jika sudah memasukan password baru, silahkan login ulang',
                style: regularTextStyle.copyWith(
                  color: lightGreyColor,
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 40),
              CustomButton(
                buttonText: 'Login Ulang',
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      ),
                      (Route<dynamic> route) => false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
