import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trash_scout/screens/user/email_sent_screen.dart';
import 'package:trash_scout/shared/theme/theme.dart';
import 'package:trash_scout/shared/widgets/user/custom_button.dart';
import 'package:trash_scout/shared/widgets/user/custom_textform.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  void _resetPassword() async {
    if (_emailController.text.isNotEmpty) {
      try {
        await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmailSentScreen(),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your email')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
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
                        'assets/forgot_pw_icon.png',
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 80),
              Text(
                'Lupa Kata Sandi?',
                style: boldTextStyle.copyWith(
                  color: blackColor,
                  fontSize: 28,
                ),
              ),
              Text(
                'Jangan khawatir! Masukkan email anda dan\nkami akan mengirimkan anda tautan pengaturan\nulang kata sandi.',
                style: regularTextStyle.copyWith(
                  color: lightGreyColor,
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 20),
              CustomTextform(
                formTitle: 'Email',
                hintText: 'Masukan Email anda',
                controller: _emailController,
              ),
              SizedBox(height: 20),
              CustomButton(
                buttonText: 'Kirim',
                onPressed: () {
                  _resetPassword();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
