enum BackupValidationIssue { malformed, unsupportedVersion, oversized }

final class BackupValidationException implements Exception {
  const BackupValidationException(this.issue, this.message);

  final BackupValidationIssue issue;
  final String message;

  @override
  String toString() => message;
}
