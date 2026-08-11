import 'package:flutter/widgets.dart';

final class SheetDismissIntentRegion extends StatefulWidget {
  const SheetDismissIntentRegion({
    required this.enabled,
    required this.onDismiss,
    required this.child,
    super.key,
  });

  final bool enabled;
  final VoidCallback onDismiss;
  final Widget child;

  @override
  State<SheetDismissIntentRegion> createState() =>
      _SheetDismissIntentRegionState();
}

final class _SheetDismissIntentRegionState
    extends State<SheetDismissIntentRegion> {
  static const double _topDragDistance = 80;
  static const double _flingMinimumDistance = 48;
  static const double _flingVelocity = 900;
  static const double _verticalDominance = 1.25;

  int? _pointer;
  Offset? _start;
  Duration? _startTime;
  double _startScrollOffset = 0;
  double _latestScrollOffset = 0;

  @override
  Widget build(BuildContext context) =>
      NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification.metrics.axis == Axis.vertical) {
            _latestScrollOffset = notification.metrics.pixels;
          }
          return false;
        },
        child: Listener(
          key: const ValueKey<String>('sheet_dismiss_intent_region'),
          behavior: HitTestBehavior.translucent,
          onPointerDown: _handlePointerDown,
          onPointerUp: _handlePointerUp,
          onPointerCancel: (_) => _reset(),
          child: widget.child,
        ),
      );

  void _handlePointerDown(PointerDownEvent event) {
    if (!widget.enabled || _pointer != null) return;
    _pointer = event.pointer;
    _start = event.position;
    _startTime = event.timeStamp;
    _startScrollOffset = _latestScrollOffset;
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (event.pointer != _pointer) return;
    final Offset? start = _start;
    final Duration? startTime = _startTime;
    final double startScrollOffset = _startScrollOffset;
    final Duration elapsed = startTime == null
        ? Duration.zero
        : event.timeStamp - startTime;
    _reset();
    if (!widget.enabled || start == null) return;
    final Offset delta = event.position - start;
    final bool vertical =
        delta.dy > 0 && delta.dy >= delta.dx.abs() * _verticalDominance;
    final double seconds = elapsed.inMicroseconds / 1000000;
    final double velocity = seconds <= 0 ? 0 : delta.dy / seconds;
    final bool topDrag =
        startScrollOffset <= 0.5 && vertical && delta.dy >= _topDragDistance;
    final bool deliberateFling =
        vertical &&
        delta.dy >= _flingMinimumDistance &&
        velocity >= _flingVelocity;
    if (topDrag || deliberateFling) widget.onDismiss();
  }

  void _reset() {
    _pointer = null;
    _start = null;
    _startTime = null;
    _startScrollOffset = 0;
  }
}
