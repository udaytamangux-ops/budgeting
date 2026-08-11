import 'package:budgeting_app/app/theme/app_motion.dart';
import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/widgets/primary_button.dart';
import 'package:budgeting_app/features/financial_activity/domain/entities/financial_activity.dart';
import 'package:budgeting_app/features/financial_activity/presentation/controllers/new_activity_type_controller.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/add_transaction_controller.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/last_saved_transaction_controller.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/category_selector.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/quick_date_selector.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/sheet_dismiss_intent_region.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_amount_field.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_amount_pad.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_type_selector.dart';
import 'package:budgeting_app/features/transfers/domain/entities/financial_transfer.dart';
import 'package:budgeting_app/features/transfers/domain/entities/transfer_enums.dart';
import 'package:budgeting_app/features/transfers/presentation/controllers/add_transfer_controller.dart';
import 'package:budgeting_app/features/transfers/presentation/widgets/transfer_endpoint_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class AddTransferScreen extends ConsumerStatefulWidget {
  const AddTransferScreen({super.key});

  @override
  ConsumerState<AddTransferScreen> createState() => _AddTransferScreenState();
}

final class _AddTransferScreenState extends ConsumerState<AddTransferScreen> {
  late final TextEditingController _amountController;
  late final TextEditingController _destinationController;
  late final TextEditingController _feeController;
  late final TextEditingController _noteController;
  final FocusNode _amountFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();
  late String _calculatorExpression;
  late bool _calculatorInteracted;
  late bool _calculatorShowValidationError;
  bool _showAmountPad = false;
  bool _allowPop = false;

  @override
  void initState() {
    super.initState();
    final AddTransferState initial = ref.read(addTransferControllerProvider);
    _amountController = TextEditingController(text: initial.amountInput);
    _destinationController = TextEditingController(
      text: initial.destinationName,
    );
    _feeController = TextEditingController(text: initial.feeInput);
    _noteController = TextEditingController(text: initial.note);
    final NewTransferDraft? draft = ref.read(initialNewTransferDraftProvider);
    _calculatorExpression =
        draft?.calculatorExpression ??
        (initial.amountInput.isEmpty ? '0' : initial.amountInput);
    _calculatorInteracted = draft?.calculatorInteracted ?? false;
    _calculatorShowValidationError =
        draft?.calculatorShowValidationError ?? false;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _destinationController.dispose();
    _feeController.dispose();
    _noteController.dispose();
    _amountFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AddTransferState state = ref.watch(addTransferControllerProvider);
    final AddTransferController controller = ref.read(
      addTransferControllerProvider.notifier,
    );
    final bool isSheet = ref.watch(newTransferSheetModeProvider);
    if (isSheet) {
      ref.listen<AddTransferState>(addTransferControllerProvider, (_, next) {
        ref.read(newTransferDraftSessionProvider.notifier).updateForm(next);
      });
    }
    final List<TransactionCategory> recentCategories =
        ref
            .watch(recentTransactionCategoriesProvider(TransactionType.expense))
            .valueOrNull ??
        const <TransactionCategory>[];
    return PopScope<Object?>(
      canPop: _allowPop || (!_showAmountPad && !state.isSubmitting),
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop && _showAmountPad) _closeAmountPad();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: isSheet ? 'Minimize' : 'Cancel',
            onPressed: state.isSubmitting ? null : _closeForm,
            icon: const Icon(Icons.close),
          ),
          title: Text(
            state.isEditing
                ? 'Edit transfer'
                : state.isRepeatDraft
                ? 'Repeat transfer'
                : 'Add transaction',
          ),
        ),
        body: GestureDetector(
          key: const ValueKey<String>('transfer_amount_pad_outside_region'),
          behavior: HitTestBehavior.translucent,
          onTap: _showAmountPad ? _closeAmountPad : null,
          child: SheetDismissIntentRegion(
            enabled: isSheet && !state.isSubmitting,
            onDismiss: _minimizeSheet,
            child: SafeArea(
              top: false,
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: ListView(
                    controller: _scrollController,
                    key: const ValueKey<String>('add_transfer_form_scroll'),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      AppSpacing.navigationClearance,
                    ),
                    children: <Widget>[
                      if (state.isRepeatDraft) ...<Widget>[
                        const Text(
                          'A new transfer will be created using details from the original.',
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      TransactionTypeSelector.activity(
                        value: FinancialActivityType.transfer,
                        isEnabled: !state.isSubmitting,
                        showTransfer: isSheet,
                        onChanged: (FinancialActivityType value) {
                          if (!isSheet) return;
                          ref
                              .read(newActivityTypeProvider.notifier)
                              .select(value);
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TransactionAmountField(
                        controller: _amountController,
                        focusNode: _amountFocus,
                        isEnabled: !state.isSubmitting,
                        errorText: state.amountError,
                        onChanged: controller.updateAmount,
                        useCustomPad: true,
                        onTap: () {
                          _amountFocus.unfocus();
                          if (!_showAmountPad) {
                            setState(() => _showAmountPad = true);
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TransferSourceSelector(
                        value: state.source,
                        enabled: !state.isSubmitting,
                        onChanged: controller.updateSource,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TransferDestinationSelector(
                        value: state.destination,
                        enabled: !state.isSubmitting,
                        onChanged: (value) {
                          controller.updateDestination(value);
                          if (!value.requiresName) {
                            _destinationController.clear();
                          }
                        },
                      ),
                      if (state.destination.requiresName) ...<Widget>[
                        const SizedBox(height: AppSpacing.md),
                        TextField(
                          key: const ValueKey<String>(
                            'transfer_destination_name',
                          ),
                          controller: _destinationController,
                          enabled: !state.isSubmitting,
                          maxLength: 60,
                          onTap: _closeAmountPad,
                          onChanged: controller.updateDestinationName,
                          decoration: InputDecoration(
                            labelText: state.destination.destinationFieldLabel,
                            errorText: state.destinationNameError,
                            counterText: '',
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      SwitchListTile.adaptive(
                        key: const ValueKey<String>(
                          'transfer_counts_as_expense',
                        ),
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Count as expense'),
                        subtitle: const Text(
                          'Include the transfer amount in recorded expenses.',
                        ),
                        value: state.countsAsExpense,
                        onChanged: state.isSubmitting
                            ? null
                            : controller.updateCountsAsExpense,
                      ),
                      if (state.countsAsExpense) ...<Widget>[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Expense category',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        CategorySelector(
                          type: TransactionType.expense,
                          selectedCategory: state.expenseCategory,
                          recentCategories: recentCategories,
                          isEnabled: !state.isSubmitting,
                          errorText: state.categoryError,
                          onSelected: controller.selectExpenseCategory,
                          onRecentSelected: controller.selectExpenseCategory,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      TextField(
                        key: const ValueKey<String>('transfer_fee_input'),
                        controller: _feeController,
                        enabled: !state.isSubmitting,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d{0,9}(?:\.\d{0,2})?'),
                          ),
                        ],
                        onTap: _closeAmountPad,
                        onChanged: controller.updateFee,
                        decoration: InputDecoration(
                          labelText: 'Transfer fee (optional)',
                          helperText: 'Recorded under Fees & Charges.',
                          errorText: state.feeError,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      QuickDateSelector(
                        date: state.occurredDate,
                        isEnabled: !state.isSubmitting,
                        errorText: state.dateError,
                        onChanged: controller.updateOccurredDate,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        key: const ValueKey<String>('transfer_note_input'),
                        controller: _noteController,
                        enabled: !state.isSubmitting,
                        maxLength: 200,
                        minLines: 2,
                        maxLines: 4,
                        onTap: _closeAmountPad,
                        onChanged: controller.updateNote,
                        decoration: const InputDecoration(
                          labelText: 'Note (optional)',
                          counterText: '',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: AnimatedSwitcher(
          duration: AppMotion.accessibleDuration(context, AppMotion.fast),
          child: _showAmountPad
              ? TransactionAmountPad(
                  key: const ValueKey<String>('bottom_docked_amount_pad'),
                  initialAmount: state.amountInput,
                  initialExpression: _calculatorExpression,
                  initiallyInteracted: _calculatorInteracted,
                  initiallyShowValidationError: _calculatorShowValidationError,
                  onClose: _closeAmountPad,
                  onWorkingStateChanged: (working) {
                    _calculatorExpression = working.expression;
                    _calculatorInteracted = working.interacted;
                    _calculatorShowValidationError =
                        working.showValidationError;
                    if (isSheet) {
                      ref
                          .read(newTransferDraftSessionProvider.notifier)
                          .updateCalculator(
                            form: ref.read(addTransferControllerProvider),
                            expression: working.expression,
                            interacted: working.interacted,
                            showValidationError: working.showValidationError,
                          );
                    }
                  },
                  onDone: (String amount) {
                    _amountController
                      ..text = amount
                      ..selection = TextSelection.collapsed(
                        offset: amount.length,
                      );
                    controller.updateAmount(amount);
                    _closeAmountPad();
                  },
                )
              : _SaveBar(
                  state: state,
                  label: state.isEditing ? 'Save changes' : 'Save transfer',
                  onSave: () => _submit(controller),
                ),
        ),
      ),
    );
  }

  void _closeAmountPad() {
    if (_showAmountPad && mounted) setState(() => _showAmountPad = false);
  }

  void _closeForm() {
    if (_showAmountPad) {
      _closeAmountPad();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _pop();
      });
      return;
    }
    _pop();
  }

  void _minimizeSheet() {
    if (!mounted || _allowPop) return;
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _pop());
  }

  void _pop([FinancialTransfer? transfer]) {
    if (ref.read(newTransferSheetModeProvider)) {
      Navigator.of(
        context,
        rootNavigator: true,
      ).pop(transfer == null ? null : TransferActivity(transfer));
    } else {
      context.pop<FinancialTransfer>(transfer);
    }
  }

  Future<void> _submit(AddTransferController controller) async {
    FocusScope.of(context).unfocus();
    final FinancialTransfer? saved = await controller.submit();
    if (saved == null) return;
    if (ref.read(newTransferSheetModeProvider)) {
      ref.read(newTransferDraftSessionProvider.notifier).clear();
      ref.read(newTransactionDraftSessionProvider.notifier).clear();
    }
    ref
        .read(lastSavedTransactionProvider.notifier)
        .show(TransferActivity(saved));
    if (!mounted) return;
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _pop(saved));
  }
}

final class _SaveBar extends StatelessWidget {
  const _SaveBar({
    required this.state,
    required this.label,
    required this.onSave,
  });

  final AddTransferState state;
  final String label;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: context.appColors.surfacePrimary,
        border: Border(top: BorderSide(color: context.appColors.borderSubtle)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (state.submissionError != null)
              Semantics(liveRegion: true, child: Text(state.submissionError!)),
            PrimaryButton(
              key: const ValueKey<String>('save_transfer_button'),
              label: label,
              isLoading: state.isSubmitting,
              onPressed: state.canSubmit ? onSave : null,
            ),
          ],
        ),
      ),
    ),
  );
}
