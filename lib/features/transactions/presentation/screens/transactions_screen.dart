import 'dart:async';

import 'package:budgeting_app/app/routing/app_routes.dart';
import 'package:budgeting_app/app/theme/app_motion.dart';
import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/formatting/formatting_providers.dart';
import 'package:budgeting_app/core/utilities/app_clock.dart';
import 'package:budgeting_app/core/widgets/app_error_state.dart';
import 'package:budgeting_app/core/widgets/app_loading_indicator.dart';
import 'package:budgeting_app/core/widgets/empty_state.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_list_filter.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_list_item.dart';
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
  late DateTime _selectedMonth;
  String _query = '';
  TransactionType? _selectedType;

  @override
  void initState() {
    super.initState();
    final DateTime current = ref.read(currentDateProvider);
    _selectedMonth = DateTime(current.year, current.month);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<FinancialTransaction>> transactions = ref.watch(
      transactionListProvider,
    );
    final DateTime currentDate = ref.watch(currentDateProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
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
                onRetry: () => ref.invalidate(transactionListProvider),
              ),
              data: (List<FinancialTransaction> values) {
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
                  transactions: values,
                  month: _selectedMonth,
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
                        child: _TransactionFilters(
                          searchController: _searchController,
                          selectedMonthLabel: ref
                              .watch(dateFormatterProvider)
                              .shortMonthYear(_selectedMonth),
                          selectedType: _selectedType,
                          onSearchChanged: _scheduleSearch,
                          onClearSearch: _clearSearch,
                          onSelectMonth: () {
                            unawaited(_selectMonth(context, currentDate));
                          },
                          onSelectType: (TransactionType? value) {
                            setState(() => _selectedType = value);
                          },
                        ),
                      ),
                    ),
                    if (entries.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyState(
                          title: 'No matching transactions',
                          message:
                              'Try another month, transaction type, or search.',
                          icon: Icons.search_off_outlined,
                          action: OutlinedButton.icon(
                            key: const ValueKey<String>(
                              'clear_transaction_filters',
                            ),
                            onPressed: () => _clearFilters(currentDate),
                            icon: const Icon(Icons.filter_alt_off_outlined),
                            label: const Text('Clear filters'),
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
                                  label: ref
                                      .watch(dateFormatterProvider)
                                      .transactionGroupLabel(
                                        date,
                                        relativeTo: currentDate,
                                      ),
                                ),
                              _TransactionRow(
                                :final FinancialTransaction value,
                              ) =>
                                Column(
                                  children: <Widget>[
                                    TransactionListItem(
                                      transaction: value,
                                      showDate: false,
                                      onTap: () {
                                        unawaited(
                                          context.push(
                                            AppRoutes.transactionDetails(
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

  void _clearFilters(DateTime currentDate) {
    _searchDebounce?.cancel();
    _searchController.clear();
    setState(() {
      _query = '';
      _selectedType = null;
      _selectedMonth = DateTime(currentDate.year, currentDate.month);
    });
  }

  Future<void> _selectMonth(BuildContext context, DateTime currentDate) async {
    final List<DateTime> months = List<DateTime>.generate(
      6,
      (int index) => DateTime(currentDate.year, currentDate.month - index),
      growable: false,
    );
    final DateTime? selected = await showModalBottomSheet<DateTime>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Text(
                  'Choose month',
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
              ),
              ...months.map(
                (DateTime month) => ListTile(
                  title: Text(ref.read(dateFormatterProvider).monthYear(month)),
                  trailing: _isSameMonth(month, _selectedMonth)
                      ? Icon(
                          Icons.check,
                          color: context.appColors.primaryAction,
                        )
                      : null,
                  selected: _isSameMonth(month, _selectedMonth),
                  onTap: () => sheetContext.pop(month),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (selected != null && mounted) {
      setState(() => _selectedMonth = selected);
    }
  }

  List<_TransactionListEntry> _buildEntries(List<TransactionDateGroup> groups) {
    final List<_TransactionListEntry> entries = <_TransactionListEntry>[];
    for (final TransactionDateGroup group in groups) {
      entries.add(_TransactionDateHeader(group.date));
      entries.addAll(group.transactions.map(_TransactionRow.new));
    }
    return entries;
  }

  bool _isSameMonth(DateTime first, DateTime second) {
    return first.year == second.year && first.month == second.month;
  }
}

final class _TransactionFilters extends StatelessWidget {
  const _TransactionFilters({
    required this.searchController,
    required this.selectedMonthLabel,
    required this.selectedType,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onSelectMonth,
    required this.onSelectType,
  });

  final TextEditingController searchController;
  final String selectedMonthLabel;
  final TransactionType? selectedType;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onSelectMonth;
  final ValueChanged<TransactionType?> onSelectType;

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
              OutlinedButton.icon(
                key: const ValueKey<String>('transaction_month_filter'),
                onPressed: onSelectMonth,
                icon: const Icon(Icons.calendar_month_outlined, size: 18),
                label: Text(selectedMonthLabel),
              ),
              const SizedBox(width: AppSpacing.xs),
              FilterChip(
                key: const ValueKey<String>('transaction_type_all'),
                selected: selectedType == null,
                onSelected: (_) => onSelectType(null),
                label: const Text('All'),
              ),
              const SizedBox(width: AppSpacing.xs),
              FilterChip(
                key: const ValueKey<String>('transaction_type_expense'),
                selected: selectedType == TransactionType.expense,
                onSelected: (_) => onSelectType(TransactionType.expense),
                label: const Text('Expenses'),
              ),
              const SizedBox(width: AppSpacing.xs),
              FilterChip(
                key: const ValueKey<String>('transaction_type_income'),
                selected: selectedType == TransactionType.income,
                onSelected: (_) => onSelectType(TransactionType.income),
                label: const Text('Income'),
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

  final FinancialTransaction value;
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
