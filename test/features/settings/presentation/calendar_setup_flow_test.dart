import 'package:budgeting_app/app/routing/app_routes.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/features/access/data/repositories/in_memory_access_preference_repository.dart';
import 'package:budgeting_app/features/access/domain/entities/access_mode.dart';
import 'package:budgeting_app/features/settings/data/repositories/in_memory_calendar_preference_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../support/pump_app.dart';

void main() {
  testWidgets('undecided access still routes to access before calendar setup', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(
      tester,
      accessMode: AccessMode.undecided,
      calendarSetupComplete: false,
    );

    expect(find.text('Track money your way'), findsOneWidget);
    expect(find.text('Choose your calendar'), findsNothing);
  });

  testWidgets('continuing as guest advances to calendar setup before Home', (
    WidgetTester tester,
  ) async {
    final InMemoryAccessPreferenceRepository accessRepository =
        InMemoryAccessPreferenceRepository();
    final InMemoryCalendarPreferenceRepository calendarRepository =
        InMemoryCalendarPreferenceRepository();
    addTearDown(accessRepository.dispose);
    addTearDown(calendarRepository.dispose);
    await pumpBudgetingApp(
      tester,
      accessRepository: accessRepository,
      calendarRepository: calendarRepository,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('continue_as_guest_button')),
    );
    await tester.pumpAndSettle();

    expect(await accessRepository.getAccessMode(), AccessMode.guest);
    expect(find.text('Choose your calendar'), findsOneWidget);
    expect(find.text('Recorded balance'), findsNothing);
  });

  testWidgets('guest with incomplete setup sees AD preselected once', (
    WidgetTester tester,
  ) async {
    final InMemoryCalendarPreferenceRepository repository =
        InMemoryCalendarPreferenceRepository();
    addTearDown(repository.dispose);
    await pumpBudgetingApp(
      tester,
      calendarRepository: repository,
      calendarSetupComplete: false,
    );

    expect(find.text('Choose your calendar'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('AD — Gregorian.*Selected')),
      findsOneWidget,
    );
    expect(await repository.isCalendarSetupComplete(), isFalse);
    expect(
      await repository.getPrimaryCalendar(),
      AppCalendarSystem.gregorianAd,
    );
  });

  testWidgets('selection persists only when Continue completes setup', (
    WidgetTester tester,
  ) async {
    final InMemoryCalendarPreferenceRepository repository =
        InMemoryCalendarPreferenceRepository();
    addTearDown(repository.dispose);
    await pumpBudgetingApp(tester, calendarRepository: repository);

    await tester.tap(
      find.byKey(
        const ValueKey<String>('calendar_setup_option_bikramSambatBs'),
      ),
    );
    await tester.pump();
    expect(
      await repository.getPrimaryCalendar(),
      AppCalendarSystem.gregorianAd,
    );
    expect(await repository.isCalendarSetupComplete(), isFalse);

    await tester.tap(
      find.byKey(const ValueKey<String>('calendar_setup_continue')),
    );
    await tester.pumpAndSettle();

    expect(await repository.isCalendarSetupComplete(), isTrue);
    expect(
      await repository.getPrimaryCalendar(),
      AppCalendarSystem.bikramSambatBs,
    );
    expect(find.text('Recorded balance'), findsOneWidget);
  });

  testWidgets('returning guest with completed setup skips setup', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(
      tester,
      calendarSystem: AppCalendarSystem.bikramSambatBs,
    );

    expect(find.text('Choose your calendar'), findsNothing);
    expect(find.text('Recorded balance'), findsOneWidget);
  });

  testWidgets('safe deep link resumes after calendar setup', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester, calendarSetupComplete: false);
    final BuildContext context = tester.element(
      find.byKey(const ValueKey<String>('calendar_setup_content')),
    );

    GoRouter.of(context).go(AppRoutes.transactions);
    await tester.pumpAndSettle();
    expect(find.text('Choose your calendar'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey<String>('calendar_setup_continue')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Transactions'), findsWidgets);
  });

  for (final double width in <double>[320, 768]) {
    testWidgets('calendar setup fits ${width.toInt()} px at 2x text', (
      WidgetTester tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 1100);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await pumpBudgetingApp(tester, calendarSetupComplete: false);
      final Finder continueButton = find.byKey(
        const ValueKey<String>('calendar_setup_continue'),
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
}
