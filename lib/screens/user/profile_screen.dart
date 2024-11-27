import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trash_scout/screens/auth/login_screen.dart';
import 'package:trash_scout/screens/user/change_pw_screen.dart';
import 'package:trash_scout/screens/user/edit_profile_screen.dart';
import 'package:trash_scout/shared/theme/theme.dart';
import 'package:trash_scout/shared/utils/capitalize.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? displayName;
  String? profileImageUrl;
  String? userLocation;
  String? userGender;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (mounted) {
        setState(() {
          displayName = userData['name'];
          profileImageUrl = userData['profileImageUrl'] ??
              'https://firebasestorage.googleapis.com/v0/b/trash-scout-3c117.appspot.com/o/users%2Fdefault_profile_image%2Fuser%20default%20profile.png?alt=media&token=79ef1308-3d3d-477d-b566-0c4e66848a4d';
          userGender = userData['gender'];
          userLocation = capitalize(userData['regency']);
        });
      }
    }
  }

  void logoutUser() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 380,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                  image: DecorationImage(
                    image: AssetImage('assets/profile_background.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 50),
                    child: Center(
                      child: Text(
                        'Profil Saya',
                        style: semiBoldTextStyle.copyWith(
                          color: whiteColor,
                          fontSize: 26,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(profileImageUrl ??
                            'https://firebasestorage.googleapis.com/v0/b/trash-scout-3c117.appspot.com/o/users%2Fdefault_profile_image%2Fuser%20default%20profile.png?alt=media&token=79ef1308-3d3d-477d-b566-0c4e66848a4d'),
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    displayName ?? 'Loading...',
                    style: semiBoldTextStyle.copyWith(
                      color: whiteColor,
                      fontSize: 24,
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: userGender ?? 'Loading...',
                          style: regularTextStyle.copyWith(
                            color: Color(0xffC4C4C4),
                            fontSize: 16,
                          ),
                        ),
                        TextSpan(
                          text: ', ',
                          style: regularTextStyle.copyWith(
                            color: Color(0xffC4C4C4),
                            fontSize: 16,
                          ),
                        ),
                        TextSpan(
                          text: userLocation ?? 'Loading...',
                          style: regularTextStyle.copyWith(
                            color: Color(0xffC4C4C4),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: 120,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: whiteColor.withOpacity(0.1),
                      ),
                      child: Center(
                        child: Text(
                          'Edit Profil',
                          style: mediumTextStyle.copyWith(
                              color: whiteColor, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
          SizedBox(height: 23),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.5,
                  ),
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: blackColor.withOpacity(0.1),
                        offset: Offset(0, 2),
                        blurRadius: 2.5,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 214, 239, 231),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.privacy_tip_rounded,
                          size: 30,
                          color: lightGreenColor,
                        ),
                      ),
                      SizedBox(width: 14),
                      Text(
                        'Ganti Kata Sandi',
                        style: mediumTextStyle.copyWith(
                          color: blackColor,
                          fontSize: 20,
                        ),
                      ),
                      Expanded(child: Container()),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChangePwScreen(),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.navigate_next_rounded,
                          size: 30,
                          color: blackColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: logoutUser,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.5,
                    ),
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: blackColor.withOpacity(0.1),
                          offset: Offset(0, 2),
                          blurRadius: 2.5,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 214, 239, 231),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.logout,
                            size: 30,
                            color: lightGreenColor,
                          ),
                        ),
                        SizedBox(width: 14),
                        Text(
                          'Keluar',
                          style: mediumTextStyle.copyWith(
                            color: blackColor,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
