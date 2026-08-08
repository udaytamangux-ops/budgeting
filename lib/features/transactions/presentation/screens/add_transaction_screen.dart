import 'package:budgeting_app/app/theme/app_motion.dart';
import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/widgets/primary_button.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/add_transaction_controller.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/last_saved_transaction_controller.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/category_selector.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/payment_method_selector.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/quick_date_selector.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_amount_field.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_type_selector.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_visuals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

final class _AddTransactionScreenState
    extends ConsumerState<AddTransactionScreen> {
  late final TextEditingController _amountController;
  late final TextEditingController _merchantController;
  late final TextEditingController _noteController;
  final FocusNode _amountFocus = FocusNode();
  final FocusNode _merchantFocus = FocusNode();
  final FocusNode _noteFocus = FocusNode();
  late bool _showOptionalFields;

  @override
  void initState() {
    super.initState();
    final AddTransactionState initial = ref.read(
      addTransactionControllerProvider,
    );
    _amountController = TextEditingController(text: initial.amountInput);
    _merchantController = TextEditingController(text: initial.merchant);
    _noteController = TextEditingController(text: initial.note);
    _showOptionalFields =
        initial.merchant.isNotEmpty || initial.note.isNotEmpty;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    _noteController.dispose();
    _amountFocus.dispose();
    _merchantFocus.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AddTransactionState state = ref.watch(
      addTransactionControllerProvider,
    );
    final AddTransactionController controller = ref.read(
      addTransactionControllerProvider.notifier,
    );
    final recurringOccurrence = ref.watch(initialRecurringOccurrenceProvider);
    final List<TransactionCategory> recentCategories = ref
        .watch(recentTransactionCategoriesProvider(state.type))
        .maybeWhen(
          data: (List<TransactionCategory> categories) => categories,
          orElse: () => const <TransactionCategory>[],
        );
    final List<PaymentMethod> recentPaymentMethods = ref
        .watch(recentPaymentMethodsProvider(state.type))
        .maybeWhen(
          data: (List<PaymentMethod> methods) => methods,
          orElse: () => const <PaymentMethod>[],
        );
    final bool isExpense = state.type == TransactionType.expense;
    final String optionalActionLabel = isExpense
        ? 'Add merchant or note'
        : 'Add payer or note';
    final String merchantLabel = isExpense
        ? 'Merchant (optional)'
        : 'Payer or source (optional)';
    final String saveLabel = state.isEditing
        ? 'Save changes'
        : isExpense
        ? 'Save expense'
        : 'Save income';

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Cancel',
          onPressed: state.isSubmitting ? null : context.pop,
          icon: const Icon(Icons.close),
        ),
        title: Text(
          state.isEditing
              ? 'Edit transaction'
              : state.isRepeatDraft
              ? 'Repeat transaction'
              : state.isRecurringOccurrenceDraft
              ? 'Record scheduled transaction'
              : 'Add transaction',
        ),
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              key: const ValueKey<String>('add_transaction_form_scroll'),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.navigationClearance,
              ),
              children: <Widget>[
                if (state.isRepeatDraft) ...<Widget>[
                  Semantics(
                    label:
                        'A new transaction will be created using details from '
                        'the original.',
                    excludeSemantics: true,
                    child: Text(
                      'A new transaction will be created using details from '
                      'the original.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (state.isRecurringOccurrenceDraft &&
                    recurringOccurrence != null) ...<Widget>[
                  Semantics(
                    label:
                        'Scheduled from ${recurringOccurrence.merchant ?? recurringOccurrence.category.visual.label}',
                    child: Text(
                      'Scheduled from '
                      '${recurringOccurrence.merchant ?? recurringOccurrence.category.visual.label}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                TransactionTypeSelector(
                  value: state.type,
                  isEnabled: !state.isSubmitting,
                  onChanged: controller.updateType,
                ),
                const SizedBox(height: AppSpacing.lg),
                TransactionAmountField(
                  controller: _amountController,
                  focusNode: _amountFocus,
                  isEnabled: !state.isSubmitting,
                  errorText: state.amountError,
                  onChanged: controller.updateAmount,
                ),
                const SizedBox(height: AppSpacing.xl),
                CategorySelector(
                  type: state.type,
                  selectedCategory: state.selectedCategory,
                  recentCategories: recentCategories,
                  isEnabled: !state.isSubmitting,
                  errorText: state.categoryError,
                  onSelected: controller.selectCategory,
                  onRecentSelected: controller.selectRecentCategory,
                ),
                const SizedBox(height: AppSpacing.xl),
                PaymentMethodSelector(
                  type: state.type,
                  value: state.paymentMethod,
                  recentMethods: recentPaymentMethods,
                  isEnabled: !state.isSubmitting,
                  onChanged: controller.updatePaymentMethod,
                  onRecentChanged: controller.selectRecentPaymentMethod,
                ),
                const SizedBox(height: AppSpacing.md),
                QuickDateSelector(
                  date: state.occurredDate,
                  isEnabled: !state.isSubmitting,
                  onChanged: controller.selectQuickDate,
                ),
                const SizedBox(height: AppSpacing.xs),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    key: const ValueKey<String>('optional_fields_toggle'),
                    onPressed: state.isSubmitting
                        ? null
                        : () {
                            setState(() {
                              _showOptionalFields = !_showOptionalFields;
                            });
                          },
                    icon: Icon(
                      _showOptionalFields ? Icons.expand_less : Icons.add,
                    ),
                    label: Text(
                      _showOptionalFields
                          ? 'Hide optional details'
                          : optionalActionLabel,
                    ),
                  ),
                ),
                ClipRect(
                  child: AnimatedSize(
                    duration: AppMotion.accessibleDuration(
                      context,
                      AppMotion.standard,
                    ),
                    curve: AppMotion.emphasized,
                    alignment: Alignment.topCenter,
                    child: _showOptionalFields
                        ? Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.xs),
                            child: Column(
                              children: <Widget>[
                                TextField(
                                  key: const ValueKey<String>('merchant_input'),
                                  controller: _merchantController,
                                  focusNode: _merchantFocus,
                                  enabled: !state.isSubmitting,
                                  textInputAction: TextInputAction.next,
                                  onSubmitted: (_) => _noteFocus.requestFocus(),
                                  onChanged: controller.updateMerchant,
                                  maxLength: 80,
                                  scrollPadding: const EdgeInsets.only(
                                    bottom: AppSpacing.navigationClearance,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: merchantLabel,
                                    counterText: '',
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                TextField(
                                  key: const ValueKey<String>('note_input'),
                                  controller: _noteController,
                                  focusNode: _noteFocus,
                                  enabled: !state.isSubmitting,
                                  textInputAction: TextInputAction.done,
                                  onChanged: controller.updateNote,
                                  maxLength: 200,
                                  minLines: 2,
                                  maxLines: 4,
                                  scrollPadding: const EdgeInsets.only(
                                    bottom: AppSpacing.navigationClearance,
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: 'Note (optional)',
                                    alignLabelWithHint: true,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox(width: double.infinity),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.appColors.surfacePrimary,
            border: Border(
              top: BorderSide(color: context.appColors.borderSubtle),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Center(
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 608),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    AnimatedSize(
                      duration: AppMotion.accessibleDuration(
                        context,
                        AppMotion.fast,
                      ),
                      child: state.submissionError == null
                          ? const SizedBox.shrink()
                          : Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: context.appColors.dangerSubtle,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.small,
                                ),
                              ),
                              child: Semantics(
                                liveRegion: true,
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.error_outline,
                                      color:
                                          context.appColors.destructiveAction,
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Expanded(
                                      child: Text(
                                        state.submissionError!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: context
                                                  .appColors
                                                  .destructiveAction,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                    PrimaryButton(
                      key: const ValueKey<String>('save_transaction_button'),
                      label: saveLabel,
                      isLoading: state.isSubmitting,
                      onPressed: state.canSubmit
                          ? () => _submit(
                              controller,
                              shouldShowConfirmation: !state.isEditing,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(
    AddTransactionController controller, {
    required bool shouldShowConfirmation,
  }) async {
    FocusScope.of(context).unfocus();
    final FinancialTransaction? saved = await controller.submit();
    if (saved != null && mounted) {
      if (shouldShowConfirmation) {
        ref.read(lastSavedTransactionProvider.notifier).show(saved);
      }
      context.pop<FinancialTransaction>(saved);
    }
  }
}
