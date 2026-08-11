import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
import 'package:budgeting_app/features/financial_activity/domain/entities/financial_activity.dart';
import 'package:budgeting_app/features/financial_activity/presentation/controllers/new_activity_type_controller.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/add_transaction_controller.dart';
import 'package:budgeting_app/features/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:budgeting_app/features/transfers/presentation/controllers/add_transfer_controller.dart';
import 'package:budgeting_app/features/transfers/presentation/screens/add_transfer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<FinancialActivity?> showNewTransactionSheet({
  required BuildContext context,
  required WidgetRef ref,
  required TransactionType requestedType,
}) {
  final NewTransactionDraft? transactionDraft = ref.read(
    newTransactionDraftSessionProvider,
  );
  final NewTransferDraft? transferDraft = ref.read(
    newTransferDraftSessionProvider,
  );
  if (transactionDraft == null && transferDraft == null) {
    ref
        .read(newActivityTypeProvider.notifier)
        .select(
          requestedType == TransactionType.income
              ? FinancialActivityType.income
              : FinancialActivityType.expense,
        );
  } else if (transferDraft != null && transactionDraft == null) {
    ref
        .read(newActivityTypeProvider.notifier)
        .select(FinancialActivityType.transfer);
  }

  return showModalBottomSheet<FinancialActivity>(
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
    builder: (BuildContext sheetContext) => FractionallySizedBox(
      key: const ValueKey<String>('new_transaction_sheet'),
      heightFactor: 0.94,
      child: Consumer(
        builder: (BuildContext context, WidgetRef ref, _) {
          final FinancialActivityType type = ref.watch(newActivityTypeProvider);
          final NewTransactionDraft? currentTransactionDraft = ref.read(
            newTransactionDraftSessionProvider,
          );
          final NewTransferDraft? currentTransferDraft = ref.read(
            newTransferDraftSessionProvider,
          );
          if (type == FinancialActivityType.transfer) {
            return ProviderScope(
              key: const ValueKey<String>('new_transfer_form_scope'),
              overrides: <Override>[
                transferFormIntentProvider.overrideWithValue(
                  TransferFormIntent.create,
                ),
                newTransferSheetModeProvider.overrideWithValue(true),
                initialNewTransferDraftProvider.overrideWithValue(
                  currentTransferDraft,
                ),
              ],
              child: const AddTransferScreen(),
            );
          }
          final TransactionType transactionType =
              type == FinancialActivityType.income
              ? TransactionType.income
              : TransactionType.expense;
          return ProviderScope(
            key: ValueKey<String>('new_${transactionType.name}_form_scope'),
            overrides: <Override>[
              initialTransactionTypeProvider.overrideWithValue(
                currentTransactionDraft?.form.type ?? transactionType,
              ),
              transactionFormIntentProvider.overrideWithValue(
                TransactionFormIntent.create,
              ),
              newTransactionSheetModeProvider.overrideWithValue(true),
              initialNewTransactionDraftProvider.overrideWithValue(
                currentTransactionDraft,
              ),
            ],
            child: const AddTransactionScreen(),
          );
        },
      ),
    ),
  );
}
