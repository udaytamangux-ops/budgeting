import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/calendar/domain/calendar_period.dart';
import 'package:budgeting_app/features/financial_activity/domain/entities/financial_activity.dart';
import 'package:budgeting_app/features/financial_activity/domain/services/financial_effect_service.dart';
import 'package:budgeting_app/features/summary/domain/entities/monthly_category_activity.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transfers/domain/entities/financial_transfer.dart';

final class CategoryActivityService {
  const CategoryActivityService();

  MonthlyCategoryActivity calculateForMonth({
    required List<FinancialTransaction> transactions,
    required DateTime month,
    required TransactionType type,
    List<FinancialTransfer> transfers = const <FinancialTransfer>[],
  }) => calculateForPeriod(
    transactions: transactions,
    transfers: transfers,
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

  MonthlyCategoryActivity calculateForPeriod({
    required List<FinancialTransaction> transactions,
    required CalendarPeriod period,
    required TransactionType type,
    List<FinancialTransfer> transfers = const <FinancialTransfer>[],
  }) {
    final List<FinancialActivity> activities = <FinancialActivity>[
      ...transactions.map(TransactionActivity.new),
      ...transfers.map(TransferActivity.new),
    ];
    final Map<TransactionCategory, Money> amounts =
        <TransactionCategory, Money>{};
    final Map<TransactionCategory, int> counts = <TransactionCategory, int>{};
    Money total = const Money.zero();
    int activityCount = 0;
    const FinancialEffectService effects = FinancialEffectService();

    for (final FinancialActivity activity in activities) {
      if (!period.contains(activity.occurredAt)) continue;
      final FinancialEffect effect = effects.forActivity(activity);
      if (type == TransactionType.income) {
        if (!effect.incomeImpact.isPositive ||
            activity is! TransactionActivity) {
          continue;
        }
        total += effect.incomeImpact;
        final TransactionCategory category = activity.transaction.category;
        amounts.update(
          category,
          (value) => value + effect.incomeImpact,
          ifAbsent: () => effect.incomeImpact,
        );
        counts.update(category, (value) => value + 1, ifAbsent: () => 1);
        activityCount += 1;
        continue;
      }
      if (!effect.expenseImpact.isPositive) continue;
      total += effect.expenseImpact;
      activityCount += 1;
      for (final MapEntry<TransactionCategory, Money> entry
          in effect.expenseCategoryContributions.entries) {
        amounts.update(
          entry.key,
          (value) => value + entry.value,
          ifAbsent: () => entry.value,
        );
        counts.update(entry.key, (value) => value + 1, ifAbsent: () => 1);
      }
    }

    final List<MapEntry<TransactionCategory, Money>> sorted =
        amounts.entries.toList()..sort((a, b) {
          final int amount = b.value.compareTo(a.value);
          return amount != 0 ? amount : a.key.index.compareTo(b.key.index);
        });
    final List<int> percentages = _allocatePercentages(
      sorted.map((entry) => entry.value).toList(growable: false),
      total.minorUnits,
    );
    final List<CategoryActivityRecord> records =
        List<CategoryActivityRecord>.generate(
          sorted.length,
          (int index) => CategoryActivityRecord(
            category: sorted[index].key,
            amount: sorted[index].value,
            sharePercentage: percentages[index],
            transactionCount: counts[sorted[index].key]!,
          ),
          growable: false,
        );
    return MonthlyCategoryActivity(
      month: period.startAdInclusive,
      type: type,
      total: total,
      transactionCount: activityCount,
      records: List<CategoryActivityRecord>.unmodifiable(records),
      groups: _groupRecords(records),
    );
  }

  CategoryActivityDetails calculateForCategories({
    required List<FinancialTransaction> transactions,
    required DateTime month,
    required TransactionType type,
    required List<TransactionCategory> categories,
    List<FinancialTransfer> transfers = const <FinancialTransfer>[],
  }) => calculateForCategoriesInPeriod(
    transactions: transactions,
    transfers: transfers,
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

  CategoryActivityDetails calculateForCategoriesInPeriod({
    required List<FinancialTransaction> transactions,
    required CalendarPeriod period,
    required TransactionType type,
    required List<TransactionCategory> categories,
    List<FinancialTransfer> transfers = const <FinancialTransfer>[],
  }) {
    if (categories.isEmpty) {
      throw ArgumentError.value(
        categories,
        'categories',
        'At least one category is required.',
      );
    }
    final Set<TransactionCategory> selected = categories.toSet();
    final MonthlyCategoryActivity monthly = calculateForPeriod(
      transactions: transactions,
      transfers: transfers,
      period: period,
      type: type,
    );
    final List<FinancialActivity> activities = <FinancialActivity>[
      ...transactions.map(TransactionActivity.new),
      ...transfers.map(TransferActivity.new),
    ];
    const FinancialEffectService effects = FinancialEffectService();
    final List<CategoryActivityItem> items = <CategoryActivityItem>[];
    Money total = const Money.zero();
    for (final FinancialActivity activity in activities) {
      if (!period.contains(activity.occurredAt)) continue;
      final FinancialEffect effect = effects.forActivity(activity);
      Money contribution = const Money.zero();
      if (type == TransactionType.income && activity is TransactionActivity) {
        if (selected.contains(activity.transaction.category)) {
          contribution = effect.incomeImpact;
        }
      } else if (type == TransactionType.expense) {
        for (final TransactionCategory category in selected) {
          contribution +=
              effect.expenseCategoryContributions[category] ??
              const Money.zero();
        }
      }
      if (!contribution.isPositive) continue;
      total += contribution;
      items.add(
        CategoryActivityItem(activity: activity, contribution: contribution),
      );
    }
    items.sort((a, b) {
      final int occurred = b.activity.occurredAt.compareTo(
        a.activity.occurredAt,
      );
      return occurred != 0
          ? occurred
          : b.activity.createdAt.compareTo(a.activity.createdAt);
    });
    int percentage = 0;
    for (final CategoryActivityRecord record in monthly.records) {
      if (selected.contains(record.category)) {
        percentage += record.sharePercentage;
      }
    }
    final Money? average = items.isEmpty
        ? null
        : Money(
            minorUnits: (total.minorUnits + items.length ~/ 2) ~/ items.length,
            currencyCode: total.currencyCode,
          );
    return CategoryActivityDetails(
      month: monthly.month,
      type: type,
      includedCategories: List<TransactionCategory>.unmodifiable(selected),
      total: total,
      relevantMonthlyTotal: monthly.total,
      sharePercentage: percentage,
      items: List<CategoryActivityItem>.unmodifiable(items),
      averageTransaction: average,
    );
  }

  List<int> _allocatePercentages(List<Money> amounts, int totalMinorUnits) {
    if (amounts.isEmpty || totalMinorUnits <= 0) {
      return List<int>.filled(amounts.length, 0, growable: false);
    }
    final List<int> result = List<int>.filled(amounts.length, 0);
    final List<int> remainders = List<int>.filled(amounts.length, 0);
    int allocated = 0;
    for (int i = 0; i < amounts.length; i += 1) {
      final int scaled = amounts[i].minorUnits * 100;
      result[i] = scaled ~/ totalMinorUnits;
      remainders[i] = scaled % totalMinorUnits;
      allocated += result[i];
    }
    final List<int> order = List<int>.generate(amounts.length, (i) => i)
      ..sort((a, b) {
        final int remainder = remainders[b].compareTo(remainders[a]);
        return remainder != 0 ? remainder : a.compareTo(b);
      });
    for (int i = 0; i < 100 - allocated; i += 1) {
      result[order[i]] += 1;
    }
    return List<int>.unmodifiable(result);
  }

  List<CategoryActivityGroup> _groupRecords(
    List<CategoryActivityRecord> records,
  ) {
    const int maximumMajorCategories = 4;
    if (records.length <= maximumMajorCategories) {
      return List<CategoryActivityGroup>.unmodifiable(
        records.map(
          (record) => CategoryActivityGroup(
            category: record.category,
            includedCategories: <TransactionCategory>[record.category],
            amount: record.amount,
            sharePercentage: record.sharePercentage,
            transactionCount: record.transactionCount,
          ),
        ),
      );
    }
    final List<CategoryActivityRecord> major = records
        .where((record) => record.category != TransactionCategory.other)
        .take(maximumMajorCategories)
        .toList(growable: false);
    final List<CategoryActivityGroup> groups = major
        .map(
          (record) => CategoryActivityGroup(
            category: record.category,
            includedCategories: <TransactionCategory>[record.category],
            amount: record.amount,
            sharePercentage: record.sharePercentage,
            transactionCount: record.transactionCount,
          ),
        )
        .toList();
    final List<CategoryActivityRecord> additional = records
        .where((record) => !major.contains(record))
        .toList(growable: false);
    Money otherAmount = const Money.zero();
    int otherPercentage = 0;
    int otherCount = 0;
    for (final CategoryActivityRecord record in additional) {
      otherAmount += record.amount;
      otherPercentage += record.sharePercentage;
      otherCount += record.transactionCount;
    }
    groups.add(
      CategoryActivityGroup(
        category: null,
        includedCategories: List<TransactionCategory>.unmodifiable(
          additional.map((record) => record.category),
        ),
        amount: otherAmount,
        sharePercentage: otherPercentage,
        transactionCount: otherCount,
      ),
    );
    return List<CategoryActivityGroup>.unmodifiable(groups);
  }
}
