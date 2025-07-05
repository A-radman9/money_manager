import 'package:sqflite/sqflite.dart';
import '../models/account_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/exceptions.dart';
import 'database_helper.dart';

class AccountDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<String> insertAccount(AccountModel account) async {
    try {
      final db = await _databaseHelper.database;
      final id = await db.insert(
        AppConstants.accountsTable,
        account.toDatabase(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return id.toString();
    } catch (e) {
      throw DatabaseException('Failed to insert account: $e');
    }
  }

  Future<AccountModel?> getAccountById(String id) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.accountsTable,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return AccountModel.fromJson(maps.first);
      }
      return null;
    } catch (e) {
      throw DatabaseException('Failed to get account: $e');
    }
  }

  Future<List<AccountModel>> getAllAccounts() async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.accountsTable,
        orderBy: 'name ASC',
      );

      return List.generate(maps.length, (i) {
        return AccountModel.fromJson(maps[i]);
      });
    } catch (e) {
      throw DatabaseException('Failed to get accounts: $e');
    }
  }

  Future<void> updateAccount(AccountModel account) async {
    try {
      final db = await _databaseHelper.database;
      final count = await db.update(
        AppConstants.accountsTable,
        account.toDatabase(),
        where: 'id = ?',
        whereArgs: [account.id],
      );

      if (count == 0) {
        throw NotFoundException('Account not found');
      }
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw DatabaseException('Failed to update account: $e');
    }
  }

  Future<void> deleteAccount(String id) async {
    try {
      final db = await _databaseHelper.database;
      final count = await db.delete(
        AppConstants.accountsTable,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (count == 0) {
        throw NotFoundException('Account not found');
      }
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw DatabaseException('Failed to delete account: $e');
    }
  }

  Future<bool> accountExists(String name) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.accountsTable,
        where: 'LOWER(name) = ?',
        whereArgs: [name.toLowerCase()],
        limit: 1,
      );

      return maps.isNotEmpty;
    } catch (e) {
      throw DatabaseException('Failed to check if account exists: $e');
    }
  }

  Future<double> getTotalBalance() async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT SUM(current_balance) as total FROM ${AppConstants.accountsTable}',
      );

      return (result.first['total'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      throw DatabaseException('Failed to get total balance: $e');
    }
  }

  Future<void> updateAccountBalance(String accountId, double newBalance) async {
    try {
      final db = await _databaseHelper.database;
      final count = await db.update(
        AppConstants.accountsTable,
        {
          'current_balance': newBalance,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [accountId],
      );

      if (count == 0) {
        throw NotFoundException('Account not found');
      }
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw DatabaseException('Failed to update account balance: $e');
    }
  }
}
