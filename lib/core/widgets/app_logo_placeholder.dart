import 'package:flutter/material.dart';

final class AppLogoPlaceholder extends StatelessWidget {
  const AppLogoPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Semantics(
      image: true,
      label: 'App logo',
      excludeSemantics: true,
      child: Container(
        key: const ValueKey<String>('app_logo_placeholder'),
        width: 72,
        height: 72,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.primaryContainer,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(
          Icons.account_balance_wallet_outlined,
          color: colors.onPrimaryContainer,
          size: 34,
        ),
      ),
    );
  }
}
