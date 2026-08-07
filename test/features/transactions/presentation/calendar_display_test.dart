import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/features/settings/domain/entities/app_theme_preference.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';
import '../../../support/test_data.dart';

void main() {
  testWidgets('BS primary updates Home and Add while retaining AD context', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(
      tester,
      calendarSystem: AppCalendarSystem.bikramSambatBs,
    );

    expect(
      find.textContaining("Here's your Shrawan activity."),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('home_add_expense_button')),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('quick_date_choose')),
      260,
      scrollable: find.byType(Scrollable).first,
    );

    expect(
      find.byKey(const ValueKey<String>('selected_transaction_date')),
      findsOneWidget,
    );
    expect(find.textContaining('Shrawan 2083'), findsWidgets);
    expect(find.text('AD · 4 August 2026'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('quick_date_choose')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('bs_date_picker')),
      findsOneWidget,
    );
    expect(find.text('Select transaction date — BS'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('bs_date_confirm')),
      findsOneWidget,
    );
  });

  testWidgets('Transactions use primary grouping and Details show both dates', (
    WidgetTester tester,
  ) async {
    final FinancialTransaction transaction = buildTestTransaction(
      id: 'calendar-display',
      merchant: 'Calendar display record',
      occurredAt: DateTime.utc(2026, 8, 2, 12),
      createdAt: DateTime.utc(2026, 8, 4, 6, 15),
    );
    await pumpBudgetingApp(
      tester,
      seedTransactions: <FinancialTransaction>[transaction],
      calendarSystem: AppCalendarSystem.bikramSambatBs,
    );

    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Shrawan 2083'), findsWidgets);
    expect(find.text('2 August 2026'), findsNothing);

    await tester.tap(find.text('Calendar display record'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Shrawan 2083'), findsNWidgets(2));
    expect(find.text('AD · 2 August 2026'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('Bikram Sambat.*Gregorian')),
      findsOneWidget,
    );
    final Finder createdRow = find.byKey(
      const ValueKey<String>('transaction_created_row'),
    );
    expect(
      find.descendant(
        of: createdRow,
        matching: find.textContaining('Shrawan 2083'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: createdRow, matching: find.textContaining('August')),
      findsNothing,
    );
    expect(
      find.descendant(
        of: createdRow,
        matching: find.byKey(
          const ValueKey<String>('transaction_date_secondary'),
        ),
      ),
      findsNothing,
    );
  });

  testWidgets('Summary navigates real BS months and keeps category context', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(
      tester,
      seedTransactions: <FinancialTransaction>[
        buildTestTransaction(occurredAt: DateTime.utc(2026, 8, 2, 12)),
      ],
      calendarSystem: AppCalendarSystem.bikramSambatBs,
    );

    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();
    expect(find.text('Shrawan 2083'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey<String>('previous_month_button')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Ashadh 2083'), findsOneWidget);
    expect(find.text('No recorded expenses in Ashadh'), findsOneWidget);
  });

  testWidgets('BS picker fits 320 px, Dark mode, and 2x text', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 1100);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pumpBudgetingApp(
      tester,
      calendarSystem: AppCalendarSystem.bikramSambatBs,
      themePreference: AppThemePreference.dark,
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('home_add_expense_button')),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('quick_date_choose')),
      260,
      scrollable: find.byType(Scrollable).first,
    );
    // The sticky save surface overlaps the bottom of this deliberately narrow,
    // large-text viewport. Move the date control fully above that surface before
    // exercising it so this remains a real hit-testability assertion.
    await tester.drag(find.byType(ListView).first, const Offset(0, -220));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('quick_date_choose')));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('bs_date_confirm')),
      220,
      scrollable: find.byType(Scrollable).last,
    );
    expect(
      find.byKey(const ValueKey<String>('bs_date_confirm')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
