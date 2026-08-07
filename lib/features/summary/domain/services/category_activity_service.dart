import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/calendar/domain/calendar_period.dart';
import 'package:budgeting_app/features/summary/domain/entities/monthly_category_activity.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';

final class CategoryActivityService {
  const CategoryActivityService();

  MonthlyCategoryActivity calculateForMonth({
    required List<FinancialTransaction> transactions,
    required DateTime month,
    required TransactionType type,
  }) {
    return calculateForPeriod(
      transactions: transactions,
      period: CalendarPeriod(
        calendarSystem: AppCalendarSystem.gregorianAd,
        year: month.year,
        month: month.month,
        startAdInclusive: DateTime.utc(month.year, month.month),
        endAdExclusive: DateTime.utc(month.year, month.month + 1),
        displayLabel: '',
      ),
      type: type,
    );
  }

  MonthlyCategoryActivity calculateForPeriod({
    required List<FinancialTransaction> transactions,
    required CalendarPeriod period,
    required TransactionType type,
  }) {
    final List<FinancialTransaction> matchingTransactions = transactions
        .where(
          (FinancialTransaction transaction) =>
              transaction.type == type &&
              period.contains(transaction.occurredAt),
        )
        .toList(growable: false);
    final Map<TransactionCategory, Money> amounts =
        <TransactionCategory, Money>{};
    final Map<TransactionCategory, int> counts = <TransactionCategory, int>{};
    Money total = const Money.zero();

    for (final FinancialTransaction transaction in matchingTransactions) {
      total += transaction.amount;
      amounts.update(
        transaction.category,
        (Money amount) => amount + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
      counts.update(
        transaction.category,
        (int count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    final List<MapEntry<TransactionCategory, Money>> sortedEntries =
        amounts.entries.toList()..sort((
          MapEntry<TransactionCategory, Money> first,
          MapEntry<TransactionCategory, Money> second,
        ) {
          final int amountComparison = second.value.compareTo(first.value);
          return amountComparison != 0
              ? amountComparison
              : first.key.index.compareTo(second.key.index);
        });
    final List<int> percentages = _allocatePercentages(
      sortedEntries
          .map((MapEntry<TransactionCategory, Money> entry) => entry.value)
          .toList(growable: false),
      total.minorUnits,
    );
    final List<CategoryActivityRecord> records = List.generate(
      sortedEntries.length,
      (int index) => CategoryActivityRecord(
        category: sortedEntries[index].key,
        amount: sortedEntries[index].value,
        sharePercentage: percentages[index],
        transactionCount: counts[sortedEntries[index].key]!,
      ),
      growable: false,
    );

    return MonthlyCategoryActivity(
      month: period.startAdInclusive,
      type: type,
      total: total,
      transactionCount: matchingTransactions.length,
      records: List<CategoryActivityRecord>.unmodifiable(records),
      groups: _groupRecords(records),
    );
  }

  CategoryActivityDetails calculateForCategories({
    required List<FinancialTransaction> transactions,
    required DateTime month,
    required TransactionType type,
    required List<TransactionCategory> categories,
  }) {
    return calculateForCategoriesInPeriod(
      transactions: transactions,
      period: CalendarPeriod(
        calendarSystem: AppCalendarSystem.gregorianAd,
        year: month.year,
        month: month.month,
        startAdInclusive: DateTime.utc(month.year, month.month),
        endAdExclusive: DateTime.utc(month.year, month.month + 1),
        displayLabel: '',
      ),
      type: type,
      categories: categories,
    );
  }

  CategoryActivityDetails calculateForCategoriesInPeriod({
    required List<FinancialTransaction> transactions,
    required CalendarPeriod period,
    required TransactionType type,
    required List<TransactionCategory> categories,
  }) {
    if (categories.isEmpty) {
      throw ArgumentError.value(
        categories,
        'categories',
        'At least one category is required.',
      );
    }
    final Set<TransactionCategory> selectedCategories = categories.toSet();
    final MonthlyCategoryActivity monthlyActivity = calculateForPeriod(
      transactions: transactions,
      period: period,
      type: type,
    );
    final List<FinancialTransaction> matchingTransactions =
        transactions
            .where(
              (FinancialTransaction transaction) =>
                  transaction.type == type &&
                  selectedCategories.contains(transaction.category) &&
                  period.contains(transaction.occurredAt),
            )
            .toList()
          ..sort(_compareTransactionsNewestFirst);
    Money total = const Money.zero();
    for (final FinancialTransaction transaction in matchingTransactions) {
      total += transaction.amount;
    }
    int sharePercentage = 0;
    for (final CategoryActivityRecord record in monthlyActivity.records) {
      if (selectedCategories.contains(record.category)) {
        sharePercentage += record.sharePercentage;
      }
    }
    final Money? averageTransaction = matchingTransactions.isEmpty
        ? null
        : Money(
            minorUnits:
                (total.minorUnits + matchingTransactions.length ~/ 2) ~/
                matchingTransactions.length,
            currencyCode: total.currencyCode,
          );

    return CategoryActivityDetails(
      month: monthlyActivity.month,
      type: type,
      includedCategories: List<TransactionCategory>.unmodifiable(
        selectedCategories,
      ),
      total: total,
      relevantMonthlyTotal: monthlyActivity.total,
      sharePercentage: sharePercentage,
      transactions: List<FinancialTransaction>.unmodifiable(
        matchingTransactions,
      ),
      averageTransaction: averageTransaction,
    );
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

  List<CategoryActivityGroup> _groupRecords(
    List<CategoryActivityRecord> records,
  ) {
    const int maximumMajorCategories = 4;
    if (records.length <= maximumMajorCategories) {
      return List<CategoryActivityGroup>.unmodifiable(
        records.map(
          (CategoryActivityRecord record) => CategoryActivityGroup(
            category: record.category,
            includedCategories: <TransactionCategory>[record.category],
            amount: record.amount,
            sharePercentage: record.sharePercentage,
            transactionCount: record.transactionCount,
          ),
        ),
      );
    }

    final List<CategoryActivityRecord> majorRecords = records
        .where(
          (CategoryActivityRecord record) =>
              record.category != TransactionCategory.other,
        )
        .take(maximumMajorCategories)
        .toList(growable: false);
    final List<CategoryActivityGroup> groups = majorRecords
        .map(
          (CategoryActivityRecord record) => CategoryActivityGroup(
            category: record.category,
            includedCategories: <TransactionCategory>[record.category],
            amount: record.amount,
            sharePercentage: record.sharePercentage,
            transactionCount: record.transactionCount,
          ),
        )
        .toList();
    final List<CategoryActivityRecord> additionalRecords = records
        .where(
          (CategoryActivityRecord record) => !majorRecords.contains(record),
        )
        .toList(growable: false);
    Money otherAmount = const Money.zero();
    int otherPercentage = 0;
    int otherTransactionCount = 0;
    for (final CategoryActivityRecord record in additionalRecords) {
      otherAmount += record.amount;
      otherPercentage += record.sharePercentage;
      otherTransactionCount += record.transactionCount;
    }
    groups.add(
      CategoryActivityGroup(
        category: null,
        includedCategories: List<TransactionCategory>.unmodifiable(
          additionalRecords.map(
            (CategoryActivityRecord record) => record.category,
          ),
        ),
        amount: otherAmount,
        sharePercentage: otherPercentage,
        transactionCount: otherTransactionCount,
      ),
    );
    return List<CategoryActivityGroup>.unmodifiable(groups);
  }

  int _compareTransactionsNewestFirst(
    FinancialTransaction first,
    FinancialTransaction second,
  ) {
    final int occurredAtComparison = second.occurredAt.compareTo(
      first.occurredAt,
    );
    if (occurredAtComparison != 0) {
      return occurredAtComparison;
    }
    final int createdAtComparison = second.createdAt.compareTo(first.createdAt);
    return createdAtComparison != 0
        ? createdAtComparison
        : second.id.compareTo(first.id);
  }
}
