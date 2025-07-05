class AppConstants {
  // Database
  static const String databaseName = 'money_manager.db';
  static const int databaseVersion = 2;
  
  // Table names
  static const String transactionsTable = 'transactions';
  static const String categoriesTable = 'categories';
  static const String accountsTable = 'accounts';
  
  // Transaction types
  static const String incomeType = 'income';
  static const String expenseType = 'expense';
  
  // Default categories
  static const List<Map<String, dynamic>> defaultIncomeCategories = [
    {'name': 'Salary', 'nameAr': 'راتب', 'icon': 'work', 'color': 0xFF4CAF50},
    {'name': 'Freelance', 'nameAr': 'عمل حر', 'icon': 'computer', 'color': 0xFF2196F3},
    {'name': 'Investment', 'nameAr': 'استثمار', 'icon': 'trending_up', 'color': 0xFF9C27B0},
    {'name': 'Gift', 'nameAr': 'هدية', 'icon': 'card_giftcard', 'color': 0xFFFF9800},
    {'name': 'Other Income', 'nameAr': 'دخل آخر', 'icon': 'attach_money', 'color': 0xFF607D8B},
  ];
  
  static const List<Map<String, dynamic>> defaultExpenseCategories = [
    {'name': 'Food & Dining', 'nameAr': 'طعام ومطاعم', 'icon': 'restaurant', 'color': 0xFFF44336},
    {'name': 'Transportation', 'nameAr': 'مواصلات', 'icon': 'directions_car', 'color': 0xFF3F51B5},
    {'name': 'Shopping', 'nameAr': 'تسوق', 'icon': 'shopping_cart', 'color': 0xFFE91E63},
    {'name': 'Entertainment', 'nameAr': 'ترفيه', 'icon': 'movie', 'color': 0xFF9C27B0},
    {'name': 'Bills & Utilities', 'nameAr': 'فواتير ومرافق', 'icon': 'receipt', 'color': 0xFF795548},
    {'name': 'Healthcare', 'nameAr': 'رعاية صحية', 'icon': 'local_hospital', 'color': 0xFF009688},
    {'name': 'Education', 'nameAr': 'تعليم', 'icon': 'school', 'color': 0xFF2196F3},
    {'name': 'Travel', 'nameAr': 'سفر', 'icon': 'flight', 'color': 0xFF4CAF50},
    {'name': 'Other Expense', 'nameAr': 'مصروف آخر', 'icon': 'more_horiz', 'color': 0xFF607D8B},
  ];
  
  // Date formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String monthYearFormat = 'MMM yyyy';
  
  // Currency
  static const String currencySymbol = '\$';
  
  // App info
  static const String appName = 'Money Manager';
  static const String appVersion = '1.0.0';
}
