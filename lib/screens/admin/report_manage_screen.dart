import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trash_scout/shared/theme/theme.dart';
import 'package:trash_scout/shared/widgets/admin/map_status.dart';
import 'dart:ui';
import 'package:trash_scout/services/firestore_service.dart';
import 'package:trash_scout/screens/admin/admin_detail_report.dart';

class ReportManageScreen extends StatefulWidget {
  const ReportManageScreen({super.key});

  @override
  State<ReportManageScreen> createState() => _ReportManageScreenState();
}

class _ReportManageScreenState extends State<ReportManageScreen> {
  String _selectedStatus = 'Semua';
  List<Map<String, dynamic>> reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getReportsByStatus(_selectedStatus);
  }

  Future<void> _getReportsByStatus(String status) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      List<Map<String, dynamic>> filteredReports = [];

      for (var userDoc in usersSnapshot.docs) {
        Query query = userDoc.reference.collection('reports');
        String userName = userDoc['name'];

        if (status != 'Semua') {
          String firestoreStatus = mapStatusToFirestore(status);
          query = query.where('status', isEqualTo: firestoreStatus);
        }

        QuerySnapshot reportsSnapshot =
            await query.orderBy('date', descending: true).get();

        for (var reportDoc in reportsSnapshot.docs) {
          Map<String, dynamic> reportData =
              reportDoc.data() as Map<String, dynamic>;

          reportData['date'] = (reportData['date'] as Timestamp).toDate();
          reportData['userId'] = userDoc.id;
          reportData['reportId'] = reportDoc.id;
          reportData['userName'] = userName;
          filteredReports.add(reportData);
        }
      }

      print('Reports retrieved: ${filteredReports.length}');
      if (mounted) {
        setState(() {
          reports = filteredReports;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error getting reports: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _updateStatus(String status) {
    if (mounted) {
      setState(() {
        _selectedStatus = status;
        _getReportsByStatus(status);
      });
    }
  }

  void _refreshReports() {
    _getReportsByStatus(_selectedStatus);
  }

  void _showStatusSheet(BuildContext context, Map<String, dynamic> report) {
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
                    _updateReportStatus(context, report, 'Diproses');
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
                    _updateReportStatus(context, report, 'Selesai');
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

  void _updateReportStatus(BuildContext context, Map<String, dynamic> report,
      String newStatus) async {
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
      _refreshReports();
    } catch (e) {
      print('Error updating report status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Failed to update report status')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: AppBar(
              elevation: 0,
              backgroundColor: Colors.white.withOpacity(0.16),
              shadowColor: Colors.black12,
              titleSpacing: 0,
              toolbarHeight: 70,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/logo_without_text.png',
                      width: 34, height: 34),
                  SizedBox(width: 14),
                  Text(
                    'Semua Laporan',
                    style: boldTextStyle.copyWith(
                      color: darkGreenColor,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
              centerTitle: true,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(10.0),
                child: Container(
                  color: Colors.white.withOpacity(0.18),
                  height: 1.5,
                  margin: EdgeInsets.symmetric(horizontal: 24),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [backgroundColor, Color(0xffE6F2EF)],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 110),
            padding:
                EdgeInsets.symmetric(horizontal: screenWidth < 400 ? 8 : 20),
            child: Column(
              children: [
                _StatusChipBar(
                  selectedStatus: _selectedStatus,
                  onStatusChanged: _updateStatus,
                ),
                SizedBox(height: 22),
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                  color: darkGreenColor, strokeWidth: 3.2),
                              SizedBox(height: 18),
                              Text('Memuat laporan, mohon tunggu...',
                                  style: regularTextStyle.copyWith(
                                      color: darkGreyColor)),
                            ],
                          ),
                        )
                      : reports.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset('assets/empty_state.png',
                                      width: 140,
                                      height: 140,
                                      fit: BoxFit.contain,
                                      errorBuilder: (c, e, s) => Icon(
                                          Icons.inbox_rounded,
                                          color: lightGreyColor,
                                          size: 70)),
                                  SizedBox(height: 16),
                                  Text('Belum ada laporan ditemukan',
                                      style: boldTextStyle.copyWith(
                                          color: darkGreenColor, fontSize: 18)),
                                  SizedBox(height: 6),
                                  Text(
                                      'Semua laporan akan muncul di sini setelah ada laporan baru.',
                                      style: regularTextStyle.copyWith(
                                          color: darkGreyColor, fontSize: 14),
                                      textAlign: TextAlign.center),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: EdgeInsets.only(bottom: 36, top: 4),
                              itemCount: reports.length,
                              separatorBuilder: (context, i) =>
                                  SizedBox(height: 22),
                              itemBuilder: (context, index) {
                                final report = reports[index];
                                return Container(
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.white, Color(0xffE6F2EF)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12.withOpacity(0.08),
                                        blurRadius: 18,
                                        offset: Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(24),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(24),
                                      splashColor:
                                          lightGreenColor.withOpacity(0.13),
                                      highlightColor: Colors.transparent,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AdminDetailReport(
                                              reportTitle: report['title'],
                                              status:
                                                  mapStatus(report['status']),
                                              imageUrl: report['imageUrl'],
                                              date: DateFormat('dd MMMM yyyy')
                                                  .format(report['date']),
                                              user: report['userName'],
                                              description:
                                                  report['description'],
                                              categories: List<String>.from(
                                                  report['categories']),
                                              latitude: report['latitude'],
                                              longitude: report['longitude'],
                                              locationDetail:
                                                  report['locationDetail'],
                                              beratB3: report['beratB3'] ?? 1,
                                              beratAnorganik:
                                                  report['beratAnorganik'] ?? 1,
                                              beratOrganik:
                                                  report['beratOrganik'] ?? 1,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            18, 18, 18, 18),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: _getStatusColor(
                                                                report[
                                                                    'status'])
                                                            .withOpacity(0.18),
                                                        blurRadius: 10,
                                                        offset: Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: InkWell(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    onTap: () =>
                                                        _showStatusSheet(
                                                            context, report),
                                                    child: _StatusBadgeWithIcon(
                                                      status: mapStatus(
                                                          report['status']),
                                                      color: _getStatusColor(
                                                          report['status']),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 2, top: 2),
                                                  child: InkWell(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    onTap: () async {
                                                      final confirm =
                                                          await showDialog<
                                                              bool>(
                                                        context: context,
                                                        builder: (ctx) =>
                                                            AlertDialog(
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          18)),
                                                          titlePadding:
                                                              EdgeInsets.only(
                                                                  top: 28,
                                                                  left: 24,
                                                                  right: 24,
                                                                  bottom: 0),
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          24,
                                                                      vertical:
                                                                          8),
                                                          actionsPadding:
                                                              EdgeInsets.only(
                                                                  left: 16,
                                                                  right: 16,
                                                                  bottom: 18,
                                                                  top: 8),
                                                          title: Column(
                                                            children: [
                                                              Icon(
                                                                  Icons
                                                                      .delete_outline_rounded,
                                                                  color: Colors
                                                                      .red,
                                                                  size: 48),
                                                              SizedBox(
                                                                  height: 10),
                                                              Text(
                                                                  'Hapus Laporan',
                                                                  style: boldTextStyle.copyWith(
                                                                      fontSize:
                                                                          22,
                                                                      color: Colors
                                                                          .red)),
                                                            ],
                                                          ),
                                                          content: Text(
                                                            'Apakah Anda yakin ingin menghapus laporan ini? Tindakan ini tidak dapat dibatalkan.',
                                                            style: regularTextStyle
                                                                .copyWith(
                                                                    fontSize:
                                                                        16,
                                                                    color:
                                                                        darkGreyColor),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                          actionsAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          actions: [
                                                            SizedBox(
                                                              width: double
                                                                  .infinity,
                                                              child: Row(
                                                                children: [
                                                                  Expanded(
                                                                    child:
                                                                        OutlinedButton(
                                                                      onPressed: () =>
                                                                          Navigator.pop(
                                                                              ctx,
                                                                              false),
                                                                      style: OutlinedButton
                                                                          .styleFrom(
                                                                        side: BorderSide(
                                                                            color:
                                                                                darkGreenColor),
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(10)),
                                                                        padding:
                                                                            EdgeInsets.symmetric(vertical: 12),
                                                                      ),
                                                                      child: Text(
                                                                          'Batal',
                                                                          style: mediumTextStyle.copyWith(
                                                                              color: darkGreenColor,
                                                                              fontSize: 16)),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      width:
                                                                          12),
                                                                  Expanded(
                                                                    child:
                                                                        ElevatedButton(
                                                                      onPressed: () =>
                                                                          Navigator.pop(
                                                                              ctx,
                                                                              true),
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        backgroundColor:
                                                                            Colors.red,
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(10)),
                                                                        padding:
                                                                            EdgeInsets.symmetric(vertical: 12),
                                                                      ),
                                                                      child: Text(
                                                                          'Hapus',
                                                                          style: mediumTextStyle.copyWith(
                                                                              color: whiteColor,
                                                                              fontSize: 16)),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                      if (confirm == true) {
                                                        try {
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'users')
                                                              .doc(report[
                                                                  'userId'])
                                                              .collection(
                                                                  'reports')
                                                              .doc(report[
                                                                  'reportId'])
                                                              .delete();
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                                content: Text(
                                                                    'Laporan berhasil dihapus!')),
                                                          );
                                                          _refreshReports();
                                                        } catch (e) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                                content: Text(
                                                                    'Gagal menghapus laporan')),
                                                          );
                                                        }
                                                      }
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.red
                                                            .withOpacity(0.13),
                                                        shape: BoxShape.circle,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.red
                                                                .withOpacity(
                                                                    0.13),
                                                            blurRadius: 8,
                                                            offset:
                                                                Offset(0, 2),
                                                          ),
                                                        ],
                                                      ),
                                                      padding:
                                                          EdgeInsets.all(7),
                                                      child: Icon(
                                                          Icons
                                                              .delete_outline_rounded,
                                                          color: Colors.red,
                                                          size: 20),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 14),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  child: Image.network(
                                                    report['imageUrl'],
                                                    width: 70,
                                                    height: 70,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Icon(Icons.person,
                                                              color:
                                                                  lightGreenColor,
                                                              size: 18),
                                                          SizedBox(width: 4),
                                                          Text(
                                                            report['userName'],
                                                            style: mediumTextStyle
                                                                .copyWith(
                                                                    color:
                                                                        darkGreenColor,
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 2),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                              Icons
                                                                  .calendar_today,
                                                              color:
                                                                  lightGreenColor,
                                                              size: 16),
                                                          SizedBox(width: 4),
                                                          Text(
                                                            DateFormat(
                                                                    'dd MMM yyyy')
                                                                .format(report[
                                                                    'date']),
                                                            style: regularTextStyle
                                                                .copyWith(
                                                                    color:
                                                                        darkGreyColor,
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 7),
                                                      Text(
                                                        report['title'],
                                                        style: boldTextStyle.copyWith(
                                                            color:
                                                                darkGreenColor,
                                                            fontSize: 20),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 12),
                                            Text(
                                              (report['description'] as String)
                                                      .isEmpty
                                                  ? '-'
                                                  : report['description'],
                                              style: regularTextStyle.copyWith(
                                                  color: darkGreyColor
                                                      .withOpacity(0.85),
                                                  fontSize: 15),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 14),
                                            Row(
                                              children: [
                                                ...List.generate(
                                                  (report['categories'] as List)
                                                      .length,
                                                  (i) => Container(
                                                    margin: EdgeInsets.only(
                                                        right: 8),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 14,
                                                            vertical: 6),
                                                    decoration: BoxDecoration(
                                                      color: _getCategoryColor(
                                                          report['categories']
                                                              [i]),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              11),
                                                    ),
                                                    child: Text(
                                                      report['categories'][i],
                                                      style: regularTextStyle
                                                          .copyWith(
                                                        color: Colors.white,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 10),
                                            Divider(
                                                height: 1,
                                                color: Colors.grey
                                                    .withOpacity(0.13)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
                SizedBox(height: 24),
              ],
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

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Organik':
        return Color(0xff6BC2A2);
      case 'Anorganik':
        return Color(0xff41BB9E);
      case 'B3':
        return Colors.red;
      default:
        return lightGreenColor;
    }
  }
}

class _StatusChipBar extends StatelessWidget {
  final String selectedStatus;
  final Function(String) onStatusChanged;
  const _StatusChipBar(
      {required this.selectedStatus, required this.onStatusChanged});
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> statuses = [
      {
        'label': 'Semua',
        'icon': Icons.list_alt_rounded,
        'color': darkGreenColor
      },
      {
        'label': 'Pending',
        'icon': Icons.hourglass_empty_rounded,
        'color': darkGreenColor
      },
      {
        'label': 'Diproses',
        'icon': Icons.sync_rounded,
        'color': lightGreenColor
      },
      {
        'label': 'Selesai',
        'icon': Icons.check_circle_rounded,
        'color': Color(0xff6BC2A2)
      },
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: statuses.map((status) {
          final bool isSelected = status['label'] == selectedStatus;
          return Padding(
            padding: const EdgeInsets.only(right: 14),
            child: ChoiceChip(
              avatar: Icon(status['icon'],
                  color: isSelected ? whiteColor : status['color'], size: 22),
              label: Text(status['label'],
                  style: mediumTextStyle.copyWith(
                      color: isSelected ? whiteColor : status['color'],
                      fontSize: 16)),
              selected: isSelected,
              selectedColor: status['color'],
              backgroundColor: whiteColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13)),
              onSelected: (_) => onStatusChanged(status['label']),
              labelPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              elevation: isSelected ? 5 : 0,
              pressElevation: 0,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StatusBadgeWithIcon extends StatelessWidget {
  final String status;
  final Color color;
  const _StatusBadgeWithIcon({required this.status, required this.color});
  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (status) {
      case 'Pending':
        icon = Icons.hourglass_empty_rounded;
        break;
      case 'Diproses':
        icon = Icons.sync_rounded;
        break;
      case 'Selesai':
        icon = Icons.check_circle_rounded;
        break;
      default:
        icon = Icons.info_outline_rounded;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 13, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.18),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: whiteColor, size: 16),
          SizedBox(width: 5),
          Text(
            status,
            style: boldTextStyle.copyWith(color: whiteColor, fontSize: 14),
          ),
        ],
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
