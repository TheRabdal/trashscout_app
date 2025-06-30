import 'package:flutter/material.dart';
import 'package:trash_scout/screens/admin/admin_detail_report.dart';
import 'package:trash_scout/services/firestore_service.dart';
import 'package:trash_scout/shared/theme/theme.dart';

class ReportItemWidget extends StatelessWidget {
  final String reportTitle;
  final String status;
  final String imageUrl;
  final String date;
  final Color statusBackgroundColor;
  final String reportId;
  final String userId;
  final Function onUpdateStatus;
  final String description;
  final List<String> categories;
  final String latitude;
  final String longitude;
  final String locationDetail;
  final String user;
  final VoidCallback? onTap;
  final int weightRating;
  final int beratB3;
  final int beratAnorganik;
  final int beratOrganik;

  const ReportItemWidget({
    required this.reportTitle,
    required this.status,
    required this.imageUrl,
    required this.date,
    required this.statusBackgroundColor,
    required this.reportId,
    required this.userId,
    required this.onUpdateStatus,
    required this.description,
    required this.categories,
    required this.latitude,
    required this.longitude,
    required this.user,
    required this.locationDetail,
    required this.weightRating,
    required this.beratB3,
    required this.beratAnorganik,
    required this.beratOrganik,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ??
          () {
            {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminDetailReport(
                    reportTitle: reportTitle,
                    status: status,
                    imageUrl: imageUrl,
                    date: date,
                    user: user,
                    description: description,
                    categories: categories,
                    latitude: latitude,
                    longitude: longitude,
                    locationDetail: locationDetail,
                    beratB3: beratB3,
                    beratAnorganik: beratAnorganik,
                    beratOrganik: beratOrganik,
                  ),
                ),
              );
            }
          },
      child: Container(
        margin: EdgeInsets.only(top: 10),
        height: 85,
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 11,
        ),
        decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: blackColor.withOpacity(0.1),
                offset: Offset(0, 1),
                blurRadius: 0.3,
                spreadRadius: 0.0,
              )
            ]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 71,
                    height: 62,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                          imageUrl,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 11),
                  Flexible(
                    fit: FlexFit.loose,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reportTitle,
                          style: mediumTextStyle.copyWith(
                            color: blackColor,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          date,
                          style: regularTextStyle.copyWith(
                            color: blackColor,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (String newStatus) {
                if (status != 'Selesai') {
                  _updateReportStatus(context, newStatus);
                }
              },
              itemBuilder: (BuildContext context) {
                if (status == 'Selesai') {
                  return [];
                } else {
                  return <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'Diproses',
                      child: Text('Diproses'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'Selesai',
                      child: Text('Selesai'),
                    ),
                  ];
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: statusBackgroundColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: status == 'Selesai'
                    ? Icon(
                        Icons.check,
                        color: Colors.white,
                      )
                    : Text(
                        status,
                        style: mediumTextStyle.copyWith(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _updateReportStatus(BuildContext context, String newStatus) async {
    try {
      FirestoreService firestoreService = FirestoreService();
      await firestoreService.updateReportStatus(userId, reportId, newStatus);
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
}
