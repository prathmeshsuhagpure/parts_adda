import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AppLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final Color? backgroundColor;
  final double opacity;

  const AppLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.backgroundColor,
    this.opacity = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: backgroundColor ?? Colors.black.withValues(alpha: opacity),
              child: const Center(
                child: AppLoadingSpinner(),
              ),
            ),
          ),
      ],
    );
  }
}

/// Reusable loading spinner widget with animated shimmer effect
class AppLoadingSpinner extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration duration;

  const AppLoadingSpinner({
    super.key,
    this.size = 50,
    this.color,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<AppLoadingSpinner> createState() => _AppLoadingSpinnerState();
}

class _AppLoadingSpinnerState extends State<AppLoadingSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput;
    final brightColor = isDark
        ? AppColorsDark.bgCard2.withValues(alpha: 0.8)
        : AppColorsLight.bgCard2;

    return AnimatedBuilder(
      animation: _animation,
      builder: (_, _) {
        final t = _animation.value;
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.lerp(baseColor, brightColor, (sin(t * 3.14159)).abs())!,
            boxShadow: [
              BoxShadow(
                color: (widget.color ?? AppColors.primary).withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: widget.size * 0.6,
              height: widget.size * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColorsDark.bg : AppColorsLight.bg,
              ),
              child: Center(
                child: Icon(
                  Icons.settings_outlined,
                  size: widget.size * 0.3,
                  color: widget.color ?? AppColors.primary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  double sin(double x) {
    final nx = x / 3.14159;
    return 4 * nx * (1 - nx);
  }
}

/// Reusable shimmer card for list loading states
class AppShimmerCard extends StatefulWidget {
  final bool isDark;
  final double? customHeight;

  const AppShimmerCard({
    super.key,
    required this.isDark,
    this.customHeight,
  });

  @override
  State<AppShimmerCard> createState() => _AppShimmerCardState();
}

class _AppShimmerCardState extends State<AppShimmerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput;
    final bright = widget.isDark
        ? AppColorsDark.bgCard2.withValues(alpha: 0.8)
        : AppColorsLight.bgCard2;
    final bgCard = widget.isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;
    final border = widget.isDark ? AppColorsDark.border : AppColorsLight.border;

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, _) {
        final t = _anim.value;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status + date row
              Row(
                children: [
                  _ShimmerBone(
                    width: 90,
                    height: 22,
                    base: base,
                    bright: bright,
                    t: t,
                  ),
                  const Spacer(),
                  _ShimmerBone(
                    width: 70,
                    height: 14,
                    base: base,
                    bright: bright,
                    t: t,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Image + content row
              Row(
                children: [
                  _ShimmerBone(
                    width: 52,
                    height: 52,
                    base: base,
                    bright: bright,
                    t: t,
                    radius: 10,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ShimmerBone(
                          width: double.infinity,
                          height: 14,
                          base: base,
                          bright: bright,
                          t: t,
                        ),
                        const SizedBox(height: 8),
                        _ShimmerBone(
                          width: 100,
                          height: 12,
                          base: base,
                          bright: bright,
                          t: t,
                        ),
                        const SizedBox(height: 8),
                        _ShimmerBone(
                          width: 80,
                          height: 12,
                          base: base,
                          bright: bright,
                          t: t,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _ShimmerBone(
                    width: 60,
                    height: 20,
                    base: base,
                    bright: bright,
                    t: t,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Divider(height: 1, color: border),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ShimmerBone(
                    width: 120,
                    height: 14,
                    base: base,
                    bright: bright,
                    t: t,
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}

/// Individual shimmer bone element for building custom loaders
class _ShimmerBone extends StatelessWidget {
  final double width, height;
  final Color base, bright;
  final double t;
  final double radius;

  const _ShimmerBone({
    required this.width,
    required this.height,
    required this.base,
    required this.bright,
    required this.t,
    this.radius = 6,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: width == double.infinity ? null : width,
    height: height,
    decoration: BoxDecoration(
      color: Color.lerp(base, bright, (sin(t * 3.14159)).abs())!,
      borderRadius: BorderRadius.circular(radius),
    ),
  );

  double sin(double x) {
    final nx = x / 3.14159;
    return 4 * nx * (1 - nx);
  }
}

/// Reusable shimmer list widget for list loading states
class AppShimmerList extends StatelessWidget {
  final int itemCount;
  final bool isDark;
  final EdgeInsets padding;
  final double spacing;

  const AppShimmerList({
    super.key,
    this.itemCount = 6,
    required this.isDark,
    this.padding = const EdgeInsets.fromLTRB(16, 14, 16, 40),
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      itemCount: itemCount,
      separatorBuilder: (_, _) => SizedBox(height: spacing),
      itemBuilder: (_, _) => AppShimmerCard(isDark: isDark),
    );
  }
}