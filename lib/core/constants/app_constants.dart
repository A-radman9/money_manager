class AppConstants {
  // Database
  static const String databaseName = 'money_manager.db';
  static const int databaseVersion = 1;
  
  // Table names
  static const String transactionsTable = 'transactions';
  static const String categoriesTable = 'categories';
  static const String accountsTable = 'accounts';
  
  // Transaction types
  static const String incomeType = 'income';
  static const String expenseType = 'expense';
  
  // Default categories
  static const List<Map<String, dynamic>> defaultIncomeCategories = [
    {'name': 'Salary', 'icon': 'work', 'color': 0xFF4CAF50},
    {'name': 'Freelance', 'icon': 'computer', 'color': 0xFF2196F3},
    {'name': 'Investment', 'icon': 'trending_up', 'color': 0xFF9C27B0},
    {'name': 'Gift', 'icon': 'card_giftcard', 'color': 0xFFFF9800},
    {'name': 'Other Income', 'icon': 'attach_money', 'color': 0xFF607D8B},
  ];
  
  static const List<Map<String, dynamic>> defaultExpenseCategories = [
    {'name': 'Food & Dining', 'icon': 'restaurant', 'color': 0xFFF44336},
    {'name': 'Transportation', 'icon': 'directions_car', 'color': 0xFF3F51B5},
    {'name': 'Shopping', 'icon': 'shopping_cart', 'color': 0xFFE91E63},
    {'name': 'Entertainment', 'icon': 'movie', 'color': 0xFF9C27B0},
    {'name': 'Bills & Utilities', 'icon': 'receipt', 'color': 0xFF795548},
    {'name': 'Healthcare', 'icon': 'local_hospital', 'color': 0xFF009688},
    {'name': 'Education', 'icon': 'school', 'color': 0xFF2196F3},
    {'name': 'Travel', 'icon': 'flight', 'color': 0xFF4CAF50},
    {'name': 'Other Expense', 'icon': 'more_horiz', 'color': 0xFF607D8B},
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
