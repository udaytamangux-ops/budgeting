import 'dart:math';

import 'package:budgeting_app/core/data/owner_scope.dart';
import 'package:budgeting_app/core/database/app_database.dart' as db;
import 'package:budgeting_app/features/categories/domain/entities/custom_category.dart';
import 'package:budgeting_app/features/categories/domain/repositories/custom_category_repository.dart';
import 'package:budgeting_app/features/categories/domain/services/category_catalog.dart';
import 'package:budgeting_app/features/categories/domain/services/category_icon_keys.dart';
import 'package:budgeting_app/features/transactions/data/database/transaction_database_mapper.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:drift/drift.dart';

final class DriftCustomCategoryRepository implements CustomCategoryRepository {
  DriftCustomCategoryRepository(
    this._database, {
    this.ownerScope = OwnerScopes.guest,
    DateTime Function()? now,
    String Function()? createId,
  }) : _now = now ?? DateTime.now,
       _createId = createId ?? _newId;

  final db.AppDatabase _database;
  final String ownerScope;
  final DateTime Function() _now;
  final String Function() _createId;

  @override
  Stream<List<CustomCategory>> watchCategories() => _database
      .watchCustomCategoriesForOwner(ownerScope)
      .map((List<db.CustomCategory> rows) => rows.map(_fromRow).toList());

  @override
  Future<List<CustomCategory>> getCategories() async =>
      (await _database.getCustomCategoriesForOwner(
        ownerScope,
      )).map(_fromRow).toList(growable: false);

  @override
  Future<CustomCategory?> getById(String id) async {
    final db.CustomCategory? row = await _database.findCustomCategory(
      id,
      ownerScope: ownerScope,
    );
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<CustomCategory> create({
    required TransactionType type,
    required String name,
    required String iconKey,
  }) async {
    final String cleanName = CategoryNameRules.clean(name);
    final String normalized = CategoryNameRules.normalize(cleanName);
    final List<CustomCategory> existing = await getCategories();
    _validate(
      type: type,
      name: cleanName,
      normalizedName: normalized,
      iconKey: iconKey,
      existing: existing,
    );
    final CustomCategory? archived = existing
        .where(
          (CustomCategory value) =>
              value.type == type &&
              value.normalizedName == normalized &&
              value.isArchived,
        )
        .firstOrNull;
    if (archived != null) {
      throw const CustomCategoryException(
        'An archived category has this name. Restore it instead.',
      );
    }
    final DateTime now = _now().toUtc();
    final CustomCategory category = CustomCategory(
      id: _createId(),
      type: type,
      name: cleanName,
      normalizedName: normalized,
      iconKey: iconKey,
      isArchived: false,
      createdAt: now,
      updatedAt: now,
    );
    try {
      await _database.insertCustomCategory(_toCompanion(category));
      return category;
    } on Object {
      throw const CustomCategoryException(
        'The category could not be saved. Try again.',
      );
    }
  }

  @override
  Future<CustomCategory> update({
    required String id,
    required String name,
    required String iconKey,
  }) async {
    final CustomCategory? current = await getById(id);
    if (current == null) {
      throw const CustomCategoryException('Category not found.');
    }
    final String cleanName = CategoryNameRules.clean(name);
    final String normalized = CategoryNameRules.normalize(cleanName);
    _validate(
      type: current.type,
      name: cleanName,
      normalizedName: normalized,
      iconKey: iconKey,
      existing: (await getCategories())
          .where((CustomCategory value) => value.id != id)
          .toList(),
      enforceLimit: false,
    );
    final CustomCategory updated = current.copyWith(
      name: cleanName,
      normalizedName: normalized,
      iconKey: iconKey,
      updatedAt: _now().toUtc(),
    );
    await _database.updateCustomCategory(
      id,
      _toCompanion(updated),
      ownerScope: ownerScope,
    );
    return updated;
  }

  @override
  Future<void> archive(String id) => _setArchived(id, true);

  @override
  Future<void> restore(String id) async {
    final CustomCategory? current = await getById(id);
    if (current == null) {
      throw const CustomCategoryException('Category not found.');
    }
    final List<CustomCategory> categories = await getCategories();
    final int activeCount = categories
        .where(
          (CustomCategory value) =>
              value.type == current.type && !value.isArchived,
        )
        .length;
    if (activeCount >= CategoryNameRules.maximumActivePerType) {
      throw const CustomCategoryException(
        'Archive another category before restoring this one.',
      );
    }
    await _setArchived(id, false);
  }

  Future<void> _setArchived(String id, bool value) async {
    final CustomCategory? current = await getById(id);
    if (current == null) {
      throw const CustomCategoryException('Category not found.');
    }
    await _database.updateCustomCategory(
      id,
      db.CustomCategoriesCompanion(
        isArchived: Value<bool>(value),
        updatedAtUtcMicros: Value<int>(_now().toUtc().microsecondsSinceEpoch),
      ),
      ownerScope: ownerScope,
    );
  }

  @override
  Future<bool> isUsed(String id) =>
      _database.isCustomCategoryUsed(id, ownerScope: ownerScope);

  @override
  Future<Set<String>> getUsedIds() =>
      _database.getUsedCategoryIds(ownerScope: ownerScope);

  @override
  Stream<Set<String>> watchUsedIds() =>
      _database.watchUsedCategoryIds(ownerScope: ownerScope);

  @override
  Future<void> deleteUnused(String id) async {
    if (await isUsed(id)) {
      throw const CustomCategoryException(
        'This category is used by financial records and cannot be deleted.',
      );
    }
    final int deleted = await _database.deleteCustomCategory(
      id,
      ownerScope: ownerScope,
    );
    if (deleted == 0) {
      throw const CustomCategoryException('Category not found.');
    }
  }

  void _validate({
    required TransactionType type,
    required String name,
    required String normalizedName,
    required String iconKey,
    required List<CustomCategory> existing,
    bool enforceLimit = true,
  }) {
    if (name.isEmpty) {
      throw const CustomCategoryException('Enter a category name.');
    }
    if (name.length > CategoryNameRules.maximumLength) {
      throw const CustomCategoryException(
        'Category names can be up to 36 characters.',
      );
    }
    if (!CategoryIconKeys.isSupported(iconKey)) {
      throw const CustomCategoryException('Choose a supported category icon.');
    }
    final bool collidesWithSystem = TransactionCategory.values
        .where((TransactionCategory value) => value.supports(type))
        .any(
          (TransactionCategory value) =>
              CategoryNameRules.normalize(value.systemLabel ?? '') ==
              normalizedName,
        );
    if (collidesWithSystem) {
      throw const CustomCategoryException(
        'A built-in category already has this name.',
      );
    }
    final bool duplicate = existing.any(
      (CustomCategory value) =>
          value.type == type &&
          value.normalizedName == normalizedName &&
          !value.isArchived,
    );
    if (duplicate) {
      throw const CustomCategoryException(
        'A category with this name already exists.',
      );
    }
    if (enforceLimit &&
        existing
                .where(
                  (CustomCategory value) =>
                      value.type == type && !value.isArchived,
                )
                .length >=
            CategoryNameRules.maximumActivePerType) {
      throw const CustomCategoryException(
        'You can keep up to 10 active custom categories for this type.',
      );
    }
  }

  CustomCategory _fromRow(db.CustomCategory row) => CustomCategory(
    id: row.id,
    type: TransactionDatabaseMapper.typeFromKey(row.typeKey),
    name: row.name,
    normalizedName: row.normalizedName,
    iconKey: row.iconKey,
    isArchived: row.isArchived,
    createdAt: DateTime.fromMicrosecondsSinceEpoch(
      row.createdAtUtcMicros,
      isUtc: true,
    ),
    updatedAt: DateTime.fromMicrosecondsSinceEpoch(
      row.updatedAtUtcMicros,
      isUtc: true,
    ),
  );

  db.CustomCategoriesCompanion _toCompanion(
    CustomCategory category,
  ) => db.CustomCategoriesCompanion(
    id: Value<String>(category.id),
    ownerScope: Value<String>(ownerScope),
    typeKey: Value<String>(TransactionDatabaseMapper.typeToKey(category.type)),
    name: Value<String>(category.name),
    normalizedName: Value<String>(category.normalizedName),
    iconKey: Value<String>(category.iconKey),
    isArchived: Value<bool>(category.isArchived),
    createdAtUtcMicros: Value<int>(category.createdAt.microsecondsSinceEpoch),
    updatedAtUtcMicros: Value<int>(category.updatedAt.microsecondsSinceEpoch),
  );

  static String _newId() {
    final Random random = Random.secure();
    String hex(int length) => List<String>.generate(
      length,
      (_) => random.nextInt(16).toRadixString(16),
    ).join();
    return 'custom:${hex(8)}-${hex(4)}-4${hex(3)}-'
        '${(8 + random.nextInt(4)).toRadixString(16)}${hex(3)}-${hex(12)}';
  }
}
