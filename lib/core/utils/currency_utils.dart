import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class CurrencyUtils {
  static String formatAmount(double amount) {
    final formatter = NumberFormat.currency(
      symbol: AppConstants.currencySymbol,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }
  
  static String formatAmountWithoutSymbol(double amount) {
    final formatter = NumberFormat('#,##0.00');
    return formatter.format(amount);
  }
  
  static double parseAmount(String amountString) {
    // Remove currency symbol and commas
    String cleanString = amountString
        .replaceAll(AppConstants.currencySymbol, '')
        .replaceAll(',', '')
        .trim();
    
    try {
      return double.parse(cleanString);
    } catch (e) {
      return 0.0;
    }
  }
  
  static String formatAmountWithSign(double amount, String type) {
    final formattedAmount = formatAmount(amount.abs());
    if (type == 'income') {
      return '+$formattedAmount';
    } else {
      return '-$formattedAmount';
    }
  }
  
  static bool isValidAmount(String amountString) {
    if (amountString.isEmpty) return false;
    
    try {
      final amount = parseAmount(amountString);
      return amount > 0;
    } catch (e) {
      return false;
    }
  }
}
