import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_visuals.dart';

final class TransactionDateGroup {
  const TransactionDateGroup({required this.date, required this.transactions});

  final DateTime date;
  final List<FinancialTransaction> transactions;
}

final class TransactionListFilter {
  const TransactionListFilter();

  List<TransactionDateGroup> apply({
    required List<FinancialTransaction> transactions,
    required DateTime month,
    String query = '',
    TransactionType? type,
  }) {
    final String normalizedQuery = query.trim().toLowerCase();
    final Map<DateTime, List<FinancialTransaction>> grouped =
        <DateTime, List<FinancialTransaction>>{};
    final List<FinancialTransaction> orderedTransactions =
        List<FinancialTransaction>.of(transactions)
          ..sort((FinancialTransaction first, FinancialTransaction second) {
            final int occurredComparison = second.occurredAt.compareTo(
              first.occurredAt,
            );
            return occurredComparison != 0
                ? occurredComparison
                : second.createdAt.compareTo(first.createdAt);
          });

    for (final FinancialTransaction transaction in orderedTransactions) {
      final DateTime localDate = transaction.occurredAt.toLocal();
      if (localDate.year != month.year || localDate.month != month.month) {
        continue;
      }
      if (type != null && transaction.type != type) {
        continue;
      }
      if (normalizedQuery.isNotEmpty &&
          !_matchesQuery(transaction, normalizedQuery)) {
        continue;
      }
      final DateTime day = DateTime(
        localDate.year,
        localDate.month,
        localDate.day,
      );
      grouped.putIfAbsent(day, () => <FinancialTransaction>[]).add(transaction);
    }

    return grouped.entries
        .map(
          (MapEntry<DateTime, List<FinancialTransaction>> entry) =>
              TransactionDateGroup(
                date: entry.key,
                transactions: List<FinancialTransaction>.unmodifiable(
                  entry.value,
                ),
              ),
        )
        .toList(growable: false);
  }

  bool _matchesQuery(FinancialTransaction transaction, String normalizedQuery) {
    final Iterable<String?> searchableValues = <String?>[
      transaction.merchant,
      transaction.note,
      transaction.category.visual.label,
      transaction.paymentMethod.label,
      transaction.type == TransactionType.expense ? 'expense' : 'income',
    ];
    return searchableValues.any(
      (String? value) =>
          value?.toLowerCase().contains(normalizedQuery) ?? false,
    );
  }
}
