import 'dart:async';

import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/data/app_data_status.dart';
import 'package:budgeting_app/features/data_portability/domain/entities/financial_data_snapshot.dart';
import 'package:budgeting_app/features/data_portability/presentation/controllers/data_portability_controller.dart';
import 'package:budgeting_app/features/settings/presentation/controllers/calendar_preference_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class PrivacyAndDataScreen extends ConsumerWidget {
  const PrivacyAndDataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppDataStatus status = ref.watch(appDataStatusProvider);
    final DataPortabilityState portability = ref.watch(
      dataPortabilityControllerProvider,
    );
    ref.listen<DataPortabilityState>(dataPortabilityControllerProvider, (
      DataPortabilityState? previous,
      DataPortabilityState next,
    ) {
      if (next.feedback == null || next.feedback == previous?.feedback) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(next.feedback!)));
    });

    final List<_DataInformation> sections = <_DataInformation>[
      _DataInformation(
        key: 'storage',
        icon: Icons.storage_outlined,
        title: status.storageTitle,
        body: status.storageDescription,
      ),
      const _DataInformation(
        key: 'bank',
        icon: Icons.account_balance_outlined,
        title: AppDataStatus.bankAccessTitle,
        body: AppDataStatus.bankAccessDescription,
      ),
      const _DataInformation(
        key: 'cloud',
        icon: Icons.cloud_off_outlined,
        title: AppDataStatus.cloudAccessTitle,
        body: AppDataStatus.cloudAccessDescription,
      ),
      const _DataInformation(
        key: 'analytics',
        icon: Icons.analytics_outlined,
        title: AppDataStatus.analyticsTitle,
        body: AppDataStatus.analyticsDescription,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy and data')),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              key: const ValueKey<String>('privacy_and_data_content'),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.navigationClearance,
              ),
              children: <Widget>[
                Text(
                  'Your data',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Export transaction history for use in a spreadsheet.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.appColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Material(
                  color: context.appColors.surfacePrimary,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: context.appColors.borderSubtle),
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  child: Column(
                    children: <Widget>[
                      _DataActionRow(
                        key: const ValueKey<String>('export_transactions'),
                        icon: Icons.table_view_outlined,
                        title: 'Export transactions',
                        subtitle: 'CSV for spreadsheets',
                        semanticLabel:
                            'Export transactions as a CSV spreadsheet',
                        isLoading:
                            portability.operation ==
                            DataPortabilityOperation.exportCsv,
                        isEnabled: !portability.isBusy,
                        onTap: () => unawaited(
                          ref
                              .read(dataPortabilityControllerProvider.notifier)
                              .exportTransactions(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  'Advanced data tools',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Create a portable backup or replace local financial '
                  'records from one.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.appColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Material(
                  color: context.appColors.surfacePrimary,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: context.appColors.borderSubtle),
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  child: Column(
                    children: <Widget>[
                      _DataActionRow(
                        key: const ValueKey<String>('backup_data'),
                        icon: Icons.save_alt_outlined,
                        title: 'Backup data',
                        subtitle:
                            'Save a portable copy of your financial records',
                        semanticLabel: 'Backup financial data to a JSON file',
                        isLoading:
                            portability.operation ==
                            DataPortabilityOperation.backup,
                        isEnabled: !portability.isBusy,
                        onTap: () => _confirmBackup(context, ref),
                      ),
                      const Divider(),
                      _DataActionRow(
                        key: const ValueKey<String>('restore_backup'),
                        icon: Icons.settings_backup_restore_outlined,
                        title: 'Restore backup',
                        subtitle:
                            'Replace local financial records from a backup',
                        semanticLabel:
                            'Restore a backup and replace local financial records',
                        isLoading:
                            portability.operation ==
                            DataPortabilityOperation.restore,
                        isEnabled: !portability.isBusy,
                        onTap: () => _selectAndPreviewRestore(context, ref),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Semantics(
                  container: true,
                  label:
                      'Backup privacy notice. This backup contains your '
                      'financial records. Store it somewhere you trust.',
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: context.appColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Backup files contain your financial records. Store '
                          'them somewhere you trust.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: context.appColors.textSecondary,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  'Current data status',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'How records and connections work in this version.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.appColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Material(
                  color: context.appColors.surfacePrimary,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: context.appColors.borderSubtle),
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  child: Column(
                    children: <Widget>[
                      for (int index = 0; index < sections.length; index++) ...[
                        _DataInformationRow(information: sections[index]),
                        if (index < sections.length - 1) const Divider(),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                const _FutureTransparencyNote(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmBackup(BuildContext context, WidgetRef ref) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Create backup?'),
        content: const Text(
          'This backup contains your financial records. Store it somewhere '
          'you trust. It is not encrypted or uploaded automatically.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Choose save location'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(dataPortabilityControllerProvider.notifier).createBackup();
    }
  }

  Future<void> _selectAndPreviewRestore(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final BackupPreview? preview = await ref
        .read(dataPortabilityControllerProvider.notifier)
        .selectBackup();
    if (preview == null || !context.mounted) return;

    final AppCalendarSystem calendar =
        ref.read(primaryCalendarProvider).valueOrNull ??
        AppCalendarSystem.gregorianAd;
    final String created = ref
        .read(appCalendarServiceProvider)
        .formatDate(preview.createdAtUtc, calendar);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AlertDialog(
        key: const ValueKey<String>('restore_backup_preview'),
        title: Text('Restore backup from $created?'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _PreviewFact(label: 'Selected file', value: preview.fileName),
              const SizedBox(height: AppSpacing.md),
              _PreviewFact(label: 'Created', value: created),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Selected backup',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text('${preview.transactionCount} transactions'),
              Text('${preview.recurringRuleCount} recurring schedules'),
              Text(
                '${preview.recurringOccurrenceCount} scheduled-history items',
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Current app',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text('${preview.currentTransactionCount} transactions'),
              Text('${preview.currentRecurringRuleCount} recurring schedules'),
              Text(
                '${preview.currentRecurringOccurrenceCount} '
                'scheduled-history items',
              ),
              if (preview.currentMayContainAdditionalActivity) ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Your current app contains financial activity that may not '
                  'exist in this backup.',
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Restoring will replace your current financial records with '
                'the records in this backup.',
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Before restoring, you’ll save a recovery copy of your current '
                'data. You can use that file later if you need to return to '
                'your current records.',
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Your appearance, calendar preference, and account/access '
                'settings will not change.',
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          Semantics(
            button: true,
            label:
                'Back up current financial data and restore backup from '
                '$created',
            excludeSemantics: true,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: context.appColors.destructiveAction,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Back up & restore'),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref
          .read(dataPortabilityControllerProvider.notifier)
          .backUpCurrentAndRestore();
    } else {
      ref
          .read(dataPortabilityControllerProvider.notifier)
          .cancelPendingRestore();
    }
  }
}

final class _DataActionRow extends StatelessWidget {
  const _DataActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.semanticLabel,
    required this.isLoading,
    required this.isEnabled,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String semanticLabel;
  final bool isLoading;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: isEnabled,
      label: semanticLabel,
      value: isLoading ? 'Working' : null,
      excludeSemantics: true,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 72),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: <Widget>[
                Icon(icon, color: context.appColors.textSecondary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.appColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                if (isLoading)
                  const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _PreviewFact extends StatelessWidget {
  const _PreviewFact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppSpacing.xxs),
        Text(value),
      ],
    );
  }
}

final class _DataInformation {
  const _DataInformation({
    required this.key,
    required this.icon,
    required this.title,
    required this.body,
  });

  final String key;
  final IconData icon;
  final String title;
  final String body;
}

final class _DataInformationRow extends StatelessWidget {
  const _DataInformationRow({required this.information});

  final _DataInformation information;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: ValueKey<String>('privacy_section_${information.key}'),
      container: true,
      label: '${information.title}. ${information.body}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(information.icon, color: context.appColors.textSecondary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    information.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    information.body,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _FutureTransparencyNote extends StatelessWidget {
  const _FutureTransparencyNote();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(Icons.info_outline, color: context.appColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            'Backups are created only when you choose. There is no automatic '
            'backup or cloud synchronisation in this version.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.appColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
