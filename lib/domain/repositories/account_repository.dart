import 'package:dartz/dartz.dart';
import '../entities/account.dart';
import '../../core/errors/failures.dart';

abstract class AccountRepository {
  Future<Either<Failure, String>> addAccount(Account account);
  Future<Either<Failure, Account?>> getAccountById(String id);
  Future<Either<Failure, List<Account>>> getAllAccounts();
  Future<Either<Failure, void>> updateAccount(Account account);
  Future<Either<Failure, void>> deleteAccount(String id);
  Future<Either<Failure, bool>> accountExists(String name);
  Future<Either<Failure, double>> getTotalBalance();
  Future<Either<Failure, void>> updateAccountBalance(String accountId, double newBalance);
}
