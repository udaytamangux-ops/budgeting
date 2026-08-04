import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract final class AppBootstrap {
  static Future<ProviderContainer> createContainer() async {
    return ProviderContainer();
  }
}
