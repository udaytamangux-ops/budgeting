import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_app.dart';
import '../support/test_data.dart';

void main() {
  const List<double> testedWidths = <double>[320, 360, 390, 430, 480, 768];

  for (final double width in testedWidths) {
    testWidgets('Home and Add Expense do not overflow at ${width.toInt()} px', (
      WidgetTester tester,
    ) async {
      _configureView(tester, width: width);
      await pumpBudgetingApp(tester, useMockTransactions: true);

      expect(tester.takeException(), isNull);
      await tester.tap(
        find.byKey(const ValueKey<String>('home_add_expense_button')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Add transaction'), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('recent_category_food')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }

  for (final double width in testedWidths) {
    testWidgets('primary destinations remain bounded at ${width.toInt()} px', (
      WidgetTester tester,
    ) async {
      _configureView(tester, width: width);
      await pumpBudgetingApp(tester);

      for (final String destination in <String>[
        'Transactions',
        'Summary',
        'Profile',
      ]) {
        await tester.tap(find.text(destination));
        await tester.pumpAndSettle();
        expect(find.text(destination), findsWidgets);
        expect(tester.takeException(), isNull);
      }
    });
  }

  testWidgets('primary flow remains usable with large system text', (
    WidgetTester tester,
  ) async {
    _configureView(tester, width: 320);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pumpBudgetingApp(tester, useMockTransactions: true);
    expect(find.text('NPR 75,650'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey<String>('central_add_button')));
    await tester.pumpAndSettle();
    expect(find.text('Add transaction'), findsOneWidget);
    expect(tester.takeException(), isNull);
    final Finder formScrollable = find
        .descendant(
          of: find.byKey(const ValueKey<String>('add_transaction_form_scroll')),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('recent_category_food')),
      280,
      scrollable: formScrollable,
    );
    expect(
      find.byKey(const ValueKey<String>('recent_category_food')),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('quick_date_today')),
      280,
      scrollable: formScrollable,
    );
    expect(
      find.byKey(const ValueKey<String>('quick_date_choose')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Minimize'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();
    expect(find.text('Period activity'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('recent transactions remain clear of bottom navigation', (
    WidgetTester tester,
  ) async {
    _configureView(tester, width: 320);
    await pumpBudgetingApp(tester, useMockTransactions: true);

    final Finder homeContent = find.byKey(
      const ValueKey<String>('home_content'),
    );
    await tester.drag(homeContent, const Offset(0, -1600));
    await tester.pumpAndSettle();

    final Finder lastTransaction = find.text('Monthly rent');
    expect(lastTransaction, findsOneWidget);

    final double transactionBottom = tester.getBottomRight(lastTransaction).dy;
    final double navigationTop = tester
        .getTopLeft(find.byType(BottomAppBar))
        .dy;
    expect(transactionBottom, lessThanOrEqualTo(navigationTop));
    expect(tester.takeException(), isNull);
  });

  testWidgets('long content and a large NPR amount remain bounded', (
    WidgetTester tester,
  ) async {
    _configureView(tester, width: 320);
    await pumpBudgetingApp(
      tester,
      seedTransactions: <FinancialTransaction>[
        buildTestTransaction(
          id: 'long-content',
          minorUnits: 99999999900,
          category: TransactionCategory.rentAndHousing,
          merchant: 'Kathmandu Metropolitan Household Services and Supplies',
        ),
      ],
    );

    await tester.scrollUntilVisible(
      find.text('Kathmandu Metropolitan Household Services and Supplies'),
      360,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('spending_donut_chart')),
      findsOneWidget,
    );
    await tester.drag(
      find.byKey(const ValueKey<String>('summary_content')),
      const Offset(0, -900),
    );
    await tester.pumpAndSettle();
    expect(find.text('Rent & Housing'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('financial animations resolve immediately with reduced motion', (
    WidgetTester tester,
  ) async {
    _configureView(tester, width: 390);
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await pumpBudgetingApp(tester);
    final Iterable<AnimatedSwitcher> switchers = tester.widgetList(
      find.byType(AnimatedSwitcher),
    );

    expect(switchers, isNotEmpty);
    expect(
      switchers.every(
        (AnimatedSwitcher value) => value.duration == Duration.zero,
      ),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home and Add Expense meet baseline accessibility guidelines', (
    WidgetTester tester,
  ) async {
    _configureView(tester, width: 390);
    final SemanticsHandle semantics = tester.ensureSemantics();
    await pumpBudgetingApp(tester);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    await tester.tap(
      find.byKey(const ValueKey<String>('home_add_expense_button')),
    );
    await tester.pumpAndSettle();
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    semantics.dispose();
  });
}

void _configureView(WidgetTester tester, {required double width}) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 920);
  addTearDown(tester.view.reset);
}
