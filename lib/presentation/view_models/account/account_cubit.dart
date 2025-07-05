import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/repositories/account_repository.dart';
import 'account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  final AccountRepository accountRepository;

  AccountCubit({required this.accountRepository}) : super(AccountInitial());

  Future<void> loadAccounts() async {
    emit(AccountLoading());
    
    final result = await accountRepository.getAllAccounts();
    result.fold(
      (failure) => emit(AccountError(failure.message)),
      (accounts) => emit(AccountLoaded(accounts)),
    );
  }

  Future<void> addAccount({
    required String name,
    required double initialBalance,
    String? description,
  }) async {
    emit(AccountOperationLoading());

    // Check if account already exists
    final existsResult = await accountRepository.accountExists(name);
    final accountExists = existsResult.fold(
      (failure) => false,
      (exists) => exists,
    );

    if (accountExists) {
      emit(AccountValidationError('An account with this name already exists'));
      return;
    }

    final now = DateTime.now();
    final account = Account(
      name: name,
      initialBalance: initialBalance,
      currentBalance: initialBalance,
      description: description,
      createdAt: now,
      updatedAt: now,
    );

    final result = await accountRepository.addAccount(account);
    result.fold(
      (failure) => emit(AccountError(failure.message)),
      (accountId) {
        emit(AccountAdded(accountId));
        loadAccounts(); // Reload accounts after adding
      },
    );
  }

  Future<void> updateAccount({
    required String id,
    required String name,
    required double initialBalance,
    required double currentBalance,
    String? description,
    required DateTime createdAt,
  }) async {
    emit(AccountOperationLoading());

    final account = Account(
      id: id,
      name: name,
      initialBalance: initialBalance,
      currentBalance: currentBalance,
      description: description,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );

    final result = await accountRepository.updateAccount(account);
    result.fold(
      (failure) => emit(AccountError(failure.message)),
      (_) {
        emit(AccountUpdated());
        loadAccounts(); // Reload accounts after updating
      },
    );
  }

  Future<void> deleteAccount(String id) async {
    emit(AccountOperationLoading());

    final result = await accountRepository.deleteAccount(id);
    result.fold(
      (failure) => emit(AccountError(failure.message)),
      (_) {
        emit(AccountDeleted());
        loadAccounts(); // Reload accounts after deleting
      },
    );
  }

  Future<void> updateAccountBalance(String accountId, double newBalance) async {
    emit(AccountOperationLoading());

    final result = await accountRepository.updateAccountBalance(accountId, newBalance);
    result.fold(
      (failure) => emit(AccountError(failure.message)),
      (_) {
        emit(const AccountOperationSuccess('Account balance updated successfully'));
        loadAccounts(); // Reload accounts after updating balance
      },
    );
  }

  Future<void> getTotalBalance() async {
    emit(AccountLoading());

    final result = await accountRepository.getTotalBalance();
    result.fold(
      (failure) => emit(AccountError(failure.message)),
      (totalBalance) => emit(TotalBalanceLoaded(totalBalance)),
    );
  }

  Future<void> getAccountById(String id) async {
    emit(AccountLoading());

    final result = await accountRepository.getAccountById(id);
    result.fold(
      (failure) => emit(AccountError(failure.message)),
      (account) {
        if (account != null) {
          emit(AccountLoaded([account]));
        } else {
          emit(const AccountError('Account not found'));
        }
      },
    );
  }

  void clearState() {
    emit(AccountInitial());
  }
}
