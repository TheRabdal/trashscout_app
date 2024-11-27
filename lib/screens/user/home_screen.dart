import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trash_scout/screens/user/create_report_page.dart';
import 'package:trash_scout/screens/user/mail_box_screen.dart';
import 'package:trash_scout/screens/user/see_all_history_screen.dart';
import 'package:trash_scout/services/firestore_service.dart';
import 'package:trash_scout/shared/theme/theme.dart';
import 'package:trash_scout/shared/widgets/user/custom_button.dart';
import 'package:trash_scout/shared/widgets/user/report_history.dart';
import 'package:trash_scout/shared/widgets/user/report_recap_widget.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  final FirestoreService _firestoreService = FirestoreService();
  String? displayName;
  String? displayProfilePicture;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    String? name = await _firestoreService.getUserName(user.uid);
    String? photo = await _firestoreService.getUserPhoto(user.uid);
    if (mounted) {
      setState(() {
        displayName = name;
        displayProfilePicture = photo;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 35,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                HomeScreenHeader(
                  profilePicture: displayProfilePicture,
                  userDisplayName: displayName,
                ),
                SizedBox(height: 20),
                // Make Report BUtton
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tumpukan sampah ilegal?',
                      style: mediumTextStyle.copyWith(
                        fontSize: 16,
                        color: blackColor,
                      ),
                    ),
                    SizedBox(height: 14),
                    CustomButton(
                      buttonText: 'Buat Laporan',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateReportPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 19),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('reports')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                          child: CircularProgressIndicator(
                        color: darkGreenColor,
                      ));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return ReportRecapHomeScreen(
                        totalCreated: 0,
                        totalInProcess: 0,
                        totalCompleted: 0,
                      );
                    }
                    var reports = snapshot.data!.docs;
                    int totalCreated = reports.length;
                    int totalInProcess = reports
                        .where((doc) => doc['status'] == 'Diproses')
                        .length;
                    int totalCompleted = reports
                        .where((doc) => doc['status'] == 'Selesai')
                        .length;
                    return ReportRecapHomeScreen(
                      totalCreated: totalCreated,
                      totalInProcess: totalInProcess,
                      totalCompleted: totalCompleted,
                    );
                  },
                ),
                SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Riwayat Laporan',
                      style: boldTextStyle.copyWith(
                        color: blackColor,
                        fontSize: 20,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SeeAllHistoryScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Lihat Semua',
                        style: mediumTextStyle.copyWith(
                          color: blackColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 14,
                ),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('reports')
                      .orderBy('date', descending: true)
                      .limit(5)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                          child: CircularProgressIndicator(
                        color: darkGreenColor,
                      ));
                    }
                    var reports = snapshot.data!.docs;
                    if (reports.isEmpty) {
                      return Center(
                        child: Text(
                          'Tidak ada laporan terbaru.',
                          style: regularTextStyle.copyWith(
                            color: lightGreyColor,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: reports.length,
                      itemBuilder: (context, index) {
                        var report = reports[index];
                        String formattedDate = DateFormat('dd MMMM yyyy')
                            .format((report['date'] as Timestamp).toDate());
                        final List<String> categories =
                            List<String>.from(report['categories']);
                        return ReportHistory(
                          reportTitle: report['title'],
                          status: report['status'],
                          imageUrl: report['imageUrl'],
                          statusBackgroundColor:
                              _getStatusColor(report['status']),
                          description: report['description'],
                          date: formattedDate,
                          categories: categories,
                          latitude: report['latitude'],
                          longitude: report['longitude'],
                          locationDetail: report['locationDetail'],
                        );
                      },
                    );
                  },
                ),
                SizedBox(height: 90),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Dibuat':
        return darkGreenColor;
      case 'Diproses':
        return lightGreenColor;
      case 'Selesai':
        return Color(0xff6BC2A2);
      default:
        return darkGreyColor;
    }
  }
}

class HomeScreenHeader extends StatelessWidget {
  final String? userDisplayName;
  final String? profilePicture;

  const HomeScreenHeader({
    required this.userDisplayName,
    required this.profilePicture,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(profilePicture ??
                      'https://firebasestorage.googleapis.com/v0/b/trash-scout-3c117.appspot.com/o/users%2Fdefault_profile_image%2Fuser%20default%20profile.png?alt=media&token=79ef1308-3d3d-477d-b566-0c4e66848a4d'),
                ),
              ),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo $userDisplayName!',
                  style: semiBoldTextStyle.copyWith(
                    color: blackColor,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'Ayo Bersihkan Bumi Kita!',
                  style: regularTextStyle.copyWith(
                    color: lightGreyColor,
                    fontSize: 15,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: whiteColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MailBoxScreen(),
                  ),
                );
              },
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/mail_icon.png',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ReportRecapHomeScreen extends StatelessWidget {
  final int totalCreated;
  final int totalInProcess;
  final int totalCompleted;

  const ReportRecapHomeScreen({
    required this.totalCreated,
    required this.totalInProcess,
    required this.totalCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total Laporan Anda',
          style: boldTextStyle.copyWith(
            color: blackColor,
            fontSize: 20,
          ),
        ),
        SizedBox(height: 9),
        Row(
          children: [
            ReportRecapWidget(
              totalReport: totalCreated,
              reportTitle: 'Dibuat',
              backgroundColor: darkGreenColor,
              iconBackgroundColor: Color(
                0xff3F8377,
              ),
            ),
            SizedBox(width: 6),
            ReportRecapWidget(
              totalReport: totalInProcess,
              reportTitle: 'Diproses',
              backgroundColor: lightGreenColor,
              iconBackgroundColor: Color(
                0xff41BB9E,
              ),
            ),
            SizedBox(width: 6),
            ReportRecapWidget(
              totalReport: totalCompleted,
              reportTitle: 'Selesai',
              backgroundColor: Color(0xff6BC2A2),
              iconBackgroundColor: Color(
                0xff8CDCBE,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
