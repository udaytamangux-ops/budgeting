import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';

final class RecentTransactionCategoriesService {
  const RecentTransactionCategoriesService();

  List<TransactionCategory> findForType({
    required Iterable<FinancialTransaction> transactions,
    required TransactionType type,
    int limit = 3,
  }) {
    if (limit <= 0) {
      return const <TransactionCategory>[];
    }

    final List<FinancialTransaction> relevantTransactions =
        transactions
            .where(
              (FinancialTransaction transaction) => transaction.type == type,
            )
            .toList()
          ..sort((FinancialTransaction first, FinancialTransaction second) {
            final int updatedComparison = second.updatedAt.compareTo(
              first.updatedAt,
            );
            if (updatedComparison != 0) {
              return updatedComparison;
            }
            return second.createdAt.compareTo(first.createdAt);
          });

    final Set<TransactionCategory> seen = <TransactionCategory>{};
    final List<TransactionCategory> recent = <TransactionCategory>[];
    for (final FinancialTransaction transaction in relevantTransactions) {
      if (seen.add(transaction.category)) {
        recent.add(transaction.category);
      }
      if (recent.length == limit) {
        break;
      }
    }
    return List<TransactionCategory>.unmodifiable(recent);
  }
}
