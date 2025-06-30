import 'package:flutter/material.dart';
import 'package:trash_scout/screens/user/detail_report_page.dart';
import 'package:trash_scout/shared/theme/theme.dart';

class ReportHistory extends StatelessWidget {
  final String reportTitle;
  final String status;
  final String imageUrl;
  final Color statusBackgroundColor;
  final String description;
  final String date;
  final List<String> categories;
  final String latitude;
  final String longitude;
  final String locationDetail;
  final int beratB3;
  final int beratAnorganik;
  final int beratOrganik;

  const ReportHistory({
    required this.reportTitle,
    required this.status,
    required this.imageUrl,
    required this.statusBackgroundColor,
    required this.description,
    required this.date,
    required this.categories,
    required this.latitude,
    required this.longitude,
    required this.locationDetail,
    required this.beratB3,
    required this.beratAnorganik,
    required this.beratOrganik,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      ),
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
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: statusBackgroundColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          status,
                          style: mediumTextStyle.copyWith(
                            color: whiteColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailReportPage(
                    reportTitle: reportTitle,
                    imageUrl: imageUrl,
                    description: description,
                    status: status,
                    date: date,
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
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: 3.5,
                horizontal: 12,
              ),
              decoration: BoxDecoration(
                color: lightGreenColor,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                'Lihat',
                style: mediumTextStyle.copyWith(
                  color: whiteColor,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryDate extends StatelessWidget {
  final String dateTime;

  const HistoryDate({required this.dateTime});

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Container(
        margin: EdgeInsets.only(
          top: 8,
        ),
        height: 25,
        decoration: BoxDecoration(
          color: Color(0xffE6E6E6),
          borderRadius: BorderRadius.circular(5),
        ),
        padding: EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.center,
        child: Text(
          dateTime,
          style: regularTextStyle.copyWith(
            color: blackColor,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
