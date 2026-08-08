import 'package:budgeting_app/app/routing/app_router.dart';
import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
import 'package:budgeting_app/app/theme/app_theme.dart';
import 'package:budgeting_app/features/recurring/presentation/controllers/recurring_providers.dart';
import 'package:budgeting_app/features/settings/presentation/controllers/theme_preference_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class BudgetingApp extends ConsumerStatefulWidget {
  const BudgetingApp({super.key});

  @override
  ConsumerState<BudgetingApp> createState() => _BudgetingAppState();
}

final class _BudgetingAppState extends ConsumerState<BudgetingApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(recurringReconciliationProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(recurringReconciliationProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Budgeting',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ref.watch(appThemeModeProvider),
      themeAnimationDuration: Duration.zero,
      builder: (BuildContext context, Widget? child) {
        final Brightness brightness = Theme.of(context).brightness;
        final AppSemanticColors colors = context.appColors;
        final SystemUiOverlayStyle base = brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: base.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: colors.canvas,
            systemNavigationBarIconBrightness: brightness == Brightness.dark
                ? Brightness.light
                : Brightness.dark,
            systemNavigationBarDividerColor: colors.borderSubtle,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
