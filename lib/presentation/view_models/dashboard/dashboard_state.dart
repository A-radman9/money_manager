import 'package:equatable/equatable.dart';
import '../../../domain/entities/transaction.dart';

class DashboardData extends Equatable {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final List<Transaction> recentTransactions;
  final double monthlyIncome;
  final double monthlyExpense;
  final double monthlyBalance;

  const DashboardData({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.recentTransactions,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.monthlyBalance,
  });

  @override
  List<Object?> get props => [
        totalIncome,
        totalExpense,
        balance,
        recentTransactions,
        monthlyIncome,
        monthlyExpense,
        monthlyBalance,
      ];
}

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardData data;

  const DashboardLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

class DashboardRefreshing extends DashboardState {
  final DashboardData? previousData;

  const DashboardRefreshing(this.previousData);

  @override
  List<Object?> get props => [previousData];
}
