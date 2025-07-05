import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/transaction_repository.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart' as date_utils;
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final TransactionRepository transactionRepository;

  DashboardCubit({required this.transactionRepository}) : super(DashboardInitial());

  Future<void> loadDashboardData() async {
    emit(DashboardLoading());
    await _fetchDashboardData();
  }

  Future<void> refreshDashboardData() async {
    final currentState = state;
    if (currentState is DashboardLoaded) {
      emit(DashboardRefreshing(currentState.data));
    } else {
      emit(DashboardLoading());
    }
    await _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      // Get current month date range
      final now = DateTime.now();
      final startOfMonth = date_utils.DateUtils.startOfMonth(now);
      final endOfMonth = date_utils.DateUtils.endOfMonth(now);

      // Fetch all data concurrently
      final results = await Future.wait([
        transactionRepository.getTotalByType(AppConstants.incomeType),
        transactionRepository.getTotalByType(AppConstants.expenseType),
        transactionRepository.getAllTransactions(),
        transactionRepository.getTotalByTypeAndDateRange(
          AppConstants.incomeType,
          startOfMonth,
          endOfMonth,
        ),
        transactionRepository.getTotalByTypeAndDateRange(
          AppConstants.expenseType,
          startOfMonth,
          endOfMonth,
        ),
      ]);

      // Check for any failures
      for (final result in results) {
        result.fold(
          (failure) {
            emit(DashboardError(failure.message));
            return;
          },
          (_) {},
        );
      }

      // Extract successful results
      final totalIncome = results[0].fold((l) => 0.0, (r) => r as double);
      final totalExpense = results[1].fold((l) => 0.0, (r) => r as double);
      final allTransactions = results[2].fold((l) => [], (r) => r as List);
      final monthlyIncome = results[3].fold((l) => 0.0, (r) => r as double);
      final monthlyExpense = results[4].fold((l) => 0.0, (r) => r as double);

      // Calculate balances
      final balance = totalIncome - totalExpense;
      final monthlyBalance = monthlyIncome - monthlyExpense;

      // Get recent transactions (last 10)
      final recentTransactions = allTransactions.take(10).toList();

      final dashboardData = DashboardData(
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        balance: balance,
        recentTransactions: recentTransactions,
        monthlyIncome: monthlyIncome,
        monthlyExpense: monthlyExpense,
        monthlyBalance: monthlyBalance,
      );

      emit(DashboardLoaded(dashboardData));
    } catch (e) {
      emit(DashboardError('Failed to load dashboard data: $e'));
    }
  }

  Future<void> loadDashboardDataForMonth(DateTime month) async {
    emit(DashboardLoading());

    try {
      final startOfMonth = date_utils.DateUtils.startOfMonth(month);
      final endOfMonth = date_utils.DateUtils.endOfMonth(month);

      // Fetch data for the specific month
      final results = await Future.wait([
        transactionRepository.getTotalByTypeAndDateRange(
          AppConstants.incomeType,
          startOfMonth,
          endOfMonth,
        ),
        transactionRepository.getTotalByTypeAndDateRange(
          AppConstants.expenseType,
          startOfMonth,
          endOfMonth,
        ),
        transactionRepository.getTransactionsByDateRange(startOfMonth, endOfMonth),
        // Also get overall totals
        transactionRepository.getTotalByType(AppConstants.incomeType),
        transactionRepository.getTotalByType(AppConstants.expenseType),
      ]);

      // Check for any failures
      for (final result in results) {
        result.fold(
          (failure) {
            emit(DashboardError(failure.message));
            return;
          },
          (_) {},
        );
      }

      // Extract successful results
      final monthlyIncome = results[0].fold((l) => 0.0, (r) => r as double);
      final monthlyExpense = results[1].fold((l) => 0.0, (r) => r as double);
      final monthTransactions = results[2].fold((l) => [], (r) => r as List);
      final totalIncome = results[3].fold((l) => 0.0, (r) => r as double);
      final totalExpense = results[4].fold((l) => 0.0, (r) => r as double);

      // Calculate balances
      final balance = totalIncome - totalExpense;
      final monthlyBalance = monthlyIncome - monthlyExpense;

      final dashboardData = DashboardData(
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        balance: balance,
        recentTransactions: monthTransactions,
        monthlyIncome: monthlyIncome,
        monthlyExpense: monthlyExpense,
        monthlyBalance: monthlyBalance,
      );

      emit(DashboardLoaded(dashboardData));
    } catch (e) {
      emit(DashboardError('Failed to load dashboard data for month: $e'));
    }
  }

  void clearState() {
    emit(DashboardInitial());
  }
}
