import 'package:equatable/equatable.dart';

class Account extends Equatable {
  final String? id;
  final String name;
  final double initialBalance;
  final double currentBalance;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Account({
    this.id,
    required this.name,
    required this.initialBalance,
    required this.currentBalance,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  Account copyWith({
    String? id,
    String? name,
    double? initialBalance,
    double? currentBalance,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      initialBalance: initialBalance ?? this.initialBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        initialBalance,
        currentBalance,
        description,
        createdAt,
        updatedAt,
      ];
}
