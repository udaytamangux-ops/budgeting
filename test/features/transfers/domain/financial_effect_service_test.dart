import 'package:budgeting_app/features/financial_activity/domain/entities/financial_activity.dart';
import 'package:budgeting_app/features/financial_activity/domain/services/financial_effect_service.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transfers/domain/entities/transfer_enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/test_data.dart';

void main() {
  const FinancialEffectService service = FinancialEffectService();

  test('transfer endpoints expose stable identifiers and exact choices', () {
    expect(
      TransferSource.values.map((value) => value.stableIdentifier),
      <String>[
        'cash',
        'bank_account',
        'esewa',
        'khalti',
        'ime_pay',
        'other_digital_wallet',
        'other',
      ],
    );
    expect(
      TransferDestination.values.map((value) => value.stableIdentifier),
      <String>[
        'cash',
        'bank_account',
        'esewa',
        'khalti',
        'ime_pay',
        'other_digital_wallet',
        'person',
        'investment',
        'other',
      ],
    );
    expect(
      TransferDestination.values.map((value) => value.stableIdentifier),
      isNot(contains('card')),
    );
    expect(TransferDestination.person.requiresName, isTrue);
    expect(TransferDestination.cash.requiresName, isFalse);
  });

  test('normal transfer has no income or expense impact', () {
    final effect = service.forActivity(TransferActivity(buildTestTransfer()));
    expect(effect.incomeImpact.minorUnits, 0);
    expect(effect.expenseImpact.minorUnits, 0);
    expect(effect.expenseCategoryContributions, isEmpty);
  });

  test('counted transfer and fee contribute exactly once', () {
    final effect = service.forActivity(
      TransferActivity(
        buildTestTransfer(
          minorUnits: 200000,
          countsAsExpense: true,
          expenseCategory: TransactionCategory.family,
          feeMinorUnits: 1000,
        ),
      ),
    );
    expect(effect.incomeImpact.minorUnits, 0);
    expect(effect.expenseImpact.minorUnits, 201000);
    expect(
      effect
          .expenseCategoryContributions[TransactionCategory.family]
          ?.minorUnits,
      200000,
    );
    expect(
      effect
          .expenseCategoryContributions[TransactionCategory.feesAndCharges]
          ?.minorUnits,
      1000,
    );
  });

  test('fee-only transfer contributes only Fees & Charges', () {
    final effect = service.forActivity(
      TransferActivity(buildTestTransfer(feeMinorUnits: 1000)),
    );
    expect(effect.expenseImpact.minorUnits, 1000);
    expect(effect.expenseCategoryContributions, hasLength(1));
    expect(
      effect
          .expenseCategoryContributions[TransactionCategory.feesAndCharges]
          ?.minorUnits,
      1000,
    );
  });
}
