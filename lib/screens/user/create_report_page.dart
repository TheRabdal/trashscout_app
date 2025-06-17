import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trash_scout/shared/theme/theme.dart';
import 'package:trash_scout/shared/widgets/user/custom_button.dart';
import 'package:trash_scout/shared/widgets/user/success_screen.dart';
import 'package:trash_scout/shared/widgets/user/trash_category_item.dart';
import 'package:image_picker/image_picker.dart';

class CreateReportPage extends StatefulWidget {
  const CreateReportPage({super.key});

  @override
  State<CreateReportPage> createState() => _CreateReportPageState();
}

class _CreateReportPageState extends State<CreateReportPage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  List<String> _selectedCategories = [];
  File? _selectedImage;
  String? _latitude;
  String? _longitude;
  final TextEditingController _locationDetailController =
      TextEditingController();

  void _handleCategoriesChanged(List<String> category) {
    if (mounted) {
      setState(() {
        _selectedCategories = category;
      });
    }
  }

  void _handleImageChanged(File image) {
    if (mounted) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  void _handleLocationChanged(String lat, String long) {
    if (mounted) {
      setState(() {
        _latitude = lat;
        _longitude = long;
      });
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

  void _submitReport() async {
    if (formKey.currentState != null && formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            actionsAlignment: MainAxisAlignment.spaceBetween,
            backgroundColor: backgroundColor,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/confirmation_icon.png', // Ganti dengan path gambar Anda
                  height: 200,
                ),
                SizedBox(height: 14),
                Text(
                  'Yakin dengan Laporannya?',
                  style: semiBoldTextStyle.copyWith(
                    color: blackColor,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 3),
                Text(
                  'Jika belum yakin periksalah kembali',
                  style: regularTextStyle.copyWith(
                      color: lightGreyColor, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 120,
                      height: 44,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: blackColor,
                          )),
                      child: Center(
                        child: Text(
                          'Belum yakin',
                          style: boldTextStyle.copyWith(
                              color: blackColor, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      _submitReportConfirmed();
                    },
                    child: Container(
                      width: 140,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: darkGreenColor,
                      ),
                      child: Center(
                        child: Text(
                          'Sudah Yakin',
                          style: boldTextStyle.copyWith(
                              color: whiteColor, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Form tidak valid"),
        ),
      );
    }
  }

  void _submitReportConfirmed() async {
    if (formKey.currentState != null && formKey.currentState!.validate()) {
      String title = _titleController.text;
      List<String> categories = _selectedCategories;
      String description = _descController.text;
      String locationDetail = _locationDetailController.text;
      if (title.isNotEmpty &&
          categories.isNotEmpty &&
          description.isNotEmpty &&
          _selectedImage != null &&
          _latitude != null &&
          _longitude != null &&
          locationDetail.isNotEmpty) {
        try {
          User? user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            String uid = user.uid;
            String imageUrl = await _uploadImage(_selectedImage!);
            String mapsUrl =
                'https://www.google.com/maps?q=$_latitude,$_longitude';

            await FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .collection('reports')
                .add({
              'title': title,
              'categories': categories,
              'description': description,
              'imageUrl': imageUrl,
              'latitude': _latitude,
              'longitude': _longitude,
              'locationUrl': mapsUrl,
              'locationDetail': locationDetail,
              'status': 'Dibuat',
              'date': Timestamp.now(),
            });

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SuccessScreen(),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("User tidak terautentikasi"),
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Gagal mengirim laporan: $e")));
          print(e);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Harap isi semua field"),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Form tidak valid"),
        ),
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
          'Buat Laporan',
          style: semiBoldTextStyle.copyWith(
            color: blackColor,
            fontSize: 26,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReportTitleForm(
                  titleController: _titleController,
                ),
                TrashCategory(onCategoryChanged: _handleCategoriesChanged),
                ReportDescForm(
                  descController: _descController,
                ),
                UploadPhoto(
                  onFileChanged: _handleImageChanged,
                ),
                SelectLocation(
                  onLocationChanged: _handleLocationChanged,
                  locationDetailController: _locationDetailController,
                ),
                SizedBox(height: 30),
                CustomButton(
                  buttonText: 'Kirim Laporan',
                  onPressed: () {
                    _submitReport();
                  },
                ),
                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReportTitleForm extends StatelessWidget {
  final TextEditingController titleController;
  const ReportTitleForm({required this.titleController});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Judul',
          style: mediumTextStyle.copyWith(
            color: blackColor,
            fontSize: 18,
          ),
        ),
        TextFormField(
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Masukkan judul laporan';
            }
            return null;
          },
          controller: titleController,
          style: mediumTextStyle.copyWith(
            color: blackColor,
            fontSize: 24,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Masukan Judul Laporan',
            hintStyle: regularTextStyle.copyWith(
              color: lightGreyColor,
            ),
          ),
          cursorColor: lightGreenColor,
          keyboardType: TextInputType.multiline,
          minLines: 1,
          maxLines: 3,
        ),
        Divider(),
      ],
    );
  }
}

class TrashCategory extends StatefulWidget {
  final ValueChanged<List<String>> onCategoryChanged;
  const TrashCategory({required this.onCategoryChanged});

  @override
  State<TrashCategory> createState() => _TrashCategoryState();
}

class _TrashCategoryState extends State<TrashCategory> {
  List<String> selectedCategories = [];

  void handleCategorySelected(String category) {
    if (mounted) {
      setState(() {
        selectedCategories.add(category);
      });
    }
    widget.onCategoryChanged(selectedCategories);
  }

  void handleCategoryDeselected(String category) {
    if (mounted) {
      setState(() {
        selectedCategories.remove(category);
      });
    }
    widget.onCategoryChanged(selectedCategories);
  }

  @override
  Widget build(BuildContext context) {
    List<String> categories = [
      'Organik',
      'Anorganik',
      'B3',
    ];

    return Container(
      margin: EdgeInsets.only(
        top: 15,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kategori Sampah',
            style: mediumTextStyle.copyWith(
              color: blackColor,
              fontSize: 18,
            ),
          ),
          Text(
            'Pilih kategori sampah yang dilaporkan',
            style: regularTextStyle.copyWith(
              color: darkGreyColor,
              fontSize: 13,
            ),
          ),
          Wrap(
            spacing: 6.0,
            runSpacing: 3.0,
            alignment: WrapAlignment.start,
            children: categories.map((category) {
              bool isSelected = selectedCategories.contains(category);
              return TrashCategoryItem(
                title: category,
                isSelected: isSelected,
                onDeselected: handleCategoryDeselected,
                onSelected: handleCategorySelected,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class ReportDescForm extends StatelessWidget {
  final TextEditingController descController;
  const ReportDescForm({super.key, required this.descController});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: 15,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Deskripsi',
            style: mediumTextStyle.copyWith(
              color: blackColor,
              fontSize: 18,
            ),
          ),
          TextFormField(
            controller: descController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Masukkan deskripsi laporan';
              }
              return null;
            },
            style: regularTextStyle.copyWith(
              color: darkGreyColor,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Masukan Deskripsi',
              hintStyle: regularTextStyle.copyWith(
                color: darkGreyColor,
              ),
            ),
            cursorColor: lightGreenColor,
            keyboardType: TextInputType.multiline,
            minLines: 1,
            maxLines: null,
            maxLength: 300,
          ),
          Divider(),
        ],
      ),
    );
  }
}

class UploadPhoto extends StatefulWidget {
  final Function(File) onFileChanged;
  const UploadPhoto({
    super.key,
    required this.onFileChanged,
  });

  @override
  State<UploadPhoto> createState() => _UploadPhotoState();
}

class _UploadPhotoState extends State<UploadPhoto> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (mounted) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
    if (pickedFile != null) {
      widget.onFileChanged(File(pickedFile.path));
    }
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (mounted) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
    if (pickedFile != null) {
      widget.onFileChanged(File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: 15,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Masukan Foto',
            style: mediumTextStyle.copyWith(
              color: blackColor,
              fontSize: 18,
            ),
          ),
          Text(
            'Wajib memasukan foto!',
            style: regularTextStyle.copyWith(
              color: darkGreyColor,
              fontSize: 13,
            ),
          ),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 227,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: lightGreyColor,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_imageFile != null)
                    Image.file(
                      File(_imageFile!.path),
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    )
                  else
                    Column(
                      children: [
                        GestureDetector(
                          onTap: _pickImageFromCamera,
                          child: IntrinsicWidth(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 7,
                                horizontal: 28,
                              ),
                              decoration: BoxDecoration(
                                color: darkGreenColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'Buka Kamera',
                                  style: mediumTextStyle.copyWith(
                                    color: whiteColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 6),
                        GestureDetector(
                          onTap: _pickImageFromGallery,
                          child: IntrinsicWidth(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 7,
                                horizontal: 28,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: darkGreenColor,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'Pilih di Galeri',
                                  style: mediumTextStyle.copyWith(
                                    color: darkGreenColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SelectLocation extends StatefulWidget {
  final Function(String, String) onLocationChanged;
  final TextEditingController locationDetailController;

  const SelectLocation({
    required this.onLocationChanged,
    required this.locationDetailController,
    super.key,
  });

  @override
  State<SelectLocation> createState() => _SelectLocationState();
}

class _SelectLocationState extends State<SelectLocation> {
  late String lat;
  late String long;

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Layanan lokasi tidak aktif"),
        ),
      );
      return Future.error('Location services are disabled.');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Izin lokasi ditolak"),
          ),
        );
        return Future.error('Location Permission are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Izin lokasi ditolak secara permanen"),
        ),
      );
      return Future.error('Permission is Denied Forever');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: 15,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih Lokasi',
            style: mediumTextStyle.copyWith(
              color: blackColor,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 10),
          CustomButton(
            buttonText: 'Ambil Lokasi',
            onPressed: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: darkGreenColor,
                    ),
                  );
                },
              );

              try {
                Position position = await _getCurrentLocation();
                lat = '${position.latitude}';
                long = '${position.longitude}';
                print('Latitude: $lat , Longitude: $long');
                widget.onLocationChanged(lat, long);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: whiteColor,
                    content: Text(
                      "Lokasi berhasil diambil",
                      style: regularTextStyle.copyWith(color: blackColor),
                    ),
                  ),
                );
              } catch (error) {
                print("Gagal mengambil lokasi! Error: $error");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Gagal mengambil lokasi"),
                  ),
                );
              } finally {
                Navigator.pop(context); // Menutup dialog loading
              }
            },
          ),
          SizedBox(height: 10),
          Text(
            'Detail lokasi',
            style: mediumTextStyle.copyWith(
              color: darkGreyColor,
            ),
          ),
          Text(
            'Detail untuk mempemudah Petugas',
            style: regularTextStyle.copyWith(
              color: darkGreyColor,
              fontSize: 12,
            ),
          ),
          TextFormField(
            style: regularTextStyle.copyWith(
              color: darkGreyColor,
              fontSize: 13,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Masukkan detail lokasi';
              }
              return null;
            },
            controller: widget.locationDetailController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(16),
              prefixIcon: Icon(
                Icons.location_city_outlined,
                size: 24,
                color: darkGreyColor,
              ),
              border: InputBorder.none,
              hintText: 'Masukan Detail Lokasi',
              hintStyle: regularTextStyle.copyWith(
                color: darkGreyColor,
              ),
            ),
            cursorColor: lightGreenColor,
            minLines: 1,
            maxLines: null,
          ),
          Divider(
            height: 0.5,
          ),
        ],
      ),
    );
  }
}
