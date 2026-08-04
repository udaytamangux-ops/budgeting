import 'package:budgeting_app/app/routing/app_routes.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final class AuthenticationPlaceholderScreen extends StatelessWidget {
  const AuthenticationPlaceholderScreen({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(Icons.lock_outline, size: 40),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '$title is prepared as a route but is not implemented in '
                    'this local prototype.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton(
                    onPressed: () => context.go(AppRoutes.home),
                    child: const Text('Continue with development session'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
