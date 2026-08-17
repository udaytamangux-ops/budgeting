import 'package:budgeting_app/features/categories/domain/entities/custom_category.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';

final class CategoryCatalog {
  CategoryCatalog(Iterable<CustomCategory> customCategories)
    : _customById = <String, CustomCategory>{
        for (final CustomCategory category in customCategories)
          category.id: category,
      };

  final Map<String, CustomCategory> _customById;

  static final Map<TransactionCategory, String> _systemIconKeys =
      <TransactionCategory, String>{
        TransactionCategory.food: 'food',
        TransactionCategory.transport: 'transport',
        TransactionCategory.rentAndHousing: 'home',
        TransactionCategory.utilities: 'utilities',
        TransactionCategory.shopping: 'shopping',
        TransactionCategory.health: 'health',
        TransactionCategory.education: 'education',
        TransactionCategory.entertainment: 'entertainment',
        TransactionCategory.family: 'family',
        TransactionCategory.feesAndCharges: 'receipt',
        TransactionCategory.salary: 'work',
        TransactionCategory.freelance: 'laptop',
        TransactionCategory.business: 'business',
        TransactionCategory.allowance: 'wallet',
        TransactionCategory.remittance: 'globe',
        TransactionCategory.gift: 'gift',
        TransactionCategory.refund: 'refund',
        TransactionCategory.other: 'other',
      };

  CategoryDefinition resolve(TransactionCategory reference) {
    if (reference.isSystem) {
      return CategoryDefinition(
        reference: reference,
        label: reference.systemLabel ?? 'Other',
        iconKey: _systemIconKeys[reference] ?? 'other',
        isArchived: false,
        isSystem: true,
      );
    }
    final CustomCategory? custom = _customById[reference.name];
    return CategoryDefinition(
      reference: reference,
      label: custom?.name ?? 'Unavailable category',
      iconKey: custom?.iconKey ?? 'other',
      isArchived: custom?.isArchived ?? true,
      isSystem: false,
    );
  }

  List<CategoryDefinition> availableFor(TransactionType type) {
    final List<CategoryDefinition> result = TransactionCategory.values
        .where((TransactionCategory value) => value.supports(type))
        .map(resolve)
        .toList();
    result.addAll(
      _customById.values
          .where(
            (CustomCategory value) => value.type == type && !value.isArchived,
          )
          .map((CustomCategory value) => resolve(value.reference)),
    );
    return List<CategoryDefinition>.unmodifiable(result);
  }

  CustomCategory? customById(String id) => _customById[id];
  List<CustomCategory> get customCategories =>
      List<CustomCategory>.unmodifiable(_customById.values);
}

abstract final class CategoryNameRules {
  static const int maximumLength = 36;
  static const int maximumActivePerType = 10;

  static String normalize(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

  static String clean(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), ' ');
}
