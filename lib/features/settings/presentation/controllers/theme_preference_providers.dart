import 'package:budgeting_app/core/database/database_providers.dart';
import 'package:budgeting_app/features/settings/data/repositories/drift_theme_preference_repository.dart';
import 'package:budgeting_app/features/settings/domain/entities/app_theme_preference.dart';
import 'package:budgeting_app/features/settings/domain/repositories/theme_preference_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<ThemePreferenceRepository> themePreferenceRepositoryProvider =
    Provider<ThemePreferenceRepository>((Ref ref) {
      return DriftThemePreferenceRepository(ref.watch(appDatabaseProvider));
    });

final StreamProvider<AppThemePreference> themePreferenceProvider =
    StreamProvider<AppThemePreference>((Ref ref) {
      return ref.watch(themePreferenceRepositoryProvider).watchThemeMode();
    });

final Provider<ThemeMode> appThemeModeProvider = Provider<ThemeMode>((Ref ref) {
  final AppThemePreference preference =
      ref.watch(themePreferenceProvider).valueOrNull ??
      AppThemePreference.system;
  return switch (preference) {
    AppThemePreference.system => ThemeMode.system,
    AppThemePreference.light => ThemeMode.light,
    AppThemePreference.dark => ThemeMode.dark,
  };
});
