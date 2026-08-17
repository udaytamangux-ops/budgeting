import 'dart:ui' show Tristate;

import 'package:budgeting_app/core/database/app_database.dart'
    hide CustomCategory;
import 'package:budgeting_app/features/categories/data/repositories/drift_custom_category_repository.dart';
import 'package:budgeting_app/features/categories/data/repositories/in_memory_custom_category_repository.dart';
import 'package:budgeting_app/features/categories/domain/entities/custom_category.dart';
import 'package:budgeting_app/features/categories/domain/repositories/custom_category_repository.dart';
import 'package:budgeting_app/features/categories/domain/services/category_catalog.dart';
import 'package:budgeting_app/features/categories/presentation/controllers/category_providers.dart';
import 'package:budgeting_app/features/categories/presentation/screens/categories_screen.dart';
import 'package:budgeting_app/features/transactions/data/repositories/drift_transaction_repository.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';
import '../../../support/test_data.dart';

void main() {
  testWidgets('Add Expense creates and selects a custom category inline', (
    WidgetTester tester,
  ) async {
    final InMemoryCustomCategoryRepository categories =
        InMemoryCustomCategoryRepository(now: () => fixedNow);
    addTearDown(categories.dispose);
    await pumpBudgetingApp(tester, customCategoryRepository: categories);

    await tester.tap(
      find.byKey(const ValueKey<String>('home_add_expense_button')),
    );
    await tester.pumpAndSettle();
    final Finder addCategory = find.byKey(
      const ValueKey<String>('add_custom_category'),
    );
    await _revealInTransactionForm(tester, addCategory);
    await tester.tap(addCategory);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey<String>('custom_category_name')),
      'Gym',
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('save_custom_category')),
    );
    await tester.pumpAndSettle();

    final Finder selected = find.byKey(
      const ValueKey<String>('category_custom:test-1'),
    );
    expect(find.text('Gym'), findsOneWidget);
    expect(selected, findsOneWidget);
    expect(
      tester.getSemantics(selected).flagsCollection.isSelected,
      Tristate.isTrue,
    );
    expect(await categories.getCategories(), hasLength(1));
  });

  testWidgets('Add Income creates a separate custom source inline', (
    WidgetTester tester,
  ) async {
    final InMemoryCustomCategoryRepository categories =
        InMemoryCustomCategoryRepository(now: () => fixedNow);
    addTearDown(categories.dispose);
    await pumpBudgetingApp(tester, customCategoryRepository: categories);

    await tester.tap(
      find.byKey(const ValueKey<String>('home_add_income_button')),
    );
    await tester.pumpAndSettle();
    final Finder addCategory = find.byKey(
      const ValueKey<String>('add_custom_category'),
    );
    await _revealInTransactionForm(tester, addCategory);
    expect(find.text('Add income source'), findsOneWidget);
    await tester.tap(addCategory);
    await tester.pumpAndSettle();
    expect(find.text('Income source name'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey<String>('custom_category_name')),
      'Tutoring',
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('save_custom_category')),
    );
    await tester.pumpAndSettle();

    final Finder selected = find.byKey(
      const ValueKey<String>('category_custom:test-1'),
    );
    expect(find.text('Tutoring'), findsOneWidget);
    expect(
      tester.getSemantics(selected).flagsCollection.isSelected,
      Tristate.isTrue,
    );
    final CustomCategory saved = (await categories.getCategories()).single;
    expect(saved.type, TransactionType.income);
  });

  testWidgets('Profile supports rename, archive and restore lifecycle', (
    WidgetTester tester,
  ) async {
    final CustomCategory gym = CustomCategory(
      id: 'custom:gym',
      type: TransactionType.expense,
      name: 'Gym',
      normalizedName: 'gym',
      iconKey: 'health',
      isArchived: false,
      createdAt: fixedNow,
      updatedAt: fixedNow,
    );
    final InMemoryCustomCategoryRepository categories =
        InMemoryCustomCategoryRepository(
          categories: <CustomCategory>[gym],
          now: () => fixedNow,
        );
    addTearDown(categories.dispose);
    await pumpBudgetingApp(tester, customCategoryRepository: categories);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    final Finder categoriesSetting = find.byKey(
      const ValueKey<String>('categories_setting'),
    );
    await tester.scrollUntilVisible(
      categoriesSetting,
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await Scrollable.ensureVisible(
      tester.element(categoriesSetting),
      alignment: 0.5,
      duration: Duration.zero,
    );
    await tester.pump();
    await tester.tap(categoriesSetting);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Gym'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Gym'), findsOneWidget);
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey<String>('custom_category_name')),
      'Fitness',
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('save_custom_category')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Fitness'), findsOneWidget);

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Archive'));
    await tester.pumpAndSettle();
    expect(find.text('Archived'), findsOneWidget);

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Restore'));
    await tester.pumpAndSettle();
    expect(find.text('Custom'), findsOneWidget);

    final CustomCategory restored = (await categories.getById('custom:gym'))!;
    expect(restored.name, 'Fitness');
    expect(restored.isArchived, isFalse);
  });

  testWidgets('built-in rows are concise and Add belongs to Your categories', (
    WidgetTester tester,
  ) async {
    final InMemoryCustomCategoryRepository categories =
        InMemoryCustomCategoryRepository();
    addTearDown(categories.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          customCategoryRepositoryProvider.overrideWithValue(categories),
        ],
        child: const MaterialApp(home: CategoriesScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Built-in category'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Your categories'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Your categories'), findsOneWidget);
    final Finder addAction = find.byKey(
      const ValueKey<String>('add_category_action'),
    );
    expect(addAction, findsOneWidget);
    expect(tester.getSize(addAction).height, greaterThanOrEqualTo(48));
    expect(find.text('No custom categories yet.'), findsOneWidget);
  });

  testWidgets('archived category menus hide impossible deletion when used', (
    WidgetTester tester,
  ) async {
    final List<CustomCategory> archived = <CustomCategory>[
      CustomCategory(
        id: 'custom:used',
        type: TransactionType.expense,
        name: 'Used archived',
        normalizedName: 'used archived',
        iconKey: 'other',
        isArchived: true,
        createdAt: fixedNow,
        updatedAt: fixedNow,
      ),
      CustomCategory(
        id: 'custom:unused',
        type: TransactionType.expense,
        name: 'Unused archived',
        normalizedName: 'unused archived',
        iconKey: 'other',
        isArchived: true,
        createdAt: fixedNow,
        updatedAt: fixedNow,
      ),
    ];
    final InMemoryCustomCategoryRepository categories =
        InMemoryCustomCategoryRepository(
          categories: archived,
          usedIds: const <String>{'custom:used'},
        );
    addTearDown(categories.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          customCategoryRepositoryProvider.overrideWithValue(categories),
        ],
        child: const MaterialApp(home: CategoriesScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final Finder usedMenu = find.byKey(
      const ValueKey<String>('manage_menu_custom:used'),
    );
    await tester.scrollUntilVisible(
      usedMenu,
      280,
      scrollable: find.byType(Scrollable).first,
    );
    await Scrollable.ensureVisible(
      tester.element(usedMenu),
      alignment: 0.5,
      duration: Duration.zero,
    );
    await tester.pump();
    await tester.tap(usedMenu);
    await tester.pumpAndSettle();
    expect(find.text('Restore'), findsOneWidget);
    expect(find.text('Delete permanently'), findsNothing);
    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();

    final Finder unusedMenu = find.byKey(
      const ValueKey<String>('manage_menu_custom:unused'),
    );
    await tester.scrollUntilVisible(
      unusedMenu,
      160,
      scrollable: find.byType(Scrollable).first,
    );
    await Scrollable.ensureVisible(
      tester.element(unusedMenu),
      alignment: 0.5,
      duration: Duration.zero,
    );
    await tester.pump();
    await tester.tap(unusedMenu);
    await tester.pumpAndSettle();
    expect(find.text('Restore'), findsOneWidget);
    expect(find.text('Delete permanently'), findsOneWidget);
    expect(
      () => categories.deleteUnused('custom:used'),
      throwsA(isA<CustomCategoryException>()),
    );
  });

  testWidgets('usage menu reacts after a transaction is created and archived', (
    WidgetTester tester,
  ) async {
    final AppDatabase database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    int idSequence = 0;
    final DriftCustomCategoryRepository categories =
        DriftCustomCategoryRepository(
          database,
          now: () => fixedNow,
          createId: () => 'custom:reactive-${idSequence++}',
        );
    final DriftTransactionRepository transactions = DriftTransactionRepository(
      database,
    );
    final CustomCategory used = await categories.create(
      type: TransactionType.expense,
      name: 'Used after opening',
      iconKey: 'other',
    );
    final CustomCategory unused = await categories.create(
      type: TransactionType.expense,
      name: 'Still unused',
      iconKey: 'other',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          customCategoryRepositoryProvider.overrideWithValue(categories),
        ],
        child: const MaterialApp(home: CategoriesScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await transactions.createTransaction(
      buildTestTransaction(
        id: 'uses-reactive-category',
      ).copyWith(category: used.reference),
    );
    await categories.archive(used.id);
    await categories.archive(unused.id);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final Finder usedMenu = find.byKey(
      ValueKey<String>('manage_menu_${used.id}'),
    );
    await tester.scrollUntilVisible(
      usedMenu,
      280,
      scrollable: find.byType(Scrollable).first,
    );
    await Scrollable.ensureVisible(
      tester.element(usedMenu),
      alignment: 0.5,
      duration: Duration.zero,
    );
    await tester.pump();
    await tester.tap(usedMenu);
    await tester.pumpAndSettle();
    expect(find.text('Restore'), findsOneWidget);
    expect(find.text('Delete permanently'), findsNothing);
    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();

    final Finder unusedMenu = find.byKey(
      ValueKey<String>('manage_menu_${unused.id}'),
    );
    await tester.scrollUntilVisible(
      unusedMenu,
      160,
      scrollable: find.byType(Scrollable).first,
    );
    await Scrollable.ensureVisible(
      tester.element(unusedMenu),
      alignment: 0.5,
      duration: Duration.zero,
    );
    await tester.pump();
    await tester.tap(unusedMenu);
    await tester.pumpAndSettle();
    expect(find.text('Restore'), findsOneWidget);
    expect(find.text('Delete permanently'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pump(Duration.zero);
  });

  testWidgets('active category limit is explained before save', (
    WidgetTester tester,
  ) async {
    final List<CustomCategory> initial = List<CustomCategory>.generate(
      CategoryNameRules.maximumActivePerType,
      (int index) => CustomCategory(
        id: 'custom:$index',
        type: TransactionType.expense,
        name: 'Custom $index',
        normalizedName: 'custom $index',
        iconKey: 'other',
        isArchived: false,
        createdAt: fixedNow,
        updatedAt: fixedNow,
      ),
    );
    final InMemoryCustomCategoryRepository categories =
        InMemoryCustomCategoryRepository(
          categories: initial,
          now: () => fixedNow,
        );
    addTearDown(categories.dispose);
    await pumpBudgetingApp(tester, customCategoryRepository: categories);

    await tester.tap(
      find.byKey(const ValueKey<String>('home_add_expense_button')),
    );
    await tester.pumpAndSettle();
    final Finder addCategory = find.byKey(
      const ValueKey<String>('add_custom_category'),
    );
    await _revealInTransactionForm(tester, addCategory);
    await tester.tap(addCategory);
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('custom_category_limit')),
      findsOneWidget,
    );
    expect(find.text('Custom category limit reached'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey<String>('save_custom_category')),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('archived duplicate offers restoration instead of duplication', (
    WidgetTester tester,
  ) async {
    final CustomCategory archived = CustomCategory(
      id: 'custom:gym',
      type: TransactionType.expense,
      name: 'Gym',
      normalizedName: 'gym',
      iconKey: 'health',
      isArchived: true,
      createdAt: fixedNow,
      updatedAt: fixedNow,
    );
    final InMemoryCustomCategoryRepository categories =
        InMemoryCustomCategoryRepository(
          categories: <CustomCategory>[archived],
          now: () => fixedNow,
        );
    addTearDown(categories.dispose);
    await pumpBudgetingApp(tester, customCategoryRepository: categories);

    await tester.tap(
      find.byKey(const ValueKey<String>('home_add_expense_button')),
    );
    await tester.pumpAndSettle();
    final Finder addCategory = find.byKey(
      const ValueKey<String>('add_custom_category'),
    );
    await _revealInTransactionForm(tester, addCategory);
    await tester.tap(addCategory);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey<String>('custom_category_name')),
      ' gym ',
    );
    await tester.pump();

    expect(
      find.text('Gym already exists in your archived categories.'),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('restore_archived_category')),
    );
    await tester.pumpAndSettle();

    final CustomCategory restored = (await categories.getById('custom:gym'))!;
    expect(restored.isArchived, isFalse);
    expect(await categories.getCategories(), hasLength(1));
    expect(
      find.byKey(const ValueKey<String>('category_custom:gym')),
      findsOneWidget,
    );
  });

  testWidgets('category management supports 320px, dark mode and 2x text', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 920);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final CustomCategory longCategory = CustomCategory(
      id: 'custom:long',
      type: TransactionType.expense,
      name: 'A longer custom category name',
      normalizedName: 'a longer custom category name',
      iconKey: 'other',
      isArchived: true,
      createdAt: fixedNow,
      updatedAt: fixedNow,
    );
    final InMemoryCustomCategoryRepository categories =
        InMemoryCustomCategoryRepository(
          categories: <CustomCategory>[longCategory],
          now: () => fixedNow,
        );
    addTearDown(categories.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          customCategoryRepositoryProvider.overrideWithValue(categories),
        ],
        child: MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.dark,
          home: const CategoriesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('A longer custom category name'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Archived'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _revealInTransactionForm(
  WidgetTester tester,
  Finder target,
) async {
  final Finder scrollable = find
      .descendant(
        of: find.byKey(const ValueKey<String>('add_transaction_form_scroll')),
        matching: find.byType(Scrollable),
      )
      .first;
  await tester.scrollUntilVisible(target, 220, scrollable: scrollable);
  await Scrollable.ensureVisible(
    tester.element(target),
    alignment: 0.45,
    duration: Duration.zero,
  );
  await tester.pumpAndSettle();
}
