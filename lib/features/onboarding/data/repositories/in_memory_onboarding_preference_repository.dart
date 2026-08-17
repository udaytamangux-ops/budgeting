import 'dart:async';

import 'package:budgeting_app/features/onboarding/domain/repositories/onboarding_preference_repository.dart';

final class InMemoryOnboardingPreferenceRepository
    implements OnboardingPreferenceRepository {
  InMemoryOnboardingPreferenceRepository({bool initialCompleted = false})
    : _completed = initialCompleted;

  final StreamController<bool> _changes = StreamController<bool>.broadcast(
    sync: true,
  );
  bool _completed;

  @override
  Future<void> complete() async {
    if (_completed) return;
    _completed = true;
    _changes.add(true);
  }

  Future<void> dispose() => _changes.close();

  @override
  Future<void> initializeForCurrentInstallation() async {}

  @override
  Future<bool> isCompleted() async => _completed;

  @override
  Stream<bool> watchCompleted() async* {
    yield _completed;
    yield* _changes.stream;
  }
}
