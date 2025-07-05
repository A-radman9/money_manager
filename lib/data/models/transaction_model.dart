import '../../domain/entities/transaction.dart';
import '../../core/utils/date_utils.dart' as date_utils;

class TransactionModel extends Transaction {
  const TransactionModel({
    super.id,
    required super.amount,
    required super.description,
    required super.categoryId,
    required super.type,
    required super.date,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id']?.toString(),
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      categoryId: json['category_id'] as String,
      type: json['type'] as String,
      date: date_utils.DateUtils.parseDate(json['date'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'category_id': categoryId,
      'type': type,
      'date': date_utils.DateUtils.formatDate(date),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toDatabase() {
    final json = toJson();
    if (id == null) {
      json.remove('id');
    }
    return json;
  }

  factory TransactionModel.fromEntity(Transaction transaction) {
    return TransactionModel(
      id: transaction.id,
      amount: transaction.amount,
      description: transaction.description,
      categoryId: transaction.categoryId,
      type: transaction.type,
      date: transaction.date,
      notes: transaction.notes,
      createdAt: transaction.createdAt,
      updatedAt: transaction.updatedAt,
    );
  }

  TransactionModel copyWith({
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
    return TransactionModel(
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
}
