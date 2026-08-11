import 'package:budgeting_app/app/routing/app_routes.dart';
import 'package:budgeting_app/features/access/data/repositories/in_memory_access_preference_repository.dart';
import 'package:budgeting_app/features/access/domain/entities/access_mode.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../support/pump_app.dart';
import '../../../support/test_data.dart';

void main() {
  testWidgets('fresh undecided access shows the honest choice screen', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester, accessMode: AccessMode.undecided);

    expect(find.text('Track money your way'), findsOneWidget);
    expect(find.text('Continue without an account'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Already have an account? Sign in'), findsOneWidget);
    expect(find.bySemanticsLabel('App logo'), findsOneWidget);
    expect(find.textContaining('not backed up to the cloud'), findsOneWidget);
    expect(find.textContaining('Uninstalling the app'), findsOneWidget);
  });

  testWidgets('Continue without an account persists guest and opens Home', (
    WidgetTester tester,
  ) async {
    final InMemoryAccessPreferenceRepository repository =
        InMemoryAccessPreferenceRepository();
    addTearDown(repository.dispose);
    await pumpBudgetingApp(tester, accessRepository: repository);

    await tester.tap(
      find.byKey(const ValueKey<String>('continue_as_guest_button')),
    );
    await tester.pumpAndSettle();

    expect(await repository.getAccessMode(), AccessMode.guest);
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Track money your way'), findsNothing);
  });

  testWidgets('choosing guest does not reset existing local records', (
    WidgetTester tester,
  ) async {
    final FinancialTransaction existing = buildTestTransaction(
      id: 'existing-before-access-choice',
      merchant: 'Existing local record',
    );
    await pumpBudgetingApp(
      tester,
      accessMode: AccessMode.undecided,
      seedTransactions: <FinancialTransaction>[existing],
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('continue_as_guest_button')),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Existing local record'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Existing local record'), findsOneWidget);
  });

  testWidgets('guest mode survives app recreation and skips access choice', (
    WidgetTester tester,
  ) async {
    final InMemoryAccessPreferenceRepository repository =
        InMemoryAccessPreferenceRepository();
    addTearDown(repository.dispose);
    await pumpBudgetingApp(tester, accessRepository: repository);
    await tester.tap(
      find.byKey(const ValueKey<String>('continue_as_guest_button')),
    );
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await pumpBudgetingApp(tester, accessRepository: repository);

    expect(find.text('Track money your way'), findsNothing);
    expect(find.text('Recorded balance'), findsOneWidget);
  });

  testWidgets('Create account and Sign in never enter fake auth', (
    WidgetTester tester,
  ) async {
    final InMemoryAccessPreferenceRepository repository =
        InMemoryAccessPreferenceRepository();
    addTearDown(repository.dispose);
    await pumpBudgetingApp(tester, accessRepository: repository);

    await tester.tap(
      find.byKey(const ValueKey<String>('create_account_button')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Account setup is not connected yet'), findsOneWidget);
    expect(
      find.textContaining('Cloud backup and cross-device sync'),
      findsOneWidget,
    );
    expect(await repository.getAccessMode(), AccessMode.undecided);

    await tester.tap(
      find.byKey(const ValueKey<String>('account_unavailable_back')),
    );
    await tester.pumpAndSettle();
    final Finder signIn = find.byKey(const ValueKey<String>('sign_in_button'));
    await tester.scrollUntilVisible(
      signIn,
      160,
      scrollable: find.byType(Scrollable).first,
    );
    await Scrollable.ensureVisible(
      tester.element(signIn),
      alignment: 0.5,
      duration: Duration.zero,
    );
    await tester.pump();
    await tester.tap(signIn);
    await tester.pumpAndSettle();
    expect(find.text('Account setup is not connected yet'), findsOneWidget);
    expect(await repository.getAccessMode(), AccessMode.undecided);
  });

  testWidgets('undecided deep link resumes its safe destination after guest', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester, accessMode: AccessMode.undecided);
    final BuildContext context = tester.element(
      find.byKey(const ValueKey<String>('access_choice_content')),
    );

    GoRouter.of(context).go(AppRoutes.transactions);
    await tester.pumpAndSettle();
    expect(find.text('Track money your way'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey<String>('continue_as_guest_button')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Transactions'), findsWidgets);
    expect(find.text('No transactions recorded yet'), findsOneWidget);
  });

  for (final double width in <double>[320, 768]) {
    testWidgets('access choice fits ${width.toInt()} px at 2x text', (
      WidgetTester tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 1100);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await pumpBudgetingApp(tester, accessMode: AccessMode.undecided);

      final Finder continueButton = find.byKey(
        const ValueKey<String>('continue_as_guest_button'),
      );
      await tester.scrollUntilVisible(
        continueButton,
        180,
        scrollable: find.byType(Scrollable).first,
      );
      expect(continueButton, findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('guest can use every primary destination without redirects', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester);

    for (final String label in <String>[
      'Transactions',
      'Summary',
      'Profile',
      'Home',
    ]) {
      await tester.tap(find.text(label).last);
      await tester.pumpAndSettle();
      expect(find.text('Track money your way'), findsNothing);
    }
  });

  testWidgets('account unavailable Continue enters guest mode', (
    WidgetTester tester,
  ) async {
    final InMemoryAccessPreferenceRepository repository =
        InMemoryAccessPreferenceRepository();
    addTearDown(repository.dispose);
    await pumpBudgetingApp(tester, accessRepository: repository);
    await tester.tap(
      find.byKey(const ValueKey<String>('create_account_button')),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey<String>('account_unavailable_continue_guest')),
    );
    await tester.pumpAndSettle();

    expect(await repository.getAccessMode(), AccessMode.guest);
    expect(find.text('Recorded balance'), findsOneWidget);
    expect(find.text('Account setup is not connected yet'), findsNothing);
  });
}
