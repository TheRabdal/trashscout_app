import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trash_scout/screens/auth/login_screen.dart';
import 'package:trash_scout/services/auth_service.dart';
import 'package:trash_scout/services/firestore_service.dart';
import 'package:trash_scout/shared/theme/theme.dart';
import 'package:trash_scout/shared/widgets/user/custom_button.dart';
import 'package:trash_scout/shared/widgets/user/custom_textform.dart';
import 'package:trash_scout/shared/widgets/user/date_of_birth_form.dart';
import 'package:trash_scout/shared/widgets/user/gender_radio_button.dart';
import 'package:trash_scout/shared/widgets/user/provinces_regencies_dropdown.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final String _role = 'user';

  String? _selectedGender;
  String? _selectedProvince;
  String? _selectedRegency;
  final String defaultProfileImageUrl =
      'https://firebasestorage.googleapis.com/v0/b/trash-scout-3c117.appspot.com/o/users%2Fdefault_profile_image%2Fuser%20default%20profile.png?alt=media&token=79ef1308-3d3d-477d-b566-0c4e66848a4d';

  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _signUp() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(
            color: darkGreenColor,
          ),
        );
      },
    );

    try {
      UserCredential userCredential =
          await _authService.signUpWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );

      await _firestoreService.saveUserData(
        userCredential.user?.uid ?? '',
        _emailController.text,
        _nameController.text,
        _role,
        _birthDateController.text,
        _selectedGender!,
        _selectedProvince!,
        _selectedRegency!,
        _phoneNumberController.text,
        defaultProfileImageUrl,
      );
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );

      // Navigate to the next screen or show a success message
    } on FirebaseAuthException catch (e) {
      // Handle error, e.g., show a snackbar with the error message
      print('Error: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: IntrinsicHeight(
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BackButton(),
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(
                          top: 10,
                        ),
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                              'assets/logo_without_text.png',
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 25),
                    Center(
                      child: Text(
                        'Daftarkan Diri Anda',
                        style: boldTextStyle.copyWith(
                          color: blackColor,
                          fontSize: 30,
                        ),
                      ),
                    ),
                    SizedBox(height: 25),
                    CustomTextform(
                      formTitle: 'Nama',
                      textInputType: TextInputType.name,
                      hintText: 'Masukan Nama',
                      controller: _nameController,
                    ),
                    SizedBox(height: 25),
                    DateOfBirthForm(dateController: _birthDateController),
                    SizedBox(height: 25),
                    GenderForm(
                      onChanged: (value) {
                        if (mounted) {
                          setState(() {
                            _selectedGender = value;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 25),
                    ProvincesRegenciesDropdown(
                      onProvinceChanged: (value) {
                        if (mounted) {
                          setState(() {
                            _selectedProvince = value['name'];
                          });
                        }
                      },
                      onRegencyChanged: (value) {
                        if (mounted) {
                          setState(() {
                            _selectedRegency = value['name'];
                          });
                        }
                      },
                    ),
                    SizedBox(height: 25),
                    CustomTextform(
                      formTitle: 'No.HP',
                      textInputType: TextInputType.phone,
                      hintText: 'Masukkan No.HP',
                      controller: _phoneNumberController,
                    ),
                    SizedBox(height: 25),
                    CustomTextform(
                      formTitle: 'Email',
                      textInputType: TextInputType.emailAddress,
                      hintText: 'Masukan Email',
                      controller: _emailController,
                    ),
                    SizedBox(height: 25),
                    CustomTextform(
                      formTitle: 'Kata Sandi',
                      hintText: 'Masukan Kata Sandi',
                      obscureText: true,
                      controller: _passwordController,
                    ),
                    SizedBox(height: 40),
                    CustomButton(
                        buttonText: 'Lanjut',
                        onPressed: () {
                          _signUp();
                        }),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sudah punya akun? ',
                          style: mediumTextStyle.copyWith(
                            color: lightGreyColor,
                            fontSize: 15,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Masuk',
                            style: semiBoldTextStyle.copyWith(
                              color: darkGreenColor,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
