import 'package:budgeting_app/app/theme/app_motion.dart';
import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/widgets/primary_button.dart';
import 'package:budgeting_app/features/financial_activity/domain/entities/financial_activity.dart';
import 'package:budgeting_app/features/financial_activity/presentation/controllers/new_activity_type_controller.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/add_transaction_controller.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/last_saved_transaction_controller.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/category_selector.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/payment_method_selector.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/quick_date_selector.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_amount_field.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_amount_pad.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_type_selector.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_visuals.dart';
import 'package:budgeting_app/features/transfers/presentation/controllers/add_transfer_controller.dart';
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
  final ScrollController _formScrollController = ScrollController();
  late bool _showOptionalFields;
  late String _calculatorExpression;
  late bool _calculatorInteracted;
  late bool _calculatorShowValidationError;
  bool _showAmountPad = false;
  bool _allowSuccessfulPop = false;
  bool _allowSheetMinimize = false;

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
    final NewTransactionDraft? draft = ref.read(
      initialNewTransactionDraftProvider,
    );
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
    _merchantController.dispose();
    _noteController.dispose();
    _amountFocus.dispose();
    _merchantFocus.dispose();
    _noteFocus.dispose();
    _formScrollController.dispose();
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
    final bool isNewTransactionSheet = ref.watch(
      newTransactionSheetModeProvider,
    );
    if (isNewTransactionSheet) {
      ref.listen<AddTransactionState>(addTransactionControllerProvider, (
        AddTransactionState? previous,
        AddTransactionState next,
      ) {
        ref.read(newTransactionDraftSessionProvider.notifier).updateForm(next);
      });
    }
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

    return PopScope<Object?>(
      canPop:
          _allowSuccessfulPop ||
          _allowSheetMinimize ||
          (!_showAmountPad && !state.isSubmitting),
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop && _showAmountPad) {
          _closeAmountPad();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading: IconButton(
            tooltip: isNewTransactionSheet ? 'Minimize' : 'Cancel',
            onPressed: state.isSubmitting ? null : _closeForm,
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
        body: GestureDetector(
          key: const ValueKey<String>('amount_pad_outside_region'),
          behavior: HitTestBehavior.translucent,
          onTap: _showAmountPad ? _closeAmountPad : null,
          child: _SheetDismissIntentRegion(
            enabled: isNewTransactionSheet && !state.isSubmitting,
            onDismiss: _minimizeSheet,
            child: SafeArea(
              top: false,
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: ListView(
                    controller: _formScrollController,
                    key: const ValueKey<String>('add_transaction_form_scroll'),
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
                        Semantics(
                          label:
                              'A new transaction will be created using details from '
                              'the original.',
                          excludeSemantics: true,
                          child: Text(
                            'A new transaction will be created using details from '
                            'the original.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
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
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: context.appColors.textSecondary,
                                ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      TransactionTypeSelector.activity(
                        value: state.type == TransactionType.expense
                            ? FinancialActivityType.expense
                            : FinancialActivityType.income,
                        isEnabled: !state.isSubmitting,
                        showTransfer: isNewTransactionSheet,
                        onChanged: (FinancialActivityType value) {
                          if (value == FinancialActivityType.transfer) {
                            ref
                                .read(newActivityTypeProvider.notifier)
                                .select(value);
                            return;
                          }
                          final TransactionType transactionType =
                              value == FinancialActivityType.income
                              ? TransactionType.income
                              : TransactionType.expense;
                          controller.updateType(transactionType);
                          if (isNewTransactionSheet) {
                            ref
                                .read(newActivityTypeProvider.notifier)
                                .select(value);
                          }
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
                        errorText: state.dateError,
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
                                  padding: const EdgeInsets.only(
                                    top: AppSpacing.xs,
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      TextField(
                                        key: const ValueKey<String>(
                                          'merchant_input',
                                        ),
                                        controller: _merchantController,
                                        focusNode: _merchantFocus,
                                        enabled: !state.isSubmitting,
                                        textInputAction: TextInputAction.next,
                                        onSubmitted: (_) =>
                                            _noteFocus.requestFocus(),
                                        onTap: () {
                                          if (_showAmountPad) {
                                            setState(
                                              () => _showAmountPad = false,
                                            );
                                          }
                                        },
                                        onChanged: controller.updateMerchant,
                                        maxLength: 80,
                                        scrollPadding: const EdgeInsets.only(
                                          bottom:
                                              AppSpacing.navigationClearance,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: merchantLabel,
                                          counterText: '',
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.md),
                                      TextField(
                                        key: const ValueKey<String>(
                                          'note_input',
                                        ),
                                        controller: _noteController,
                                        focusNode: _noteFocus,
                                        enabled: !state.isSubmitting,
                                        textInputAction: TextInputAction.done,
                                        onTap: () {
                                          if (_showAmountPad) {
                                            setState(
                                              () => _showAmountPad = false,
                                            );
                                          }
                                        },
                                        onChanged: controller.updateNote,
                                        maxLength: 200,
                                        minLines: 2,
                                        maxLines: 4,
                                        scrollPadding: const EdgeInsets.only(
                                          bottom:
                                              AppSpacing.navigationClearance,
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
          ),
        ),
        bottomNavigationBar: AnimatedSwitcher(
          duration: AppMotion.accessibleDuration(context, AppMotion.fast),
          switchInCurve: AppMotion.entering,
          switchOutCurve: AppMotion.exiting,
          child: _showAmountPad
              ? TransactionAmountPad(
                  key: const ValueKey<String>('bottom_docked_amount_pad'),
                  initialAmount: state.amountInput,
                  initialExpression: _calculatorExpression,
                  initiallyInteracted: _calculatorInteracted,
                  initiallyShowValidationError: _calculatorShowValidationError,
                  onClose: _closeAmountPad,
                  onWorkingStateChanged:
                      (TransactionAmountWorkingState working) {
                        _calculatorExpression = working.expression;
                        _calculatorInteracted = working.interacted;
                        _calculatorShowValidationError =
                            working.showValidationError;
                        if (isNewTransactionSheet) {
                          ref
                              .read(newTransactionDraftSessionProvider.notifier)
                              .updateCalculator(
                                form: ref.read(
                                  addTransactionControllerProvider,
                                ),
                                expression: working.expression,
                                interacted: working.interacted,
                                showValidationError:
                                    working.showValidationError,
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
              : _buildSaveBar(
                  context,
                  state: state,
                  controller: controller,
                  saveLabel: saveLabel,
                ),
        ),
      ),
    );
  }

  Widget _buildSaveBar(
    BuildContext context, {
    required AddTransactionState state,
    required AddTransactionController controller,
    required String saveLabel,
  }) {
    return SafeArea(
      key: const ValueKey<String>('transaction_save_bar'),
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
                                    color: context.appColors.destructiveAction,
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
    );
  }

  void _closeAmountPad() {
    if (!_showAmountPad || !mounted) {
      return;
    }
    setState(() => _showAmountPad = false);
  }

  void _minimizeSheet() {
    if (!mounted || _allowSheetMinimize) {
      return;
    }
    final NavigatorState rootNavigator = Navigator.of(
      context,
      rootNavigator: true,
    );
    setState(() => _allowSheetMinimize = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      rootNavigator.pop();
    });
  }

  void _closeForm() {
    if (_showAmountPad) {
      setState(() => _showAmountPad = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _popForm();
        }
      });
      return;
    }
    _popForm();
  }

  void _popForm([FinancialTransaction? result]) {
    if (ref.read(newTransactionSheetModeProvider)) {
      Navigator.of(
        context,
        rootNavigator: true,
      ).pop(result == null ? null : TransactionActivity(result));
      return;
    }
    context.pop<FinancialTransaction>(result);
  }

  Future<void> _submit(
    AddTransactionController controller, {
    required bool shouldShowConfirmation,
  }) async {
    FocusScope.of(context).unfocus();
    final NavigatorState rootNavigator = Navigator.of(
      context,
      rootNavigator: true,
    );
    final bool isNewTransactionSheet = ref.read(
      newTransactionSheetModeProvider,
    );
    final NewTransactionDraftSessionController? draftController =
        isNewTransactionSheet
        ? ref.read(newTransactionDraftSessionProvider.notifier)
        : null;
    final FinancialTransaction? saved = await controller.submit();
    if (saved != null) {
      draftController?.clear();
      if (isNewTransactionSheet) {
        ref.read(newTransferDraftSessionProvider.notifier).clear();
      }
      if (!mounted) {
        rootNavigator.pop(saved);
        return;
      }
      if (shouldShowConfirmation) {
        ref.read(lastSavedTransactionProvider.notifier).show(saved);
      }
      setState(() => _allowSuccessfulPop = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _popForm(saved);
        } else {
          rootNavigator.pop(saved);
        }
      });
    }
  }
}

final class _SheetDismissIntentRegion extends StatefulWidget {
  const _SheetDismissIntentRegion({
    required this.enabled,
    required this.onDismiss,
    required this.child,
  });

  final bool enabled;
  final VoidCallback onDismiss;
  final Widget child;

  @override
  State<_SheetDismissIntentRegion> createState() =>
      _SheetDismissIntentRegionState();
}

final class _SheetDismissIntentRegionState
    extends State<_SheetDismissIntentRegion> {
  static const double _topDragDistance = 80;
  static const double _flingMinimumDistance = 48;
  static const double _flingVelocity = 900;
  static const double _verticalDominance = 1.25;

  int? _pointer;
  Offset? _start;
  Duration? _startTime;
  double _startScrollOffset = 0;
  double _latestScrollOffset = 0;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification.metrics.axis == Axis.vertical) {
          _latestScrollOffset = notification.metrics.pixels;
        }
        return false;
      },
      child: Listener(
        key: const ValueKey<String>('sheet_dismiss_intent_region'),
        behavior: HitTestBehavior.translucent,
        onPointerDown: _handlePointerDown,
        onPointerUp: _handlePointerUp,
        onPointerCancel: (_) => _reset(),
        child: widget.child,
      ),
    );
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (!widget.enabled || _pointer != null) {
      return;
    }
    _pointer = event.pointer;
    _start = event.position;
    _startTime = event.timeStamp;
    _startScrollOffset = _latestScrollOffset;
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (event.pointer != _pointer) {
      return;
    }
    final Offset? start = _start;
    final Duration? startTime = _startTime;
    final double startScrollOffset = _startScrollOffset;
    final Duration elapsed = startTime == null
        ? Duration.zero
        : event.timeStamp - startTime;
    _reset();
    if (!widget.enabled || start == null) {
      return;
    }

    final Offset delta = event.position - start;
    final bool displacementIsVertical =
        delta.dy > 0 && delta.dy >= delta.dx.abs() * _verticalDominance;
    final double elapsedSeconds = elapsed.inMicroseconds / 1000000;
    final double averageDownwardVelocity = elapsedSeconds <= 0
        ? 0
        : delta.dy / elapsedSeconds;
    final bool startedAtTop = startScrollOffset <= 0.5;
    final bool topDrag =
        startedAtTop && displacementIsVertical && delta.dy >= _topDragDistance;
    final bool deliberateFling =
        displacementIsVertical &&
        delta.dy >= _flingMinimumDistance &&
        averageDownwardVelocity >= _flingVelocity;
    if (topDrag || deliberateFling) {
      widget.onDismiss();
    }
  }

  void _reset() {
    _pointer = null;
    _start = null;
    _startTime = null;
    _startScrollOffset = 0;
  }
}
