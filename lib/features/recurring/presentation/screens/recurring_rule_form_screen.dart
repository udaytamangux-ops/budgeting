import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_service.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/calendar/presentation/app_calendar_date_picker.dart';
import 'package:budgeting_app/core/utilities/app_clock.dart';
import 'package:budgeting_app/core/widgets/primary_button.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_enums.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_rule.dart';
import 'package:budgeting_app/features/recurring/presentation/controllers/recurring_rule_form_controller.dart';
import 'package:budgeting_app/features/settings/presentation/controllers/calendar_preference_providers.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/category_selector.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/payment_method_selector.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_amount_field.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_type_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

final class RecurringRuleFormScreen extends ConsumerStatefulWidget {
  const RecurringRuleFormScreen({super.key});

  @override
  ConsumerState<RecurringRuleFormScreen> createState() =>
      _RecurringRuleFormScreenState();
}

final class _RecurringRuleFormScreenState
    extends ConsumerState<RecurringRuleFormScreen> {
  late final TextEditingController _amountController;
  late final TextEditingController _merchantController;
  late final TextEditingController _noteController;
  final FocusNode _amountFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final RecurringRuleFormState state = ref.read(
      recurringRuleFormControllerProvider,
    );
    _amountController = TextEditingController(text: state.amountInput);
    _merchantController = TextEditingController(text: state.merchant);
    _noteController = TextEditingController(text: state.note);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    _noteController.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final RecurringRuleFormState state = ref.watch(
      recurringRuleFormControllerProvider,
    );
    final RecurringRuleFormController controller = ref.read(
      recurringRuleFormControllerProvider.notifier,
    );
    final List<TransactionCategory> recentCategories =
        ref
            .watch(recentTransactionCategoriesProvider(state.type))
            .valueOrNull ??
        const <TransactionCategory>[];
    final List<PaymentMethod> recentMethods =
        ref.watch(recentPaymentMethodsProvider(state.type)).valueOrNull ??
        const <PaymentMethod>[];
    final AppCalendarService calendarService = ref.watch(
      appCalendarServiceProvider,
    );
    DateTime previewNext;
    try {
      previewNext = controller.previewNextDate();
    } catch (_) {
      previewNext = state.firstDueDateAd;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Cancel',
          onPressed: state.isSaving ? null : context.pop,
          icon: const Icon(Icons.close),
        ),
        title: Text(
          state.isEditing
              ? 'Edit recurring transaction'
              : 'Create recurring transaction',
        ),
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              key: const ValueKey<String>('recurring_rule_form'),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.navigationClearance,
              ),
              children: <Widget>[
                if (state.isEditing) ...<Widget>[
                  Text(
                    'Changes affect future dates that are not waiting yet. '
                    'Waiting occurrences keep their recorded details.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.appColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                TransactionTypeSelector(
                  value: state.type,
                  isEnabled: !state.isSaving,
                  onChanged: controller.updateType,
                ),
                const SizedBox(height: AppSpacing.lg),
                TransactionAmountField(
                  controller: _amountController,
                  focusNode: _amountFocus,
                  isEnabled: !state.isSaving,
                  errorText: state.amountError,
                  onChanged: controller.updateAmount,
                ),
                const SizedBox(height: AppSpacing.xl),
                CategorySelector(
                  type: state.type,
                  selectedCategory: state.category,
                  recentCategories: recentCategories,
                  isEnabled: !state.isSaving,
                  errorText: state.categoryError,
                  onSelected: controller.updateCategory,
                  onRecentSelected: controller.updateCategory,
                ),
                const SizedBox(height: AppSpacing.xl),
                PaymentMethodSelector(
                  type: state.type,
                  value: state.paymentMethod,
                  recentMethods: recentMethods,
                  isEnabled: !state.isSaving,
                  onChanged: controller.updatePaymentMethod,
                  onRecentChanged: controller.updatePaymentMethod,
                ),
                const SizedBox(height: AppSpacing.xl),
                TextField(
                  key: const ValueKey<String>('recurring_merchant_input'),
                  controller: _merchantController,
                  enabled: !state.isSaving,
                  onChanged: controller.updateMerchant,
                  decoration: InputDecoration(
                    labelText: state.type == TransactionType.expense
                        ? 'Merchant (optional)'
                        : 'Payer or source (optional)',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  key: const ValueKey<String>('recurring_note_input'),
                  controller: _noteController,
                  enabled: !state.isSaving,
                  onChanged: controller.updateNote,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text('Schedule', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.md),
                _ChoiceWrap<RecurringFrequency>(
                  semanticLabel: 'Recurring frequency',
                  values: RecurringFrequency.values,
                  selected: state.frequency,
                  labelFor: (value) => value.label,
                  keyFor: (value) => 'recurring_frequency_${value.name}',
                  onSelected: state.isSaving
                      ? null
                      : controller.updateFrequency,
                ),
                const SizedBox(height: AppSpacing.lg),
                _ChoiceWrap<AppCalendarSystem>(
                  semanticLabel: 'Schedule calendar',
                  values: AppCalendarSystem.values,
                  selected: state.recurrenceCalendar,
                  labelFor: (value) => value.title,
                  keyFor: (value) => 'recurring_calendar_${value.storageValue}',
                  onSelected: state.isSaving ? null : controller.updateCalendar,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (!state.isEditing) ...<Widget>[
                  Text(
                    'First due date',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  OutlinedButton.icon(
                    key: const ValueKey<String>('recurring_first_due_date'),
                    onPressed: state.isSaving
                        ? null
                        : () => _pickFirstDueDate(
                            context,
                            state,
                            controller,
                            calendarService,
                          ),
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: Text(
                      calendarService.formatDate(
                        state.firstDueDateAd,
                        state.recurrenceCalendar,
                      ),
                    ),
                  ),
                  if (state.dateError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: Text(
                        state.dateError!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.appColors.destructiveAction,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                _ScheduleSummary(
                  state: state,
                  nextDate: previewNext,
                  calendarService: calendarService,
                ),
                if (state.submissionError != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      state.submissionError!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.appColors.destructiveAction,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  key: const ValueKey<String>('save_recurring_rule'),
                  label: state.isEditing ? 'Save changes' : 'Save schedule',
                  isLoading: state.isSaving,
                  onPressed: state.isSaving
                      ? null
                      : () async {
                          final RecurringTransactionRule? saved =
                              await controller.submit();
                          if (saved != null && context.mounted) {
                            context.pop(saved);
                          }
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickFirstDueDate(
    BuildContext context,
    RecurringRuleFormState state,
    RecurringRuleFormController controller,
    AppCalendarService calendarService,
  ) async {
    final DateTime current = ref.read(currentDateProvider).toLocal();
    final DateTime? selected = await AppCalendarDatePicker.show(
      context: context,
      calendarSystem: state.recurrenceCalendar,
      calendarService: calendarService,
      initialDate: state.firstDueDateAd.toLocal(),
      firstDate: DateTime(current.year, current.month, current.day),
      lastDate: DateTime(current.year + 10, 12, 31),
    );
    if (selected != null) {
      controller.updateFirstDueDate(selected);
    }
  }
}

final class _ChoiceWrap<T> extends StatelessWidget {
  const _ChoiceWrap({
    required this.semanticLabel,
    required this.values,
    required this.selected,
    required this.labelFor,
    required this.keyFor,
    required this.onSelected,
  });

  final String semanticLabel;
  final List<T> values;
  final T selected;
  final String Function(T) labelFor;
  final String Function(T) keyFor;
  final ValueChanged<T>? onSelected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: semanticLabel,
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: values
            .map(
              (T value) => ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: ChoiceChip(
                  key: ValueKey<String>(keyFor(value)),
                  label: Text(labelFor(value)),
                  selected: selected == value,
                  showCheckmark: true,
                  onSelected: onSelected == null
                      ? null
                      : (_) => onSelected!(value),
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

final class _ScheduleSummary extends StatelessWidget {
  const _ScheduleSummary({
    required this.state,
    required this.nextDate,
    required this.calendarService,
  });

  final RecurringRuleFormState state;
  final DateTime nextDate;
  final AppCalendarService calendarService;

  @override
  Widget build(BuildContext context) {
    final String description = switch (state.frequency) {
      RecurringFrequency.weekly =>
        'Every ${DateFormat('EEEE').format(state.firstDueDateAd.toLocal())}',
      RecurringFrequency.monthly => 'Every month on day ${state.anchorDay}',
      RecurringFrequency.yearly =>
        'Every year on ${calendarService.formatDate(state.firstDueDateAd, state.recurrenceCalendar)}',
    };
    return Container(
      key: const ValueKey<String>('recurring_schedule_summary'),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.appColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: context.appColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '${state.frequency.label} · ${state.recurrenceCalendar.shortLabel}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(description),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Next: ${calendarService.formatDate(nextDate, state.recurrenceCalendar)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.appColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Schedule follows ${state.recurrenceCalendar.shortLabel}.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
