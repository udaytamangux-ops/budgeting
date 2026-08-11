import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/add_transaction_controller.dart';
import 'package:budgeting_app/features/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<FinancialTransaction?> showNewTransactionSheet({
  required BuildContext context,
  required WidgetRef ref,
  required TransactionType requestedType,
}) {
  final NewTransactionDraft? draft = ref.read(
    newTransactionDraftSessionProvider,
  );
  final TransactionType initialType = draft?.form.type ?? requestedType;
  return showModalBottomSheet<FinancialTransaction>(
    context: context,
    useRootNavigator: true,
    useSafeArea: true,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    showDragHandle: true,
    backgroundColor: context.appColors.surfacePrimary,
    barrierLabel: 'Dismiss Add transaction',
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.large),
      ),
    ),
    clipBehavior: Clip.antiAlias,
    builder: (BuildContext sheetContext) {
      return FractionallySizedBox(
        key: const ValueKey<String>('new_transaction_sheet'),
        heightFactor: 0.94,
        child: ProviderScope(
          overrides: <Override>[
            initialTransactionTypeProvider.overrideWithValue(initialType),
            transactionFormIntentProvider.overrideWithValue(
              TransactionFormIntent.create,
            ),
            newTransactionSheetModeProvider.overrideWithValue(true),
            initialNewTransactionDraftProvider.overrideWithValue(draft),
          ],
          child: const AddTransactionScreen(),
        ),
      );
    },
  );
}
