import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final String? id;
  final double amount;
  final String description;
  final String categoryId;
  final String type; // 'income' or 'expense'
  final DateTime date;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Transaction({
    this.id,
    required this.amount,
    required this.description,
    required this.categoryId,
    required this.type,
    required this.date,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Transaction copyWith({
    String? id,
    double? amount,
    String? description,
    String? categoryId,
    String? type,
    DateTime? date,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        amount,
        description,
        categoryId,
        type,
        date,
        notes,
        createdAt,
        updatedAt,
      ];
}
