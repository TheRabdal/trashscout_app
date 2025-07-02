import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:trash_scout/shared/theme/theme.dart';

class AdminDetailReport extends StatelessWidget {
  final String reportTitle;
  final String status;
  final String imageUrl;
  final String description;
  final String date;
  final List<String> categories;
  final String latitude;
  final String longitude;
  final String locationDetail;
  final String user;
  final int beratB3;
  final int beratAnorganik;
  final int beratOrganik;

  const AdminDetailReport({
    required this.reportTitle,
    required this.status,
    required this.imageUrl,
    required this.description,
    required this.date,
    required this.categories,
    required this.latitude,
    required this.longitude,
    required this.locationDetail,
    required this.user,
    required this.beratB3,
    required this.beratAnorganik,
    required this.beratOrganik,
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
                user: user,
                categories: categories,
                latitude: latitude,
                longitude: longitude,
                onLaunchMap: _launchMap,
                locationDetail: locationDetail,
                beratB3: beratB3,
                beratAnorganik: beratAnorganik,
                beratOrganik: beratOrganik,
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
  final String user;
  final List<String> categories;
  final String latitude;
  final String longitude;
  final VoidCallback onLaunchMap;
  final String locationDetail;
  final int beratB3;
  final int beratAnorganik;
  final int beratOrganik;

  const ReportDetailContent({
    super.key,
    required this.reportTitle,
    required this.status,
    required this.description,
    required this.date,
    required this.categories,
    required this.latitude,
    required this.user,
    required this.longitude,
    required this.onLaunchMap,
    required this.locationDetail,
    required this.beratB3,
    required this.beratAnorganik,
    required this.beratOrganik,
  });

  Widget _buildWeightRatingBadge(int rating) {
    String label;
    String desc;
    Color color;
    IconData icon;
    switch (rating) {
      case 4:
        label = '< 1 kg';
        desc = 'Baik';
        color = Colors.green;
        icon = Icons.sentiment_very_satisfied;
        break;
      case 3:
        label = '1 – 2 kg';
        desc = 'Cukup';
        color = Colors.lightGreen;
        icon = Icons.sentiment_satisfied;
        break;
      case 2:
        label = '3 – 4 kg';
        desc = 'Buruk';
        color = Colors.orange;
        icon = Icons.sentiment_dissatisfied;
        break;
      case 1:
      default:
        label = '> 4 kg';
        desc = 'Sangat Buruk';
        color = Colors.red;
        icon = Icons.sentiment_very_dissatisfied;
        break;
    }
    return Container(
      margin: EdgeInsets.only(bottom: 14),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                      semiBoldTextStyle.copyWith(color: color, fontSize: 18)),
              Text(desc,
                  style: regularTextStyle.copyWith(color: color, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

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
        SizedBox(height: 6),
        Row(
          children: [
            Icon(
              Icons.person,
              size: 20,
              color: darkGreyColor,
            ),
            SizedBox(width: 4),
            Text(
              'Dibuat oleh: $user',
              style: regularTextStyle.copyWith(
                color: darkGreyColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
        SizedBox(height: 6),
        Text(
          date,
          style: regularTextStyle.copyWith(
            fontSize: 16,
            color: darkGreyColor,
          ),
        ),
        SizedBox(height: 16),
        Text('Berat Sampah',
            style: semiBoldTextStyle.copyWith(color: blackColor, fontSize: 18)),
        SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) {
            List<Widget> weightWidgets = [];
            if (beratB3 != 0) {
              weightWidgets.add(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('B3', style: mediumTextStyle),
                  _buildWeightRatingBadge(beratB3),
                ],
              ));
            }
            if (beratAnorganik != 0) {
              weightWidgets.add(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Anorganik', style: mediumTextStyle),
                  _buildWeightRatingBadge(beratAnorganik),
                ],
              ));
            }
            if (beratOrganik != 0) {
              weightWidgets.add(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Organik', style: mediumTextStyle),
                  _buildWeightRatingBadge(beratOrganik),
                ],
              ));
            }
            if (weightWidgets.isEmpty) {
              return Text('Tidak ada data berat sampah',
                  style: regularTextStyle.copyWith(color: Colors.grey));
            }
            if (constraints.maxWidth > 420) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: weightWidgets.map((w) => Flexible(child: w)).toList(),
              );
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: weightWidgets
                    .expand((w) => [w, SizedBox(height: 8)])
                    .toList()
                  ..removeLast(),
              );
            }
          },
        ),
        SizedBox(height: 10),
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
          children: [
            if (categories.contains('B3') && beratB3 != 0)
              Container(
                constraints: BoxConstraints(maxWidth: 120),
                padding: EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'B3',
                    style: regularTextStyle.copyWith(
                        color: Colors.white, fontSize: 15),
                    softWrap: false,
                  ),
                ),
              ),
            if (categories.contains('Anorganik') && beratAnorganik != 0)
              Container(
                constraints: BoxConstraints(maxWidth: 120),
                padding: EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: darkGreenColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Anorganik',
                    style: regularTextStyle.copyWith(
                        color: Colors.white, fontSize: 15),
                    softWrap: false,
                  ),
                ),
              ),
            if (categories.contains('Organik') && beratOrganik != 0)
              Container(
                constraints: BoxConstraints(maxWidth: 120),
                padding: EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: darkGreenColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Organik',
                    style: regularTextStyle.copyWith(
                        color: Colors.white, fontSize: 15),
                    softWrap: false,
                  ),
                ),
              ),
          ],
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
