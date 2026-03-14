import 'package:intl/intl.dart';

class AppDateFormatter {
  static String dateTime(DateTime date) {
    return DateFormat('dd MMM • hh:mm a').format(date);
  }

  static String dateOnly(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String timeOnly(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  static String weekday(DateTime date) {
    return DateFormat.E().format(date); // Mon, Tue
  }
}
