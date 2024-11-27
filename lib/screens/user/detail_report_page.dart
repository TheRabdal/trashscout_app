import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:trash_scout/shared/theme/theme.dart';

class DetailReportPage extends StatelessWidget {
  final String reportTitle;
  final String status;
  final String imageUrl;
  final String description;
  final String date;
  final List<String> categories;
  final String latitude;
  final String longitude;
  final String locationDetail;

  const DetailReportPage({
    required this.reportTitle,
    required this.status,
    required this.imageUrl,
    required this.description,
    required this.date,
    required this.categories,
    required this.latitude,
    required this.longitude,
    required this.locationDetail,
  });

  Future<void> _launchMap() async {
    try {
      print('Launching map...'); // Debug statement
      print('Latitude: $latitude, Longitude: $longitude');

      final availableMaps = await MapLauncher.installedMaps;
      print('Available maps: $availableMaps');

      if (availableMaps.isNotEmpty) {
        if (await MapLauncher.isMapAvailable(MapType.google) ?? false) {
          await MapLauncher.showMarker(
            title: reportTitle,
            mapType: MapType.google,
            coords: Coords(double.parse(latitude), double.parse(longitude)),
          );
        } else {
          print('Google Maps is not available');
        }
      } else {
        print('No map applications available');
      }
    } catch (e) {
      print('Error launching map: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 400,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                        imageUrl,
                      ),
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    left: 16,
                    top: 60,
                  ),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: whiteColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.arrow_back_ios,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(
                top: 10,
                left: 16,
                right: 16,
              ),
              child: ReportDetailContent(
                reportTitle: reportTitle,
                status: status,
                description: description,
                date: date,
                categories: categories,
                latitude: latitude,
                longitude: longitude,
                onLaunchMap: _launchMap,
                locationDetail: locationDetail,
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class ReportDetailContent extends StatelessWidget {
  final String reportTitle;
  final String status;
  final String description;
  final String date;
  final List<String> categories;
  final String latitude;
  final String longitude;
  final VoidCallback onLaunchMap;
  final String locationDetail;

  const ReportDetailContent({
    super.key,
    required this.reportTitle,
    required this.status,
    required this.description,
    required this.date,
    required this.categories,
    required this.latitude,
    required this.longitude,
    required this.onLaunchMap,
    required this.locationDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          reportTitle,
          style: semiBoldTextStyle.copyWith(
            color: blackColor,
            fontSize: 24,
          ),
        ),
        SizedBox(height: 10),
        Text(
          date,
          style: regularTextStyle.copyWith(
            fontSize: 16,
            color: darkGreyColor,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Kategori',
          style: semiBoldTextStyle.copyWith(
            color: blackColor,
            fontSize: 18,
          ),
        ),
        SizedBox(height: 9),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          alignment: WrapAlignment.start,
          children: categories.map((category) {
            return Container(
              constraints: BoxConstraints(
                maxWidth: 120,
              ),
              padding: EdgeInsets.symmetric(
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: darkGreenColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  category,
                  style: regularTextStyle.copyWith(
                    color: whiteColor,
                    fontSize: 15,
                  ),
                  softWrap: false,
                  // overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 10),
        Text(
          'Deskripsi',
          style: semiBoldTextStyle.copyWith(
            color: blackColor,
            fontSize: 18,
          ),
        ),
        SizedBox(height: 9),
        Text(
          description,
          style: regularTextStyle.copyWith(
            color: darkGreyColor,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Lihat Lokasi',
          style: semiBoldTextStyle.copyWith(
            color: blackColor,
            fontSize: 18,
          ),
        ),
        SizedBox(height: 9),
        Text(
          'Klik disini untuk melihat lokasi',
          style: regularTextStyle.copyWith(
            color: darkGreyColor,
          ),
        ),
        SizedBox(height: 9),
        ElevatedButton(
          onPressed: onLaunchMap,
          style: ElevatedButton.styleFrom(
            backgroundColor: darkGreenColor,
            minimumSize: Size(double.infinity, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: semiBoldTextStyle.copyWith(
              fontSize: 24,
            ),
          ),
          child: Text(
            'Lihat Lokasi',
            style: semiBoldTextStyle.copyWith(
              color: whiteColor,
            ),
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Patokan lokasi',
          style: mediumTextStyle.copyWith(
            color: darkGreyColor,
            fontSize: 16,
          ),
        ),
        Text(
          locationDetail,
          style: regularTextStyle.copyWith(
            color: darkGreyColor,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
