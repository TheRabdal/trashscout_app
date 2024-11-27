import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trash_scout/shared/theme/theme.dart';
import 'package:trash_scout/shared/utils/get_formatted_date.dart';

class MailBoxScreen extends StatelessWidget {
  const MailBoxScreen({super.key});

  // Perulangan Untuk Mapping Pesan ke dalam Group
  Map<String, List<Map<String, dynamic>>> groupNotificationsByDate(
      List<Map<String, dynamic>> notifications) {
    Map<String, List<Map<String, dynamic>>> groupedNotifications = {};

    for (var notification in notifications) {
      DateTime dateTime = (notification['dateTime'] as Timestamp).toDate();
      String dateKey = getFormattedDate(dateTime);

      if (!groupedNotifications.containsKey(dateKey)) {
        groupedNotifications[dateKey] = [];
      }

      groupedNotifications[dateKey]!.add(notification);
    }

    return groupedNotifications;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final notificationStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .orderBy('dateTime', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: backgroundColor,
        title: Text(
          'Kotak Masuk',
          style: semiBoldTextStyle.copyWith(
            color: blackColor,
            fontSize: 26,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream: notificationStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              List<Map<String, dynamic>> notifications = snapshot.data!.docs
                  .map((doc) => {
                        'reportTitle': doc['reportTitle'],
                        'dateTime': doc['dateTime'],
                        'isDone': doc['isDone'],
                      })
                  .toList();
              Map<String, List<Map<String, dynamic>>> groupedNotifications =
                  groupNotificationsByDate(notifications);

              return ListView.builder(
                itemCount: groupedNotifications.keys.length,
                itemBuilder: (context, index) {
                  String dateKey = groupedNotifications.keys.elementAt(index);

                  List<Map<String, dynamic>> dateNotifications =
                      groupedNotifications[dateKey]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      MailHistoryDate(dateTime: dateKey),
                      ...dateNotifications.map((notification) {
                        return Column(
                          children: [
                            MailBoxItem(
                              reportTitle: notification['reportTitle'],
                              dateTime: DateFormat('HH:mm').format(
                                (notification['dateTime'] as Timestamp)
                                    .toDate(),
                              ),
                              isDone: notification['isDone'],
                            ),
                          ],
                        );
                      }).toList()
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class MailBoxItem extends StatelessWidget {
  final bool isDone;
  final String reportTitle;
  final String dateTime;

  const MailBoxItem({
    this.isDone = false,
    required this.reportTitle,
    required this.dateTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone ? Color(0xff6BC2A2) : darkGreenColor,
            ),
            child: Center(
              child: Image.asset(
                'assets/message_icon.png',
                width: 20,
                height: 20,
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDone
                      ? 'Laporan anda sudah selesai!'
                      : 'Laporan anda sedang diproses!',
                  style: semiBoldTextStyle.copyWith(
                    color: blackColor,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 3),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: reportTitle,
                        style: semiBoldTextStyle.copyWith(
                          color: darkGreyColor,
                          fontSize: 13,
                        ),
                      ),
                      TextSpan(
                        text: isDone
                            ? ' telah berhasil ditangani!'
                            : ' sedang diproses oleh pihak berwajib',
                        style: regularTextStyle.copyWith(
                          color: darkGreyColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Text(
            dateTime,
            style: regularTextStyle.copyWith(
              color: darkGreyColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class MailHistoryDate extends StatelessWidget {
  final String dateTime;

  const MailHistoryDate({super.key, required this.dateTime});

  @override
  Widget build(BuildContext context) {
    return Text(
      dateTime,
      style: mediumTextStyle.copyWith(
        color: lightGreyColor,
        fontSize: 12,
      ),
    );
  }
}
