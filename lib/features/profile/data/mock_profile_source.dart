import 'package:budgeting_app/features/profile/domain/entities/profile_identity.dart';

abstract final class MockProfileSource {
  static const ProfileIdentity profile = ProfileIdentity(
    fullName: 'Aarav Shrestha',
    email: 'aarav.shrestha@example.com',
    initials: 'AS',
  );
}
