import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_occurrence.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_rule.dart';
import 'package:budgeting_app/features/settings/domain/entities/app_theme_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';
import '../../../support/test_data.dart';

void main() {
  testWidgets('Transactions opens the intentional recurring empty state', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester);

    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Recurring transactions'));
    await tester.pumpAndSettle();

    expect(find.text('Recurring transactions'), findsOneWidget);
    expect(find.text('No recurring transactions yet'), findsOneWidget);
    expect(
      find.textContaining('review them when they are due'),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('create_first_recurring_rule')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('create_first_recurring_rule')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Create recurring transaction'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('recurring_rule_form')),
      findsOneWidget,
    );
  });

  testWidgets('Home shows only due work and Review preserves the occurrence', (
    WidgetTester tester,
  ) async {
    final occurrence = buildTestRecurringOccurrence();
    await pumpBudgetingApp(
      tester,
      seedRecurringRules: <RecurringTransactionRule>[buildTestRecurringRule()],
      seedRecurringOccurrences: <RecurringTransactionOccurrence>[occurrence],
    );

    await _revealHomeDue(tester);
    expect(find.text('Scheduled transaction waiting'), findsOneWidget);
    expect(find.textContaining('Landlord'), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey<String>('review_scheduled_transactions')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(ValueKey<String>('record_occurrence_${occurrence.id}')),
      findsOneWidget,
    );
    expect(
      find.byKey(ValueKey<String>('skip_occurrence_${occurrence.id}')),
      findsOneWidget,
    );
  });

  testWidgets('creating a due-today rule materializes pending, not money', (
    WidgetTester tester,
  ) async {
    final repository = await pumpBudgetingApp(tester);
    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Recurring transactions'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('create_first_recurring_rule')),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey<String>('amount_input')),
      '1500',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('category_food')));
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('save_recurring_rule')),
      320,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey<String>('save_recurring_rule')));
    await tester.pumpAndSettle();

    expect(find.text('Due · 1'), findsOneWidget);
    expect(find.text('Record transaction'), findsOneWidget);
    expect(find.text('NPR 1,500 · Monthly · AD'), findsNWidgets(2));
    expect((await repository.watchTransactions().first), isEmpty);
  });

  testWidgets('recording a due occurrence creates exactly one transaction', (
    WidgetTester tester,
  ) async {
    final occurrence = buildTestRecurringOccurrence();
    final repository = await pumpBudgetingApp(
      tester,
      seedRecurringRules: <RecurringTransactionRule>[buildTestRecurringRule()],
      seedRecurringOccurrences: <RecurringTransactionOccurrence>[occurrence],
    );
    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Recurring transactions'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(ValueKey<String>('record_occurrence_${occurrence.id}')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Record scheduled transaction'), findsOneWidget);
    expect(find.textContaining('Scheduled from Landlord'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey<String>('amount_input')))
          .controller
          ?.text,
      '25000',
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey<String>('save_transaction_button')),
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('save_transaction_button')),
    );
    await tester.pumpAndSettle();

    expect((await repository.watchTransactions().first), hasLength(1));
    expect(find.text('Record transaction'), findsNothing);
    expect(find.text('Upcoming'), findsOneWidget);
  });

  testWidgets('cancelling record leaves pending and Skip records nothing', (
    WidgetTester tester,
  ) async {
    final occurrence = buildTestRecurringOccurrence();
    final repository = await pumpBudgetingApp(
      tester,
      seedRecurringRules: <RecurringTransactionRule>[buildTestRecurringRule()],
      seedRecurringOccurrences: <RecurringTransactionOccurrence>[occurrence],
    );
    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Recurring transactions'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(ValueKey<String>('record_occurrence_${occurrence.id}')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Record transaction'), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.text('Skip this scheduled occurrence?'), findsOneWidget);
    await tester.tap(find.text('Skip occurrence'));
    await tester.pumpAndSettle();

    expect(find.text('Record transaction'), findsNothing);
    expect((await repository.watchTransactions().first), isEmpty);
    expect(find.text('Upcoming'), findsOneWidget);
  });

  testWidgets('recurring UI supports 320px, dark mode, and 2x text', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await pumpBudgetingApp(
      tester,
      themePreference: AppThemePreference.dark,
      seedRecurringRules: <RecurringTransactionRule>[buildTestRecurringRule()],
      seedRecurringOccurrences: <RecurringTransactionOccurrence>[
        buildTestRecurringOccurrence(),
      ],
    );
    expect(tester.takeException(), isNull, reason: 'Home overflowed');
    await _revealHomeDue(tester);
    await tester.tap(
      find.byKey(const ValueKey<String>('review_scheduled_transactions')),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull, reason: 'Recurring list overflowed');
    expect(find.text('Recurring transactions'), findsOneWidget);
    expect(find.text('Record transaction'), findsOneWidget);
  });

  testWidgets('recurring management remains bounded at 768px and 2x text', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(768, 1024);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pumpBudgetingApp(
      tester,
      seedRecurringRules: <RecurringTransactionRule>[buildTestRecurringRule()],
      seedRecurringOccurrences: <RecurringTransactionOccurrence>[
        buildTestRecurringOccurrence(),
      ],
    );
    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Recurring transactions'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Recurring transactions'), findsOneWidget);
    expect(find.text('Record transaction'), findsOneWidget);
  });
}

Future<void> _revealHomeDue(WidgetTester tester) async {
  final Finder surface = find.byKey(
    const ValueKey<String>('home_scheduled_due_surface'),
  );
  for (int attempt = 0; attempt < 12 && surface.evaluate().isEmpty; attempt++) {
    await tester.drag(
      find.byKey(const ValueKey<String>('home_content')),
      const Offset(0, -180),
    );
    await tester.pump();
  }
  await tester.ensureVisible(surface);
  await tester.ensureVisible(
    find.byKey(const ValueKey<String>('review_scheduled_transactions')),
  );
  await tester.pumpAndSettle();
}
