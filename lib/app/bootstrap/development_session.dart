import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SessionStatus { developmentAuthenticated }

final Provider<SessionStatus> sessionStatusProvider = Provider<SessionStatus>(
  (Ref ref) => SessionStatus.developmentAuthenticated,
);
