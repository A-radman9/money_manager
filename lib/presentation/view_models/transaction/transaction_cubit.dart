import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/repositories/transaction_repository.dart';
import '../../../core/constants/app_constants.dart';
import 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  final TransactionRepository transactionRepository;

  TransactionCubit({required this.transactionRepository}) : super(TransactionInitial());

  Future<void> loadTransactions() async {
    emit(TransactionLoading());
    
    final result = await transactionRepository.getAllTransactions();
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (transactions) => emit(TransactionLoaded(transactions)),
    );
  }

  Future<void> loadTransactionsByDateRange(DateTime startDate, DateTime endDate) async {
    emit(TransactionLoading());
    
    final result = await transactionRepository.getTransactionsByDateRange(startDate, endDate);
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (transactions) => emit(TransactionLoaded(transactions)),
    );
  }

  Future<void> loadTransactionsByType(String type) async {
    emit(TransactionLoading());
    
    final result = await transactionRepository.getTransactionsByType(type);
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (transactions) => emit(TransactionLoaded(transactions)),
    );
  }

  Future<void> loadTransactionsByCategory(String categoryId) async {
    emit(TransactionLoading());
    
    final result = await transactionRepository.getTransactionsByCategory(categoryId);
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (transactions) => emit(TransactionLoaded(transactions)),
    );
  }

  Future<void> addTransaction({
    required double amount,
    required String description,
    required String categoryId,
    required String type,
    required DateTime date,
    String? notes,
  }) async {
    emit(TransactionOperationLoading());

    final now = DateTime.now();
    final transaction = Transaction(
      amount: amount,
      description: description,
      categoryId: categoryId,
      type: type,
      date: date,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );

    final result = await transactionRepository.addTransaction(transaction);
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (transactionId) {
        emit(TransactionAdded(transactionId));
        loadTransactions(); // Reload transactions after adding
      },
    );
  }

  Future<void> updateTransaction({
    required String id,
    required double amount,
    required String description,
    required String categoryId,
    required String type,
    required DateTime date,
    String? notes,
    required DateTime createdAt,
  }) async {
    emit(TransactionOperationLoading());

    final transaction = Transaction(
      id: id,
      amount: amount,
      description: description,
      categoryId: categoryId,
      type: type,
      date: date,
      notes: notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );

    final result = await transactionRepository.updateTransaction(transaction);
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (_) {
        emit(TransactionUpdated());
        loadTransactions(); // Reload transactions after updating
      },
    );
  }

  Future<void> deleteTransaction(String id) async {
    emit(TransactionOperationLoading());

    final result = await transactionRepository.deleteTransaction(id);
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (_) {
        emit(TransactionDeleted());
        loadTransactions(); // Reload transactions after deleting
      },
    );
  }

  Future<void> getTransactionById(String id) async {
    emit(TransactionLoading());

    final result = await transactionRepository.getTransactionById(id);
    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (transaction) {
        if (transaction != null) {
          emit(TransactionLoaded([transaction]));
        } else {
          emit(const TransactionError('Transaction not found'));
        }
      },
    );
  }

  void clearState() {
    emit(TransactionInitial());
  }
}
