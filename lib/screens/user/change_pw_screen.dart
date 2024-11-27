import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trash_scout/screens/auth/login_screen.dart';
import 'package:trash_scout/screens/user/reset_pw_screen.dart';
import 'package:trash_scout/shared/theme/theme.dart';
import 'package:trash_scout/shared/widgets/user/custom_button.dart';
import 'package:trash_scout/shared/widgets/user/custom_textform.dart';

class ChangePwScreen extends StatefulWidget {
  const ChangePwScreen({super.key});

  @override
  State<ChangePwScreen> createState() => _ChangePwScreenState();
}

class _ChangePwScreenState extends State<ChangePwScreen> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _changePassword() async {
    String currentPassword = _currentPasswordController.text;
    String newPassword = _newPasswordController.text;

    User? user = _auth.currentUser;
    if (user != null) {
      try {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );

        await user.reauthenticateWithCredential(credential);

        await user.updatePassword(newPassword);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
          (Route<dynamic> route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Password berhasil diganti, Silahkan login ulang!',
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
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
                  margin: EdgeInsets.only(top: 40),
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/change_pw_icon.png'),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
              Text(
                'Ganti Kata Sandi?',
                style: boldTextStyle.copyWith(
                  color: blackColor,
                  fontSize: 28,
                ),
              ),
              Text(
                'Masukan kata sandi lama dan baru',
                style: regularTextStyle.copyWith(
                  color: lightGreyColor,
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 16),
              CustomTextform(
                formTitle: 'Kata Sandi Lama',
                hintText: 'Masukan Kata Sandi Lama',
                controller: _currentPasswordController,
                obscureText: true,
              ),
              SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResetPasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Lupa kata sandi',
                      style: mediumTextStyle.copyWith(
                        color: darkGreenColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              CustomTextform(
                formTitle: 'Kata Sandi Baru',
                hintText: 'Masukan Kata Sandi Baru',
                controller: _newPasswordController,
                obscureText: true,
              ),
              SizedBox(height: 30),
              CustomButton(
                buttonText: 'Simpan',
                onPressed: _changePassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
