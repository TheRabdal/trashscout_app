import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trash_scout/shared/theme/theme.dart';
import 'package:trash_scout/shared/widgets/admin/map_status.dart';
import 'package:trash_scout/shared/widgets/admin/report_item_widget.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: backgroundColor,
        title: Text(
          'Semua Laporan',
          style: semiBoldTextStyle.copyWith(
            color: blackColor,
            fontSize: 26,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(6.0), // Tinggi garis
          child: Container(
            color: Color(0xffC7C7C7), // Warna garis
            height: 0.4, // Ketebalan garis
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Column(
          children: [
            SizedBox(height: 16),
            ReportFilterByStatus(
              selectedStatus: _selectedStatus,
              onStatusChanged: _updateStatus,
            ),
            SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: darkGreenColor,
                      ),
                    )
                  : reports.isEmpty
                      ? Center(
                          child: Text(
                            'Belum ada laporan untuk status ini',
                            style: regularTextStyle.copyWith(
                              color: darkGreyColor,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: reports.length,
                          itemBuilder: (context, index) {
                            final report = reports[index];
                            return ReportItemWidget(
                              reportTitle: report['title'],
                              reportId: report['reportId'],
                              user: report['userName'],
                              userId: report['userId'],
                              status: mapStatus(report['status']),
                              imageUrl: report['imageUrl'],
                              date: DateFormat('dd MMMM yyyy')
                                  .format(report['date']),
                              statusBackgroundColor: _getStatusColor(
                                report['status'],
                              ),
                              onUpdateStatus: _refreshReports,
                              description: report['description'],
                              categories:
                                  List<String>.from(report['categories']),
                              latitude: report['latitude'],
                              longitude: report['longitude'],
                              locationDetail: report['locationDetail'],
                            );
                          },
                        ),
            ),
            SizedBox(
              height: 70,
            )
          ],
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

class ReportFilterByStatus extends StatefulWidget {
  final String selectedStatus;
  final Function(String) onStatusChanged;

  const ReportFilterByStatus({
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  @override
  State<ReportFilterByStatus> createState() => _ReportFilterByStatusState();
}

class _ReportFilterByStatusState extends State<ReportFilterByStatus> {
  @override
  Widget build(BuildContext context) {
    final List<String> statuses = ['Semua', 'Pending', 'Diproses', 'Selesai'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: statuses.map((status) {
        final isSelected = status == widget.selectedStatus;
        final color = isSelected ? lightGreenColor : darkGreyColor;

        return TextButton(
          style: TextButton.styleFrom(
            overlayColor: darkGreenColor,
          ),
          onPressed: () => widget.onStatusChanged(status),
          child: Text(
            status,
            style: mediumTextStyle.copyWith(
              color: color,
              fontSize: 16,
            ),
          ),
        );
      }).toList(),
    );
  }
}
