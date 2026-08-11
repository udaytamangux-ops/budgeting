import 'package:budgeting_app/core/calendar/domain/calendar_period.dart';
import 'package:budgeting_app/features/settings/presentation/controllers/calendar_preference_providers.dart';
import 'package:budgeting_app/features/summary/domain/entities/monthly_category_activity.dart';
import 'package:budgeting_app/features/summary/domain/entities/monthly_transaction_summary.dart';
import 'package:budgeting_app/features/summary/domain/services/category_activity_service.dart';
import 'package:budgeting_app/features/summary/domain/services/transaction_summary_service.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:budgeting_app/features/transfers/presentation/controllers/transfer_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef MonthlyCategoryActivityRequest = ({
  DateTime month,
  TransactionType type,
});

typedef MonthlyCategoryActivityPeriodRequest = ({
  CalendarPeriod period,
  TransactionType type,
});

final class CategoryActivityPeriodDetailsRequest {
  CategoryActivityPeriodDetailsRequest({
    required this.period,
    required this.type,
    required List<TransactionCategory> categories,
  }) : categories = List<TransactionCategory>.unmodifiable(categories);

  final CalendarPeriod period;
  final TransactionType type;
  final List<TransactionCategory> categories;

  @override
  bool operator ==(Object other) {
    if (other is! CategoryActivityPeriodDetailsRequest ||
        period != other.period ||
        type != other.type ||
        categories.length != other.categories.length) {
      return false;
    }
    for (int index = 0; index < categories.length; index += 1) {
      if (categories[index] != other.categories[index]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(period, type, Object.hashAll(categories));
}

final class CategoryActivityDetailsRequest {
  CategoryActivityDetailsRequest({
    required DateTime month,
    required this.type,
    required List<TransactionCategory> categories,
  }) : month = DateTime(month.year, month.month),
       categories = List<TransactionCategory>.unmodifiable(categories);

  final DateTime month;
  final TransactionType type;
  final List<TransactionCategory> categories;

  @override
  bool operator ==(Object other) {
    if (other is! CategoryActivityDetailsRequest ||
        month != other.month ||
        type != other.type ||
        categories.length != other.categories.length) {
      return false;
    }
    for (int index = 0; index < categories.length; index += 1) {
      if (categories[index] != other.categories[index]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(month, type, Object.hashAll(categories));
}

final ProviderFamily<
  AsyncValue<MonthlyCategoryActivity>,
  MonthlyCategoryActivityRequest
>
monthlyCategoryActivityProvider =
    Provider.family<
      AsyncValue<MonthlyCategoryActivity>,
      MonthlyCategoryActivityRequest
    >((Ref ref, request) {
      return ref
          .watch(transactionListProvider)
          .whenData(
            (List<FinancialTransaction> transactions) =>
                const CategoryActivityService().calculateForMonth(
                  transactions: transactions,
                  month: request.month,
                  type: request.type,
                ),
          );
    });

final ProviderFamily<
  AsyncValue<MonthlyCategoryActivity>,
  MonthlyCategoryActivityPeriodRequest
>
monthlyCategoryActivityForPeriodProvider =
    Provider.family<
      AsyncValue<MonthlyCategoryActivity>,
      MonthlyCategoryActivityPeriodRequest
    >((Ref ref, request) {
      final transactions = ref.watch(transactionListProvider);
      final transfers = ref.watch(transferListProvider);
      if (transactions.hasError) {
        return AsyncError(transactions.error!, transactions.stackTrace!);
      }
      if (transfers.hasError) {
        return AsyncError(transfers.error!, transfers.stackTrace!);
      }
      if (transactions.valueOrNull == null || transfers.valueOrNull == null) {
        return const AsyncLoading<MonthlyCategoryActivity>();
      }
      return AsyncData(
        const CategoryActivityService().calculateForPeriod(
          transactions: transactions.valueOrNull!,
          transfers: transfers.valueOrNull!,
          period: request.period,
          type: request.type,
        ),
      );
    });

final ProviderFamily<
  AsyncValue<CategoryActivityDetails>,
  CategoryActivityDetailsRequest
>
categoryActivityDetailsProvider =
    Provider.family<
      AsyncValue<CategoryActivityDetails>,
      CategoryActivityDetailsRequest
    >((Ref ref, request) {
      return ref
          .watch(transactionListProvider)
          .whenData(
            (List<FinancialTransaction> transactions) =>
                const CategoryActivityService().calculateForCategories(
                  transactions: transactions,
                  month: request.month,
                  type: request.type,
                  categories: request.categories,
                ),
          );
    });

final ProviderFamily<
  AsyncValue<CategoryActivityDetails>,
  CategoryActivityPeriodDetailsRequest
>
categoryActivityDetailsForPeriodProvider =
    Provider.family<
      AsyncValue<CategoryActivityDetails>,
      CategoryActivityPeriodDetailsRequest
    >((Ref ref, CategoryActivityPeriodDetailsRequest request) {
      final transactions = ref.watch(transactionListProvider);
      final transfers = ref.watch(transferListProvider);
      if (transactions.hasError) {
        return AsyncError(transactions.error!, transactions.stackTrace!);
      }
      if (transfers.hasError) {
        return AsyncError(transfers.error!, transfers.stackTrace!);
      }
      if (transactions.valueOrNull == null || transfers.valueOrNull == null) {
        return const AsyncLoading<CategoryActivityDetails>();
      }
      return AsyncData(
        const CategoryActivityService().calculateForCategoriesInPeriod(
          transactions: transactions.valueOrNull!,
          transfers: transfers.valueOrNull!,
          period: request.period,
          type: request.type,
          categories: request.categories,
        ),
      );
    });

final ProviderFamily<AsyncValue<MonthlyTransactionSummary>, DateTime>
monthlyTransactionSummaryForMonthProvider =
    Provider.family<AsyncValue<MonthlyTransactionSummary>, DateTime>((
      Ref ref,
      DateTime month,
    ) {
      final AsyncValue<List<FinancialTransaction>> transactions = ref.watch(
        transactionListProvider,
      );
      return transactions.whenData(
        (List<FinancialTransaction> value) => const TransactionSummaryService()
            .calculateForMonth(transactions: value, month: month),
      );
    });

final ProviderFamily<AsyncValue<MonthlyTransactionSummary>, CalendarPeriod>
monthlyTransactionSummaryForPeriodProvider =
    Provider.family<AsyncValue<MonthlyTransactionSummary>, CalendarPeriod>((
      Ref ref,
      CalendarPeriod period,
    ) {
      final transactions = ref.watch(transactionListProvider);
      final transfers = ref.watch(transferListProvider);
      if (transactions.hasError) {
        return AsyncError(transactions.error!, transactions.stackTrace!);
      }
      if (transfers.hasError) {
        return AsyncError(transfers.error!, transfers.stackTrace!);
      }
      if (transactions.valueOrNull == null || transfers.valueOrNull == null) {
        return const AsyncLoading<MonthlyTransactionSummary>();
      }
      return AsyncData(
        const TransactionSummaryService().calculateForPeriod(
          transactions: transactions.valueOrNull!,
          transfers: transfers.valueOrNull!,
          period: period,
        ),
      );
    });

final Provider<AsyncValue<MonthlyTransactionSummary>>
currentMonthlyTransactionSummaryProvider =
    Provider<AsyncValue<MonthlyTransactionSummary>>((Ref ref) {
      final CalendarPeriod currentPeriod = ref.watch(
        currentCalendarPeriodProvider,
      );
      return ref.watch(
        monthlyTransactionSummaryForPeriodProvider(currentPeriod),
      );
    });
