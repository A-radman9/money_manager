import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class DateUtils {
  static String formatDate(DateTime date) {
    return DateFormat(AppConstants.dateFormat).format(date);
  }
  
  static String formatDisplayDate(DateTime date) {
    return DateFormat(AppConstants.displayDateFormat).format(date);
  }
  
  static String formatMonthYear(DateTime date) {
    return DateFormat(AppConstants.monthYearFormat).format(date);
  }
  
  static DateTime parseDate(String dateString) {
    return DateFormat(AppConstants.dateFormat).parse(dateString);
  }
  
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }
  
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }
  
  static DateTime startOfYear(DateTime date) {
    return DateTime(date.year, 1, 1);
  }
  
  static DateTime endOfYear(DateTime date) {
    return DateTime(date.year, 12, 31);
  }
  
  static bool isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }
  
  static bool isSameYear(DateTime date1, DateTime date2) {
    return date1.year == date2.year;
  }
  
  static List<DateTime> getMonthsInYear(int year) {
    return List.generate(12, (index) => DateTime(year, index + 1, 1));
  }
  
  static String getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);
    
    if (targetDate == today) {
      return 'Today';
    } else if (targetDate == yesterday) {
      return 'Yesterday';
    } else {
      return formatDisplayDate(date);
    }
  }
}
