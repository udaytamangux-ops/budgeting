import 'package:budgeting_app/core/database/app_database.dart';
import 'package:budgeting_app/features/settings/domain/entities/app_theme_preference.dart';
import 'package:budgeting_app/features/settings/domain/repositories/theme_preference_repository.dart';

final class DriftThemePreferenceRepository
    implements ThemePreferenceRepository {
  const DriftThemePreferenceRepository(this._database);

  static const String preferenceKey = 'theme_mode';

  final AppDatabase _database;

  @override
  Future<AppThemePreference> getThemeMode() async {
    return _modeFromStoredValue(await _database.readPreference(preferenceKey));
  }

  @override
  Future<void> setThemeMode(AppThemePreference mode) {
    return _database.writePreference(preferenceKey, mode.name);
  }

  @override
  Stream<AppThemePreference> watchThemeMode() {
    return _database.watchPreference(preferenceKey).map(_modeFromStoredValue);
  }

  AppThemePreference _modeFromStoredValue(String? value) {
    return AppThemePreference.values
            .where((mode) => mode.name == value)
            .firstOrNull ??
        AppThemePreference.system;
  }
}
