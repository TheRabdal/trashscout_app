import 'package:flutter/material.dart';
import 'package:trash_scout/shared/theme/theme.dart';

class AdminRecapWidget extends StatelessWidget {
  final int totalReport;
  final String reportTitle;
  final Color backgroundColor;
  final Color iconBackgroundColor;

  const AdminRecapWidget({
    required this.totalReport,
    required this.reportTitle,
    required this.backgroundColor,
    required this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 185,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 23,
                    height: 23,
                    decoration: BoxDecoration(
                      color: iconBackgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                              'assets/megaphone_icon.png',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 2),
                  Text(
                    reportTitle,
                    style: mediumTextStyle.copyWith(
                      color: whiteColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 22),
            Text(
              totalReport.toString(),
              style: boldTextStyle.copyWith(
                color: whiteColor,
                fontSize: 55,
              ),
            ),
            Text(
              'Laporan',
              style: regularTextStyle.copyWith(
                color: whiteColor,
                fontSize: 14,
                height: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
