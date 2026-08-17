import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';

final class CustomCategory {
  const CustomCategory({
    required this.id,
    required this.type,
    required this.name,
    required this.normalizedName,
    required this.iconKey,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final TransactionType type;
  final String name;
  final String normalizedName;
  final String iconKey;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionCategory get reference =>
      TransactionCategory.custom(id, type: type);

  CustomCategory copyWith({
    String? name,
    String? normalizedName,
    String? iconKey,
    bool? isArchived,
    DateTime? updatedAt,
  }) {
    return CustomCategory(
      id: id,
      type: type,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      iconKey: iconKey ?? this.iconKey,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

final class CategoryDefinition {
  const CategoryDefinition({
    required this.reference,
    required this.label,
    required this.iconKey,
    required this.isArchived,
    required this.isSystem,
  });

  final TransactionCategory reference;
  final String label;
  final String iconKey;
  final bool isArchived;
  final bool isSystem;
}
