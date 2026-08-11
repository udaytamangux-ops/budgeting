import 'package:budgeting_app/features/access/domain/entities/access_mode.dart';
import 'package:budgeting_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:budgeting_app/features/settings/data/repositories/in_memory_theme_preference_repository.dart';
import 'package:budgeting_app/features/settings/domain/entities/app_theme_preference.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_list_item.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_type_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';

void main() {
  testWidgets('System is the default and follows platform brightness', (
    WidgetTester tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await pumpBudgetingApp(tester);
    expect(_effectiveBrightness(tester), Brightness.dark);

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    await tester.pumpAndSettle();
    expect(_effectiveBrightness(tester), Brightness.light);
  });

  testWidgets('Profile shows System, Light, and Dark with selected semantics', (
    WidgetTester tester,
  ) async {
    final InMemoryThemePreferenceRepository repository =
        InMemoryThemePreferenceRepository();
    addTearDown(repository.dispose);
    await pumpBudgetingApp(tester, themeRepository: repository);
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    final Finder appearance = find.byKey(
      const ValueKey<String>('appearance_setting'),
    );
    await tester.scrollUntilVisible(
      appearance,
      240,
      scrollable: _profileScrollable,
    );
    await Scrollable.ensureVisible(
      tester.element(appearance),
      alignment: 0.35,
      duration: Duration.zero,
    );
    await tester.pump();
    await tester.tap(appearance);
    await tester.pumpAndSettle();

    expect(find.text('System'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    final Semantics systemSemantics = tester.widget<Semantics>(
      find
          .ancestor(
            of: find.byKey(const ValueKey<String>('theme_option_system')),
            matching: find.byType(Semantics),
          )
          .first,
    );
    expect(systemSemantics.properties.selected, isTrue);

    await tester.tap(find.byKey(const ValueKey<String>('theme_option_dark')));
    await tester.pumpAndSettle();

    expect(await repository.getThemeMode(), AppThemePreference.dark);
    expect(_effectiveBrightness(tester), Brightness.dark);
    expect(find.text('Dark'), findsOneWidget);
  });

  testWidgets('Dark preference survives app recreation', (
    WidgetTester tester,
  ) async {
    final InMemoryThemePreferenceRepository repository =
        InMemoryThemePreferenceRepository(initialMode: AppThemePreference.dark);
    addTearDown(repository.dispose);
    await pumpBudgetingApp(tester, themeRepository: repository);
    expect(_effectiveBrightness(tester), Brightness.dark);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await pumpBudgetingApp(tester, themeRepository: repository);

    expect(_effectiveBrightness(tester), Brightness.dark);
    expect(find.text('Recorded balance'), findsOneWidget);
  });

  testWidgets('dark theme supports primary screens and account status', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(
      tester,
      useMockTransactions: true,
      themePreference: AppThemePreference.dark,
    );

    expect(_effectiveBrightness(tester), Brightness.dark);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();
    expect(find.text('Transactions'), findsWidgets);
    expect(_effectiveBrightness(tester), Brightness.dark);

    await tester.tap(find.byType(TransactionListItem).first);
    await tester.pumpAndSettle();
    expect(find.text('Transaction details'), findsOneWidget);
    expect(_effectiveBrightness(tester), Brightness.dark);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('central_add_button')));
    await tester.pumpAndSettle();
    expect(find.text('Add transaction'), findsOneWidget);
    expect(_effectiveBrightness(tester), Brightness.dark);
    await tester.tap(
      find.descendant(
        of: find.byType(TransactionTypeSelector),
        matching: find.byKey(const ValueKey<String>('transaction_type_income')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Income source'), findsOneWidget);
    await tester.tap(find.byTooltip('Minimize'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('spending_donut_chart')),
      findsOneWidget,
    );
    final Finder foodRow = find.byKey(
      const ValueKey<String>('summary_category_row_food'),
    );
    final Finder summaryScrollable = find
        .descendant(
          of: find.byKey(const ValueKey<String>('summary_content')),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      foodRow,
      260,
      scrollable: summaryScrollable,
    );
    await Scrollable.ensureVisible(
      tester.element(foodRow),
      alignment: 0.5,
      duration: Duration.zero,
    );
    await tester.pump();
    await tester.tap(foodRow);
    await tester.pumpAndSettle();
    final Finder viewTransactions = find.text('View transactions');
    await tester.scrollUntilVisible(
      viewTransactions,
      180,
      scrollable: summaryScrollable,
    );
    await tester.tap(viewTransactions);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('category_details_content')),
      findsOneWidget,
    );
    expect(_effectiveBrightness(tester), Brightness.dark);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Using without an account'), findsOneWidget);
    expect(_effectiveBrightness(tester), Brightness.dark);
    final Finder privacy = find.byKey(
      const ValueKey<String>('privacy_and_data_setting'),
    );
    await tester.scrollUntilVisible(
      privacy,
      240,
      scrollable: _profileScrollable,
    );
    await Scrollable.ensureVisible(
      tester.element(privacy),
      alignment: 0.4,
      duration: Duration.zero,
    );
    await tester.pump();
    await tester.tap(privacy);
    await tester.pumpAndSettle();
    expect(find.text('Privacy and data'), findsWidgets);
    expect(_effectiveBrightness(tester), Brightness.dark);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dark access and account unavailable screens fit at 320px 2x', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 1100);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pumpBudgetingApp(
      tester,
      accessMode: AccessMode.undecided,
      themePreference: AppThemePreference.dark,
    );
    expect(_effectiveBrightness(tester), Brightness.dark);
    final Finder createAccount = find.byKey(
      const ValueKey<String>('create_account_button'),
    );
    await tester.scrollUntilVisible(
      createAccount,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await Scrollable.ensureVisible(
      tester.element(createAccount),
      alignment: 0.5,
      duration: Duration.zero,
    );
    await tester.pump();
    await tester.tap(createAccount);
    await tester.pumpAndSettle();

    expect(find.text('Account setup is not connected yet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dark access actions meet tap target and contrast guidelines', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 900);
    addTearDown(tester.view.reset);
    final SemanticsHandle semantics = tester.ensureSemantics();

    await pumpBudgetingApp(
      tester,
      accessMode: AccessMode.undecided,
      themePreference: AppThemePreference.dark,
    );

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    semantics.dispose();
  });
}

Brightness _effectiveBrightness(WidgetTester tester) {
  return Theme.of(tester.element(find.byType(Scaffold).first)).brightness;
}

Finder get _profileScrollable => find
    .descendant(
      of: find.byType(ProfileScreen),
      matching: find.byType(Scrollable),
    )
    .first;
