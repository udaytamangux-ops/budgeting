import 'dart:async';

import 'package:budgeting_app/app/routing/app_routes.dart';
import 'package:budgeting_app/app/theme/app_motion.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_service.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/calendar/domain/calendar_period.dart';
import 'package:budgeting_app/core/calendar/presentation/calendar_period_navigator.dart';
import 'package:budgeting_app/core/calendar/presentation/selected_calendar_period_providers.dart';
import 'package:budgeting_app/core/utilities/app_clock.dart';
import 'package:budgeting_app/core/widgets/app_error_state.dart';
import 'package:budgeting_app/core/widgets/app_loading_indicator.dart';
import 'package:budgeting_app/core/widgets/empty_state.dart';
import 'package:budgeting_app/features/financial_activity/domain/entities/financial_activity.dart';
import 'package:budgeting_app/features/financial_activity/presentation/controllers/financial_activity_providers.dart';
import 'package:budgeting_app/features/financial_activity/presentation/widgets/financial_activity_list_item.dart';
import 'package:budgeting_app/features/settings/presentation/controllers/calendar_preference_providers.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_list_filter.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:budgeting_app/features/transfers/presentation/controllers/transfer_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

final class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TransactionListFilter _filter = const TransactionListFilter();
  Timer? _searchDebounce;
  String _query = '';
  FinancialActivityType? _selectedType;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<FinancialActivity>> transactions = ref.watch(
      financialActivityListProvider,
    );
    final DateTime currentDate = ref.watch(currentDateProvider);
    final AppCalendarSystem primaryCalendar =
        ref.watch(primaryCalendarProvider).valueOrNull ??
        AppCalendarSystem.gregorianAd;
    final AppCalendarService calendarService = ref.watch(
      appCalendarServiceProvider,
    );
    final CalendarPeriod selectedPeriod = ref.watch(
      effectiveSelectedCalendarPeriodProvider,
    );
    final CalendarPeriodBounds bounds =
        ref.watch(calendarPeriodBoundsProvider).valueOrNull ??
        CalendarPeriodBounds(
          earliest: selectedPeriod,
          current: selectedPeriod,
          latest: selectedPeriod,
        );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: <Widget>[
          IconButton(
            key: const ValueKey<String>('open_recurring_transactions'),
            tooltip: 'Recurring transactions',
            onPressed: () => context.push(AppRoutes.recurring),
            icon: const Icon(Icons.event_repeat_outlined),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: transactions.when(
              loading: () =>
                  const AppLoadingIndicator(label: 'Loading transactions'),
              error: (Object error, StackTrace stackTrace) => AppErrorState(
                message: 'Transactions are unavailable. Try again.',
                onRetry: () {
                  ref.invalidate(transactionListProvider);
                  ref.invalidate(transferListProvider);
                },
              ),
              data: (List<FinancialActivity> values) {
                if (values.isEmpty) {
                  return EmptyState(
                    title: 'No transactions recorded yet',
                    message: 'Income and expenses you add will appear here.',
                    icon: Icons.receipt_long_outlined,
                    action: FilledButton.icon(
                      key: const ValueKey<String>(
                        'empty_transactions_add_button',
                      ),
                      onPressed: () {
                        unawaited(context.push<void>(AppRoutes.addExpense));
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add transaction'),
                    ),
                  );
                }
                final List<TransactionDateGroup> groups = _filter.apply(
                  activities: values,
                  period: selectedPeriod,
                  query: _query,
                  type: _selectedType,
                );
                final List<_TransactionListEntry> entries = _buildEntries(
                  groups,
                );

                return CustomScrollView(
                  key: const ValueKey<String>('transaction_list'),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: <Widget>[
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.xs,
                        AppSpacing.md,
                        AppSpacing.sm,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: CalendarPeriodNavigator(
                          period: selectedPeriod,
                          bounds: bounds,
                          calendarService: calendarService,
                          onSelected: ref
                              .read(selectedCalendarPeriodProvider.notifier)
                              .select,
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.xs,
                        AppSpacing.md,
                        AppSpacing.sm,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _TransactionFilters(
                          searchController: _searchController,
                          selectedType: _selectedType,
                          onSearchChanged: _scheduleSearch,
                          onClearSearch: _clearSearch,
                          onSelectType: (FinancialActivityType? value) {
                            setState(() => _selectedType = value);
                          },
                        ),
                      ),
                    ),
                    if (entries.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyState(
                          title: _query.isEmpty && _selectedType == null
                              ? 'No transactions in '
                                    '${selectedPeriod.displayLabel}'
                              : 'No matching transactions',
                          message: _query.isEmpty && _selectedType == null
                              ? 'No recorded financial activity for this month.'
                              : 'Try another month, transaction type, or '
                                    'search.',
                          icon: Icons.search_off_outlined,
                          action: OutlinedButton.icon(
                            key: const ValueKey<String>(
                              'clear_transaction_filters',
                            ),
                            onPressed:
                                _query.isEmpty &&
                                    _selectedType == null &&
                                    selectedPeriod != bounds.current
                                ? () => ref
                                      .read(
                                        selectedCalendarPeriodProvider.notifier,
                                      )
                                      .showCurrent()
                                : _clearFilters,
                            icon: Icon(
                              _query.isEmpty &&
                                      _selectedType == null &&
                                      selectedPeriod != bounds.current
                                  ? Icons.today_outlined
                                  : Icons.filter_alt_off_outlined,
                            ),
                            label: Text(
                              _query.isEmpty &&
                                      _selectedType == null &&
                                      selectedPeriod != bounds.current
                                  ? 'Current month'
                                  : 'Clear filters',
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        sliver: SliverList.builder(
                          itemCount: entries.length,
                          itemBuilder: (BuildContext context, int index) {
                            final _TransactionListEntry entry = entries[index];
                            return switch (entry) {
                              _TransactionDateHeader(:final DateTime date) =>
                                _DateGroupHeader(
                                  label: calendarService.formatDayGroup(
                                    date,
                                    primaryCalendar,
                                    relativeTo: currentDate,
                                  ),
                                ),
                              _TransactionRow(:final FinancialActivity value) =>
                                Column(
                                  children: <Widget>[
                                    FinancialActivityListItem(
                                      activity: value,
                                      showDate: false,
                                      onTap: () {
                                        unawaited(
                                          context.push(
                                            value is TransferActivity
                                                ? AppRoutes.transferDetails(
                                                    value.id,
                                                  )
                                                : AppRoutes.transactionDetails(
                                                    value.id,
                                                  ),
                                          ),
                                        );
                                      },
                                    ),
                                    const Divider(),
                                  ],
                                ),
                            };
                          },
                        ),
                      ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.navigationClearance),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _scheduleSearch(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(AppMotion.standard, () {
      if (mounted) {
        setState(() => _query = value);
      }
    });
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    setState(() => _query = '');
  }

  void _clearFilters() {
    _searchDebounce?.cancel();
    _searchController.clear();
    setState(() {
      _query = '';
      _selectedType = null;
    });
  }

  List<_TransactionListEntry> _buildEntries(List<TransactionDateGroup> groups) {
    final List<_TransactionListEntry> entries = <_TransactionListEntry>[];
    for (final TransactionDateGroup group in groups) {
      entries.add(_TransactionDateHeader(group.date));
      entries.addAll(group.activities.map(_TransactionRow.new));
    }
    return entries;
  }
}

final class _TransactionFilters extends StatelessWidget {
  const _TransactionFilters({
    required this.searchController,
    required this.selectedType,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onSelectType,
  });

  final TextEditingController searchController;
  final FinancialActivityType? selectedType;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<FinancialActivityType?> onSelectType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
          key: const ValueKey<String>('transaction_search_field'),
          controller: searchController,
          onChanged: onSearchChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            labelText: 'Search transactions',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: searchController.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    onPressed: onClearSearch,
                    icon: const Icon(Icons.close),
                  ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: <Widget>[
              FilterChip(
                key: const ValueKey<String>('transaction_type_all'),
                selected: selectedType == null,
                onSelected: (_) => onSelectType(null),
                label: const Text('All'),
              ),
              const SizedBox(width: AppSpacing.xs),
              FilterChip(
                key: const ValueKey<String>('transaction_type_expense'),
                selected: selectedType == FinancialActivityType.expense,
                onSelected: (_) => onSelectType(FinancialActivityType.expense),
                label: const Text('Expenses'),
              ),
              const SizedBox(width: AppSpacing.xs),
              FilterChip(
                key: const ValueKey<String>('transaction_type_income'),
                selected: selectedType == FinancialActivityType.income,
                onSelected: (_) => onSelectType(FinancialActivityType.income),
                label: const Text('Income'),
              ),
              const SizedBox(width: AppSpacing.xs),
              FilterChip(
                key: const ValueKey<String>('transaction_type_transfer'),
                selected: selectedType == FinancialActivityType.transfer,
                onSelected: (_) => onSelectType(FinancialActivityType.transfer),
                label: const Text('Transfer'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

sealed class _TransactionListEntry {
  const _TransactionListEntry();
}

final class _TransactionDateHeader extends _TransactionListEntry {
  const _TransactionDateHeader(this.date);

  final DateTime date;
}

final class _TransactionRow extends _TransactionListEntry {
  const _TransactionRow(this.value);

  final FinancialActivity value;
}

final class _DateGroupHeader extends StatelessWidget {
  const _DateGroupHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xs),
      child: Text(label, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
