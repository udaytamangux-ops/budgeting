import 'package:budgeting_app/app/routing/app_routes.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/features/access/domain/entities/access_mode.dart';
import 'package:budgeting_app/features/access/presentation/controllers/access_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class AccountUnavailableScreen extends ConsumerStatefulWidget {
  const AccountUnavailableScreen({required this.actionTitle, super.key});

  final String actionTitle;

  @override
  ConsumerState<AccountUnavailableScreen> createState() =>
      _AccountUnavailableScreenState();
}

final class _AccountUnavailableScreenState
    extends ConsumerState<AccountUnavailableScreen> {
  bool _isContinuing = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final AccessMode mode =
        ref.watch(accessModeProvider).valueOrNull ?? AccessMode.undecided;
    return Scaffold(
      appBar: AppBar(title: Text(widget.actionTitle)),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: ListView(
              key: const ValueKey<String>('account_unavailable_content'),
              shrinkWrap: true,
              padding: const EdgeInsets.all(AppSpacing.xl),
              children: <Widget>[
                Icon(
                  Icons.cloud_off_outlined,
                  size: 48,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Account setup is not connected yet',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'You can continue using the app without an account. Your '
                  'records will stay on this device.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Cloud backup and cross-device sync are not available yet.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                FilledButton(
                  key: const ValueKey<String>(
                    'account_unavailable_continue_guest',
                  ),
                  onPressed: _isContinuing ? null : _continueAsGuest,
                  child: _isContinuing
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.4),
                        )
                      : Text(
                          mode == AccessMode.guest
                              ? 'Return to Home'
                              : 'Continue without an account',
                        ),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(
                  key: const ValueKey<String>('account_unavailable_back'),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(
                        mode == AccessMode.guest
                            ? AppRoutes.home
                            : AppRoutes.access,
                      );
                    }
                  },
                  child: const Text('Back'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _continueAsGuest() async {
    setState(() => _isContinuing = true);
    await ref.read(accessPreferenceRepositoryProvider).setGuestMode();
    if (mounted) {
      context.go(AppRoutes.home);
    }
  }
}
