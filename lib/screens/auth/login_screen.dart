import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trash_scout/provider/bottom_navigation_provider.dart';
import 'package:trash_scout/screens/admin/main_admin_screen.dart';
import 'package:trash_scout/screens/user/main_screen.dart';
import 'package:trash_scout/screens/auth/sign_up_screen.dart';
import 'package:trash_scout/screens/user/reset_pw_screen.dart';
import 'package:trash_scout/shared/theme/theme.dart';
import 'package:trash_scout/shared/widgets/user/custom_button.dart';
import 'package:trash_scout/shared/widgets/user/custom_textform.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _error = '';

// User Login
  Future<void> loginUser() async {
    if (mounted) {
      setState(() {
        _error = '';
      });
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      User user = userCredential.user!;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (mounted) {
        if (userDoc.exists &&
            userDoc.data() != null &&
            (userDoc.data() as Map<String, dynamic>).containsKey('role')) {
          String role = userDoc['role'];
          Provider.of<BottomNavigationProvider>(context, listen: false)
              .currentIndex = 0;
          if (role == 'admin') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => AdminMainScreen(),
              ),
              (Route<dynamic> route) => false,
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => MainScreen(),
              ),
              (Route<dynamic> route) => false,
            );
          }
        } else {
          setState(() {
            _error = 'User tidak ditemukan atau data tidak lengkap.';
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      // Conditional Error
      if (mounted) {
        setState(() {
          switch (e.code) {
            case 'wrong-password':
              _error = 'Password yang dimasukkan salah.';
              break;
            case 'user-not-found':
              _error = 'Pengguna dengan email ini tidak ditemukan.';
              break;
            case 'invalid-email':
              _error = 'Email yang dimasukkan tidak valid.';
              break;
            default:
              _error = 'Terjadi kesalahan. Silakan coba lagi.';
              break;
          }
        });
      }
    }
  }

  // Future<void> _signInWithGoogle() async {
  //   final GoogleSignIn googleSignIn = GoogleSignIn();
  //   try {
  //     final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
  //     if (googleUser == null) return;

  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser.authentication;
  //     final AuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     UserCredential userCredential =
  //         await _auth.signInWithCredential(credential);
  //     User user = userCredential.user!;

  //     DocumentSnapshot userDoc = await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(user.uid)
  //         .get();

  //     if (mounted) {
  //       String role = userDoc['role'];
  //       Provider.of<BottomNavigationProvider>(context, listen: false)
  //           .currentIndex = 0;
  //       if (role == 'admin') {
  //         Navigator.pushAndRemoveUntil(
  //           context,
  //           MaterialPageRoute(builder: (context) => AdminMainScreen()),
  //           (Route<dynamic> route) => false,
  //         );
  //       } else {
  //         Navigator.pushAndRemoveUntil(
  //           context,
  //           MaterialPageRoute(builder: (context) => MainScreen()),
  //           (Route<dynamic> route) => false,
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     setState(() {
  //       _error = 'Failed to sign in with Google: $e';
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(
                        top: 150,
                        left: 16,
                        right: 16,
                      ),
                      width: double.infinity,
                      height: 155,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/login_asset.png'),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.only(
                        top: 23,
                        left: 16,
                        right: 16,
                        bottom: 66,
                      ),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(35),
                        ),
                      ),
                      child: Column(
                        children: [
                          Center(
                            child: Text(
                              'Masuk ke Akun Anda',
                              style: boldTextStyle.copyWith(
                                fontSize: 26,
                                color: blackColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 35),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              CustomTextform(
                                formTitle: 'Email',
                                hintText: 'Masukan Email',
                                textInputType: TextInputType.emailAddress,
                                controller: _emailController,
                              ),
                              const SizedBox(height: 20),
                              CustomTextform(
                                formTitle: 'Kata Sandi',
                                hintText: 'Masukan Kata Sandi',
                                obscureText: true,
                                controller: _passwordController,
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.all(0),
                                  alignment: Alignment.topRight,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ResetPasswordScreen(),
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
                          CustomButton(
                            onPressed: () {
                              loginUser();
                            },
                            buttonText: 'Masuk',
                          ),
                          SizedBox(height: 12),
                          // GestureDetector(
                          //   onTap: _signInWithGoogle,
                          //   child: Container(
                          //     width: double.infinity,
                          //     height: 60,
                          //     decoration: BoxDecoration(
                          //       borderRadius: BorderRadius.circular(12),
                          //       border: Border.all(
                          //         color: darkGreenColor,
                          //         width: 1,
                          //       ),
                          //     ),
                          //     child: Center(
                          //       child: Text(
                          //         'Masuk dengan Google',
                          //         style: semiBoldTextStyle.copyWith(
                          //           color: darkGreenColor,
                          //           fontSize: 24,
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          if (_error.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Text(
                                _error,
                                style: regularTextStyle.copyWith(
                                  color: redColor,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Belum punya akun? ',
                                style: mediumTextStyle.copyWith(
                                  color: lightGreyColor,
                                  fontSize: 15,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SignUpScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Daftar',
                                  style: semiBoldTextStyle.copyWith(
                                    color: darkGreenColor,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Tombol info di pojok kanan atas
          Positioned(
            top: 36,
            right: 18,
            child: PopupMenuButton<String>(
              icon: Icon(Icons.info_outline_rounded,
                  color: darkGreenColor, size: 28),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              onSelected: (value) {
                if (value == 'admin') {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      title: Row(
                        children: [
                          Icon(Icons.admin_panel_settings,
                              color: darkGreenColor),
                          SizedBox(width: 8),
                          Text('Panduan Admin'),
                        ],
                      ),
                      content: SingleChildScrollView(
                        child: Text(
                          '''Sebagai Admin, Anda dapat:
- Melihat, memproses, dan menyelesaikan laporan
- Mengelola prioritas laporan
- Melihat rekap dan statistik laporan
- Mengakses detail setiap laporan dan mengubah statusnya''',
                          style: regularTextStyle.copyWith(fontSize: 15),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text('Tutup'),
                        ),
                      ],
                    ),
                  );
                } else if (value == 'user') {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      title: Row(
                        children: [
                          Icon(Icons.person, color: lightGreenColor),
                          SizedBox(width: 8),
                          Text('Panduan User'),
                        ],
                      ),
                      content: SingleChildScrollView(
                        child: Text(
                          '''Sebagai User, Anda dapat:
- Membuat laporan sampah baru
- Melihat riwayat dan status laporan
- Mengedit atau menghapus laporan sendiri
- Melihat detail dan perkembangan laporan
- Mendapatkan notifikasi status laporan''',
                          style: regularTextStyle.copyWith(fontSize: 15),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text('Tutup'),
                        ),
                      ],
                    ),
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'admin',
                  child: Row(
                    children: [
                      Icon(Icons.admin_panel_settings, color: darkGreenColor),
                      SizedBox(width: 8),
                      Text('Panduan Admin'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'user',
                  child: Row(
                    children: [
                      Icon(Icons.person, color: lightGreenColor),
                      SizedBox(width: 8),
                      Text('Panduan User'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
