import 'package:sqflite/sqflite.dart';
import '../models/transaction_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import 'database_helper.dart';

class TransactionDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<String> insertTransaction(TransactionModel transaction) async {
    try {
      final db = await _databaseHelper.database;
      final id = await db.insert(
        AppConstants.transactionsTable,
        transaction.toDatabase(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return id.toString();
    } catch (e) {
      throw DatabaseException('Failed to insert transaction: $e');
    }
  }

  Future<TransactionModel?> getTransactionById(String id) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.transactionsTable,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return TransactionModel.fromJson(maps.first);
      }
      return null;
    } catch (e) {
      throw DatabaseException('Failed to get transaction: $e');
    }
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.transactionsTable,
        orderBy: 'date DESC, created_at DESC',
      );

      return List.generate(maps.length, (i) {
        return TransactionModel.fromJson(maps[i]);
      });
    } catch (e) {
      throw DatabaseException('Failed to get transactions: $e');
    }
  }

  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.transactionsTable,
        where: 'date BETWEEN ? AND ?',
        whereArgs: [
          startDate.toIso8601String().split('T')[0],
          endDate.toIso8601String().split('T')[0],
        ],
        orderBy: 'date DESC, created_at DESC',
      );

      return List.generate(maps.length, (i) {
        return TransactionModel.fromJson(maps[i]);
      });
    } catch (e) {
      throw DatabaseException('Failed to get transactions by date range: $e');
    }
  }

  Future<List<TransactionModel>> getTransactionsByType(String type) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.transactionsTable,
        where: 'type = ?',
        whereArgs: [type],
        orderBy: 'date DESC, created_at DESC',
      );

      return List.generate(maps.length, (i) {
        return TransactionModel.fromJson(maps[i]);
      });
    } catch (e) {
      throw DatabaseException('Failed to get transactions by type: $e');
    }
  }

  Future<List<TransactionModel>> getTransactionsByCategory(String categoryId) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.transactionsTable,
        where: 'category_id = ?',
        whereArgs: [categoryId],
        orderBy: 'date DESC, created_at DESC',
      );

      return List.generate(maps.length, (i) {
        return TransactionModel.fromJson(maps[i]);
      });
    } catch (e) {
      throw DatabaseException('Failed to get transactions by category: $e');
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      final db = await _databaseHelper.database;
      final count = await db.update(
        AppConstants.transactionsTable,
        transaction.toDatabase(),
        where: 'id = ?',
        whereArgs: [transaction.id],
      );

      if (count == 0) {
        throw NotFoundException('Transaction not found');
      }
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw DatabaseException('Failed to update transaction: $e');
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      final db = await _databaseHelper.database;
      final count = await db.delete(
        AppConstants.transactionsTable,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (count == 0) {
        throw NotFoundException('Transaction not found');
      }
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw DatabaseException('Failed to delete transaction: $e');
    }
  }

  Future<double> getTotalByType(String type) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT SUM(amount) as total FROM ${AppConstants.transactionsTable} WHERE type = ?',
        [type],
      );

      return (result.first['total'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      throw DatabaseException('Failed to get total by type: $e');
    }
  }

  Future<double> getTotalByTypeAndDateRange(
    String type,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT SUM(amount) as total FROM ${AppConstants.transactionsTable} WHERE type = ? AND date BETWEEN ? AND ?',
        [
          type,
          startDate.toIso8601String().split('T')[0],
          endDate.toIso8601String().split('T')[0],
        ],
      );

      return (result.first['total'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      throw DatabaseException('Failed to get total by type and date range: $e');
    }
  }
}
