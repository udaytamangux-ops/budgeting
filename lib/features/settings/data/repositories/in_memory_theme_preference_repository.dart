import 'dart:async';

import 'package:budgeting_app/features/settings/domain/entities/app_theme_preference.dart';
import 'package:budgeting_app/features/settings/domain/repositories/theme_preference_repository.dart';

final class InMemoryThemePreferenceRepository
    implements ThemePreferenceRepository {
  InMemoryThemePreferenceRepository({
    AppThemePreference initialMode = AppThemePreference.system,
  }) : _mode = initialMode;

  final StreamController<AppThemePreference> _changes =
      StreamController<AppThemePreference>.broadcast(sync: true);
  AppThemePreference _mode;

  Future<void> dispose() => _changes.close();

  @override
  Future<AppThemePreference> getThemeMode() async => _mode;

  @override
  Future<void> setThemeMode(AppThemePreference mode) async {
    if (_mode != mode) {
      _mode = mode;
      _changes.add(mode);
    }
  }

  @override
  Stream<AppThemePreference> watchThemeMode() async* {
    yield _mode;
    yield* _changes.stream;
  }
}
