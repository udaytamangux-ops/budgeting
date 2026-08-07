import 'package:budgeting_app/app/app.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/utilities/app_clock.dart';
import 'package:budgeting_app/features/access/data/repositories/in_memory_access_preference_repository.dart';
import 'package:budgeting_app/features/access/domain/entities/access_mode.dart';
import 'package:budgeting_app/features/access/presentation/controllers/access_providers.dart';
import 'package:budgeting_app/features/settings/data/repositories/in_memory_calendar_preference_repository.dart';
import 'package:budgeting_app/features/settings/data/repositories/in_memory_theme_preference_repository.dart';
import 'package:budgeting_app/features/settings/domain/entities/app_theme_preference.dart';
import 'package:budgeting_app/features/settings/presentation/controllers/calendar_preference_providers.dart';
import 'package:budgeting_app/features/settings/presentation/controllers/theme_preference_providers.dart';
import 'package:budgeting_app/features/transactions/data/repositories/in_memory_transaction_repository.dart';
import 'package:budgeting_app/features/transactions/data/sources/mock_transaction_source.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_data.dart';

Future<InMemoryTransactionRepository> pumpBudgetingApp(
  WidgetTester tester, {
  List<FinancialTransaction>? seedTransactions,
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
  if (accessRepository == null) {
    addTearDown(resolvedAccessRepository.dispose);
  }
  if (themeRepository == null) {
    addTearDown(resolvedThemeRepository.dispose);
  }
  if (calendarRepository == null) {
    addTearDown(resolvedCalendarRepository.dispose);
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
    transactionRepositoryProvider.overrideWithValue(repository),
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
