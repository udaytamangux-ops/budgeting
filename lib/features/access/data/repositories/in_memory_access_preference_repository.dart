import 'dart:async';

import 'package:budgeting_app/features/access/domain/entities/access_mode.dart';
import 'package:budgeting_app/features/access/domain/repositories/access_preference_repository.dart';

final class InMemoryAccessPreferenceRepository
    implements AccessPreferenceRepository {
  InMemoryAccessPreferenceRepository({
    AccessMode initialMode = AccessMode.undecided,
  }) : _mode = initialMode;

  final StreamController<AccessMode> _changes =
      StreamController<AccessMode>.broadcast(sync: true);
  AccessMode _mode;

  Future<void> dispose() => _changes.close();

  @override
  Future<AccessMode> getAccessMode() async => _mode;

  @override
  Future<void> resetAccessChoice() async {
    _setMode(AccessMode.undecided);
  }

  @override
  Future<void> setGuestMode() async {
    _setMode(AccessMode.guest);
  }

  @override
  Stream<AccessMode> watchAccessMode() async* {
    yield _mode;
    yield* _changes.stream;
  }

  void _setMode(AccessMode mode) {
    if (_mode != mode) {
      _mode = mode;
      _changes.add(mode);
    }
  }
}
