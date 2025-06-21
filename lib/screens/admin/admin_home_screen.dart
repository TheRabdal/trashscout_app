import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trash_scout/screens/auth/login_screen.dart';
import 'package:trash_scout/services/firestore_service.dart';
import 'package:trash_scout/shared/theme/theme.dart';
import 'package:trash_scout/shared/widgets/admin/admin_recap_widget.dart';
import 'package:trash_scout/shared/widgets/admin/map_status.dart';
import 'dart:ui';
import 'package:trash_scout/screens/admin/admin_detail_report.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminHomeScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = true;
  String? displayName;
  String? profileImageUrl;
  final String defaultProfileImageUrl =
      'https://firebasestorage.googleapis.com/v0/b/trash-scout-3c117.appspot.com/o/users%2Fdefault_profile_image%2Fuser%20default%20profile.png?alt=media&token=79ef1308-3d3d-477d-b566-0c4e66848a4d';

  int totalPending = 0;
  int totalInProcess = 0;
  int totalCompleted = 0;
  int totalReport = 0;
  List<Map<String, dynamic>> latestReports = [];

  @override
  void initState() {
    _getUserData();
    _getReportStats();
    _getLatestReports();
    super.initState();
  }

  void logoutUser() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }

  Future<void> _getUserData() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    String? name = await _firestoreService.getUserName(user.uid);
    String? profileImageUrl;

    Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

    if (userSnapshot.exists && userData.containsKey('profileImageUrl')) {
      profileImageUrl = userSnapshot['profileImageUrl'];
    } else {
      profileImageUrl = defaultProfileImageUrl;
    }

    if (mounted) {
      setState(() {
        displayName = name;
        this.profileImageUrl = profileImageUrl;
      });
    }
  }

  Future<void> _getReportStats() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      int reportCount = 0;
      int inProcessCount = 0;
      int completedCount = 0;
      int pendingCount = 0;

      for (var userDoc in usersSnapshot.docs) {
        QuerySnapshot reportsSnapshot =
            await userDoc.reference.collection('reports').get();

        for (var reportDoc in reportsSnapshot.docs) {
          String status = reportDoc['status'];
          reportCount++;
          if (status == 'Diproses') {
            inProcessCount++;
          } else if (status == 'Selesai') {
            completedCount++;
          } else if (status == 'Dibuat') {
            pendingCount++;
          }
        }
      }

      if (mounted) {
        setState(() {
          totalPending = pendingCount;
          totalInProcess = inProcessCount;
          totalCompleted = completedCount;
          totalReport = reportCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error mendapatkan statistik laporan: $e');
      _isLoading = false;
    }
  }

  Future<void> _getLatestReports() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      List<Map<String, dynamic>> allReports = [];

      for (var userDoc in usersSnapshot.docs) {
        String userName = userDoc['name'];
        QuerySnapshot reportsSnapshot =
            await userDoc.reference.collection('reports').get();

        for (var reportDoc in reportsSnapshot.docs) {
          Map<String, dynamic> reportData =
              reportDoc.data() as Map<String, dynamic>;
          reportData['date'] = (reportData['date'] as Timestamp).toDate();
          reportData['userId'] = userDoc.id;
          reportData['reportId'] = reportDoc.id;
          reportData['userName'] = userName;
          allReports.add(reportData);
        }
      }

      allReports.sort((a, b) => b['date'].compareTo(a['date']));

      if (mounted) {
        setState(() {
          latestReports = allReports.take(5).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error mendapatkan laporan terbaru: $e');
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Background gradient + pattern
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  darkGreenColor,
                  lightGreenColor.withOpacity(0.8),
                  Color(0xffE6F2EF),
                ],
              ),
            ),
          ),
          Positioned(
            top: -40,
            right: -60,
            child: Opacity(
              opacity: 0.13,
              child: Image.asset(
                'assets/leaderboard_bg.png',
                width: 260,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header glassmorphism
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 18, vertical: 18),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1.2),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 54,
                                      height: 54,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: whiteColor, width: 2),
                                        image: DecorationImage(
                                          image: NetworkImage(profileImageUrl ??
                                              defaultProfileImageUrl),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Image.asset(
                                                  'assets/logo_without_text.png',
                                                  width: 28,
                                                  height: 28),
                                              SizedBox(width: 5),
                                              Flexible(
                                                child: Text(
                                                  'TrashScout',
                                                  style: boldTextStyle.copyWith(
                                                      color: darkGreenColor,
                                                      fontSize: 18),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Selamat datang,',
                                            style: regularTextStyle.copyWith(
                                                color: whiteColor,
                                                fontSize: 13),
                                          ),
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  displayName ?? '-',
                                                  style: boldTextStyle.copyWith(
                                                      color: whiteColor,
                                                      fontSize: 16),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              SizedBox(width: 4),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 7, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.amber[700],
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.verified_user,
                                                        color: Colors.white,
                                                        size: 13),
                                                    SizedBox(width: 2),
                                                    Text('Admin',
                                                        style: mediumTextStyle
                                                            .copyWith(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 11)),
                                                  ],
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
                              SizedBox(width: 10),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: whiteColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  onPressed: logoutUser,
                                  icon: Icon(Icons.logout,
                                      color: darkGreenColor, size: 22),
                                  tooltip: 'Logout',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    // Card statistik animasi
                    AnimatedOpacity(
                      opacity: _isLoading ? 0.5 : 1.0,
                      duration: Duration(milliseconds: 400),
                      child: Container(
                        padding: EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 16,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: _isLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                    color: darkGreenColor))
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Rekap Laporan',
                                      style: boldTextStyle.copyWith(
                                          color: darkGreenColor, fontSize: 22)),
                                  SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _AnimatedStatBox(
                                        title: 'Pending',
                                        value: totalPending,
                                        color: darkGreenColor,
                                        icon: Icons.hourglass_empty_rounded,
                                      ),
                                      _AnimatedStatBox(
                                        title: 'Diproses',
                                        value: totalInProcess,
                                        color: lightGreenColor,
                                        icon: Icons.sync_rounded,
                                      ),
                                      _AnimatedStatBox(
                                        title: 'Selesai',
                                        value: totalCompleted,
                                        color: Color(0xff6BC2A2),
                                        icon: Icons.check_circle_rounded,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 18),
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(vertical: 18),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          darkGreenColor,
                                          lightGreenColor
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        AnimatedCounter(
                                          value: totalReport,
                                          textStyle: boldTextStyle.copyWith(
                                              color: whiteColor, fontSize: 40),
                                        ),
                                        Text(
                                          'Total Laporan Diterima',
                                          style: regularTextStyle.copyWith(
                                              color: whiteColor, fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    SizedBox(height: 32),
                    // Riwayat laporan
                    Text(
                      'Riwayat Laporan Terbaru',
                      style: boldTextStyle.copyWith(
                          color: darkGreenColor, fontSize: 22),
                    ),
                    SizedBox(height: 10),
                    if (_isLoading)
                      Center(
                          child:
                              CircularProgressIndicator(color: darkGreenColor))
                    else if (latestReports.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text('Belum ada laporan terbaru.',
                              style: regularTextStyle.copyWith(
                                  color: darkGreyColor)),
                        ),
                      )
                    else
                      Column(
                        children: latestReports.map((report) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _HDReportCard(
                                report: report,
                                getStatusColor: _getStatusColor,
                                onUpdateStatus: _getLatestReports),
                          );
                        }).toList(),
                      ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
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

class AnimatedCounter extends StatefulWidget {
  final int value;
  final TextStyle textStyle;
  const AnimatedCounter({required this.value, required this.textStyle});
  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;
  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: Duration(milliseconds: 900), vsync: this);
    _animation = IntTween(begin: 0, end: widget.value)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = IntTween(begin: 0, end: widget.value)
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) =>
          Text(_animation.value.toString(), style: widget.textStyle),
    );
  }
}

class _AnimatedStatBox extends StatelessWidget {
  final String title;
  final int value;
  final Color color;
  final IconData icon;
  const _AnimatedStatBox(
      {required this.title,
      required this.value,
      required this.color,
      required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.09),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 8),
          AnimatedCounter(
            value: value,
            textStyle: boldTextStyle.copyWith(color: color, fontSize: 22),
          ),
          SizedBox(height: 2),
          Text(
            title,
            style: mediumTextStyle.copyWith(color: color, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _HDReportCard extends StatelessWidget {
  final Map<String, dynamic> report;
  final Color Function(String) getStatusColor;
  final VoidCallback onUpdateStatus;
  const _HDReportCard(
      {required this.report,
      required this.getStatusColor,
      required this.onUpdateStatus});

  void _updateReportStatus(BuildContext context, String newStatus) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        titlePadding: EdgeInsets.only(top: 28, left: 24, right: 24, bottom: 0),
        contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        actionsPadding:
            EdgeInsets.only(left: 16, right: 16, bottom: 18, top: 8),
        title: Column(
          children: [
            Icon(Icons.help_outline_rounded, color: darkGreenColor, size: 48),
            SizedBox(height: 10),
            Text('Konfirmasi',
                style: boldTextStyle.copyWith(
                    fontSize: 22, color: darkGreenColor)),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin mengubah status laporan menjadi "$newStatus"?',
          style: regularTextStyle.copyWith(fontSize: 16, color: darkGreyColor),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: darkGreenColor),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('Batal',
                        style: mediumTextStyle.copyWith(
                            color: darkGreenColor, fontSize: 16)),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkGreenColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('Ya',
                        style: mediumTextStyle.copyWith(
                            color: whiteColor, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      FirestoreService firestoreService = FirestoreService();
      await firestoreService.updateReportStatus(
          report['userId'], report['reportId'], newStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status laporan diperbarui menjadi $newStatus'),
          duration: Duration(seconds: 1),
        ),
      );
      onUpdateStatus();
    } catch (e) {
      print('Error updating report status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Failed to update report status')),
      );
    }
  }

  void _showStatusSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text('Ubah Status Laporan',
                  style: boldTextStyle.copyWith(fontSize: 20)),
              SizedBox(height: 18),
              if (report['status'] != 'Diproses' &&
                  report['status'] != 'Selesai')
                _StatusOption(
                  icon: Icons.sync_rounded,
                  color: lightGreenColor,
                  label: 'Diproses',
                  description: 'Laporan sedang diproses petugas',
                  onTap: () {
                    Navigator.pop(ctx);
                    _updateReportStatus(context, 'Diproses');
                  },
                ),
              if (report['status'] != 'Selesai')
                _StatusOption(
                  icon: Icons.check_circle_rounded,
                  color: Color(0xff6BC2A2),
                  label: 'Selesai',
                  description: 'Laporan sudah selesai ditangani',
                  onTap: () {
                    Navigator.pop(ctx);
                    _updateReportStatus(context, 'Selesai');
                  },
                ),
              if (report['status'] == 'Selesai')
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text('Laporan sudah selesai',
                      style: mediumTextStyle.copyWith(color: darkGreyColor)),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminDetailReport(
              reportTitle: report['title'],
              status: mapStatus(report['status']),
              imageUrl: report['imageUrl'],
              date: DateFormat('dd MMMM yyyy').format(report['date']),
              user: report['userName'],
              description: report['description'],
              categories: List<String>.from(report['categories']),
              latitude: report['latitude'],
              longitude: report['longitude'],
              locationDetail: report['locationDetail'],
              weightRating: report['weightRating'],
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                bottomLeft: Radius.circular(18),
              ),
              child: Image.network(
                report['imageUrl'],
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _showStatusSheet(context),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  getStatusColor(report['status']),
                                  lightGreenColor
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: report['status'] == 'Selesai'
                                ? Icon(Icons.check, color: Colors.white)
                                : Text(
                                    mapStatus(report['status']),
                                    style: mediumTextStyle.copyWith(
                                        color: whiteColor, fontSize: 13),
                                  ),
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios,
                            color: darkGreenColor, size: 18),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      report['title'],
                      style: boldTextStyle.copyWith(
                          color: darkGreenColor, fontSize: 17),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      report['description'],
                      style: regularTextStyle.copyWith(
                          color: darkGreyColor, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 7),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            color: lightGreenColor, size: 15),
                        SizedBox(width: 4),
                        Text(
                          DateFormat('dd MMMM yyyy').format(report['date']),
                          style: regularTextStyle.copyWith(
                              color: darkGreyColor, fontSize: 12),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.person, color: lightGreenColor, size: 15),
                        SizedBox(width: 4),
                        Text(
                          report['userName'],
                          style: regularTextStyle.copyWith(
                              color: darkGreyColor, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String description;
  final VoidCallback onTap;
  const _StatusOption(
      {required this.icon,
      required this.color,
      required this.label,
      required this.description,
      required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: EdgeInsets.only(bottom: 14),
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.09),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: boldTextStyle.copyWith(color: color, fontSize: 18)),
                SizedBox(height: 2),
                Text(description,
                    style: regularTextStyle.copyWith(
                        color: darkGreyColor, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AdminHeader extends StatelessWidget {
  final String? userProfilePict;
  final String? userDisplayName;
  final String defaultProfileImage;

  const AdminHeader(
      {required this.userDisplayName,
      required this.userProfilePict,
      required this.defaultProfileImage,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: NetworkImage(userProfilePict ?? defaultProfileImage),
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
          ],
        ),
      ],
    );
  }
}

class ReportRecapAdmin extends StatelessWidget {
  final int totalPending;
  final int totalInProcess;
  final int totalCompleted;
  final int totalReport;

  const ReportRecapAdmin({
    required this.totalPending,
    required this.totalInProcess,
    required this.totalCompleted,
    required this.totalReport,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rekap Laporan:',
          style: boldTextStyle.copyWith(
            color: blackColor,
            fontSize: 20,
          ),
        ),
        SizedBox(height: 9),
        Row(
          children: [
            AdminRecapWidget(
              totalReport: totalPending,
              reportTitle: 'Pending',
              backgroundColor: darkGreenColor,
              iconBackgroundColor: Color(0xff3F8377),
            ),
            SizedBox(width: 6),
            AdminRecapWidget(
              totalReport: totalInProcess,
              reportTitle: 'Diproses',
              backgroundColor: lightGreenColor,
              iconBackgroundColor: Color(0xff41BB9E),
            ),
            SizedBox(width: 6),
            AdminRecapWidget(
              totalReport: totalCompleted,
              reportTitle: 'Selesai',
              backgroundColor: Color(0xff6BC2A2),
              iconBackgroundColor: Color(0xff8CDCBE),
            ),
          ],
        ),
        Container(
          margin: EdgeInsets.only(top: 16),
          width: double.infinity,
          height: 85,
          padding: EdgeInsets.only(
            right: 12,
          ),
          decoration: BoxDecoration(
            color: darkGreenColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Text(
                totalReport.toString(),
                style: boldTextStyle.copyWith(
                  color: whiteColor,
                  fontSize: 40,
                ),
              ),
              Text(
                'Total Laporan Diterima',
                style: regularTextStyle.copyWith(
                  color: whiteColor,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
