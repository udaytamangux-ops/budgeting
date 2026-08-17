import 'dart:async';

import 'package:budgeting_app/app/routing/app_routes.dart';
import 'package:budgeting_app/app/routing/category_details_route_data.dart';
import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/app/theme/app_typography.dart';
import 'package:budgeting_app/core/analytics/analytics_event_names.dart';
import 'package:budgeting_app/core/analytics/app_analytics.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_service.dart';
import 'package:budgeting_app/core/formatting/formatting_providers.dart';
import 'package:budgeting_app/core/widgets/app_error_state.dart';
import 'package:budgeting_app/core/widgets/app_loading_indicator.dart';
import 'package:budgeting_app/core/widgets/empty_state.dart';
import 'package:budgeting_app/features/categories/presentation/controllers/category_providers.dart';
import 'package:budgeting_app/features/financial_activity/domain/entities/financial_activity.dart';
import 'package:budgeting_app/features/financial_activity/presentation/widgets/financial_activity_list_item.dart';
import 'package:budgeting_app/features/settings/presentation/controllers/calendar_preference_providers.dart';
import 'package:budgeting_app/features/summary/domain/entities/monthly_category_activity.dart';
import 'package:budgeting_app/features/summary/presentation/controllers/summary_providers.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_visuals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class CategoryDetailsScreen extends ConsumerWidget {
  const CategoryDetailsScreen({required this.routeData, super.key});

  final CategoryDetailsRouteData routeData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CategoryActivityPeriodDetailsRequest request =
        CategoryActivityPeriodDetailsRequest(
          period: routeData.period,
          type: routeData.type,
          categories: routeData.categories,
        );
    final AsyncValue<CategoryActivityDetails> details = ref.watch(
      categoryActivityDetailsForPeriodProvider(request),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Category details')),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: details.when(
              loading: () =>
                  const AppLoadingIndicator(label: 'Loading category details'),
              error: (Object error, StackTrace stackTrace) => AppErrorState(
                message: 'Category details are unavailable. Try again.',
                onRetry: () => ref.invalidate(transactionListProvider),
              ),
              data: (CategoryActivityDetails value) =>
                  _CategoryDetailsContent(details: value, routeData: routeData),
            ),
          ),
        ),
      ),
    );
  }
}

final class _CategoryDetailsContent extends ConsumerWidget {
  const _CategoryDetailsContent({
    required this.details,
    required this.routeData,
  });

  final CategoryActivityDetails details;
  final CategoryDetailsRouteData routeData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TransactionCategory? category = routeData.categories.length == 1
        ? routeData.categories.single
        : null;
    final selected = category ?? TransactionCategory.other;
    final definition = ref.watch(categoryCatalogProvider).resolve(selected);
    final TransactionCategoryVisual visual = selected.visualFor(definition);
    final String categoryLabel = category == null ? 'Other' : definition.label;
    final AppCalendarService calendarService = ref.watch(
      appCalendarServiceProvider,
    );
    final String monthYear = calendarService.formatMonthYear(routeData.period);
    final String monthName = calendarService.formatMonthName(routeData.period);
    final String formattedTotal = ref
        .watch(currencyFormatterProvider)
        .format(details.total);
    final String relevantTotalLabel = routeData.type == TransactionType.expense
        ? 'expenses'
        : 'income';
    final String transactionCountLabel = details.transactionCount == 1
        ? '1 recorded transaction'
        : '${details.transactionCount} recorded transactions';

    return CustomScrollView(
      key: const ValueKey<String>('category_details_content'),
      slivers: <Widget>[
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            details.items.isEmpty
                ? AppSpacing.navigationClearance
                : AppSpacing.xs,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate(<Widget>[
              _CategoryDetailsHeader(
                categoryLabel: categoryLabel,
                monthYear: monthYear,
                formattedTotal: formattedTotal,
                percentageLabel:
                    '${details.sharePercentage}% of $monthName '
                    '$relevantTotalLabel',
                transactionCountLabel: transactionCountLabel,
                averageLabel: details.averageTransaction == null
                    ? null
                    : ref
                          .watch(currencyFormatterProvider)
                          .format(details.averageTransaction!),
                visual: visual,
                type: routeData.type,
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                'Recorded transactions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              if (details.items.isEmpty)
                EmptyState(
                  title: 'No $categoryLabel activity in $monthName.',
                  message: 'No matching recorded activity for this period.',
                  icon: Icons.receipt_long_outlined,
                  action: TextButton(
                    onPressed: context.pop,
                    child: const Text('Back to Summary'),
                  ),
                ),
            ]),
          ),
        ),
        if (details.items.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.navigationClearance,
            ),
            sliver: SliverList.builder(
              itemCount: details.items.length * 2 - 1,
              itemBuilder: (BuildContext context, int index) {
                if (index.isOdd) {
                  return const Divider();
                }
                final CategoryActivityItem item = details.items[index ~/ 2];
                return FinancialActivityListItem(
                  activity: item.activity,
                  displayAmount: item.contribution,
                  onTap: () =>
                      unawaited(_openActivity(context, ref, item.activity)),
                );
              },
            ),
          ),
      ],
    );
  }

  Future<void> _openActivity(
    BuildContext context,
    WidgetRef ref,
    FinancialActivity activity,
  ) async {
    ref
        .read(appAnalyticsProvider)
        .recordEvent(AnalyticsEventNames.categoryTransactionOpened);
    await context.push<void>(
      activity is TransferActivity
          ? AppRoutes.transferDetails(activity.id)
          : AppRoutes.categoryTransactionDetails(routeData, activity.id),
    );
  }
}

final class _CategoryDetailsHeader extends StatelessWidget {
  const _CategoryDetailsHeader({
    required this.categoryLabel,
    required this.monthYear,
    required this.formattedTotal,
    required this.percentageLabel,
    required this.transactionCountLabel,
    required this.averageLabel,
    required this.visual,
    required this.type,
  });

  final String categoryLabel;
  final String monthYear;
  final String formattedTotal;
  final String percentageLabel;
  final String transactionCountLabel;
  final String? averageLabel;
  final TransactionCategoryVisual visual;
  final TransactionType type;

  @override
  Widget build(BuildContext context) {
    final Color amountColor = type == TransactionType.expense
        ? context.appColors.expenseText
        : context.appColors.incomeAccent;
    final String semanticLabel = <String>[
      categoryLabel,
      monthYear,
      formattedTotal,
      percentageLabel,
      transactionCountLabel,
      if (averageLabel != null) 'Average transaction, $averageLabel',
    ].join(', ');

    return Semantics(
      container: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.appColors.surfaceSecondary,
          border: Border.all(color: context.appColors.borderSubtle),
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: visual.background,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(visual.icon, color: visual.foreground, size: 22),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        categoryLabel,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        monthYear,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                formattedTotal,
                key: const ValueKey<String>('category_details_total'),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: amountColor,
                  fontFeatures: AppTypography.tabularFigures,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(percentageLabel),
            const SizedBox(height: AppSpacing.xs),
            Text(transactionCountLabel),
            if (averageLabel != null) ...<Widget>[
              const SizedBox(height: AppSpacing.xs),
              Text('Average transaction: $averageLabel'),
            ],
          ],
        ),
      ),
    );
  }
}
