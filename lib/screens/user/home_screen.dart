import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trash_scout/screens/user/create_report_page.dart';
import 'package:trash_scout/screens/user/mail_box_screen.dart';
import 'package:trash_scout/screens/user/see_all_history_screen.dart';
import 'package:trash_scout/screens/user/detail_report_page.dart';
import 'package:trash_scout/services/firestore_service.dart';
import 'package:trash_scout/shared/theme/theme.dart';
import 'dart:ui';

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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: whiteColor, width: 2),
                                  image: DecorationImage(
                                    image: NetworkImage(displayProfilePicture ??
                                        'https://firebasestorage.googleapis.com/v0/b/trash-scout-3c117.appspot.com/o/users%2Fdefault_profile_image%2Fuser%20default%20profile.png?alt=media&token=79ef1308-3d3d-477d-b566-0c4e66848a4d'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 2),
                                    Text('Selamat datang,',
                                        style: regularTextStyle.copyWith(
                                            color: whiteColor, fontSize: 13)),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            displayName ?? '-',
                                            style: boldTextStyle.copyWith(
                                                color: whiteColor,
                                                fontSize: 16),
                                            overflow: TextOverflow.ellipsis,
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
                                              Text('User',
                                                  style:
                                                      mediumTextStyle.copyWith(
                                                          color: Colors.white,
                                                          fontSize: 11)),
                                            ],
                                          ),
                                        ),
                                      ],
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
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MailBoxScreen(),
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.mail_outline,
                                      color: darkGreenColor, size: 22),
                                  tooltip: 'Kotak Masuk',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    // Statistik laporan
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .collection('reports')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                              child: CircularProgressIndicator(
                                  color: darkGreenColor));
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return _UserStatCard(
                              totalCreated: 0,
                              totalInProcess: 0,
                              totalCompleted: 0);
                        }
                        var reports = snapshot.data!.docs;
                        int totalCreated = reports.length;
                        int totalInProcess = reports
                            .where((doc) => doc['status'] == 'Diproses')
                            .length;
                        int totalCompleted = reports
                            .where((doc) => doc['status'] == 'Selesai')
                            .length;
                        return _UserStatCard(
                          totalCreated: totalCreated,
                          totalInProcess: totalInProcess,
                          totalCompleted: totalCompleted,
                        );
                      },
                    ),
                    SizedBox(height: 32),
                    // Tombol Buat Laporan
                    Center(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkGreenColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          padding: EdgeInsets.symmetric(
                              horizontal: 32, vertical: 18),
                          elevation: 4,
                        ),
                        icon: Icon(Icons.add_circle_outline,
                            color: whiteColor, size: 24),
                        label: Text('Buat Laporan',
                            style: boldTextStyle.copyWith(
                                color: whiteColor, fontSize: 18)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateReportPage(),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 32),
                    // Laporan terbaru
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Laporan Terbaru',
                            style: boldTextStyle.copyWith(
                                color: darkGreenColor, fontSize: 22)),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            border:
                                Border.all(color: darkGreenColor, width: 1.2),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: darkGreenColor.withOpacity(0.07),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SeeAllHistoryScreen(),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 7),
                                child: Text(
                                  'Lihat Semua',
                                  style: mediumTextStyle.copyWith(
                                    color: darkGreenColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .collection('reports')
                          .orderBy('date', descending: true)
                          .limit(5)
                          .snapshots(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                              child: CircularProgressIndicator(
                                  color: darkGreenColor));
                        }
                        var reports = snapshot.data!.docs;
                        if (reports.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.inbox,
                                      color: lightGreenColor, size: 54),
                                  SizedBox(height: 10),
                                  Text('Belum ada laporan terbaru.',
                                      style: regularTextStyle.copyWith(
                                          color: darkGreyColor)),
                                ],
                              ),
                            ),
                          );
                        }
                        return Column(
                          children: reports.map((report) {
                            String formattedDate = DateFormat('dd MMMM yyyy')
                                .format((report['date'] as Timestamp).toDate());
                            final List<String> categories =
                                List<String>.from(report['categories']);
                            final data = report.data() as Map<String, dynamic>?;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _UserReportCard(
                                report: report,
                                formattedDate: formattedDate,
                                categories: categories,
                                data: data,
                                getStatusColor: _getStatusColor,
                              ),
                            );
                          }).toList(),
                        );
                      },
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
      case 'B3':
        return Colors.red;
      default:
        return darkGreyColor;
    }
  }
}

class _UserStatCard extends StatelessWidget {
  final int totalCreated;
  final int totalInProcess;
  final int totalCompleted;
  const _UserStatCard(
      {required this.totalCreated,
      required this.totalInProcess,
      required this.totalCompleted});
  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Statistik Laporan',
              style:
                  boldTextStyle.copyWith(color: darkGreenColor, fontSize: 22)),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _AnimatedStatBox(
                  title: 'Dibuat',
                  value: totalCreated,
                  color: darkGreenColor,
                  icon: Icons.create),
              _AnimatedStatBox(
                  title: 'Diproses',
                  value: totalInProcess,
                  color: lightGreenColor,
                  icon: Icons.sync_rounded),
              _AnimatedStatBox(
                  title: 'Selesai',
                  value: totalCompleted,
                  color: Color(0xff6BC2A2),
                  icon: Icons.check_circle_rounded),
            ],
          ),
        ],
      ),
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
          _AnimatedCounter(value: value, color: color),
          SizedBox(height: 2),
          Text(title,
              style: mediumTextStyle.copyWith(color: color, fontSize: 15)),
        ],
      ),
    );
  }
}

class _AnimatedCounter extends StatefulWidget {
  final int value;
  final Color color;
  const _AnimatedCounter({required this.value, required this.color});
  @override
  State<_AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<_AnimatedCounter>
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
  void didUpdateWidget(covariant _AnimatedCounter oldWidget) {
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
      builder: (context, child) => Text(_animation.value.toString(),
          style: boldTextStyle.copyWith(color: widget.color, fontSize: 22)),
    );
  }
}

class _UserReportCard extends StatelessWidget {
  final QueryDocumentSnapshot report;
  final String formattedDate;
  final List<String> categories;
  final Map<String, dynamic>? data;
  final Color Function(String) getStatusColor;
  const _UserReportCard(
      {required this.report,
      required this.formattedDate,
      required this.categories,
      required this.data,
      required this.getStatusColor});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.10),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                report['imageUrl'],
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          report['title'],
                          style: boldTextStyle.copyWith(
                              fontSize: 16, color: darkGreenColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 6),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: getStatusColor(report['status'])
                              .withOpacity(0.13),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              report['status'] == 'Selesai'
                                  ? Icons.check_circle
                                  : report['status'] == 'Diproses'
                                      ? Icons.sync_rounded
                                      : Icons.create,
                              color: getStatusColor(report['status']),
                              size: 15,
                            ),
                            SizedBox(width: 3),
                            Text(report['status'],
                                style: mediumTextStyle.copyWith(
                                    color: getStatusColor(report['status']),
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 14, color: lightGreenColor),
                      SizedBox(width: 4),
                      Text(
                        formattedDate,
                        style: regularTextStyle.copyWith(
                            fontSize: 13, color: darkGreyColor),
                      ),
                      if (report.data() != null &&
                          (report.data() as Map<String, dynamic>)
                              .containsKey('location')) ...[
                        SizedBox(width: 10),
                        Icon(Icons.location_on,
                            size: 14, color: Colors.redAccent),
                        SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            report['location'] ?? '-',
                            style: regularTextStyle.copyWith(
                                fontSize: 13, color: darkGreyColor),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ]
                    ],
                  ),
                  SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    children: categories
                        .take(3)
                        .map((cat) => Chip(
                              label: Text(cat,
                                  style: regularTextStyle.copyWith(
                                      color: cat == 'B3'
                                          ? Colors.red[900]
                                          : darkGreenColor,
                                      fontSize: 11)),
                              backgroundColor: cat == 'B3'
                                  ? Colors.red[100]
                                  : lightGreenColor.withOpacity(0.18),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 0),
                              visualDensity: VisualDensity.compact,
                            ))
                        .toList(),
                  ),
                  if (report['description'] != null &&
                      (report['description'] as String).isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        report['description'],
                        style: regularTextStyle.copyWith(
                            color: darkGreyColor, fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              color: Colors.white,
              elevation: 8,
              offset: Offset(0, 30),
              icon: Icon(Icons.more_vert, color: lightGreenColor),
              onSelected: (String value) {
                if (value == 'detail') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailReportPage(
                        reportTitle: report['title'],
                        status: report['status'],
                        imageUrl: report['imageUrl'],
                        description: report['description'],
                        date: formattedDate,
                        categories: categories,
                        latitude: report['latitude'] ?? '',
                        longitude: report['longitude'] ?? '',
                        locationDetail: report['locationDetail'] ?? '-',
                        beratB3: report['beratB3'] ?? 0,
                        beratAnorganik: report['beratAnorganik'] ?? 0,
                        beratOrganik: report['beratOrganik'] ?? 0,
                      ),
                    ),
                  );
                } else if (value == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateReportPage(report: report),
                    ),
                  );
                } else if (value == 'delete') {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Hapus Laporan'),
                      content: Text(
                          'Apakah Anda yakin ingin menghapus laporan ini?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () async {
                            await report.reference.delete();
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Laporan berhasil dihapus')),
                            );
                          },
                          child: Text('Hapus',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 'detail',
                  child: Row(
                    children: [
                      Icon(Icons.visibility,
                          color: Colors.green[700], size: 20),
                      SizedBox(width: 10),
                      Text('Lihat Detail',
                          style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                PopupMenuDivider(),
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.blue[700], size: 20),
                      SizedBox(width: 10),
                      Text('Edit Laporan',
                          style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                PopupMenuDivider(),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red[700], size: 20),
                      SizedBox(width: 10),
                      Text('Hapus Laporan',
                          style: TextStyle(
                              color: Colors.red[700],
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
