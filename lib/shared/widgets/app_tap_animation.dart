import 'package:flutter/material.dart';

/// A wrapper that adds a press-scale animation to any child widget.
///
/// Used on all buttons (`scale 0.96`) and cards (`translateY -2px`).
class AppTapAnimation extends StatefulWidget {
  const AppTapAnimation({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.96,
    this.duration = const Duration(milliseconds: 100),
    this.liftEffect = false,
  });

  final Widget child;
  final VoidCallback? onTap;

  /// How much to scale on press (default 0.96 for buttons).
  final double scaleDown;

  /// Duration for the press animation.
  final Duration duration;

  /// If true, applies a translateY –2 px lift instead of scale.
  final bool liftEffect;

  @override
  State<AppTapAnimation> createState() => _AppTapAnimationState();
}

class _AppTapAnimationState extends State<AppTapAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _translateY;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: widget.duration,
    );
    _scale = Tween<double>(begin: 1.0, end: widget.scaleDown).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _translateY = Tween<double>(begin: 0, end: -2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _controller.forward();

  void _onTapUp(TapUpDetails _) {
    _controller.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? _onTapDown : null,
      onTapUp: widget.onTap != null ? _onTapUp : null,
      onTapCancel: widget.onTap != null ? _onTapCancel : null,
      behavior: HitTestBehavior.translucent,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, widget.liftEffect ? _translateY.value : 0),
            child: Transform.scale(
              scale: widget.liftEffect ? 1.0 : _scale.value,
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
