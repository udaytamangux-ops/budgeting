import 'package:budgeting_app/app/theme/app_motion.dart';
import 'package:flutter/material.dart';

/// Local tactile feedback for controls that already own their tap semantics.
final class PressableScale extends StatefulWidget {
  const PressableScale({
    required this.child,
    this.enabled = true,
    this.pressedScale = 0.97,
    super.key,
  });

  final Widget child;
  final bool enabled;
  final double pressedScale;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

final class _PressableScaleState extends State<PressableScale> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: widget.enabled ? (_) => _setPressed(true) : null,
      onPointerUp: widget.enabled ? (_) => _setPressed(false) : null,
      onPointerCancel: widget.enabled ? (_) => _setPressed(false) : null,
      child: AnimatedScale(
        scale: _isPressed ? widget.pressedScale : 1,
        duration: AppMotion.accessibleDuration(context, AppMotion.tapFeedback),
        curve: AppMotion.emphasized,
        child: widget.child,
      ),
    );
  }

  void _setPressed(bool value) {
    if (_isPressed != value && mounted) {
      setState(() => _isPressed = value);
    }
  }
}
