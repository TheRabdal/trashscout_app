import 'package:intl/intl.dart';

String getFormattedDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(Duration(days: 1));
  final dateToCheck = DateTime(date.year, date.month, date.day);

  if (dateToCheck == today) {
    return 'Hari ini';
  } else if (dateToCheck == yesterday) {
    return 'Kemarin';
  } else {
    return DateFormat('dd MMMM yyyy').format(date);
  }
}
