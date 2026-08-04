final class ProfileIdentity {
  const ProfileIdentity({
    required this.fullName,
    required this.email,
    required this.initials,
  });

  final String fullName;
  final String email;
  final String initials;

  String get firstName => fullName.split(' ').first;
}
