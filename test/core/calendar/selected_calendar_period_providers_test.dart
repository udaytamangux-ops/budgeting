import 'dart:async';

import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/calendar/presentation/selected_calendar_period_providers.dart';
import 'package:budgeting_app/core/utilities/app_clock.dart';
import 'package:budgeting_app/features/settings/presentation/controllers/calendar_preference_providers.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/test_data.dart';

void main() {
  ProviderContainer containerFor({
    required AppCalendarSystem calendar,
    List<FinancialTransaction> transactions = const <FinancialTransaction>[],
  }) {
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        appClockProvider.overrideWithValue(() => fixedNow),
        primaryCalendarProvider.overrideWith(
          (Ref ref) => Stream<AppCalendarSystem>.value(calendar),
        ),
        transactionListProvider.overrideWith(
          (Ref ref) => Stream<List<FinancialTransaction>>.value(transactions),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('default selected period is the current AD month', () async {
    final ProviderContainer container = containerFor(
      calendar: AppCalendarSystem.gregorianAd,
    );
    await container.read(primaryCalendarProvider.future);
    final period = container.read(selectedCalendarPeriodProvider);
    expect(period.year, 2026);
    expect(period.month, 8);
  });

  test('default selected period is the current real BS month', () async {
    final ProviderContainer container = containerFor(
      calendar: AppCalendarSystem.bikramSambatBs,
    );
    await container.read(primaryCalendarProvider.future);
    final period = container.read(selectedCalendarPeriodProvider);
    expect(period.calendarSystem, AppCalendarSystem.bikramSambatBs);
    expect(period.displayLabel, 'Shrawan 2083');
  });

  test('bounds stop at earliest record and current month normally', () async {
    final ProviderContainer container = containerFor(
      calendar: AppCalendarSystem.gregorianAd,
      transactions: <FinancialTransaction>[
        buildTestTransaction(occurredAt: DateTime.utc(2026, 4, 2, 12)),
      ],
    );
    await container.read(primaryCalendarProvider.future);
    await container.read(transactionListProvider.future);
    final CalendarPeriodBounds bounds = container
        .read(calendarPeriodBoundsProvider)
        .requireValue;
    expect(bounds.earliest.displayLabel, 'April 2026');
    expect(bounds.current.displayLabel, 'August 2026');
    expect(bounds.latest, bounds.current);
    expect(bounds.canGoNext(bounds.current), isFalse);
  });

  test(
    'legacy future record extends navigation without changing data',
    () async {
      final FinancialTransaction legacy = buildTestTransaction(
        id: 'legacy-future',
        occurredAt: DateTime.utc(2026, 11, 2, 12),
      );
      final ProviderContainer container = containerFor(
        calendar: AppCalendarSystem.gregorianAd,
        transactions: <FinancialTransaction>[legacy],
      );
      await container.read(primaryCalendarProvider.future);
      await container.read(transactionListProvider.future);
      final CalendarPeriodBounds bounds = container
          .read(calendarPeriodBoundsProvider)
          .requireValue;
      expect(bounds.latest.displayLabel, 'November 2026');
      expect(bounds.canGoNext(bounds.current), isTrue);
      expect(legacy.occurredAt, DateTime.utc(2026, 11, 2, 12));
    },
  );

  test(
    'calendar preference change resets browsing to new current month',
    () async {
      final StreamController<AppCalendarSystem> calendars =
          StreamController<AppCalendarSystem>();
      addTearDown(calendars.close);
      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          appClockProvider.overrideWithValue(() => fixedNow),
          primaryCalendarProvider.overrideWith((Ref ref) => calendars.stream),
          transactionListProvider.overrideWith(
            (Ref ref) => Stream<List<FinancialTransaction>>.value(
              <FinancialTransaction>[
                buildTestTransaction(occurredAt: DateTime.utc(2026, 4, 2, 12)),
              ],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      calendars.add(AppCalendarSystem.gregorianAd);
      await container.read(primaryCalendarProvider.future);
      final adCurrent = container.read(selectedCalendarPeriodProvider);
      container
          .read(selectedCalendarPeriodProvider.notifier)
          .select(
            container
                .read(appCalendarServiceProvider)
                .previousPeriod(adCurrent),
          );
      calendars.add(AppCalendarSystem.bikramSambatBs);
      await Future<void>.delayed(Duration.zero);
      expect(
        container.read(selectedCalendarPeriodProvider).displayLabel,
        'Shrawan 2083',
      );
    },
  );
}
