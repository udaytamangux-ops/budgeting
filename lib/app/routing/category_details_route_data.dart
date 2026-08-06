import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';

final class CategoryDetailsRouteData {
  CategoryDetailsRouteData({
    required this.type,
    required List<TransactionCategory> categories,
    required DateTime month,
  }) : categories = List<TransactionCategory>.unmodifiable(categories),
       month = DateTime(month.year, month.month) {
    if (categories.isEmpty) {
      throw ArgumentError.value(
        categories,
        'categories',
        'At least one category is required.',
      );
    }
    if (categories.any(
      (TransactionCategory category) => !category.supports(type),
    )) {
      throw ArgumentError.value(
        categories,
        'categories',
        'Every category must support the transaction type.',
      );
    }
  }

  final TransactionType type;
  final List<TransactionCategory> categories;
  final DateTime month;

  String get categoryIdentifiers =>
      categories.map((TransactionCategory category) => category.name).join(',');

  static CategoryDetailsRouteData? tryParse({
    required String? typeIdentifier,
    required String? categoryIdentifiers,
    required String? year,
    required String? month,
  }) {
    final TransactionType? type = _transactionType(typeIdentifier);
    final int? parsedYear = int.tryParse(year ?? '');
    final int? parsedMonth = int.tryParse(month ?? '');
    if (type == null ||
        parsedYear == null ||
        parsedMonth == null ||
        parsedYear < 1 ||
        parsedMonth < 1 ||
        parsedMonth > 12 ||
        categoryIdentifiers == null) {
      return null;
    }

    final List<TransactionCategory> categories = <TransactionCategory>[];
    for (final String identifier in categoryIdentifiers.split(',')) {
      final TransactionCategory? category = _category(identifier);
      if (category == null || !category.supports(type)) {
        return null;
      }
      if (!categories.contains(category)) {
        categories.add(category);
      }
    }
    if (categories.isEmpty) {
      return null;
    }
    return CategoryDetailsRouteData(
      type: type,
      categories: categories,
      month: DateTime(parsedYear, parsedMonth),
    );
  }

  static TransactionType? _transactionType(String? identifier) {
    for (final TransactionType type in TransactionType.values) {
      if (type.name == identifier) {
        return type;
      }
    }
    return null;
  }

  static TransactionCategory? _category(String identifier) {
    for (final TransactionCategory category in TransactionCategory.values) {
      if (category.name == identifier) {
        return category;
      }
    }
    return null;
  }
}
