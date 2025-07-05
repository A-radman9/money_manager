import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
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
    // For now, we'll just recreate the database
    if (oldVersion < newVersion) {
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
        'icon': category['icon'],
        'color': category['color'],
        'type': AppConstants.expenseType,
        'is_default': 1,
        'created_at': now,
        'updated_at': now,
      });
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
