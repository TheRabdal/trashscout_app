import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trash_scout/shared/theme/theme.dart';
import 'package:trash_scout/shared/widgets/admin/map_status.dart';
import 'package:trash_scout/shared/widgets/admin/report_item_widget.dart';

class AdminPriorityScreen extends StatefulWidget {
  const AdminPriorityScreen({super.key});

  @override
  State<AdminPriorityScreen> createState() => _AdminPriorityScreenState();
}

class _AdminPriorityScreenState extends State<AdminPriorityScreen> {
  String _selectedStatus = 'Semua';
  List<Map<String, dynamic>> reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getReportsByStatus();
  }

  Future<void> _getReportsByStatus() async {
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

        QuerySnapshot reportsSnapshot =
            await query.orderBy('date', descending: true).get();

        for (var reportDoc in reportsSnapshot.docs) {
          Map<String, dynamic> reportData =
              reportDoc.data() as Map<String, dynamic>;

          // Ambil kategori dari laporan
          List<String> categories =
              List<String>.from(reportData['categories'] ?? []);
          // Filter hanya jika ada kategori Medis, Beracun, atau Berbahaya
          if (categories.contains('Medis') ||
              categories.contains('Beracun') ||
              categories.contains('Berbahaya')) {
            reportData['date'] = (reportData['date'] as Timestamp).toDate();
            reportData['userId'] = userDoc.id;
            reportData['reportId'] = reportDoc.id;
            reportData['userName'] = userName;
            filteredReports.add(reportData);
          }
        }
      }

      if (mounted) {
        setState(() {
          reports = filteredReports;
          // Urutkan dengan metode SAW
          reports.sort((a, b) {
            double getSAWScore(List<String> categories) {
              double score = 0.0;
              if (categories.contains('Beracun')) score += 0.5;
              if (categories.contains('Berbahaya')) score += 0.3;
              if (categories.contains('Medis')) score += 0.2;
              return score;
            }

            final aScore =
                getSAWScore(List<String>.from(a['categories'] ?? []));
            final bScore =
                getSAWScore(List<String>.from(b['categories'] ?? []));
            return bScore.compareTo(aScore); // descending
          });
          _isLoading = false;
        });
      }
    } catch (e) {
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
        _getReportsByStatus();
      });
    }
  }

  void _refreshReports() {
    _getReportsByStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: backgroundColor,
        title: Text(
          'Sampah Prioritas',
          style: semiBoldTextStyle.copyWith(
            color: blackColor,
            fontSize: 26,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: blackColor),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Informasi Prioritas Sampah'),
                  content: Text(
                    'Laporan prioritas adalah laporan dengan kategori: Beracun, Berbahaya, atau Medis. Urutan prioritas menggunakan metode Simple Additive Weighting (SAW) dengan bobot: Beracun=0.5, Berbahaya=0.3, Medis=0.2. Laporan dengan skor tertinggi akan tampil paling atas.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Tutup'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
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
                            'Belum ada laporan sampah prioritas',
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

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
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
      ),
    );
  }
}
