import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trash_scout/shared/theme/theme.dart';
import 'package:trash_scout/shared/widgets/admin/map_status.dart';
import 'dart:ui';
import 'package:trash_scout/services/firestore_service.dart';

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
                                return Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () {},
                                    child: Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: whiteColor.withOpacity(0.98),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                                color: Colors.black12
                                                    .withOpacity(0.07)),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 14,
                                                offset: Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                14, 14, 14, 14),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              14),
                                                      child: Image.network(
                                                        report['imageUrl'],
                                                        width: 74,
                                                        height: 74,
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
                                                                  size: 17),
                                                              SizedBox(
                                                                  width: 4),
                                                              Flexible(
                                                                child: Text(
                                                                  report[
                                                                      'userName'],
                                                                  style: mediumTextStyle
                                                                      .copyWith(
                                                                          color:
                                                                              darkGreyColor,
                                                                          fontSize:
                                                                              14),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
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
                                                                  size: 15),
                                                              SizedBox(
                                                                  width: 4),
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
                                                                            13),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 7),
                                                          Text(
                                                            report['title'],
                                                            style: boldTextStyle
                                                                .copyWith(
                                                                    color:
                                                                        darkGreenColor,
                                                                    fontSize:
                                                                        18),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 10),
                                                Text(
                                                  (report['description']
                                                              as String)
                                                          .isEmpty
                                                      ? '-'
                                                      : report['description'],
                                                  style:
                                                      regularTextStyle.copyWith(
                                                          color: darkGreyColor,
                                                          fontSize: 14),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    ...List.generate(
                                                      (report['categories']
                                                              as List)
                                                          .length,
                                                      (i) => Container(
                                                        margin: EdgeInsets.only(
                                                            right: 7),
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 12,
                                                                vertical: 4),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: lightGreenColor
                                                              .withOpacity(
                                                                  0.13),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(9),
                                                        ),
                                                        child: Text(
                                                          report['categories']
                                                              [i],
                                                          style: regularTextStyle
                                                              .copyWith(
                                                                  color:
                                                                      lightGreenColor,
                                                                  fontSize: 13),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 14,
                                          right: 14,
                                          child: GestureDetector(
                                            onTap: () => _showStatusSheet(
                                                context, report),
                                            child: _StatusBadgeWithIcon(
                                                status:
                                                    mapStatus(report['status']),
                                                color: _getStatusColor(
                                                    report['status'])),
                                          ),
                                        ),
                                      ],
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
      default:
        return darkGreyColor;
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
