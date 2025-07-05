import 'package:equatable/equatable.dart';
import '../../../domain/entities/account.dart';

abstract class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object?> get props => [];
}

class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

class AccountLoaded extends AccountState {
  final List<Account> accounts;

  const AccountLoaded(this.accounts);

  @override
  List<Object?> get props => [accounts];
}

class AccountError extends AccountState {
  final String message;

  const AccountError(this.message);

  @override
  List<Object?> get props => [message];
}

class AccountAdded extends AccountState {
  final String accountId;

  const AccountAdded(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class AccountUpdated extends AccountState {}

class AccountDeleted extends AccountState {}

class AccountOperationLoading extends AccountState {}

class AccountOperationSuccess extends AccountState {
  final String message;

  const AccountOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AccountValidationError extends AccountState {
  final String message;

  const AccountValidationError(this.message);

  @override
  List<Object?> get props => [message];
}

class TotalBalanceLoaded extends AccountState {
  final double totalBalance;

  const TotalBalanceLoaded(this.totalBalance);

  @override
  List<Object?> get props => [totalBalance];
}
