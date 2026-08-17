import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/features/access/domain/entities/access_mode.dart';
import 'package:budgeting_app/features/categories/data/repositories/in_memory_custom_category_repository.dart';
import 'package:budgeting_app/features/onboarding/data/repositories/in_memory_onboarding_preference_repository.dart';
import 'package:budgeting_app/features/settings/data/repositories/in_memory_calendar_preference_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';

void main() {
  testWidgets('undecided access still takes priority over onboarding', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(
      tester,
      accessMode: AccessMode.undecided,
      calendarSetupComplete: false,
      onboardingComplete: false,
    );

    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Know where your money went'), findsNothing);
  });

  testWidgets('fresh guest sees three-step onboarding before calendar setup', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(
      tester,
      calendarSetupComplete: false,
      onboardingComplete: false,
    );

    expect(find.text('Know where your money went'), findsOneWidget);
    expect(
      find.textContaining('then see a clear monthly picture'),
      findsOneWidget,
    );
    expect(find.text('Choose your calendar'), findsNothing);
    expect(find.bySemanticsLabel('Step 1 of 3'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Made for everyday money in Nepal'), findsOneWidget);
    expect(find.text('NPR-first'), findsOneWidget);
    expect(find.text('AD + BS'), findsOneWidget);
    expect(find.text('Cash, bank & local wallets'), findsOneWidget);
    expect(find.text('No bank connection required'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Your categories are ready'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('+ more'), findsOneWidget);
    expect(find.text('Add your own category'), findsOneWidget);
    expect(find.text('Start tracking'), findsOneWidget);
    expect(find.text('Skip'), findsNothing);
  });

  testWidgets('Skip completes onboarding and keeps default AD without wizard', (
    WidgetTester tester,
  ) async {
    final onboarding = InMemoryOnboardingPreferenceRepository();
    final calendar = InMemoryCalendarPreferenceRepository(
      initialCalendar: AppCalendarSystem.gregorianAd,
      initialSetupComplete: false,
    );
    addTearDown(onboarding.dispose);
    addTearDown(calendar.dispose);

    await pumpBudgetingApp(
      tester,
      calendarRepository: calendar,
      onboardingRepository: onboarding,
    );
    await tester.tap(find.byKey(const ValueKey<String>('onboarding_skip')));
    await tester.pumpAndSettle();

    expect(find.text('Namaste'), findsOneWidget);
    expect(await onboarding.isCompleted(), isTrue);
    expect(await calendar.isCalendarSetupComplete(), isTrue);
    expect(await calendar.getPrimaryCalendar(), AppCalendarSystem.gregorianAd);
  });

  testWidgets('optional category can be added without leaving step three', (
    WidgetTester tester,
  ) async {
    final categories = InMemoryCustomCategoryRepository();
    addTearDown(categories.dispose);
    await pumpBudgetingApp(
      tester,
      onboardingComplete: false,
      customCategoryRepository: categories,
    );
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    final Finder addCategory = find.byKey(
      const ValueKey<String>('onboarding_add_category'),
    );
    await tester.scrollUntilVisible(
      addCategory,
      120,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(addCategory);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey<String>('custom_category_name')),
      'Fitness',
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('save_custom_category')),
    );
    await tester.pumpAndSettle();

    expect(await categories.getCategories(), hasLength(1));
    expect(find.text('Your categories are ready'), findsOneWidget);
  });

  testWidgets('swipe navigation and Start tracking complete onboarding', (
    WidgetTester tester,
  ) async {
    final onboarding = InMemoryOnboardingPreferenceRepository();
    addTearDown(onboarding.dispose);
    await pumpBudgetingApp(tester, onboardingRepository: onboarding);

    await tester.fling(
      find.byKey(const ValueKey<String>('onboarding_pages')),
      const Offset(-420, 0),
      1000,
    );
    await tester.pumpAndSettle();
    expect(find.text('Made for everyday money in Nepal'), findsOneWidget);
    expect(find.bySemanticsLabel('Step 2 of 3'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start tracking'));
    await tester.pumpAndSettle();

    expect(await onboarding.isCompleted(), isTrue);
    expect(find.text('Namaste'), findsOneWidget);
  });

  testWidgets('onboarding remains bounded at 320px with 2x text', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 920);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pumpBudgetingApp(tester, onboardingComplete: false);
    expect(find.text('Know where your money went'), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(
      tester
          .getSize(find.byKey(const ValueKey<String>('onboarding_skip')))
          .height,
      greaterThanOrEqualTo(48),
    );

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Your categories are ready'), findsOneWidget);
    expect(find.text('Skip'), findsNothing);
    expect(find.text('Start tracking'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('completed users skip onboarding and open the app', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester);

    expect(find.text('Namaste'), findsOneWidget);
    expect(find.text('Know where your money went'), findsNothing);
  });
}
