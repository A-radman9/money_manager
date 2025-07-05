import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:money_manager/data/datasources/database_helper.dart';
import 'package:money_manager/core/constants/app_constants.dart';

void main() {
  group('Database Migration Tests', () {
    late DatabaseHelper databaseHelper;

    setUpAll(() {
      // Initialize FFI for testing
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() {
      databaseHelper = DatabaseHelper();
    });

    tearDown(() async {
      await databaseHelper.deleteDatabase();
    });

    test('Fresh install should create default categories with Arabic names', () async {
      // Get the database (this will create it fresh)
      final db = await databaseHelper.database;

      // Query all default categories
      final categories = await db.query(
        AppConstants.categoriesTable,
        where: 'is_default = ?',
        whereArgs: [1],
      );

      // Verify we have the expected number of default categories
      final expectedCount = AppConstants.defaultIncomeCategories.length + 
                           AppConstants.defaultExpenseCategories.length;
      expect(categories.length, expectedCount);

      // Verify that all default categories have Arabic names
      for (final category in categories) {
        expect(category['name'], isNotNull);
        expect(category['name_ar'], isNotNull);
        expect(category['name_ar'], isNotEmpty);
        
        print('Category: ${category['name']} → ${category['name_ar']}');
      }

      // Verify specific categories exist with correct Arabic names
      final salaryCategory = categories.firstWhere(
        (cat) => cat['name'] == 'Salary',
      );
      expect(salaryCategory['name_ar'], 'راتب');

      final foodCategory = categories.firstWhere(
        (cat) => cat['name'] == 'Food & Dining',
      );
      expect(foodCategory['name_ar'], 'طعام ومطاعم');
    });

    test('Database migration from v1 to v2 should add Arabic names to existing categories', () async {
      // First, create a v1 database by manually creating the old schema
      final db = await databaseHelper.database;
      
      // Drop the current table and recreate with v1 schema (without name_ar)
      await db.execute('DROP TABLE IF EXISTS ${AppConstants.categoriesTable}');
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

      // Insert some default categories without Arabic names (simulating v1)
      final now = DateTime.now().toIso8601String();
      await db.insert(AppConstants.categoriesTable, {
        'name': 'Salary',
        'icon': 'work',
        'color': 0xFF4CAF50,
        'type': AppConstants.incomeType,
        'is_default': 1,
        'created_at': now,
        'updated_at': now,
      });

      await db.insert(AppConstants.categoriesTable, {
        'name': 'Food & Dining',
        'icon': 'restaurant',
        'color': 0xFFF44336,
        'type': AppConstants.expenseType,
        'is_default': 1,
        'created_at': now,
        'updated_at': now,
      });

      // Verify categories exist without Arabic names
      var categories = await db.query(AppConstants.categoriesTable);
      expect(categories.length, 2);
      
      // Check that name_ar column doesn't exist yet
      final tableInfo = await db.rawQuery('PRAGMA table_info(${AppConstants.categoriesTable})');
      final hasNameArColumn = tableInfo.any((column) => column['name'] == 'name_ar');
      expect(hasNameArColumn, false);

      // Now simulate the migration by adding the column and updating categories
      await db.execute('ALTER TABLE ${AppConstants.categoriesTable} ADD COLUMN name_ar TEXT');
      await databaseHelper.updateDefaultCategoriesWithArabicNames(db);

      // Verify the migration worked
      categories = await db.query(AppConstants.categoriesTable);
      expect(categories.length, 2);

      final salaryCategory = categories.firstWhere((cat) => cat['name'] == 'Salary');
      expect(salaryCategory['name_ar'], 'راتب');

      final foodCategory = categories.firstWhere((cat) => cat['name'] == 'Food & Dining');
      expect(foodCategory['name_ar'], 'طعام ومطاعم');

      print('Migration test passed: Categories now have Arabic names');
    });
  });
}
