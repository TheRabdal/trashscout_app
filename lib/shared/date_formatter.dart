import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime date) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = DateTime(now.year, now.month, now.day - 1);
    DateTime dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Hari ini';
    } else if (dateToCheck == yesterday) {
      return 'Kemarin';
    } else {
      return DateFormat('dd MMMM yyyy').format(date);
    }
  }
}
