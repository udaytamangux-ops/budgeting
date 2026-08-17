import 'package:budgeting_app/app/app.dart';
import 'package:budgeting_app/core/calendar/data/bikram_sambat_calendar_service.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/utilities/app_clock.dart';
import 'package:budgeting_app/features/access/data/repositories/in_memory_access_preference_repository.dart';
import 'package:budgeting_app/features/access/domain/entities/access_mode.dart';
import 'package:budgeting_app/features/access/presentation/controllers/access_providers.dart';
import 'package:budgeting_app/features/categories/data/repositories/in_memory_custom_category_repository.dart';
import 'package:budgeting_app/features/categories/domain/entities/custom_category.dart';
import 'package:budgeting_app/features/categories/presentation/controllers/category_providers.dart';
import 'package:budgeting_app/features/money_plan/data/repositories/in_memory_money_plan_repository.dart';
import 'package:budgeting_app/features/money_plan/domain/repositories/money_plan_repository.dart';
import 'package:budgeting_app/features/money_plan/presentation/controllers/money_plan_providers.dart';
import 'package:budgeting_app/features/onboarding/data/repositories/in_memory_onboarding_preference_repository.dart';
import 'package:budgeting_app/features/onboarding/presentation/controllers/onboarding_providers.dart';
import 'package:budgeting_app/features/recurring/data/repositories/in_memory_recurring_transaction_repository.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_occurrence.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_rule.dart';
import 'package:budgeting_app/features/recurring/domain/repositories/recurring_transaction_repository.dart';
import 'package:budgeting_app/features/recurring/domain/services/recurrence_service.dart';
import 'package:budgeting_app/features/recurring/presentation/controllers/recurring_providers.dart';
import 'package:budgeting_app/features/settings/data/repositories/in_memory_calendar_preference_repository.dart';
import 'package:budgeting_app/features/settings/data/repositories/in_memory_theme_preference_repository.dart';
import 'package:budgeting_app/features/settings/domain/entities/app_theme_preference.dart';
import 'package:budgeting_app/features/settings/presentation/controllers/calendar_preference_providers.dart';
import 'package:budgeting_app/features/settings/presentation/controllers/theme_preference_providers.dart';
import 'package:budgeting_app/features/transactions/data/repositories/in_memory_transaction_repository.dart';
import 'package:budgeting_app/features/transactions/data/sources/mock_transaction_source.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:budgeting_app/features/transfers/data/repositories/in_memory_transfer_repository.dart';
import 'package:budgeting_app/features/transfers/domain/entities/financial_transfer.dart';
import 'package:budgeting_app/features/transfers/presentation/controllers/transfer_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_data.dart';

Future<InMemoryTransactionRepository> pumpBudgetingApp(
  WidgetTester tester, {
  List<FinancialTransaction>? seedTransactions,
  List<FinancialTransfer> seedTransfers = const <FinancialTransfer>[],
  bool useMockTransactions = false,
  Stream<List<FinancialTransaction>>? transactionStream,
  Duration operationDelay = Duration.zero,
  AccessMode accessMode = AccessMode.guest,
  AppThemePreference themePreference = AppThemePreference.system,
  InMemoryAccessPreferenceRepository? accessRepository,
  InMemoryThemePreferenceRepository? themeRepository,
  AppCalendarSystem calendarSystem = AppCalendarSystem.gregorianAd,
  bool calendarSetupComplete = true,
  InMemoryCalendarPreferenceRepository? calendarRepository,
  bool onboardingComplete = true,
  InMemoryOnboardingPreferenceRepository? onboardingRepository,
  List<CustomCategory> seedCustomCategories = const <CustomCategory>[],
  InMemoryCustomCategoryRepository? customCategoryRepository,
  RecurringTransactionRepository? recurringRepository,
  List<RecurringTransactionRule> seedRecurringRules =
      const <RecurringTransactionRule>[],
  List<RecurringTransactionOccurrence> seedRecurringOccurrences =
      const <RecurringTransactionOccurrence>[],
  MoneyPlanRepository? moneyPlanRepository,
}) async {
  assert(
    seedTransactions == null || !useMockTransactions,
    'Provide seedTransactions or useMockTransactions, not both.',
  );
  final InMemoryTransactionRepository repository =
      InMemoryTransactionRepository(
        seedTransactions:
            seedTransactions ??
            (useMockTransactions
                ? MockTransactionSource.buildSeedData(fixedNow)
                : const <FinancialTransaction>[]),
        operationDelay: operationDelay,
        now: () => fixedNow,
      );
  final InMemoryTransferRepository transferRepository =
      InMemoryTransferRepository(seedTransfers: seedTransfers);
  final InMemoryAccessPreferenceRepository resolvedAccessRepository =
      accessRepository ??
      InMemoryAccessPreferenceRepository(initialMode: accessMode);
  final InMemoryThemePreferenceRepository resolvedThemeRepository =
      themeRepository ??
      InMemoryThemePreferenceRepository(initialMode: themePreference);
  final InMemoryCalendarPreferenceRepository resolvedCalendarRepository =
      calendarRepository ??
      InMemoryCalendarPreferenceRepository(
        initialCalendar: calendarSystem,
        initialSetupComplete: calendarSetupComplete,
      );
  final InMemoryOnboardingPreferenceRepository resolvedOnboardingRepository =
      onboardingRepository ??
      InMemoryOnboardingPreferenceRepository(
        initialCompleted: onboardingComplete,
      );
  final InMemoryCustomCategoryRepository resolvedCustomCategoryRepository =
      customCategoryRepository ??
      InMemoryCustomCategoryRepository(
        categories: seedCustomCategories,
        now: () => fixedNow,
      );
  final InMemoryRecurringTransactionRepository? ownedRecurringRepository =
      recurringRepository == null
      ? InMemoryRecurringTransactionRepository(
          RecurrenceService(BikramSambatCalendarService()),
          repository,
          rules: seedRecurringRules,
          occurrences: seedRecurringOccurrences,
        )
      : null;
  final RecurringTransactionRepository resolvedRecurringRepository =
      recurringRepository ?? ownedRecurringRepository!;
  final InMemoryMoneyPlanRepository? ownedMoneyPlanRepository =
      moneyPlanRepository == null
      ? InMemoryMoneyPlanRepository(now: () => fixedNow)
      : null;
  final MoneyPlanRepository resolvedMoneyPlanRepository =
      moneyPlanRepository ?? ownedMoneyPlanRepository!;
  if (accessRepository == null) {
    addTearDown(resolvedAccessRepository.dispose);
  }
  if (themeRepository == null) {
    addTearDown(resolvedThemeRepository.dispose);
  }
  if (calendarRepository == null) {
    addTearDown(resolvedCalendarRepository.dispose);
  }
  if (onboardingRepository == null) {
    addTearDown(resolvedOnboardingRepository.dispose);
  }
  if (customCategoryRepository == null) {
    addTearDown(resolvedCustomCategoryRepository.dispose);
  }
  if (ownedRecurringRepository != null) {
    addTearDown(ownedRecurringRepository.dispose);
  }
  if (ownedMoneyPlanRepository != null) {
    addTearDown(ownedMoneyPlanRepository.dispose);
  }
  final List<Override> overrides = <Override>[
    appClockProvider.overrideWithValue(() => fixedNow),
    accessPreferenceRepositoryProvider.overrideWithValue(
      resolvedAccessRepository,
    ),
    themePreferenceRepositoryProvider.overrideWithValue(
      resolvedThemeRepository,
    ),
    calendarPreferenceRepositoryProvider.overrideWithValue(
      resolvedCalendarRepository,
    ),
    onboardingPreferenceRepositoryProvider.overrideWithValue(
      resolvedOnboardingRepository,
    ),
    customCategoryRepositoryProvider.overrideWithValue(
      resolvedCustomCategoryRepository,
    ),
    transactionRepositoryProvider.overrideWithValue(repository),
    transferRepositoryProvider.overrideWithValue(transferRepository),
    recurringTransactionRepositoryProvider.overrideWithValue(
      resolvedRecurringRepository,
    ),
    moneyPlanRepositoryProvider.overrideWithValue(resolvedMoneyPlanRepository),
  ];
  if (transactionStream != null) {
    overrides.add(
      transactionListProvider.overrideWith((Ref ref) => transactionStream),
    );
  }
  await tester.pumpWidget(
    ProviderScope(overrides: overrides, child: const BudgetingApp()),
  );
  await tester.pumpAndSettle();
  return repository;
}
