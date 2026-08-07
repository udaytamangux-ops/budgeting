import 'dart:async';

import 'package:budgeting_app/app/routing/app_routes.dart';
import 'package:budgeting_app/app/routing/category_details_route_data.dart';
import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/analytics/analytics_event_names.dart';
import 'package:budgeting_app/core/analytics/app_analytics.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_service.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/calendar/domain/calendar_period.dart';
import 'package:budgeting_app/core/formatting/currency_formatter.dart';
import 'package:budgeting_app/core/formatting/formatting_providers.dart';
import 'package:budgeting_app/core/utilities/app_clock.dart';
import 'package:budgeting_app/core/widgets/app_error_state.dart';
import 'package:budgeting_app/core/widgets/app_loading_indicator.dart';
import 'package:budgeting_app/features/settings/presentation/controllers/calendar_preference_providers.dart';
import 'package:budgeting_app/features/summary/domain/entities/monthly_category_activity.dart';
import 'package:budgeting_app/features/summary/domain/entities/monthly_transaction_summary.dart';
import 'package:budgeting_app/features/summary/presentation/controllers/summary_providers.dart';
import 'package:budgeting_app/features/summary/presentation/widgets/category_exploration_section.dart';
import 'package:budgeting_app/features/summary/presentation/widgets/summary_record_row.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class SummaryScreen extends ConsumerStatefulWidget {
  const SummaryScreen({super.key});

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

final class _SummaryScreenState extends ConsumerState<SummaryScreen> {
  late DateTime _periodAnchorAd;
  TransactionType _activityType = TransactionType.expense;
  String? _selectedGroupKey;

  @override
  void initState() {
    super.initState();
    _periodAnchorAd = ref.read(currentDateProvider);
  }

  @override
  Widget build(BuildContext context) {
    final AppCalendarSystem primaryCalendar =
        ref.watch(primaryCalendarProvider).valueOrNull ??
        AppCalendarSystem.gregorianAd;
    final AppCalendarService calendarService = ref.watch(
      appCalendarServiceProvider,
    );
    final CalendarPeriod selectedPeriod = calendarService.periodForDate(
      _periodAnchorAd,
      primaryCalendar,
    );
    final AsyncValue<MonthlyTransactionSummary> summary = ref.watch(
      monthlyTransactionSummaryForPeriodProvider(selectedPeriod),
    );
    final AsyncValue<MonthlyCategoryActivity> categoryActivity = ref.watch(
      monthlyCategoryActivityForPeriodProvider((
        period: selectedPeriod,
        type: _activityType,
      )),
    );
    final DateTime currentDate = ref.watch(currentDateProvider);
    final CurrencyFormatter currencyFormatter = ref.watch(
      currencyFormatterProvider,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Summary')),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: summary.when(
              loading: () =>
                  const AppLoadingIndicator(label: 'Loading monthly summary'),
              error: (Object error, StackTrace stackTrace) => AppErrorState(
                message: 'Your transaction summary is unavailable. Try again.',
                onRetry: () => ref.invalidate(transactionListProvider),
              ),
              data: (MonthlyTransactionSummary value) => categoryActivity.when(
                loading: () => const AppLoadingIndicator(
                  label: 'Loading category activity',
                ),
                error: (Object error, StackTrace stackTrace) => AppErrorState(
                  message: 'Category activity is unavailable. Try again.',
                  onRetry: () => ref.invalidate(transactionListProvider),
                ),
                data: (MonthlyCategoryActivity activity) => ListView(
                  key: const ValueKey<String>('summary_content'),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.xs,
                    AppSpacing.md,
                    AppSpacing.navigationClearance,
                  ),
                  children: <Widget>[
                    _MonthSelector(
                      label: calendarService.formatMonthYear(selectedPeriod),
                      calendarSystem: primaryCalendar,
                      onPrevious: () => _changePeriod(
                        calendarService.previousPeriod(selectedPeriod),
                      ),
                      onNext:
                          _isCurrentPeriod(
                            selectedPeriod,
                            calendarService.periodForDate(
                              currentDate,
                              primaryCalendar,
                            ),
                          )
                          ? null
                          : () => _changePeriod(
                              calendarService.nextPeriod(selectedPeriod),
                            ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    _MonthlyRecords(
                      summary: value,
                      currencyFormatter: currencyFormatter,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    CategoryExplorationSection(
                      activity: activity,
                      monthName: calendarService.formatMonthName(
                        selectedPeriod,
                      ),
                      selectedGroupKey: _selectedGroupKey,
                      currencyFormatter: currencyFormatter,
                      onTypeChanged: _changeActivityType,
                      onGroupSelected: _selectGroup,
                      onAllCategoriesSelected: _showAllCategories,
                      onViewTransactions: (CategoryActivityGroup group) {
                        unawaited(
                          _openCategoryDetails(context, group, selectedPeriod),
                        );
                      },
                      onAddTransaction: (TransactionType type) {
                        unawaited(
                          context.push<void>(
                            type == TransactionType.expense
                                ? AppRoutes.addExpense
                                : AppRoutes.addIncome,
                          ),
                        );
                      },
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

  void _changePeriod(CalendarPeriod period) {
    setState(() {
      _periodAnchorAd = period.startAdInclusive;
      _selectedGroupKey = null;
    });
  }

  void _changeActivityType(TransactionType type) {
    if (type == _activityType) {
      return;
    }
    setState(() {
      _activityType = type;
      _selectedGroupKey = null;
    });
  }

  void _selectGroup(CategoryActivityGroup group) {
    ref
        .read(appAnalyticsProvider)
        .recordEvent(AnalyticsEventNames.summaryCategorySelected);
    setState(() => _selectedGroupKey = group.selectionKey);
  }

  void _showAllCategories() {
    ref
        .read(appAnalyticsProvider)
        .recordEvent(AnalyticsEventNames.summaryAllCategoriesSelected);
    setState(() => _selectedGroupKey = null);
  }

  Future<void> _openCategoryDetails(
    BuildContext context,
    CategoryActivityGroup group,
    CalendarPeriod period,
  ) async {
    ref
        .read(appAnalyticsProvider)
        .recordEvent(AnalyticsEventNames.categoryDetailsOpened);
    final CategoryDetailsRouteData routeData = CategoryDetailsRouteData(
      type: _activityType,
      categories: group.includedCategories,
      period: period,
    );
    await context.push<void>(AppRoutes.categoryDetails(routeData));
  }

  bool _isCurrentPeriod(CalendarPeriod selected, CalendarPeriod current) {
    return selected == current;
  }
}

final class _MonthlyRecords extends StatelessWidget {
  const _MonthlyRecords({
    required this.summary,
    required this.currencyFormatter,
  });

  final MonthlyTransactionSummary summary;
  final CurrencyFormatter currencyFormatter;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('This month', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: context.appColors.surfaceSecondary,
            border: Border.all(color: context.appColors.borderSubtle),
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          child: Column(
            children: <Widget>[
              SummaryRecordRow(
                label: 'Income',
                value: currencyFormatter.format(summary.income),
              ),
              const Divider(),
              SummaryRecordRow(
                label: 'Expenses',
                value: currencyFormatter.format(summary.expenses),
              ),
              const Divider(),
              SummaryRecordRow(
                label: 'Net change',
                value: currencyFormatter.formatSigned(summary.netChange),
              ),
              const Divider(),
              SummaryRecordRow(
                label: 'Transaction count',
                value: summary.transactionCount == 1
                    ? '1 recorded'
                    : '${summary.transactionCount} recorded',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

final class _MonthSelector extends StatelessWidget {
  const _MonthSelector({
    required this.label,
    required this.calendarSystem,
    required this.onPrevious,
    required this.onNext,
  });

  final String label;
  final AppCalendarSystem calendarSystem;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('summary_month_selector'),
      decoration: BoxDecoration(
        color: context.appColors.surfacePrimary,
        border: Border.all(color: context.appColors.borderSubtle),
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            key: const ValueKey<String>('previous_month_button'),
            tooltip: 'Previous ${calendarSystem.shortLabel} month',
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: Semantics(
              selected: true,
              label: calendarSystem == AppCalendarSystem.gregorianAd
                  ? 'Selected month, $label'
                  : 'Selected month, $label, ${calendarSystem.semanticName}',
              excludeSemantics: true,
              child: Text(
                label,
                key: const ValueKey<String>('summary_selected_month'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          IconButton(
            key: const ValueKey<String>('next_month_button'),
            tooltip: 'Next ${calendarSystem.shortLabel} month',
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
