import 'package:budgeting_app/features/settings/domain/entities/app_theme_preference.dart';

abstract interface class ThemePreferenceRepository {
  Stream<AppThemePreference> watchThemeMode();

  Future<AppThemePreference> getThemeMode();

  Future<void> setThemeMode(AppThemePreference mode);
}
