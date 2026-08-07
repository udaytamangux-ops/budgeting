import 'package:budgeting_app/app/theme/app_colors.dart';
import 'package:budgeting_app/app/theme/app_theme.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/features/settings/data/repositories/in_memory_calendar_preference_repository.dart';
import 'package:budgeting_app/features/settings/presentation/controllers/calendar_preference_providers.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/test_data.dart';

void main() {
  testWidgets('transaction amounts retain signs without visual type labels', (
    WidgetTester tester,
  ) async {
    final InMemoryCalendarPreferenceRepository calendarRepository =
        InMemoryCalendarPreferenceRepository(
          initialCalendar: AppCalendarSystem.gregorianAd,
          initialSetupComplete: true,
        );
    addTearDown(calendarRepository.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          calendarPreferenceRepositoryProvider.overrideWithValue(
            calendarRepository,
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Column(
              children: <Widget>[
                TransactionListItem(
                  transaction: buildTestTransaction(id: 'expense'),
                  onTap: () {},
                ),
                TransactionListItem(
                  transaction: buildTestTransaction(
                    id: 'income',
                    type: TransactionType.income,
                    category: TransactionCategory.salary,
                    merchant: 'Himalayan Tech Pvt. Ltd.',
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('−NPR 1,250'), findsOneWidget);
    expect(find.text('+NPR 1,250'), findsOneWidget);
    expect(find.text('Expense'), findsNothing);
    expect(find.text('Income'), findsNothing);
    expect(find.bySemanticsLabel(RegExp('Expense, NPR 1,250')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Income, NPR 1,250')), findsOneWidget);

    final Text expenseTitle = tester.widget<Text>(
      find.byKey(const ValueKey<String>('transaction_title_expense')),
    );
    final Text incomeTitle = tester.widget<Text>(
      find.byKey(const ValueKey<String>('transaction_title_income')),
    );
    final Text expenseAmount = tester.widget<Text>(
      find.byKey(const ValueKey<String>('transaction_amount_expense')),
    );
    final Text incomeAmount = tester.widget<Text>(
      find.byKey(const ValueKey<String>('transaction_amount_income')),
    );
    expect(expenseTitle.style?.color, AppColors.textPrimary);
    expect(incomeTitle.style?.color, AppColors.textPrimary);
    expect(expenseAmount.style?.color, AppColors.expenseAccent);
    expect(incomeAmount.style?.color, AppColors.incomeAccent);
    expect(expenseAmount.style?.color, isNot(AppColors.dangerAction));

    final Finder expenseIcon = find.byKey(
      const ValueKey<String>('transaction_category_icon_expense'),
    );
    final Finder incomeIcon = find.byKey(
      const ValueKey<String>('transaction_category_icon_income'),
    );
    expect(tester.getSize(expenseIcon), const Size.square(40));
    expect(tester.getSize(incomeIcon), const Size.square(40));
    expect(
      (tester.widget<Container>(expenseIcon).decoration! as BoxDecoration)
          .shape,
      BoxShape.circle,
    );
    expect(
      (tester.widget<Container>(incomeIcon).decoration! as BoxDecoration).shape,
      BoxShape.circle,
    );
  });
}
