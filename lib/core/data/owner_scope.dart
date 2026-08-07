import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract final class OwnerScopes {
  static const String guest = 'guest';
}

/// Future authentication can override this provider with `user:<id>`.
/// Phase 4A deliberately keeps the only active owner as guest.
final Provider<String> activeOwnerScopeProvider = Provider<String>(
  (Ref ref) => OwnerScopes.guest,
);
