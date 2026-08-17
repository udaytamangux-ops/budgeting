import 'package:budgeting_app/features/categories/domain/entities/custom_category.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';

abstract interface class CustomCategoryRepository {
  Stream<List<CustomCategory>> watchCategories();
  Future<List<CustomCategory>> getCategories();
  Future<CustomCategory?> getById(String id);
  Future<CustomCategory> create({
    required TransactionType type,
    required String name,
    required String iconKey,
  });
  Future<CustomCategory> update({
    required String id,
    required String name,
    required String iconKey,
  });
  Future<void> archive(String id);
  Future<void> restore(String id);
  Future<Set<String>> getUsedIds();
  Stream<Set<String>> watchUsedIds();
  Future<bool> isUsed(String id);
  Future<void> deleteUnused(String id);
}

final class CustomCategoryException implements Exception {
  const CustomCategoryException(this.message);
  final String message;
  @override
  String toString() => message;
}
