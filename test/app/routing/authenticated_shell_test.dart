import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/pump_app.dart';

void main() {
  testWidgets('floating utility dock exposes selection and switches branches', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await pumpBudgetingApp(tester);

    expect(
      find.byKey(const ValueKey<String>('floating_utility_dock')),
      findsOneWidget,
    );
    expect(
      tester
          .getSemantics(find.byKey(const ValueKey<String>('navigation_home')))
          .flagsCollection
          .isSelected,
      Tristate.isTrue,
    );
    AnimatedAlign indicator = tester.widget<AnimatedAlign>(
      find.byKey(const ValueKey<String>('navigation_active_indicator')),
    );
    expect(indicator.alignment, const Alignment(-1, 0));

    await tester.tap(
      find.byKey(const ValueKey<String>('navigation_transactions')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Transactions'), findsWidgets);
    expect(
      tester
          .getSemantics(
            find.byKey(const ValueKey<String>('navigation_transactions')),
          )
          .flagsCollection
          .isSelected,
      Tristate.isTrue,
    );
    indicator = tester.widget<AnimatedAlign>(
      find.byKey(const ValueKey<String>('navigation_active_indicator')),
    );
    expect(indicator.alignment, const Alignment(-0.5, 0));
    semantics.dispose();
  });

  testWidgets('dock Add action is accessible and opens the existing form', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester);

    final Finder addAction = find.byKey(
      const ValueKey<String>('central_add_button'),
    );
    expect(
      find.bySemanticsLabel('Add transaction from navigation dock'),
      findsOneWidget,
    );
    expect(tester.getSize(addAction), const Size(56, 56));

    await tester.tap(addAction);
    await tester.pumpAndSettle();

    expect(find.text('Add transaction'), findsOneWidget);
  });

  testWidgets('dock motion resolves immediately when motion is reduced', (
    WidgetTester tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await pumpBudgetingApp(tester);

    final AnimatedAlign indicator = tester.widget<AnimatedAlign>(
      find.byKey(const ValueKey<String>('navigation_active_indicator')),
    );
    expect(indicator.duration, Duration.zero);
    expect(
      tester
          .widgetList<AnimatedSlide>(find.byType(AnimatedSlide))
          .every((AnimatedSlide slide) => slide.duration == Duration.zero),
      isTrue,
    );
  });

  testWidgets('dock remains bounded at 320 px with 2x text', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 720);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pumpBudgetingApp(tester);

    expect(tester.takeException(), isNull);
    final Size dockSize = tester.getSize(
      find.byKey(const ValueKey<String>('floating_utility_dock')),
    );
    expect(dockSize.width, lessThan(320));
    expect(dockSize.height, 78);
  });
}
