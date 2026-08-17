import 'dart:async';

import 'package:budgeting_app/features/categories/domain/entities/custom_category.dart';
import 'package:budgeting_app/features/categories/domain/repositories/custom_category_repository.dart';
import 'package:budgeting_app/features/categories/domain/services/category_catalog.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';

final class InMemoryCustomCategoryRepository
    implements CustomCategoryRepository {
  InMemoryCustomCategoryRepository({
    List<CustomCategory> categories = const <CustomCategory>[],
    Set<String> usedIds = const <String>{},
    DateTime Function()? now,
  }) : _categories = <CustomCategory>[...categories],
       _usedIds = <String>{...usedIds},
       _now = now ?? DateTime.now;

  final StreamController<List<CustomCategory>> _changes =
      StreamController<List<CustomCategory>>.broadcast(sync: true);
  final List<CustomCategory> _categories;
  final Set<String> _usedIds;
  final DateTime Function() _now;
  int _nextId = 1;

  @override
  Future<void> archive(String id) => _setArchived(id, true);

  @override
  Future<CustomCategory> create({
    required TransactionType type,
    required String name,
    required String iconKey,
  }) async {
    final String cleanName = CategoryNameRules.clean(name);
    _validateName(type, cleanName);
    final DateTime timestamp = _now().toUtc();
    final CustomCategory category = CustomCategory(
      id: 'custom:test-${_nextId++}',
      type: type,
      name: cleanName,
      normalizedName: CategoryNameRules.normalize(cleanName),
      iconKey: iconKey,
      isArchived: false,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
    _categories.add(category);
    _emit();
    return category;
  }

  Future<void> dispose() => _changes.close();

  @override
  Future<void> deleteUnused(String id) async {
    if (_usedIds.contains(id)) {
      throw const CustomCategoryException(
        'This category is used by recorded financial activity.',
      );
    }
    _categories.removeWhere((CustomCategory item) => item.id == id);
    _emit();
  }

  @override
  Future<List<CustomCategory>> getCategories() async =>
      List<CustomCategory>.unmodifiable(_categories);

  @override
  Future<CustomCategory?> getById(String id) async {
    for (final CustomCategory category in _categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  @override
  Future<Set<String>> getUsedIds() async => Set<String>.unmodifiable(_usedIds);

  @override
  Stream<Set<String>> watchUsedIds() async* {
    yield Set<String>.unmodifiable(_usedIds);
  }

  @override
  Future<bool> isUsed(String id) async => _usedIds.contains(id);

  @override
  Future<void> restore(String id) => _setArchived(id, false);

  @override
  Future<CustomCategory> update({
    required String id,
    required String name,
    required String iconKey,
  }) async {
    final int index = _categories.indexWhere(
      (CustomCategory item) => item.id == id,
    );
    if (index < 0) {
      throw const CustomCategoryException('Category not found.');
    }
    final String cleanName = CategoryNameRules.clean(name);
    _validateName(_categories[index].type, cleanName, excludingId: id);
    final CustomCategory updated = _categories[index].copyWith(
      name: cleanName,
      normalizedName: CategoryNameRules.normalize(cleanName),
      iconKey: iconKey,
      updatedAt: _now().toUtc(),
    );
    _categories[index] = updated;
    _emit();
    return updated;
  }

  @override
  Stream<List<CustomCategory>> watchCategories() async* {
    yield List<CustomCategory>.unmodifiable(_categories);
    yield* _changes.stream;
  }

  void _emit() {
    _changes.add(List<CustomCategory>.unmodifiable(_categories));
  }

  Future<void> _setArchived(String id, bool archived) async {
    final int index = _categories.indexWhere(
      (CustomCategory item) => item.id == id,
    );
    if (index < 0) {
      throw const CustomCategoryException('Category not found.');
    }
    if (!archived) {
      final int activeCount = _categories
          .where(
            (CustomCategory item) =>
                item.type == _categories[index].type && !item.isArchived,
          )
          .length;
      if (activeCount >= CategoryNameRules.maximumActivePerType) {
        throw const CustomCategoryException(
          'You can keep up to 10 active custom categories for each type.',
        );
      }
    }
    _categories[index] = _categories[index].copyWith(
      isArchived: archived,
      updatedAt: _now().toUtc(),
    );
    _emit();
  }

  void _validateName(
    TransactionType type,
    String cleanName, {
    String? excludingId,
  }) {
    if (cleanName.isEmpty ||
        cleanName.length > CategoryNameRules.maximumLength) {
      throw const CustomCategoryException(
        'Enter a category name using 1 to 36 characters.',
      );
    }
    final String normalized = CategoryNameRules.normalize(cleanName);
    if (excludingId == null &&
        _categories
                .where(
                  (CustomCategory item) =>
                      item.type == type && !item.isArchived,
                )
                .length >=
            CategoryNameRules.maximumActivePerType) {
      throw const CustomCategoryException(
        'You can keep up to 10 active custom categories for each type.',
      );
    }
    final bool collidesWithSystem = TransactionCategory.values
        .where((TransactionCategory item) => item.supports(type))
        .any(
          (TransactionCategory item) =>
              CategoryNameRules.normalize(item.systemLabel ?? '') == normalized,
        );
    final CustomCategory? collidingCustom = _categories
        .where(
          (CustomCategory item) =>
              item.id != excludingId &&
              item.type == type &&
              item.normalizedName == normalized,
        )
        .firstOrNull;
    if (collidingCustom?.isArchived ?? false) {
      throw const CustomCategoryException(
        'An archived category has this name. Restore it instead.',
      );
    }
    final bool collidesWithCustom = collidingCustom != null;
    if (collidesWithSystem || collidesWithCustom) {
      throw const CustomCategoryException(
        'A category with this name already exists.',
      );
    }
  }
}
