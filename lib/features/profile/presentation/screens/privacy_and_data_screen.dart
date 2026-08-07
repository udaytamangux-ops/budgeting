import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/data/app_data_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class PrivacyAndDataScreen extends ConsumerWidget {
  const PrivacyAndDataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppDataStatus status = ref.watch(appDataStatusProvider);
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
                      for (
                        int index = 0;
                        index < sections.length;
                        index += 1
                      ) ...<Widget>[
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
            'If storage, backup, or synchronisation changes in a future '
            'version, this '
            'information should be updated before the feature is enabled.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.appColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
