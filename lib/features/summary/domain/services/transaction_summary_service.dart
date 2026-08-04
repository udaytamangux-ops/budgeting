import 'package:budgeting_app/features/summary/domain/entities/monthly_transaction_summary.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/monthly_financial_summary.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/domain/services/financial_summary_service.dart';

final class TransactionSummaryService {
  const TransactionSummaryService();

  MonthlyTransactionSummary calculateForMonth({
    required List<FinancialTransaction> transactions,
    required DateTime month,
  }) {
    final MonthlyFinancialSummary financialSummary =
        const FinancialSummaryService().calculateForMonth(
          transactions: transactions,
          month: month,
        );
    final Map<TransactionCategory, Money> categorySpending =
        <TransactionCategory, Money>{};
    final Map<PaymentMethod, int> paymentMethodCounts = <PaymentMethod, int>{};
    int transactionCount = 0;

    for (final FinancialTransaction transaction in transactions) {
      if (!_isInLocalMonth(transaction.occurredAt, month)) {
        continue;
      }
      transactionCount += 1;
      paymentMethodCounts.update(
        transaction.paymentMethod,
        (int count) => count + 1,
        ifAbsent: () => 1,
      );
      if (transaction.type == TransactionType.expense) {
        categorySpending.update(
          transaction.category,
          (Money amount) => amount + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }
    }

    final List<MapEntry<TransactionCategory, Money>> sortedCategoryEntries =
        categorySpending.entries.toList()..sort((
          MapEntry<TransactionCategory, Money> first,
          MapEntry<TransactionCategory, Money> second,
        ) {
          final int amountComparison = second.value.compareTo(first.value);
          return amountComparison != 0
              ? amountComparison
              : first.key.index.compareTo(second.key.index);
        });
    final List<int> categoryPercentages = _allocatePercentages(
      sortedCategoryEntries
          .map((MapEntry<TransactionCategory, Money> entry) => entry.value)
          .toList(growable: false),
      financialSummary.expenses.minorUnits,
    );
    final List<CategorySpendingRecord> categoryRecords = List.generate(
      sortedCategoryEntries.length,
      (int index) => CategorySpendingRecord(
        category: sortedCategoryEntries[index].key,
        amount: sortedCategoryEntries[index].value,
        sharePercentage: categoryPercentages[index],
      ),
      growable: false,
    );
    final List<CategorySpendingGroup> spendingGroups = _groupCategorySpending(
      categoryRecords,
    );

    final List<PaymentMethodUsageRecord> paymentRecords =
        paymentMethodCounts.entries
            .map(
              (MapEntry<PaymentMethod, int> entry) => PaymentMethodUsageRecord(
                paymentMethod: entry.key,
                transactionCount: entry.value,
                sharePercentage: _percentage(entry.value, transactionCount),
              ),
            )
            .toList()
          ..sort((
            PaymentMethodUsageRecord first,
            PaymentMethodUsageRecord second,
          ) {
            final int countComparison = second.transactionCount.compareTo(
              first.transactionCount,
            );
            return countComparison != 0
                ? countComparison
                : first.paymentMethod.index.compareTo(
                    second.paymentMethod.index,
                  );
          });

    return MonthlyTransactionSummary(
      financialSummary: financialSummary,
      transactionCount: transactionCount,
      categorySpending: List<CategorySpendingRecord>.unmodifiable(
        categoryRecords,
      ),
      spendingGroups: spendingGroups,
      paymentMethods: List<PaymentMethodUsageRecord>.unmodifiable(
        paymentRecords,
      ),
    );
  }

  int _percentage(int part, int total) {
    if (part <= 0 || total <= 0) {
      return 0;
    }
    return (part * 100 + total ~/ 2) ~/ total;
  }

  List<int> _allocatePercentages(List<Money> amounts, int totalMinorUnits) {
    if (amounts.isEmpty || totalMinorUnits <= 0) {
      return List<int>.filled(amounts.length, 0, growable: false);
    }

    final List<int> percentages = List<int>.filled(amounts.length, 0);
    final List<int> remainders = List<int>.filled(amounts.length, 0);
    int allocated = 0;
    for (int index = 0; index < amounts.length; index += 1) {
      final int scaledAmount = amounts[index].minorUnits * 100;
      percentages[index] = scaledAmount ~/ totalMinorUnits;
      remainders[index] = scaledAmount % totalMinorUnits;
      allocated += percentages[index];
    }

    final List<int> rankedIndexes =
        List<int>.generate(amounts.length, (int index) => index)
          ..sort((int first, int second) {
            final int remainderComparison = remainders[second].compareTo(
              remainders[first],
            );
            return remainderComparison != 0
                ? remainderComparison
                : first.compareTo(second);
          });
    final int pointsToAllocate = 100 - allocated;
    for (int index = 0; index < pointsToAllocate; index += 1) {
      percentages[rankedIndexes[index]] += 1;
    }
    return List<int>.unmodifiable(percentages);
  }

  List<CategorySpendingGroup> _groupCategorySpending(
    List<CategorySpendingRecord> records,
  ) {
    const int maximumMajorCategories = 4;
    if (records.length <= maximumMajorCategories) {
      return List<CategorySpendingGroup>.unmodifiable(
        records.map(
          (CategorySpendingRecord record) => CategorySpendingGroup(
            category: record.category,
            includedCategories: <TransactionCategory>[record.category],
            amount: record.amount,
            sharePercentage: record.sharePercentage,
          ),
        ),
      );
    }

    final List<CategorySpendingRecord> majorRecords = records
        .where(
          (CategorySpendingRecord record) =>
              record.category != TransactionCategory.other,
        )
        .take(maximumMajorCategories)
        .toList(growable: false);
    final List<CategorySpendingGroup> groups = majorRecords
        .map(
          (CategorySpendingRecord record) => CategorySpendingGroup(
            category: record.category,
            includedCategories: <TransactionCategory>[record.category],
            amount: record.amount,
            sharePercentage: record.sharePercentage,
          ),
        )
        .toList();
    final List<CategorySpendingRecord> additionalRecords = records
        .where(
          (CategorySpendingRecord record) => !majorRecords.contains(record),
        )
        .toList(growable: false);
    Money otherAmount = const Money.zero();
    int otherPercentage = 0;
    for (final CategorySpendingRecord record in additionalRecords) {
      otherAmount += record.amount;
      otherPercentage += record.sharePercentage;
    }
    groups.add(
      CategorySpendingGroup(
        category: null,
        includedCategories: List<TransactionCategory>.unmodifiable(
          additionalRecords.map(
            (CategorySpendingRecord record) => record.category,
          ),
        ),
        amount: otherAmount,
        sharePercentage: otherPercentage,
      ),
    );
    return List<CategorySpendingGroup>.unmodifiable(groups);
  }

  bool _isInLocalMonth(DateTime timestamp, DateTime month) {
    final DateTime localTimestamp = timestamp.toLocal();
    return localTimestamp.year == month.year &&
        localTimestamp.month == month.month;
  }
}
