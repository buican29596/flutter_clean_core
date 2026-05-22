import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_clean_core/src/theme/app_colors.dart';

/// Premium custom loading indicator with dynamic gradient rotation.
///
/// Looks stunning and feels premium.
class AppLoading extends StatefulWidget {
  const AppLoading({
    super.key,
    this.size = 40,
    this.color,
    this.strokeWidth = 4,
  }) : isFullScreen = false;

  const AppLoading.fullScreen({
    super.key,
    this.size = 56,
    this.color,
    this.strokeWidth = 4,
  }) : isFullScreen = true;

  final double size;
  final Color? color;
  final double strokeWidth;
  final bool isFullScreen;

  @override
  State<AppLoading> createState() => _AppLoadingState();
}

class _AppLoadingState extends State<AppLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spinnerColor = widget.color ?? AppColors.primary;

    final spinner = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _GradientSpinnerPainter(
              color: spinnerColor,
              strokeWidth: widget.strokeWidth,
            ),
          ),
        );
      },
    );

    if (widget.isFullScreen) {
      return Container(
        color: Colors.black.withOpacity(0.35),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: spinner,
          ),
        ),
      );
    }

    return Center(child: spinner);
  }
}

class _GradientSpinnerPainter extends CustomPainter {
  _GradientSpinnerPainter({
    required this.color,
    required this.strokeWidth,
  });

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [
          color.withOpacity(0.0),
          color.withOpacity(0.2),
          color.withOpacity(0.6),
          color,
        ],
        stops: const [0.0, 0.25, 0.75, 1.0],
      ).createShader(rect);

    // Draw sweep arc
    canvas.drawArc(rect, -math.pi / 2, 1.7 * math.pi, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
