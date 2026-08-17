import 'package:budgeting_app/core/data/owner_scope.dart';
import 'package:budgeting_app/core/database/database_providers.dart';
import 'package:budgeting_app/features/categories/data/repositories/drift_custom_category_repository.dart';
import 'package:budgeting_app/features/categories/domain/entities/custom_category.dart';
import 'package:budgeting_app/features/categories/domain/repositories/custom_category_repository.dart';
import 'package:budgeting_app/features/categories/domain/services/category_catalog.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<CustomCategoryRepository> customCategoryRepositoryProvider =
    Provider<CustomCategoryRepository>((Ref ref) {
      return DriftCustomCategoryRepository(
        ref.watch(appDatabaseProvider),
        ownerScope: ref.watch(activeOwnerScopeProvider),
      );
    });

final StreamProvider<List<CustomCategory>> customCategoriesProvider =
    StreamProvider<List<CustomCategory>>((Ref ref) {
      return ref.watch(customCategoryRepositoryProvider).watchCategories();
    });

final AutoDisposeStreamProvider<Set<String>> usedCustomCategoryIdsProvider =
    StreamProvider.autoDispose<Set<String>>((Ref ref) {
      return ref.watch(customCategoryRepositoryProvider).watchUsedIds();
    });

final Provider<CategoryCatalog> categoryCatalogProvider =
    Provider<CategoryCatalog>((Ref ref) {
      return CategoryCatalog(
        ref.watch(customCategoriesProvider).valueOrNull ??
            const <CustomCategory>[],
      );
    });

final ProviderFamily<List<CategoryDefinition>, TransactionType>
availableCategoryDefinitionsProvider =
    Provider.family<List<CategoryDefinition>, TransactionType>((Ref ref, type) {
      return ref.watch(categoryCatalogProvider).availableFor(type);
    });
