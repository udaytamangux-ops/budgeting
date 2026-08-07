import 'package:budgeting_app/features/access/data/repositories/in_memory_access_preference_repository.dart';
import 'package:budgeting_app/features/access/domain/entities/access_mode.dart';
import 'package:budgeting_app/features/access/presentation/controllers/access_providers.dart';
import 'package:budgeting_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:budgeting_app/features/settings/data/repositories/in_memory_theme_preference_repository.dart';
import 'package:budgeting_app/features/settings/presentation/controllers/theme_preference_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';

void main() {
  testWidgets('Profile shows a neutral local state and honest preferences', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester);
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Using without an account'), findsOneWidget);
    expect(
      find.text('Your records are stored on this device.'),
      findsOneWidget,
    );
    expect(find.text('Aarav Shrestha'), findsNothing);
    expect(find.textContaining('example.com'), findsNothing);
    expect(find.text('AS'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Currency'),
      240,
      scrollable: _profileScrollable,
    );
    expect(find.text('Currency'), findsOneWidget);
    expect(find.textContaining('Nepalese rupee'), findsOneWidget);
    expect(find.text('Date format'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Not available in this version'), findsOneWidget);
    final SwitchListTile notifications = tester.widget<SwitchListTile>(
      find.byKey(const ValueKey<String>('notifications_setting')),
    );
    expect(notifications.onChanged, isNull);

    final Finder privacySetting = find.byKey(
      const ValueKey<String>('privacy_and_data_setting'),
    );
    await tester.scrollUntilVisible(
      privacySetting,
      280,
      scrollable: _profileScrollable,
    );
    await Scrollable.ensureVisible(
      tester.element(privacySetting),
      alignment: 0.5,
      duration: Duration.zero,
    );
    await tester.pump();
    expect(find.text('Review local storage and connections'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Developer information'),
      280,
      scrollable: _profileScrollable,
    );
    expect(find.text('Developer information'), findsOneWidget);
    expect(find.text('Drift / SQLite local database'), findsOneWidget);
    expect(find.text('Debug information'), findsNothing);
    await tester.scrollUntilVisible(
      privacySetting,
      -280,
      scrollable: _profileScrollable,
    );
    await Scrollable.ensureVisible(
      tester.element(privacySetting),
      alignment: 0.5,
      duration: Duration.zero,
    );
    await tester.pump();
    await tester.tap(privacySetting);
    await tester.pumpAndSettle();

    expect(find.text('Privacy and data'), findsWidgets);
    expect(find.text('Stored on this device'), findsOneWidget);
    expect(find.text('No bank connection'), findsOneWidget);
    expect(find.text('No cloud sync'), findsOneWidget);
    expect(find.text('No financial data transmission'), findsOneWidget);
    expect(
      find.textContaining('stored locally on this device'),
      findsOneWidget,
    );
    expect(
      find.textContaining('does not connect to your bank account'),
      findsOneWidget,
    );
    expect(
      find.textContaining('not backed up or synchronised'),
      findsOneWidget,
    );
    expect(
      find.textContaining('No analytics service currently sends'),
      findsOneWidget,
    );

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Using without an account'),
      -280,
      scrollable: _profileScrollable,
    );
    expect(find.text('Using without an account'), findsOneWidget);
  });

  testWidgets('Developer information can be omitted outside debug mode', (
    WidgetTester tester,
  ) async {
    final InMemoryAccessPreferenceRepository accessRepository =
        InMemoryAccessPreferenceRepository(initialMode: AccessMode.guest);
    final InMemoryThemePreferenceRepository themeRepository =
        InMemoryThemePreferenceRepository();
    addTearDown(accessRepository.dispose);
    addTearDown(themeRepository.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          accessPreferenceRepositoryProvider.overrideWithValue(
            accessRepository,
          ),
          themePreferenceRepositoryProvider.overrideWithValue(themeRepository),
        ],
        child: const MaterialApp(
          home: ProfileScreen(showDeveloperInformation: false),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Using without an account'), findsOneWidget);
    expect(find.text('Developer information'), findsNothing);
    expect(find.text('In-memory repository'), findsNothing);
  });

  for (final double width in <double>[320, 768]) {
    testWidgets('Privacy and Data fits ${width.toInt()} px at 2x text', (
      WidgetTester tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 1000);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpBudgetingApp(tester);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      final Finder setting = find.byKey(
        const ValueKey<String>('privacy_and_data_setting'),
      );
      await tester.scrollUntilVisible(
        setting,
        240,
        scrollable: _profileScrollable,
      );
      await Scrollable.ensureVisible(
        tester.element(setting),
        alignment: 0.5,
        duration: Duration.zero,
      );
      await tester.pump();
      await tester.tap(setting);
      await tester.pumpAndSettle();

      expect(find.text('Stored on this device'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

Finder get _profileScrollable => find
    .descendant(
      of: find.byType(ProfileScreen),
      matching: find.byType(Scrollable),
    )
    .first;
