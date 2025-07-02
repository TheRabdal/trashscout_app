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
  final DocumentSnapshot? report;
  const CreateReportPage({super.key, this.report});

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
  int? _selectedBeratAnorganik;
  int? _selectedBeratOrganik;
  int? _selectedBeratB3;

  @override
  void initState() {
    super.initState();
    if (widget.report != null) {
      final data = widget.report!.data() as Map<String, dynamic>;
      _titleController.text = data['title'] ?? '';
      _descController.text = data['description'] ?? '';
      _selectedCategories = List<String>.from(data['categories'] ?? []);
      _latitude = data['latitude']?.toString();
      _longitude = data['longitude']?.toString();
      _locationDetailController.text = data['locationDetail'] ?? '';
      _selectedBeratB3 = data['beratB3'];
      _selectedBeratAnorganik = data['beratAnorganik'];
      _selectedBeratOrganik = data['beratOrganik'];
      // _selectedImage tidak bisa diisi dari url, biarkan user upload ulang jika perlu
    }
  }

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
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 54),
              SizedBox(height: 12),
              Text(
                'Lengkapi data terlebih dahulu',
                style: boldTextStyle.copyWith(
                    color: Colors.orange[800], fontSize: 19),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Pastikan semua field sudah diisi dengan benar sebelum mengirim laporan.',
                style: regularTextStyle.copyWith(
                    color: darkGreyColor, fontSize: 15),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 18),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[700],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                ),
                onPressed: () => Navigator.pop(ctx),
                icon: Icon(Icons.close, color: whiteColor),
                label: Text('Tutup',
                    style: boldTextStyle.copyWith(color: whiteColor)),
              ),
            ],
          ),
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
      bool hasValidWeight = false;
      if (categories.contains('B3') && _selectedBeratB3 != null)
        hasValidWeight = true;
      if (categories.contains('Anorganik') && _selectedBeratAnorganik != null)
        hasValidWeight = true;
      if (categories.contains('Organik') && _selectedBeratOrganik != null)
        hasValidWeight = true;
      if (title.isNotEmpty &&
          categories.isNotEmpty &&
          description.isNotEmpty &&
          _selectedImage != null &&
          _latitude != null &&
          _longitude != null &&
          locationDetail.isNotEmpty &&
          hasValidWeight) {
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
              'beratAnorganik': _selectedBeratAnorganik,
              'beratOrganik': _selectedBeratOrganik,
              'beratB3': _selectedBeratB3,
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
            content: Text(
                "Harap isi semua field dan pilih rating berat untuk minimal satu kategori yang dipilih"),
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
          widget.report != null ? 'Edit Laporan' : 'Buat Laporan',
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
                SizedBox(height: 15),
                Text('Perkiraan Berat Sampah',
                    style: mediumTextStyle.copyWith(
                        color: blackColor, fontSize: 18)),
                SizedBox(height: 6),
                if (_selectedCategories.contains('B3')) ...[
                  Text('B3', style: mediumTextStyle),
                  _WeightRatingSelector(
                    selectedRating: _selectedBeratB3,
                    onChanged: (val) => setState(() => _selectedBeratB3 = val),
                    showTidakAda: false,
                  ),
                ],
                if (_selectedCategories.contains('Anorganik')) ...[
                  Text('Anorganik', style: mediumTextStyle),
                  _WeightRatingSelector(
                    selectedRating: _selectedBeratAnorganik,
                    onChanged: (val) =>
                        setState(() => _selectedBeratAnorganik = val),
                    showTidakAda: false,
                  ),
                ],
                if (_selectedCategories.contains('Organik')) ...[
                  Text('Organik', style: mediumTextStyle),
                  _WeightRatingSelector(
                    selectedRating: _selectedBeratOrganik,
                    onChanged: (val) =>
                        setState(() => _selectedBeratOrganik = val),
                    showTidakAda: false,
                  ),
                ],
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
    List<String> categories = ['B3', 'Anorganik', 'Organik'];

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
            child: Stack(
              children: [
                if (_imageFile != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(_imageFile!.path),
                      width: double.infinity,
                      height: 227,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                  ),
                if (_imageFile != null)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Material(
                      color: Colors.black38,
                      shape: CircleBorder(),
                      child: InkWell(
                        customBorder: CircleBorder(),
                        onTap: () async {
                          showModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(18)),
                            ),
                            builder: (ctx) => SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.photo_library,
                                        color: darkGreenColor),
                                    title: Text('Ganti Foto (Galeri)'),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      _pickImageFromGallery();
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.camera_alt,
                                        color: darkGreenColor),
                                    title: Text('Ambil Ulang (Kamera)'),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      _pickImageFromCamera();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child:
                              Icon(Icons.edit, color: Colors.white, size: 26),
                        ),
                      ),
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
                Navigator.pop(context); // Tutup dialog loading
                await Future.delayed(Duration(milliseconds: 200));
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                    backgroundColor: Colors.white,
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on,
                            color: darkGreenColor, size: 54),
                        SizedBox(height: 12),
                        Text(
                          'Lokasi Berhasil Diambil!',
                          style: boldTextStyle.copyWith(
                              color: darkGreenColor, fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Koordinat lokasi sudah tersimpan. Pastikan detail lokasi sudah benar.',
                          style: regularTextStyle.copyWith(
                              color: darkGreyColor, fontSize: 15),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 18),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkGreenColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 10),
                          ),
                          onPressed: () => Navigator.pop(ctx),
                          icon: Icon(Icons.check, color: whiteColor),
                          label: Text('Tutup',
                              style: boldTextStyle.copyWith(color: whiteColor)),
                        ),
                      ],
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

class _WeightRatingSelector extends StatelessWidget {
  final int? selectedRating;
  final ValueChanged<int> onChanged;
  final bool showTidakAda;
  const _WeightRatingSelector(
      {required this.selectedRating,
      required this.onChanged,
      this.showTidakAda = true});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> options = [
      {'label': 'Pilih terlebih dahulu', 'rating': null, 'desc': ''},
      if (showTidakAda)
        {'label': 'Tidak ada', 'rating': 0, 'desc': 'Tidak ada sampah'},
      {'label': '< 1 kg', 'rating': 4, 'desc': 'Baik'},
      {'label': '1 – 2 kg', 'rating': 3, 'desc': 'Cukup'},
      {'label': '3 – 4 kg', 'rating': 2, 'desc': 'Buruk'},
      {'label': '> 4 kg', 'rating': 1, 'desc': 'Sangat buruk'},
    ];
    final selected = options.firstWhere(
      (opt) => opt['rating'] == selectedRating,
      orElse: () => <String, dynamic>{},
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<int>(
          value: selectedRating,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down_rounded,
              color: darkGreenColor, size: 28),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: darkGreenColor, width: 1.4),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: lightGreenColor, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: darkGreenColor, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            hintText: 'Pilih rating berat sampah...',
            hintStyle: regularTextStyle.copyWith(color: Colors.grey[500]),
            prefixIcon: Icon(Icons.scale, color: darkGreenColor, size: 22),
            filled: true,
            fillColor: Colors.white,
          ),
          dropdownColor: Colors.white,
          style: mediumTextStyle.copyWith(fontSize: 16, color: blackColor),
          items: options
              .map((opt) => DropdownMenuItem<int>(
                    value: opt['rating'],
                    enabled: opt['rating'] != null,
                    child: Row(
                      children: [
                        if (opt['rating'] != null && opt['rating'] != 0)
                          Icon(Icons.circle,
                              size: 12,
                              color: opt['rating'] == 4
                                  ? Colors.green
                                  : opt['rating'] == 3
                                      ? Colors.lightGreen
                                      : opt['rating'] == 2
                                          ? Colors.orange
                                          : Colors.red),
                        if (opt['rating'] == 0)
                          Icon(Icons.remove_circle_outline,
                              size: 16, color: Colors.grey),
                        if (opt['rating'] != null) SizedBox(width: 8),
                        Text(opt['label'],
                            style: mediumTextStyle.copyWith(
                                fontSize: 16,
                                color: opt['rating'] == null
                                    ? Colors.grey
                                    : blackColor)),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
          validator: (val) {
            if (val == null) return 'Pilih rating berat terlebih dahulu';
            return null;
          },
        ),
        if (selected.isNotEmpty && selected['rating'] != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 4),
            child: Text(
              selected['desc'],
              style: regularTextStyle.copyWith(
                fontSize: 13,
                color: selected['rating'] == 4
                    ? Colors.green
                    : selected['rating'] == 3
                        ? Colors.lightGreen
                        : selected['rating'] == 2
                            ? Colors.orange
                            : selected['rating'] == 1
                                ? Colors.red
                                : Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}
