abstract interface class OnboardingPreferenceRepository {
  Stream<bool> watchCompleted();
  Future<bool> isCompleted();
  Future<void> initializeForCurrentInstallation();
  Future<void> complete();
}
