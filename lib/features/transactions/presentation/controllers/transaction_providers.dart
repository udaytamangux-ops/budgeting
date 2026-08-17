import 'package:budgeting_app/core/calendar/domain/calendar_period.dart';
import 'package:budgeting_app/core/data/owner_scope.dart';
import 'package:budgeting_app/core/database/database_providers.dart';
import 'package:budgeting_app/features/budgets/domain/entities/budget_configuration.dart';
import 'package:budgeting_app/features/budgets/domain/entities/monthly_budget_summary.dart';
import 'package:budgeting_app/features/budgets/domain/services/budget_summary_service.dart';
import 'package:budgeting_app/features/budgets/presentation/controllers/budget_configuration_controller.dart';
import 'package:budgeting_app/features/categories/presentation/controllers/category_providers.dart';
import 'package:budgeting_app/features/settings/presentation/controllers/calendar_preference_providers.dart';
import 'package:budgeting_app/features/transactions/data/repositories/drift_transaction_repository.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/monthly_financial_summary.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:budgeting_app/features/transactions/domain/services/financial_summary_service.dart';
import 'package:budgeting_app/features/transactions/domain/services/recent_payment_methods_service.dart';
import 'package:budgeting_app/features/transactions/domain/services/recent_transaction_categories_service.dart';
import 'package:budgeting_app/features/transfers/domain/entities/financial_transfer.dart';
import 'package:budgeting_app/features/transfers/presentation/controllers/transfer_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:budgeting_app/core/database/database_providers.dart'
    show appDatabaseProvider;

final Provider<TransactionRepository> transactionRepositoryProvider =
    Provider<TransactionRepository>((Ref ref) {
      return DriftTransactionRepository(
        ref.watch(appDatabaseProvider),
        ownerScope: ref.watch(activeOwnerScopeProvider),
      );
    });

final StreamProvider<List<FinancialTransaction>> transactionListProvider =
    StreamProvider<List<FinancialTransaction>>((Ref ref) {
      return ref.watch(transactionRepositoryProvider).watchTransactions();
    });

final ProviderFamily<AsyncValue<List<TransactionCategory>>, TransactionType>
recentTransactionCategoriesProvider =
    Provider.family<AsyncValue<List<TransactionCategory>>, TransactionType>((
      Ref ref,
      TransactionType type,
    ) {
      return ref
          .watch(transactionListProvider)
          .whenData(
            (List<FinancialTransaction> transactions) =>
                const RecentTransactionCategoriesService()
                    .findForType(transactions: transactions, type: type)
                    .where(
                      (TransactionCategory category) => !ref
                          .watch(categoryCatalogProvider)
                          .resolve(category)
                          .isArchived,
                    )
                    .toList(growable: false),
          );
    });

final ProviderFamily<AsyncValue<List<PaymentMethod>>, TransactionType>
recentPaymentMethodsProvider =
    Provider.family<AsyncValue<List<PaymentMethod>>, TransactionType>((
      Ref ref,
      TransactionType type,
    ) {
      return ref
          .watch(transactionListProvider)
          .whenData(
            (List<FinancialTransaction> transactions) =>
                const RecentPaymentMethodsService().findForType(
                  transactions: transactions,
                  type: type,
                ),
          );
    });

final Provider<AsyncValue<MonthlyFinancialSummary>>
monthlyFinancialSummaryProvider = Provider<AsyncValue<MonthlyFinancialSummary>>(
  (Ref ref) {
    final AsyncValue<List<FinancialTransaction>> transactions = ref.watch(
      transactionListProvider,
    );
    final AsyncValue<List<FinancialTransfer>> transfers = ref.watch(
      transferListProvider,
    );
    final CalendarPeriod currentPeriod = ref.watch(
      currentCalendarPeriodProvider,
    );
    if (transactions.hasError) {
      return AsyncError(transactions.error!, transactions.stackTrace!);
    }
    if (transfers.hasError) {
      return AsyncError(transfers.error!, transfers.stackTrace!);
    }
    final List<FinancialTransaction>? transactionValues =
        transactions.valueOrNull;
    final List<FinancialTransfer>? transferValues = transfers.valueOrNull;
    if (transactionValues == null || transferValues == null) {
      return const AsyncLoading<MonthlyFinancialSummary>();
    }
    return AsyncData<MonthlyFinancialSummary>(
      const FinancialSummaryService().calculateForPeriod(
        transactions: transactionValues,
        transfers: transferValues,
        period: currentPeriod,
      ),
    );
  },
);

final ProviderFamily<AsyncValue<MonthlyBudgetSummary>, DateTime>
monthlyBudgetSummaryForMonthProvider =
    Provider.family<AsyncValue<MonthlyBudgetSummary>, DateTime>((
      Ref ref,
      DateTime month,
    ) {
      final AsyncValue<List<FinancialTransaction>> transactions = ref.watch(
        transactionListProvider,
      );
      final BudgetConfiguration configuration = ref.watch(
        budgetConfigurationProvider,
      );
      return transactions.whenData(
        (List<FinancialTransaction> value) =>
            const BudgetSummaryService().calculateForMonth(
              transactions: value,
              month: month,
              monthlyLimit: configuration.monthlyLimit,
              categoryLimits: configuration.categoryLimits,
            ),
      );
    });

final ProviderFamily<AsyncValue<MonthlyBudgetSummary>, CalendarPeriod>
monthlyBudgetSummaryForPeriodProvider =
    Provider.family<AsyncValue<MonthlyBudgetSummary>, CalendarPeriod>((
      Ref ref,
      CalendarPeriod period,
    ) {
      final AsyncValue<List<FinancialTransaction>> transactions = ref.watch(
        transactionListProvider,
      );
      final BudgetConfiguration configuration = ref.watch(
        budgetConfigurationProvider,
      );
      return transactions.whenData(
        (List<FinancialTransaction> value) =>
            const BudgetSummaryService().calculateForPeriod(
              transactions: value,
              period: period,
              monthlyLimit: configuration.monthlyLimit,
              categoryLimits: configuration.categoryLimits,
            ),
      );
    });

final Provider<AsyncValue<MonthlyBudgetSummary>> monthlyBudgetSummaryProvider =
    Provider<AsyncValue<MonthlyBudgetSummary>>((Ref ref) {
      return ref.watch(
        monthlyBudgetSummaryForPeriodProvider(
          ref.watch(currentCalendarPeriodProvider),
        ),
      );
    });

final ProviderFamily<AsyncValue<FinancialTransaction?>, String>
transactionByIdProvider =
    Provider.family<AsyncValue<FinancialTransaction?>, String>((
      Ref ref,
      String id,
    ) {
      return ref.watch(transactionListProvider).whenData((
        List<FinancialTransaction> transactions,
      ) {
        for (final FinancialTransaction transaction in transactions) {
          if (transaction.id == id) {
            return transaction;
          }
        }
        return null;
      });
    });
