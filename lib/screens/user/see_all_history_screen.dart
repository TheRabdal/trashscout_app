import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trash_scout/shared/date_formatter.dart';
import 'package:trash_scout/shared/theme/theme.dart';
import 'package:trash_scout/shared/widgets/user/report_history.dart';
import 'package:trash_scout/screens/user/detail_report_page.dart';

class SeeAllHistoryScreen extends StatefulWidget {
  const SeeAllHistoryScreen({super.key});

  @override
  State<SeeAllHistoryScreen> createState() => _SeeAllHistoryScreenState();
}

class _SeeAllHistoryScreenState extends State<SeeAllHistoryScreen> {
  String _selectedStatus = 'Dibuat';

  void _updateStatus(String status) {
    if (mounted) {
      setState(() {
        _selectedStatus = status;
      });
    }
  }

  Map<String, List<QueryDocumentSnapshot>> _groupReportsByDate(
      List<QueryDocumentSnapshot> reports) {
    Map<String, List<QueryDocumentSnapshot>> groupedReports = {};
    for (var report in reports) {
      DateTime reportDate = (report['date'] as Timestamp).toDate();
      String formattedDate = DateFormatter.formatDate(reportDate);
      if (!groupedReports.containsKey(formattedDate)) {
        groupedReports[formattedDate] = [];
      }
      groupedReports[formattedDate]!.add(report);
    }
    return groupedReports;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: backgroundColor,
        title: Text(
          'Riwayat Laporan',
          style: semiBoldTextStyle.copyWith(
            color: blackColor,
            fontSize: 26,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(6.0),
          child: Container(
            color: Color(0xffC7C7C7),
            height: 0.4,
          ),
        ),
      ),
      backgroundColor: backgroundColor,
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            SizedBox(height: 16),
            // Filter status dengan chip
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatusChip('Dibuat'),
                  SizedBox(width: 8),
                  _buildStatusChip('Diproses'),
                  SizedBox(width: 8),
                  _buildStatusChip('Selesai'),
                  SizedBox(width: 8)
                ],
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('reports')
                    .where('status', isEqualTo: _selectedStatus)
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'Belum ada laporan untuk status ini',
                        style: regularTextStyle.copyWith(
                          color: lightGreyColor,
                        ),
                      ),
                    );
                  }
                  var reports = snapshot.data!.docs;
                  var groupedReports = _groupReportsByDate(reports);
                  return ListView(
                    padding: EdgeInsets.only(bottom: 20),
                    children: groupedReports.entries.map((entry) {
                      String date = entry.key;
                      List<QueryDocumentSnapshot> reports = entry.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDateBadge(date),
                          ...reports.map((report) {
                            String formattedDate = DateFormat('dd MMMM yyyy')
                                .format((report['date'] as Timestamp).toDate());
                            final List<String> categories =
                                List<String>.from(report['categories']);
                            final data = report.data() as Map<String, dynamic>?;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 2),
                              child: _AdvancedReportCard(
                                report: report,
                                formattedDate: formattedDate,
                                categories: categories,
                                data: data,
                                onDelete: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                      title: Row(
                                        children: [
                                          Icon(Icons.warning,
                                              color: Colors.red, size: 28),
                                          SizedBox(width: 8),
                                          Text('Hapus Laporan?'),
                                        ],
                                      ),
                                      content: Text(
                                          'Yakin ingin menghapus laporan ini?'),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: Text('Batal')),
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child: Text('Hapus',
                                                style: TextStyle(
                                                    color: Colors.red))),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(FirebaseAuth
                                            .instance.currentUser!.uid)
                                        .collection('reports')
                                        .doc(report.id)
                                        .delete();
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final isSelected = _selectedStatus == status;
    Color color = isSelected ? darkGreenColor : Colors.grey[300]!;
    Color textColor = isSelected ? Colors.white : darkGreenColor;
    return ChoiceChip(
      label: Text(status, style: TextStyle(fontWeight: FontWeight.w600)),
      selected: isSelected,
      selectedColor: color,
      backgroundColor: Colors.grey[100],
      labelStyle: TextStyle(color: textColor),
      onSelected: (_) => _updateStatus(status),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: isSelected ? 4 : 0,
      pressElevation: 0,
      side: BorderSide(color: color, width: 1.2),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
    );
  }

  Widget _buildDateBadge(String date) {
    return Container(
      margin: EdgeInsets.only(top: 16, left: 2, bottom: 4),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        date,
        style: mediumTextStyle.copyWith(color: darkGreenColor, fontSize: 15),
      ),
    );
  }
}

class _AdvancedReportCard extends StatelessWidget {
  final QueryDocumentSnapshot report;
  final String formattedDate;
  final List<String> categories;
  final Map<String, dynamic>? data;
  final VoidCallback onDelete;
  const _AdvancedReportCard({
    required this.report,
    required this.formattedDate,
    required this.categories,
    required this.data,
    required this.onDelete,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
                          color: _getStatusColor(report['status'])
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
                              color: _getStatusColor(report['status']),
                              size: 15,
                            ),
                            SizedBox(width: 3),
                            Text(report['status'],
                                style: mediumTextStyle.copyWith(
                                    color: _getStatusColor(report['status']),
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
            Column(
              children: [
                IconButton(
                  icon:
                      Icon(Icons.visibility, color: lightGreenColor, size: 26),
                  tooltip: 'Lihat Detail',
                  onPressed: () {
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
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red[400], size: 26),
                  tooltip: 'Hapus',
                  onPressed: onDelete,
                ),
              ],
            ),
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
