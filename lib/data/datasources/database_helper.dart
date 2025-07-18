import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create categories table
    await db.execute('''
      CREATE TABLE ${AppConstants.categoriesTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        name_ar TEXT,
        icon TEXT NOT NULL,
        color INTEGER NOT NULL,
        type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
        is_default INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create accounts table
    await db.execute('''
      CREATE TABLE ${AppConstants.accountsTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        initial_balance REAL NOT NULL DEFAULT 0.0,
        current_balance REAL NOT NULL DEFAULT 0.0,
        description TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create transactions table
    await db.execute('''
      CREATE TABLE ${AppConstants.transactionsTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
        date TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES ${AppConstants.categoriesTable} (id)
      )
    ''');

    // Create indexes for better performance
    await db.execute('''
      CREATE INDEX idx_transactions_date ON ${AppConstants.transactionsTable} (date)
    ''');

    await db.execute('''
      CREATE INDEX idx_transactions_category ON ${AppConstants.transactionsTable} (category_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_transactions_type ON ${AppConstants.transactionsTable} (type)
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < 2 && newVersion >= 2) {
      // Add name_ar column to categories table
      await db.execute('ALTER TABLE ${AppConstants.categoriesTable} ADD COLUMN name_ar TEXT');

      // Update existing default categories with Arabic names
      await updateDefaultCategoriesWithArabicNames(db);
    }

    // For any other major changes, recreate the database
    if (oldVersion < newVersion && newVersion > 2) {
      await db.execute('DROP TABLE IF EXISTS ${AppConstants.transactionsTable}');
      await db.execute('DROP TABLE IF EXISTS ${AppConstants.categoriesTable}');
      await db.execute('DROP TABLE IF EXISTS ${AppConstants.accountsTable}');
      await _onCreate(db, newVersion);
    }
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final now = DateTime.now().toIso8601String();

    // Insert default income categories
    for (final category in AppConstants.defaultIncomeCategories) {
      await db.insert(AppConstants.categoriesTable, {
        'name': category['name'],
        'name_ar': category['nameAr'],
        'icon': category['icon'],
        'color': category['color'],
        'type': AppConstants.incomeType,
        'is_default': 1,
        'created_at': now,
        'updated_at': now,
      });
    }

    // Insert default expense categories
    for (final category in AppConstants.defaultExpenseCategories) {
      await db.insert(AppConstants.categoriesTable, {
        'name': category['name'],
        'name_ar': category['nameAr'],
        'icon': category['icon'],
        'color': category['color'],
        'type': AppConstants.expenseType,
        'is_default': 1,
        'created_at': now,
        'updated_at': now,
      });
    }
  }

  @visibleForTesting
  Future<void> updateDefaultCategoriesWithArabicNames(Database db) async {
    // Update existing default income categories with Arabic names
    for (final category in AppConstants.defaultIncomeCategories) {
      await db.execute('''
        UPDATE ${AppConstants.categoriesTable}
        SET name_ar = ?
        WHERE name = ? AND type = ? AND is_default = 1
      ''', [category['nameAr'], category['name'], AppConstants.incomeType]);
    }

    // Update existing default expense categories with Arabic names
    for (final category in AppConstants.defaultExpenseCategories) {
      await db.execute('''
        UPDATE ${AppConstants.categoriesTable}
        SET name_ar = ?
        WHERE name = ? AND type = ? AND is_default = 1
      ''', [category['nameAr'], category['name'], AppConstants.expenseType]);
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  Future<void> deleteDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConstants.databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
