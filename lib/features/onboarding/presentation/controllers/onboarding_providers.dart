import 'package:budgeting_app/core/database/database_providers.dart';
import 'package:budgeting_app/features/onboarding/data/repositories/drift_onboarding_preference_repository.dart';
import 'package:budgeting_app/features/onboarding/domain/repositories/onboarding_preference_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<OnboardingPreferenceRepository>
onboardingPreferenceRepositoryProvider =
    Provider<OnboardingPreferenceRepository>((Ref ref) {
      return DriftOnboardingPreferenceRepository(
        ref.watch(appDatabaseProvider),
      );
    });

final StreamProvider<bool> onboardingCompletedProvider = StreamProvider<bool>((
  Ref ref,
) {
  return ref.watch(onboardingPreferenceRepositoryProvider).watchCompleted();
});
