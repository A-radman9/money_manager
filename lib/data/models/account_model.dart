import '../../domain/entities/account.dart';

class AccountModel extends Account {
  const AccountModel({
    super.id,
    required super.name,
    required super.initialBalance,
    required super.currentBalance,
    super.description,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id']?.toString(),
      name: json['name'] as String,
      initialBalance: (json['initial_balance'] as num).toDouble(),
      currentBalance: (json['current_balance'] as num).toDouble(),
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'initial_balance': initialBalance,
      'current_balance': currentBalance,
      'description': description,
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

  factory AccountModel.fromEntity(Account account) {
    return AccountModel(
      id: account.id,
      name: account.name,
      initialBalance: account.initialBalance,
      currentBalance: account.currentBalance,
      description: account.description,
      createdAt: account.createdAt,
      updatedAt: account.updatedAt,
    );
  }

  @override
  AccountModel copyWith({
    String? id,
    String? name,
    double? initialBalance,
    double? currentBalance,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      initialBalance: initialBalance ?? this.initialBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
