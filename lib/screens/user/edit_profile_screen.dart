import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trash_scout/screens/user/main_screen.dart';
import 'package:trash_scout/shared/theme/theme.dart';
import 'package:trash_scout/shared/widgets/user/custom_button.dart';
import 'package:trash_scout/shared/widgets/user/custom_textform.dart';
import 'package:trash_scout/shared/widgets/user/provinces_regencies_dropdown.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String? _selectedProvince;
  String? _selectedRegency;
  String? _photoUrl;
  String? _profileImage;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userData.exists) {
        final data = userData.data() as Map<String, dynamic>?;
        if (mounted) {
          setState(() {
            _nameController.text =
                (data != null && data.containsKey('name')) ? data['name'] : '';
            _phoneNumberController.text =
                (data != null && data.containsKey('phoneNumber'))
                    ? data['phoneNumber']
                    : '';
            _selectedProvince = (data != null && data.containsKey('province'))
                ? data['province']
                : null;
            _selectedRegency = (data != null && data.containsKey('regency'))
                ? data['regency']
                : null;
            _profileImage =
                (data != null && data.containsKey('profileImageUrl'))
                    ? data['profileImageUrl']
                    : null;
          });
        }
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (mounted) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    }
  }

  Future<String> _uploadImage(File image) async {
    String fileName = path.basename(image.path);
    Reference storageRef =
        FirebaseStorage.instance.ref().child('uploads/$fileName');
    UploadTask uploadTask = storageRef.putFile(image);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _saveProfile() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String? photoUrl = _photoUrl;
        if (_selectedImage != null) {
          photoUrl = await _uploadImage(_selectedImage!);
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'name': _nameController.text,
          'phoneNumber': _phoneNumberController.text,
          'province': _selectedProvince,
          'regency': _selectedRegency,
          'profileImageUrl': photoUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profil berhasil diperbarui")),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memperbarui profil: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: backgroundColor,
        title: Text(
          'Edit Profil',
          style: semiBoldTextStyle.copyWith(
            color: blackColor,
            fontSize: 26,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: backgroundColor,
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 50),
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : NetworkImage(_photoUrl ?? _profileImage ?? '')
                              as ImageProvider,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 120,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: darkGreenColor,
                  ),
                  child: Center(
                    child: Text(
                      'Edit Foto',
                      style: mediumTextStyle.copyWith(
                          color: whiteColor, fontSize: 16),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              CustomTextform(
                formTitle: 'Nama',
                hintText: 'Masukan Nama',
                controller: _nameController,
              ),
              SizedBox(height: 20),
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
              SizedBox(height: 20),
              CustomTextform(
                formTitle: 'No. HP',
                hintText: 'Masukan Nomor HP',
                controller: _phoneNumberController,
              ),
              SizedBox(height: 40),
              CustomButton(buttonText: 'Simpan', onPressed: _saveProfile),
            ],
          ),
        ),
      ),
    );
  }
}
