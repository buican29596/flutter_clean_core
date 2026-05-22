import 'package:flutter/material.dart';

/// Premium standalone Shimmer loading widget.
///
/// Can be used as a placeholder block (e.g. skeleton loaders) or as a shader mask
/// over complex layouts.
class AppShimmer extends StatefulWidget {
  const AppShimmer({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.isCircular = false,
    this.child,
  });

  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final bool isCircular;
  final Widget? child;

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      colors: const [
        Color(0xFFE5E7EB),
        Color(0xFFF3F4F6),
        Color(0xFFE5E7EB),
      ],
      stops: const [0.3, 0.5, 0.7],
      begin: Alignment(_animation.value - 1.0, -0.3),
      end: Alignment(_animation.value + 1.0, 0.3),
    );

    if (widget.child != null) {
      return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return ShaderMask(
            shaderCallback: gradient.createShader,
            blendMode: BlendMode.srcATop,
            child: widget.child,
          );
        },
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.isCircular
                ? null
                : (widget.borderRadius ?? BorderRadius.circular(8)),
            shape: widget.isCircular ? BoxShape.circle : BoxShape.rectangle,
            gradient: gradient,
          ),
        );
      },
    );
  }
}
