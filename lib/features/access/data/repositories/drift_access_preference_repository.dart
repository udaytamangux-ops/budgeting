import 'package:budgeting_app/core/database/app_database.dart';
import 'package:budgeting_app/features/access/domain/entities/access_mode.dart';
import 'package:budgeting_app/features/access/domain/repositories/access_preference_repository.dart';

final class DriftAccessPreferenceRepository
    implements AccessPreferenceRepository {
  const DriftAccessPreferenceRepository(this._database);

  static const String preferenceKey = 'access_mode';
  static const String _guestValue = 'guest';

  final AppDatabase _database;

  @override
  Future<AccessMode> getAccessMode() async {
    return _modeFromStoredValue(await _database.readPreference(preferenceKey));
  }

  @override
  Future<void> resetAccessChoice() {
    return _database.deletePreference(preferenceKey);
  }

  @override
  Future<void> setGuestMode() {
    return _database.writePreference(preferenceKey, _guestValue);
  }

  @override
  Stream<AccessMode> watchAccessMode() {
    return _database.watchPreference(preferenceKey).map(_modeFromStoredValue);
  }

  AccessMode _modeFromStoredValue(String? value) {
    // `authenticated` is deliberately not restored until a real auth
    // provider owns that state in a future phase.
    return value == _guestValue ? AccessMode.guest : AccessMode.undecided;
  }
}
