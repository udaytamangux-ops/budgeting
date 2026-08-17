import 'package:budgeting_app/app/routing/app_routes.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/widgets/app_logo_placeholder.dart';
import 'package:budgeting_app/features/access/presentation/controllers/access_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class AccessChoiceScreen extends ConsumerStatefulWidget {
  const AccessChoiceScreen({this.intendedLocation, super.key});

  final String? intendedLocation;

  @override
  ConsumerState<AccessChoiceScreen> createState() => _AccessChoiceScreenState();
}

final class _AccessChoiceScreenState extends ConsumerState<AccessChoiceScreen> {
  bool _isContinuing = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: ListView(
              key: const ValueKey<String>('access_choice_content'),
              shrinkWrap: true,
              padding: const EdgeInsets.all(AppSpacing.xl),
              children: <Widget>[
                const Align(child: AppLogoPlaceholder()),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Track money your way',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Record expenses, income and transfers privately on this '
                  'device. No account or bank connection required.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Your records stay on this device unless you export a '
                  'backup.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                FilledButton(
                  key: const ValueKey<String>('continue_as_guest_button'),
                  onPressed: _isContinuing ? null : _continueAsGuest,
                  child: _isContinuing
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.4),
                        )
                      : const Text('Continue'),
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
      context.go(widget.intendedLocation ?? AppRoutes.home);
    }
  }
}
