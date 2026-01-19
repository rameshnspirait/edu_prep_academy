import 'package:intl/intl.dart';

class AppUtils {
  static String format(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
    // Example: 14 Jan 2026
  }
}
