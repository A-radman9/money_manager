import 'package:sqflite/sqflite.dart';
import '../models/category_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import 'database_helper.dart';

class CategoryDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<String> insertCategory(CategoryModel category) async {
    try {
      final db = await _databaseHelper.database;
      final id = await db.insert(
        AppConstants.categoriesTable,
        category.toDatabase(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return id.toString();
    } catch (e) {
      throw DatabaseException('Failed to insert category: $e');
    }
  }

  Future<CategoryModel?> getCategoryById(String id) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.categoriesTable,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return CategoryModel.fromJson(maps.first);
      }
      return null;
    } catch (e) {
      throw DatabaseException('Failed to get category: $e');
    }
  }

  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.categoriesTable,
        orderBy: 'is_default DESC, name ASC',
      );

      return List.generate(maps.length, (i) {
        return CategoryModel.fromJson(maps[i]);
      });
    } catch (e) {
      throw DatabaseException('Failed to get categories: $e');
    }
  }

  Future<List<CategoryModel>> getCategoriesByType(String type) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.categoriesTable,
        where: 'type = ?',
        whereArgs: [type],
        orderBy: 'is_default DESC, name ASC',
      );

      return List.generate(maps.length, (i) {
        return CategoryModel.fromJson(maps[i]);
      });
    } catch (e) {
      throw DatabaseException('Failed to get categories by type: $e');
    }
  }

  Future<List<CategoryModel>> getDefaultCategories() async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.categoriesTable,
        where: 'is_default = ?',
        whereArgs: [1],
        orderBy: 'type ASC, name ASC',
      );

      return List.generate(maps.length, (i) {
        return CategoryModel.fromJson(maps[i]);
      });
    } catch (e) {
      throw DatabaseException('Failed to get default categories: $e');
    }
  }

  Future<List<CategoryModel>> getCustomCategories() async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.categoriesTable,
        where: 'is_default = ?',
        whereArgs: [0],
        orderBy: 'type ASC, name ASC',
      );

      return List.generate(maps.length, (i) {
        return CategoryModel.fromJson(maps[i]);
      });
    } catch (e) {
      throw DatabaseException('Failed to get custom categories: $e');
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    try {
      final db = await _databaseHelper.database;
      final count = await db.update(
        AppConstants.categoriesTable,
        category.toDatabase(),
        where: 'id = ?',
        whereArgs: [category.id],
      );

      if (count == 0) {
        throw NotFoundException('Category not found');
      }
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw DatabaseException('Failed to update category: $e');
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      final db = await _databaseHelper.database;
      
      // Check if category is being used by any transactions
      final List<Map<String, dynamic>> transactions = await db.query(
        AppConstants.transactionsTable,
        where: 'category_id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (transactions.isNotEmpty) {
        throw ValidationException('Cannot delete category that is being used by transactions');
      }

      // Check if it's a default category
      final List<Map<String, dynamic>> category = await db.query(
        AppConstants.categoriesTable,
        where: 'id = ? AND is_default = ?',
        whereArgs: [id, 1],
        limit: 1,
      );

      if (category.isNotEmpty) {
        throw ValidationException('Cannot delete default category');
      }

      final count = await db.delete(
        AppConstants.categoriesTable,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (count == 0) {
        throw NotFoundException('Category not found');
      }
    } catch (e) {
      if (e is NotFoundException || e is ValidationException) rethrow;
      throw DatabaseException('Failed to delete category: $e');
    }
  }

  Future<bool> categoryExists(String name, String type) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.categoriesTable,
        where: 'LOWER(name) = ? AND type = ?',
        whereArgs: [name.toLowerCase(), type],
        limit: 1,
      );

      return maps.isNotEmpty;
    } catch (e) {
      throw DatabaseException('Failed to check if category exists: $e');
    }
  }
}
