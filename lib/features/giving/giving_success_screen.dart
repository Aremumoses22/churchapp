import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// ──────────────────────────────────────────────────────────────────────────────
// GIVING SUCCESS SCREEN — Section 11.9
//
// Confetti burst, checkmark circle with stroke animation, thank you content,
// receipt link, back-to-home button.
// ──────────────────────────────────────────────────────────────────────────────

class GivingSuccessScreen extends StatefulWidget {
  const GivingSuccessScreen({
    super.key,
    this.amount,
    this.reference,
    this.category,
  });

  final double? amount;
  final String? reference;
  final String? category;

  @override
  State<GivingSuccessScreen> createState() => _GivingSuccessScreenState();
}

class _GivingSuccessScreenState extends State<GivingSuccessScreen>
    with TickerProviderStateMixin {
  late final AnimationController _checkCtrl;
  late final AnimationController _confettiCtrl;
  late final Animation<double> _circleAnim;
  late final Animation<double> _tickAnim;
  late final Animation<double> _scaleAnim;

  final List<_ConfettiParticle> _particles = [];

  @override
  void initState() {
    super.initState();

    // Checkmark animation
    _checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _circleAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkCtrl, curve: const Interval(0.0, 0.6)),
    );
    _tickAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkCtrl, curve: const Interval(0.6, 0.8)),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.5, end: 1.1)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 6),
      TweenSequenceItem(
          tween: Tween(begin: 1.1, end: 1.0)
              .chain(CurveTween(curve: Curves.bounceOut)),
          weight: 4),
    ]).animate(_checkCtrl);

    // Confetti
    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    final rng = Random();
    for (var i = 0; i < 60; i++) {
      _particles.add(_ConfettiParticle(
        color: [AppColors.primary, AppColors.gold, Colors.white][rng.nextInt(3)],
        startX: rng.nextDouble(),
        speed: 0.3 + rng.nextDouble() * 0.7,
        drift: (rng.nextDouble() - 0.5) * 0.3,
        size: 4 + rng.nextDouble() * 6,
      ));
    }

    // Start animations
    _confettiCtrl.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _checkCtrl.forward();
    });
  }

  @override
  void dispose() {
    _checkCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  String _formatNaira(double amount) {
    final str = amount.toInt().toString();
    final buf = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write(',');
      buf.write(str[i]);
    }
    return '₦${buf.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.warmWhite,
      body: Stack(
        children: [
          // ── Confetti ────────────────────────────────────────────────
          AnimatedBuilder(
            listenable: _confettiCtrl,
            builder: (_, __) => CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _ConfettiPainter(
                particles: _particles,
                progress: _confettiCtrl.value,
              ),
            ),
          ),

          // ── Content ────────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated checkmark
                    AnimatedBuilder(
                      listenable: _checkCtrl,
                      builder: (_, __) => Transform.scale(
                        scale: _scaleAnim.value,
                        child: CustomPaint(
                          size: const Size(100, 100),
                          painter: _CheckmarkPainter(
                            circleProgress: _circleAnim.value,
                            tickProgress: _tickAnim.value,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sp6),

                    Text(
                      'Thank You for Your\nGenerosity \u{1F64F}',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headingLarge.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sp4),

                    if (widget.amount != null)
                      Text(
                        _formatNaira(widget.amount!),
                        style: AppTextStyles.displayLarge.copyWith(
                          color: isDark
                              ? AppColors.primaryLight
                              : AppColors.primary,
                        ),
                      ),
                    if (widget.category != null) ...[
                      const SizedBox(height: AppSpacing.sp2),
                      Text(
                        widget.category!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                    if (widget.reference?.isNotEmpty == true) ...[
                      const SizedBox(height: AppSpacing.sp2),
                      Text(
                        'Ref: ${widget.reference}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textDisabled,
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.sp8),

                    AppPrimaryButton(
                      label: 'Back to Home',
                      onPressed: () => context.go('/home'),
                    ),
                    const SizedBox(height: AppSpacing.sp3),
                    AppGhostButton(
                      label: 'View Receipt',
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── AnimatedBuilder helper (same pattern as live_service_screen) ─────────────

class AnimatedBuilder extends AnimatedWidget {
  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
  });
  final Widget Function(BuildContext, Widget?) builder;
  @override
  Widget build(BuildContext context) => builder(context, null);
}

// ── Checkmark painter ───────────────────────────────────────────────────────

class _CheckmarkPainter extends CustomPainter {
  _CheckmarkPainter({
    required this.circleProgress,
    required this.tickProgress,
  });
  final double circleProgress;
  final double tickProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Circle stroke
    final circlePaint = Paint()
      ..color = AppColors.success
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final sweepAngle = circleProgress * 2 * pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      circlePaint,
    );

    // Tick
    if (tickProgress > 0) {
      final tickPaint = Paint()
        ..color = AppColors.success
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;

      final path = Path();
      final p1 = Offset(size.width * 0.28, size.height * 0.52);
      final p2 = Offset(size.width * 0.44, size.height * 0.68);
      final p3 = Offset(size.width * 0.72, size.height * 0.36);

      if (tickProgress < 0.5) {
        final t = tickProgress / 0.5;
        path.moveTo(p1.dx, p1.dy);
        path.lineTo(
          p1.dx + (p2.dx - p1.dx) * t,
          p1.dy + (p2.dy - p1.dy) * t,
        );
      } else {
        final t = (tickProgress - 0.5) / 0.5;
        path.moveTo(p1.dx, p1.dy);
        path.lineTo(p2.dx, p2.dy);
        path.lineTo(
          p2.dx + (p3.dx - p2.dx) * t,
          p2.dy + (p3.dy - p2.dy) * t,
        );
      }
      canvas.drawPath(path, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CheckmarkPainter old) =>
      old.circleProgress != circleProgress || old.tickProgress != tickProgress;
}

// ── Confetti painter ────────────────────────────────────────────────────────

class _ConfettiParticle {
  const _ConfettiParticle({
    required this.color,
    required this.startX,
    required this.speed,
    required this.drift,
    required this.size,
  });
  final Color color;
  final double startX;
  final double speed;
  final double drift;
  final double size;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.particles, required this.progress});
  final List<_ConfettiParticle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = (progress * p.speed).clamp(0.0, 1.0);
      final x = (p.startX + p.drift * t) * size.width;
      final y = -10 + t * (size.height + 20);
      final opacity = (1.0 - t).clamp(0.0, 1.0);

      final paint = Paint()..color = p.color.withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), p.size / 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) =>
      old.progress != progress;
}
