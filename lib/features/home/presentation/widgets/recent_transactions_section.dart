import 'package:budgeting_app/app/routing/app_routes.dart';
import 'package:budgeting_app/app/theme/app_motion.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/calendar/domain/calendar_period.dart';
import 'package:budgeting_app/core/calendar/presentation/selected_calendar_period_providers.dart';
import 'package:budgeting_app/core/widgets/empty_state.dart';
import 'package:budgeting_app/features/financial_activity/domain/entities/financial_activity.dart';
import 'package:budgeting_app/features/financial_activity/presentation/controllers/financial_activity_providers.dart';
import 'package:budgeting_app/features/financial_activity/presentation/widgets/financial_activity_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class RecentTransactionsSection extends ConsumerWidget {
  const RecentTransactionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CalendarPeriod period = ref.watch(
      effectiveSelectedCalendarPeriodProvider,
    );
    final List<FinancialActivity> allActivities =
        ref.watch(financialActivityListProvider).valueOrNull ??
        const <FinancialActivity>[];
    final List<FinancialActivity> activities = allActivities
        .where((activity) => period.contains(activity.occurredAt))
        .take(5)
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Recent transactions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if (activities.isNotEmpty)
              TextButton(
                onPressed: () => context.go(AppRoutes.transactions),
                child: const Text('View all'),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        if (activities.isEmpty)
          EmptyState(
            key: const ValueKey<String>('home_recent_transactions_empty_state'),
            title: allActivities.isEmpty
                ? 'No recent transactions yet'
                : 'No transactions in ${period.displayLabel}',
            message: allActivities.isEmpty
                ? 'Income and expenses you add will appear here.'
                : 'No recorded financial activity for this month.',
            icon: Icons.receipt_long_outlined,
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (BuildContext context, int index) {
              final FinancialActivity activity = activities[index];
              return AnimatedSwitcher(
                duration: AppMotion.accessibleDuration(
                  context,
                  AppMotion.standard,
                ),
                child: FinancialActivityListItem(
                  key: ValueKey<String>(activity.id),
                  activity: activity,
                  onTap: () => context.push(
                    activity is TransferActivity
                        ? AppRoutes.transferDetails(activity.id)
                        : AppRoutes.transactionDetails(activity.id),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
