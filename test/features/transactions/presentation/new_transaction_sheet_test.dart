import 'dart:ui' show Tristate;

import 'package:budgeting_app/features/settings/domain/entities/app_theme_preference.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/quick_date_selector.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_type_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';

void main() {
  testWidgets('central Add tap and upward drag open the create sheet', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await pumpBudgetingApp(tester);
    final Finder add = find.byKey(const ValueKey<String>('central_add_button'));

    expect(find.bySemanticsLabel('Add transaction'), findsOneWidget);
    await tester.tap(add);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('new_transaction_sheet')),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Minimize'));
    await tester.pumpAndSettle();

    await tester.drag(add, const Offset(0, -12));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('new_transaction_sheet')),
      findsNothing,
    );
    await tester.drag(add, const Offset(64, 0));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('new_transaction_sheet')),
      findsNothing,
    );

    await tester.drag(add, const Offset(0, -52));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('new_transaction_sheet')),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('Home quick actions open the requested fresh type', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester);

    await tester.tap(
      find.byKey(const ValueKey<String>('home_add_expense_button')),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TransactionTypeSelector>(find.byType(TransactionTypeSelector))
          .value,
      TransactionType.expense,
    );
    await tester.tap(find.byTooltip('Minimize'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey<String>('home_add_income_button')),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TransactionTypeSelector>(find.byType(TransactionTypeSelector))
          .value,
      TransactionType.income,
    );
  });

  testWidgets('downward swipe minimizes and restores the dirty draft', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester);
    await tester.tap(
      find.byKey(const ValueKey<String>('home_add_expense_button')),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey<String>('amount_input')),
      '845.50',
    );
    await tester.tap(find.byKey(const ValueKey<String>('category_food')));
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('payment_method_field')),
      280,
      scrollable: _formScrollable(),
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('payment_method_field')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('eSewa').last);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('quick_date_yesterday')),
    );
    await tester.drag(
      find.byKey(const ValueKey<String>('add_transaction_form_scroll')),
      const Offset(0, -900),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('optional_fields_toggle')),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey<String>('merchant_input')),
      'Neighbourhood shop',
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('note_input')),
      'Shared lunch',
    );

    await tester.fling(
      find.byKey(const ValueKey<String>('sheet_dismiss_intent_region')),
      const Offset(0, 160),
      1300,
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('new_transaction_sheet')),
      findsNothing,
    );

    await tester.tap(find.byKey(const ValueKey<String>('central_add_button')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TransactionTypeSelector>(find.byType(TransactionTypeSelector))
          .value,
      TransactionType.expense,
    );
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey<String>('amount_input')))
          .controller
          ?.text,
      '845.50',
    );
    expect(
      tester
          .getSemantics(find.byKey(const ValueKey<String>('category_food')))
          .flagsCollection
          .isSelected,
      Tristate.isTrue,
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('payment_method_field')),
      280,
      scrollable: _formScrollable(),
    );
    expect(
      tester
          .widget<DropdownButtonFormField<PaymentMethod>>(
            find.byType(DropdownButtonFormField<PaymentMethod>),
          )
          .initialValue,
      PaymentMethod.eSewa,
    );
    final QuickDateSelector date = tester.widget<QuickDateSelector>(
      find.byType(QuickDateSelector),
    );
    expect(date.date.day, 3);
    await tester.drag(
      find.byKey(const ValueKey<String>('add_transaction_form_scroll')),
      const Offset(0, -900),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(
            find.byKey(const ValueKey<String>('merchant_input')),
          )
          .controller
          ?.text,
      'Neighbourhood shop',
    );
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey<String>('note_input')))
          .controller
          ?.text,
      'Shared lunch',
    );
  });

  testWidgets('top drag minimizes from the form surface', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester);
    await tester.tap(find.byKey(const ValueKey<String>('central_add_button')));
    await tester.pumpAndSettle();

    final Rect region = tester.getRect(
      find.byKey(const ValueKey<String>('sheet_dismiss_intent_region')),
    );
    await tester.timedDragFrom(
      Offset(region.left + 8, region.top + 24),
      const Offset(0, 100),
      const Duration(milliseconds: 600),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('new_transaction_sheet')),
      findsNothing,
    );
  });

  testWidgets(
    'slow middle scrolling and non-vertical gestures do not dismiss',
    (WidgetTester tester) async {
      await pumpBudgetingApp(tester);
      await tester.tap(
        find.byKey(const ValueKey<String>('central_add_button')),
      );
      await tester.pumpAndSettle();

      final Finder scrollable = _formScrollable();
      await tester.drag(scrollable, const Offset(0, -700));
      await tester.pumpAndSettle();
      final ScrollPosition position = tester
          .state<ScrollableState>(scrollable)
          .position;
      final double beforeSlowDrag = position.pixels;
      expect(beforeSlowDrag, greaterThan(0));

      final Rect scrollRect = tester.getRect(scrollable);
      final Offset scrollStart = Offset(
        scrollRect.center.dx,
        scrollRect.top + 180,
      );
      await tester.timedDragFrom(
        scrollStart,
        const Offset(0, 120),
        const Duration(milliseconds: 800),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey<String>('new_transaction_sheet')),
        findsOneWidget,
      );
      expect(position.pixels, lessThan(beforeSlowDrag));

      await tester.dragFrom(scrollStart, const Offset(0, 30));
      await tester.pumpAndSettle();
      await tester.dragFrom(scrollStart, const Offset(150, 8));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey<String>('new_transaction_sheet')),
        findsOneWidget,
      );

      position.jumpTo(0);
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey<String>('category_food')));
      await tester.pump();
      expect(
        find.byKey(const ValueKey<String>('new_transaction_sheet')),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey<String>('payment_method_field')),
        240,
        scrollable: scrollable,
      );
      await tester.tap(
        find.byKey(const ValueKey<String>('payment_method_field')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Cash'), findsWidgets);
      expect(
        find.byKey(const ValueKey<String>('new_transaction_sheet')),
        findsOneWidget,
      );
    },
  );

  testWidgets('fast dismiss with calculator open preserves working state', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester);
    final Finder add = find.byKey(const ValueKey<String>('central_add_button'));
    await tester.tap(add);
    await tester.pumpAndSettle();
    final Finder amount = find.byKey(const ValueKey<String>('amount_input'));
    await tester.tap(amount);
    await tester.pumpAndSettle();
    await _tapCalculatorKey(tester, '3');
    await _tapCalculatorKey(tester, '5');
    await _tapCalculatorKey(tester, '0');
    await _tapCalculatorKey(tester, '+');
    expect(find.text('350 +'), findsOneWidget);

    await tester.fling(
      find.byKey(const ValueKey<String>('sheet_dismiss_intent_region')),
      const Offset(0, 140),
      1300,
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('new_transaction_sheet')),
      findsNothing,
    );

    await tester.drag(add, const Offset(0, -52));
    await tester.pumpAndSettle();
    await tester.tap(amount);
    await tester.pumpAndSettle();
    expect(find.text('350 +'), findsOneWidget);
    expect(find.text('Complete the calculation.'), findsNothing);
    await tester.tap(find.bySemanticsLabel('Seven'));
    await tester.pump();
    expect(find.text('NPR 357'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('new_transaction_sheet')),
      findsOneWidget,
    );
  });

  testWidgets('working expression survives outside tap and Android Back', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester);
    await tester.tap(
      find.byKey(const ValueKey<String>('home_add_expense_button')),
    );
    await tester.pumpAndSettle();
    final Finder amount = find.byKey(const ValueKey<String>('amount_input'));
    await tester.tap(amount);
    await tester.pumpAndSettle();
    await _tapCalculatorKey(tester, '3');
    await _tapCalculatorKey(tester, '5');
    await _tapCalculatorKey(tester, '0');
    await _tapCalculatorKey(tester, '+');
    await _tapCalculatorKey(tester, '2');
    await _tapCalculatorKey(tester, '8');
    await _tapCalculatorKey(tester, '0');
    expect(find.text('350 + 280'), findsOneWidget);
    expect(find.text('NPR 630'), findsOneWidget);

    await tester.tapAt(const Offset(8, 220));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('transaction_amount_pad')),
      findsNothing,
    );
    expect(tester.widget<TextField>(amount).controller?.text, isEmpty);

    await tester.tap(amount);
    await tester.pumpAndSettle();
    expect(find.text('350 + 280'), findsOneWidget);
    expect(find.text('NPR 630'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('transaction_amount_pad')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('new_transaction_sheet')),
      findsOneWidget,
    );
    await tester.tap(amount);
    await tester.pumpAndSettle();
    expect(find.text('350 + 280'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('calculator_done')));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(amount).controller?.text, '630');
  });

  testWidgets('successful save clears the session draft', (
    WidgetTester tester,
  ) async {
    final repository = await pumpBudgetingApp(tester);
    await tester.tap(
      find.byKey(const ValueKey<String>('home_add_expense_button')),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey<String>('amount_input')),
      '500',
    );
    await tester.tap(find.byKey(const ValueKey<String>('category_food')));
    await tester.pump();
    expect(
      tester
          .widget<FilledButton>(
            find.descendant(
              of: find.byKey(const ValueKey<String>('save_transaction_button')),
              matching: find.byType(FilledButton),
            ),
          )
          .onPressed,
      isNotNull,
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('save_transaction_button')),
    );
    await tester.pumpAndSettle();
    expect((await repository.watchTransactions().first).length, 1);
    expect(
      find.byKey(const ValueKey<String>('new_transaction_sheet')),
      findsNothing,
    );

    await tester.tap(find.byKey(const ValueKey<String>('central_add_button')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey<String>('amount_input')))
          .controller
          ?.text,
      isEmpty,
    );
    expect(
      tester
          .getSemantics(find.byKey(const ValueKey<String>('category_food')))
          .flagsCollection
          .isSelected,
      isNot(Tristate.isTrue),
    );
  });

  for (final double width in <double>[320, 390, 768]) {
    testWidgets('sheet and keypad fit ${width.toInt()}px at 2x text', (
      WidgetTester tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 1100);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await pumpBudgetingApp(
        tester,
        themePreference: width == 320
            ? AppThemePreference.dark
            : AppThemePreference.light,
      );
      await tester.tap(
        find.byKey(const ValueKey<String>('central_add_button')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey<String>('amount_input')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey<String>('bottom_docked_amount_pad')),
        findsOneWidget,
      );
      final Rect pad = tester.getRect(
        find.byKey(const ValueKey<String>('transaction_amount_pad')),
      );
      final Rect sheet = tester.getRect(
        find.byKey(const ValueKey<String>('new_transaction_sheet')),
      );
      expect(sheet.bottom - pad.bottom, lessThanOrEqualTo(40));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('sheet and calculator respect reduced motion', (
    WidgetTester tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await pumpBudgetingApp(tester);
    await tester.tap(find.byKey(const ValueKey<String>('central_add_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('amount_input')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('transaction_amount_pad')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}

Finder _formScrollable() {
  return find
      .descendant(
        of: find.byKey(const ValueKey<String>('add_transaction_form_scroll')),
        matching: find.byType(Scrollable),
      )
      .first;
}

Future<void> _tapCalculatorKey(WidgetTester tester, String value) async {
  await tester.tap(find.byKey(ValueKey<String>('calculator_key_$value')));
  await tester.pump();
}
