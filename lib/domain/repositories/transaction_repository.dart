import 'package:dartz/dartz.dart';
import '../entities/transaction.dart';
import '../../core/errors/failures.dart';

abstract class TransactionRepository {
  Future<Either<Failure, String>> addTransaction(Transaction transaction);
  Future<Either<Failure, Transaction?>> getTransactionById(String id);
  Future<Either<Failure, List<Transaction>>> getAllTransactions();
  Future<Either<Failure, List<Transaction>>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  Future<Either<Failure, List<Transaction>>> getTransactionsByType(String type);
  Future<Either<Failure, List<Transaction>>> getTransactionsByCategory(String categoryId);
  Future<Either<Failure, void>> updateTransaction(Transaction transaction);
  Future<Either<Failure, void>> deleteTransaction(String id);
  Future<Either<Failure, double>> getTotalByType(String type);
  Future<Either<Failure, double>> getTotalByTypeAndDateRange(
    String type,
    DateTime startDate,
    DateTime endDate,
  );
}
