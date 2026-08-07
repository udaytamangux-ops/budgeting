import 'package:budgeting_app/features/access/domain/entities/access_mode.dart';

abstract interface class AccessPreferenceRepository {
  Stream<AccessMode> watchAccessMode();

  Future<AccessMode> getAccessMode();

  Future<void> setGuestMode();

  Future<void> resetAccessChoice();
}
