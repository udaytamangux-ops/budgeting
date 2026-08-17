import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';

extension TransactionCategoryMetadata on TransactionCategory {
  String get displayLabel => systemLabel ?? 'Custom category';
}
