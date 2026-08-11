import 'dart:async';

import 'package:budgeting_app/app/routing/app_routes.dart';
import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/formatting/formatting_providers.dart';
import 'package:budgeting_app/core/widgets/app_error_state.dart';
import 'package:budgeting_app/core/widgets/app_loading_indicator.dart';
import 'package:budgeting_app/features/settings/presentation/controllers/calendar_preference_providers.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_category_metadata.dart';
import 'package:budgeting_app/features/transfers/domain/entities/financial_transfer.dart';
import 'package:budgeting_app/features/transfers/domain/entities/transfer_enums.dart';
import 'package:budgeting_app/features/transfers/presentation/controllers/transfer_details_controller.dart';
import 'package:budgeting_app/features/transfers/presentation/controllers/transfer_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class TransferDetailsScreen extends ConsumerWidget {
  const TransferDetailsScreen({required this.transferId, super.key});

  final String transferId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transfer details')),
      body: ref
          .watch(transferByIdProvider(transferId))
          .when(
            loading: () =>
                const AppLoadingIndicator(label: 'Loading transfer details'),
            error: (_, _) => AppErrorState(
              message: 'Transfer details are unavailable. Try again.',
              onRetry: () => ref.invalidate(transferListProvider),
            ),
            data: (FinancialTransfer? transfer) => transfer == null
                ? const AppErrorState(
                    title: 'Transfer not found',
                    message: 'This transfer may have been deleted.',
                  )
                : _TransferDetailsContent(transfer: transfer),
          ),
    );
  }
}

final class _TransferDetailsContent extends ConsumerWidget {
  const _TransferDetailsContent({required this.transfer});

  final FinancialTransfer transfer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transferDetailsControllerProvider(transfer.id));
    final formatter = ref.watch(currencyFormatterProvider);
    final AppCalendarSystem primary =
        ref.watch(primaryCalendarProvider).valueOrNull ??
        AppCalendarSystem.gregorianAd;
    final AppCalendarSystem secondary = primary == AppCalendarSystem.gregorianAd
        ? AppCalendarSystem.bikramSambatBs
        : AppCalendarSystem.gregorianAd;
    final calendar = ref.watch(appCalendarServiceProvider);
    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.navigationClearance,
        ),
        children: <Widget>[
          Text('Transfer', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            formatter.format(transfer.amount),
            key: const ValueKey<String>('transfer_details_amount'),
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const Divider(height: AppSpacing.xxl),
          _DetailRow(label: 'From', value: transfer.source.label),
          _DetailRow(label: 'To', value: transfer.destination.label),
          if (transfer.destinationName != null)
            _DetailRow(
              label: transfer.destination.destinationFieldLabel,
              value: transfer.destinationName!,
            ),
          _DetailRow(
            label: 'Count as expense',
            value: transfer.countsAsExpense ? 'Yes' : 'No',
          ),
          if (transfer.expenseCategory != null)
            _DetailRow(
              label: 'Expense category',
              value: transfer.expenseCategory!.displayLabel,
            ),
          if (transfer.fee.isPositive)
            _DetailRow(
              label: 'Transfer fee',
              value: formatter.format(transfer.fee),
            ),
          _DetailRow(
            label: 'Transfer date',
            value: calendar.formatDate(transfer.occurredAt, primary),
            secondary:
                '${secondary.shortLabel} · ${calendar.formatDate(transfer.occurredAt, secondary)}',
          ),
          _DetailRow(
            label: 'Created',
            value: calendar.formatDateAndTime(transfer.createdAt, primary),
          ),
          if (transfer.note != null)
            _DetailRow(label: 'Note', value: transfer.note!),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            key: const ValueKey<String>('edit_transfer_button'),
            onPressed: state.isDeleting
                ? null
                : () => context.push(AppRoutes.editTransfer(transfer.id)),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit transfer'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            key: const ValueKey<String>('repeat_transfer_button'),
            onPressed: state.isDeleting
                ? null
                : () => context.push(AppRoutes.repeatTransfer(transfer.id)),
            icon: const Icon(Icons.replay_outlined),
            label: const Text('Repeat transfer'),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextButton.icon(
            key: const ValueKey<String>('delete_transfer_button'),
            style: TextButton.styleFrom(
              foregroundColor: context.appColors.destructiveAction,
              minimumSize: const Size(48, 48),
            ),
            onPressed: state.isDeleting ? null : () => _delete(context, ref),
            icon: const Icon(Icons.delete_outline),
            label: Text(
              state.isDeleting ? 'Deleting transfer' : 'Delete transfer',
            ),
          ),
          if (state.errorMessage != null)
            Semantics(liveRegion: true, child: Text(state.errorMessage!)),
        ],
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this transfer?'),
        content: const Text(
          'Deleting it will remove its recorded financial effects from your summaries.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => dialogContext.pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => dialogContext.pop(true),
            child: const Text('Delete transfer'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final bool deleted = await ref
        .read(transferDetailsControllerProvider(transfer.id).notifier)
        .deleteTransfer();
    if (deleted && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Transfer deleted.')));
      context.pop();
    }
  }
}

final class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.secondary});

  final String label;
  final String value;
  final String? secondary;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(width: 132, child: Text(label)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(value, style: Theme.of(context).textTheme.bodyLarge),
              if (secondary != null)
                Text(
                  secondary!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.appColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}
