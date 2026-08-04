import 'package:budgeting_app/app/theme/app_motion.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:flutter/material.dart';

final class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPressed != null && !isLoading,
      liveRegion: isLoading,
      label: isLoading ? '$label, saving' : label,
      excludeSemantics: true,
      onTap: onPressed != null && !isLoading ? onPressed : null,
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: isLoading ? null : onPressed,
          child: AnimatedSwitcher(
            duration: AppMotion.accessibleDuration(context, AppMotion.fast),
            child: isLoading
                ? const SizedBox.square(
                    key: ValueKey<String>('loading'),
                    dimension: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    key: const ValueKey<String>('label'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (icon != null) ...<Widget>[
                        Icon(icon, size: 20),
                        const SizedBox(width: AppSpacing.xs),
                      ],
                      Flexible(child: Text(label)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
