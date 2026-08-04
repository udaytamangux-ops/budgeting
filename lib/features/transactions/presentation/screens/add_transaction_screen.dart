import 'package:budgeting_app/app/theme/app_colors.dart';
import 'package:budgeting_app/app/theme/app_motion.dart';
import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/formatting/formatting_providers.dart';
import 'package:budgeting_app/core/widgets/primary_button.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/add_transaction_controller.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/category_selector.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/payment_method_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  @override
  void initState() {
    super.initState();
    final AddTransactionState initial = ref.read(
      addTransactionControllerProvider,
    );
    _amountController = TextEditingController(text: initial.amountInput);
    _merchantController = TextEditingController(text: initial.merchant);
    _noteController = TextEditingController(text: initial.note);
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
    final String typeLabel = state.type == TransactionType.expense
        ? 'Expense'
        : 'Income';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Cancel',
          onPressed: state.isSubmitting ? null : context.pop,
          icon: const Icon(Icons.close),
        ),
        title: Text(state.isEditing ? 'Edit transaction' : 'Add transaction'),
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                120,
              ),
              children: <Widget>[
                Semantics(
                  label: 'Transaction type, $typeLabel selected',
                  child: SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<TransactionType>(
                      segments: const <ButtonSegment<TransactionType>>[
                        ButtonSegment<TransactionType>(
                          value: TransactionType.expense,
                          label: Text('Expense'),
                          icon: Icon(Icons.remove_circle_outline),
                        ),
                        ButtonSegment<TransactionType>(
                          value: TransactionType.income,
                          label: Text('Income'),
                          icon: Icon(Icons.add_circle_outline),
                        ),
                      ],
                      selected: <TransactionType>{state.type},
                      onSelectionChanged: state.isSubmitting
                          ? null
                          : (Set<TransactionType> selection) {
                              controller.updateType(selection.first);
                            },
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                TextField(
                  key: const ValueKey<String>('amount_input'),
                  controller: _amountController,
                  focusNode: _amountFocus,
                  enabled: !state.isSubmitting,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.done,
                  inputFormatters: <TextInputFormatter>[
                    const TransactionAmountInputFormatter(),
                  ],
                  onChanged: controller.updateAmount,
                  style: Theme.of(context).textTheme.displaySmall,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    helperText: 'Required · NPR',
                    errorText: state.amountError,
                    prefixText: 'NPR ',
                    prefixStyle: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                CategorySelector(
                  type: state.type,
                  selectedCategory: state.selectedCategory,
                  errorText: state.categoryError,
                  onSelected: controller.selectCategory,
                ),
                const SizedBox(height: AppSpacing.xl),
                PaymentMethodSelector(
                  value: state.paymentMethod,
                  onChanged: controller.updatePaymentMethod,
                ),
                const SizedBox(height: AppSpacing.md),
                _DateField(
                  date: state.occurredDate,
                  isEnabled: !state.isSubmitting,
                  onChanged: controller.updateOccurredDate,
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  key: const ValueKey<String>('merchant_input'),
                  controller: _merchantController,
                  focusNode: _merchantFocus,
                  enabled: !state.isSubmitting,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _noteFocus.requestFocus(),
                  onChanged: controller.updateMerchant,
                  maxLength: 80,
                  decoration: const InputDecoration(
                    labelText: 'Merchant',
                    helperText: 'Optional',
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
                  decoration: const InputDecoration(
                    labelText: 'Note',
                    helperText: 'Optional',
                    alignLabelWithHint: true,
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
          decoration: const BoxDecoration(
            color: AppColors.surfacePrimary,
            border: Border(top: BorderSide(color: AppColors.borderSubtle)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.md,
            ),
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
                              color: AppColors.dangerSubtle,
                              borderRadius: BorderRadius.circular(
                                AppRadius.small,
                              ),
                            ),
                            child: Semantics(
                              liveRegion: true,
                              child: Row(
                                children: <Widget>[
                                  const Icon(
                                    Icons.error_outline,
                                    color: AppColors.destructiveAction,
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Expanded(
                                    child: Text(
                                      state.submissionError!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: AppColors.destructiveAction,
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
                    label: state.isEditing ? 'Save changes' : 'Save $typeLabel',
                    isLoading: state.isSubmitting,
                    onPressed: state.canSubmit
                        ? () => _submit(controller)
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

  Future<void> _submit(AddTransactionController controller) async {
    FocusScope.of(context).unfocus();
    final FinancialTransaction? saved = await controller.submit();
    if (saved != null && mounted) {
      context.pop<FinancialTransaction>(saved);
    }
  }
}

final class _DateField extends ConsumerWidget {
  const _DateField({
    required this.date,
    required this.isEnabled,
    required this.onChanged,
  });

  final DateTime date;
  final bool isEnabled;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String formattedDate = ref
        .watch(dateFormatterProvider)
        .longDate(date);
    return Semantics(
      button: true,
      label: 'Transaction date, $formattedDate, required',
      child: InkWell(
        onTap: isEnabled ? () => _selectDate(context) : null,
        borderRadius: BorderRadius.circular(AppRadius.small),
        child: InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Date',
            helperText: 'Required',
            suffixIcon: Icon(Icons.calendar_today_outlined),
          ),
          child: Text(formattedDate),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      helpText: 'Select transaction date',
    );
    if (selected != null) {
      onChanged(selected);
    }
  }
}

final class TransactionAmountInputFormatter extends TextInputFormatter {
  const TransactionAmountInputFormatter();

  static final RegExp _validInput = RegExp(r'^\d{0,9}(?:\.\d{0,2})?$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return _validInput.hasMatch(newValue.text) ? newValue : oldValue;
  }
}
