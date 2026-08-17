import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/calendar/domain/calendar_period.dart';
import 'package:budgeting_app/features/financial_activity/domain/entities/financial_activity.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/payment_method_metadata.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_category_metadata.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transfers/domain/entities/transfer_enums.dart';

final class TransactionDateGroup {
  const TransactionDateGroup({required this.date, required this.activities});

  final DateTime date;
  final List<FinancialActivity> activities;

  List<FinancialTransaction> get transactions =>
      List<FinancialTransaction>.unmodifiable(
        activities.whereType<TransactionActivity>().map(
          (TransactionActivity value) => value.transaction,
        ),
      );
}

final class TransactionListFilter {
  const TransactionListFilter();

  List<TransactionDateGroup> apply({
    List<FinancialActivity>? activities,
    List<FinancialTransaction>? transactions,
    DateTime? month,
    CalendarPeriod? period,
    String query = '',
    Object? type,
    String Function(TransactionCategory category)? categoryLabelFor,
  }) {
    if (month == null && period == null) {
      throw ArgumentError('A month or calendar period is required.');
    }
    final CalendarPeriod effectivePeriod =
        period ??
        CalendarPeriod(
          calendarSystem: AppCalendarSystem.gregorianAd,
          year: month!.year,
          month: month.month,
          startAdInclusive: DateTime.utc(month.year, month.month),
          endAdExclusive: DateTime.utc(month.year, month.month + 1),
          displayLabel: '',
        );
    if (activities == null && transactions == null) {
      throw ArgumentError('Activities or transactions are required.');
    }
    final List<FinancialActivity> effectiveActivities =
        activities ??
        transactions!.map(TransactionActivity.new).toList(growable: false);
    final FinancialActivityType? effectiveType = switch (type) {
      final FinancialActivityType value => value,
      TransactionType.expense => FinancialActivityType.expense,
      TransactionType.income => FinancialActivityType.income,
      null => null,
      _ => throw ArgumentError.value(type, 'type'),
    };
    final String normalized = query.trim().toLowerCase();
    final Map<DateTime, List<FinancialActivity>> grouped =
        <DateTime, List<FinancialActivity>>{};
    for (final FinancialActivity activity in effectiveActivities) {
      if (!effectivePeriod.contains(activity.occurredAt)) continue;
      if (effectiveType != null && activity.type != effectiveType) continue;
      if (normalized.isNotEmpty &&
          !_matches(activity, normalized, categoryLabelFor)) {
        continue;
      }
      final DateTime date = activity.occurredAt.toUtc();
      final DateTime day = DateTime.utc(date.year, date.month, date.day);
      grouped.putIfAbsent(day, () => <FinancialActivity>[]).add(activity);
    }
    final List<TransactionDateGroup> result = grouped.entries
        .map((entry) {
          entry.value.sort(_compareActivitiesNewestFirst);
          return TransactionDateGroup(
            date: entry.key,
            activities: List<FinancialActivity>.unmodifiable(entry.value),
          );
        })
        .toList(growable: false);
    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  static int _compareActivitiesNewestFirst(
    FinancialActivity a,
    FinancialActivity b,
  ) {
    final int occurred = b.occurredAt.compareTo(a.occurredAt);
    if (occurred != 0) return occurred;
    final int created = b.createdAt.compareTo(a.createdAt);
    return created != 0 ? created : b.id.compareTo(a.id);
  }

  bool _matches(
    FinancialActivity activity,
    String query,
    String Function(TransactionCategory category)? categoryLabelFor,
  ) => switch (activity) {
    TransactionActivity(:final transaction) => <String?>[
      transaction.merchant,
      transaction.note,
      categoryLabelFor?.call(transaction.category) ??
          transaction.category.displayLabel,
      transaction.paymentMethod.label,
      activity.type.name,
    ].any((value) => value?.toLowerCase().contains(query) ?? false),
    TransferActivity(:final transfer) => <String?>[
      'transfer',
      transfer.source.label,
      transfer.destination.label,
      transfer.destinationName,
      transfer.note,
      transfer.expenseCategory == null
          ? null
          : categoryLabelFor?.call(transfer.expenseCategory!) ??
                transfer.expenseCategory!.displayLabel,
    ].any((value) => value?.toLowerCase().contains(query) ?? false),
  };
}
