import 'package:budgeting_app/core/database/app_database.dart';
import 'package:budgeting_app/features/access/data/repositories/drift_access_preference_repository.dart';
import 'package:budgeting_app/features/onboarding/domain/repositories/onboarding_preference_repository.dart';
import 'package:budgeting_app/features/settings/data/repositories/drift_calendar_preference_repository.dart';

final class DriftOnboardingPreferenceRepository
    implements OnboardingPreferenceRepository {
  const DriftOnboardingPreferenceRepository(this._database);

  static const String completedKey = 'onboarding_v1_completed';
  static const String initializedKey = 'onboarding_v1_initialized';

  final AppDatabase _database;

  @override
  Future<void> initializeForCurrentInstallation() async {
    if (await _database.readPreference(initializedKey) == 'true') return;
    final bool established =
        await _database.readPreference(
              DriftAccessPreferenceRepository.preferenceKey,
            ) !=
            null ||
        await _database.readPreference(
              DriftCalendarPreferenceRepository.setupCompleteKey,
            ) !=
            null ||
        await _database.readPreference(
              DriftCalendarPreferenceRepository.primaryCalendarKey,
            ) !=
            null ||
        await _database.hasAnyFinancialData();
    await _database.transaction(() async {
      await _database.writePreference(initializedKey, 'true');
      await _database.writePreference(completedKey, established.toString());
    });
  }

  @override
  Future<void> complete() => _database.writePreference(completedKey, 'true');

  @override
  Future<bool> isCompleted() async =>
      await _database.readPreference(completedKey) == 'true';

  @override
  Stream<bool> watchCompleted() => _database
      .watchPreference(completedKey)
      .map((String? value) => value == 'true');
}
