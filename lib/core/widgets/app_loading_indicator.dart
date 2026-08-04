import 'package:flutter/material.dart';

final class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({this.label = 'Loading', super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      liveRegion: true,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
