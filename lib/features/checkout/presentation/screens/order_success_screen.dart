import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_routes.dart';

// ═══════════════════════════════════════════════════════════════
// OrderSuccessScreen
// ═══════════════════════════════════════════════════════════════

class OrderSuccessScreen extends StatefulWidget {
  final String orderId;

  const OrderSuccessScreen({super.key, required this.orderId});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with TickerProviderStateMixin {
  // ── Animation controllers ──────────────────────────────────
  late final AnimationController _checkCtrl;
  late final AnimationController _confettiCtrl;
  late final AnimationController _cardCtrl;
  late final AnimationController _pulseCtrl;

  late final Animation<double> _checkScale;
  late final Animation<double> _checkOpacity;
  late final Animation<double> _ringScale;
  late final Animation<double> _cardSlide;
  late final Animation<double> _cardOpacity;
  late final Animation<double> _pulse;

  // ── Confetti particles ─────────────────────────────────────
  final List<_Particle> _particles = [];
  final _rng = math.Random();

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _bg => _isDark ? AppColorsDark.bg : AppColorsLight.bg;

  Color get _bgCard => _isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;

  Color get _border => _isDark ? AppColorsDark.border : AppColorsLight.border;

  Color get _txtPri =>
      _isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary;

  Color get _txtSec =>
      _isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;

  Color get _txtMut =>
      _isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;

  // Short display ID
  String get _displayId {
    if (widget.orderId.isEmpty) return '—';
    return widget.orderId.length > 10
        ? widget.orderId.substring(widget.orderId.length - 10).toUpperCase()
        : widget.orderId.toUpperCase();
  }

  @override
  void initState() {
    super.initState();

    // Haptic feedback
    HapticFeedback.heavyImpact();

    // Check mark animation
    _checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _checkScale = CurvedAnimation(
      parent: _checkCtrl,
      curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
    );
    _checkOpacity = CurvedAnimation(
      parent: _checkCtrl,
      curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
    );
    _ringScale = CurvedAnimation(
      parent: _checkCtrl,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    );

    // Confetti
    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // Card slide-up
    _cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _cardSlide = Tween<double>(
      begin: 60,
      end: 0,
    ).animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic));
    _cardOpacity = CurvedAnimation(
      parent: _cardCtrl,
      curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
    );

    // Pulse ring
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulse = Tween<double>(
      begin: 1.0,
      end: 1.12,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    // Generate confetti
    for (int i = 0; i < 60; i++) {
      _particles.add(_Particle(rng: _rng));
    }

    // Sequence
    _checkCtrl.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _confettiCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) _cardCtrl.forward();
    });
  }

  @override
  void dispose() {
    _checkCtrl.dispose();
    _confettiCtrl.dispose();
    _cardCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Prevent back button — user must use our CTAs
      onWillPop: () async {
        context.go(AppRoutes.home);
        return false;
      },
      child: Scaffold(
        backgroundColor: _bg,
        body: Stack(
          children: [
            // Confetti layer
            AnimatedBuilder(
              animation: _confettiCtrl,
              builder: (_, _) => CustomPaint(
                painter: _ConfettiPainter(
                  particles: _particles,
                  progress: _confettiCtrl.value,
                ),
                size: MediaQuery.of(context).size,
              ),
            ),
            // Main content
            SafeArea(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  _buildSuccessIcon(),
                  const SizedBox(height: 28),
                  _buildHeadline(),
                  const SizedBox(height: 32),
                  _buildOrderCard(),
                  const SizedBox(height: 20),
                  _buildTimelineCard(),
                  const SizedBox(height: 20),
                  _buildInfoCard(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
        _buildBottomActions(),
      ],
    );
  }

  // ── Success icon ───────────────────────────────────────────
  Widget _buildSuccessIcon() {
    return AnimatedBuilder(
      animation: Listenable.merge([_checkCtrl, _pulseCtrl]),
      builder: (_, _) => SizedBox(
        width: 160,
        height: 160,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulse ring
            Transform.scale(
              scale: _pulse.value,
              child: Opacity(
                opacity: 0.15,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            // Mid ring (scales in)
            Transform.scale(
              scale: _ringScale.value,
              child: Container(
                width: 124,
                height: 124,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    width: 2,
                  ),
                ),
              ),
            ),
            // Inner check circle
            Transform.scale(
              scale: _checkScale.value,
              child: Opacity(
                opacity: _checkOpacity.value,
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x40E8290B),
                        blurRadius: 30,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 46,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Headline ───────────────────────────────────────────────
  Widget _buildHeadline() {
    return AnimatedBuilder(
      animation: _cardCtrl,
      builder: (_, _) => Opacity(
        opacity: _cardOpacity.value,
        child: Transform.translate(
          offset: Offset(0, _cardSlide.value * 0.5),
          child: Column(
            children: [
              Text(
                'Order Placed! 🎉',
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                  color: _txtPri,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your order has been confirmed and\nis being prepared for dispatch.',
                style: AppTextStyles.bodyMd(
                  _isDark,
                ).copyWith(color: _txtSec, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Order ID card ──────────────────────────────────────────
  Widget _buildOrderCard() {
    return AnimatedBuilder(
      animation: _cardCtrl,
      builder: (_, _) => Opacity(
        opacity: _cardOpacity.value,
        child: Transform.translate(
          offset: Offset(0, _cardSlide.value),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                // Order ID row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.receipt_long_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order ID',
                            style: AppTextStyles.bodyXs(
                              _isDark,
                            ).copyWith(color: _txtMut, letterSpacing: 0.3),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                _displayId,
                                style: AppTextStyles.mono(_isDark).copyWith(
                                  fontSize: 14,
                                  letterSpacing: 1.2,
                                  color: _txtPri,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(
                                    ClipboardData(text: widget.orderId),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Order ID copied',
                                        style: AppTextStyles.bodyMd(_isDark),
                                      ),
                                      backgroundColor: _bgCard,
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                },
                                child: Icon(
                                  Icons.copy_rounded,
                                  size: 14,
                                  color: _txtMut,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Status pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColorsDark.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColorsDark.success.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColorsDark.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Confirmed',
                            style: TextStyle(
                              fontFamily: 'Syne',
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              color: AppColorsDark.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Divider(height: 1, color: _border),
                const SizedBox(height: 14),

                // Quick stats row
                Row(
                  children: [
                    _StatCell(
                      icon: Icons.calendar_today_outlined,
                      label: 'Placed on',
                      value: _todayLabel(),
                      isDark: _isDark,
                    ),
                    _VertDivider(color: _border),
                    _StatCell(
                      icon: Icons.local_shipping_outlined,
                      label: 'Est. Delivery',
                      value: _estDelivery(),
                      isDark: _isDark,
                    ),
                    _VertDivider(color: _border),
                    _StatCell(
                      icon: Icons.payments_outlined,
                      label: 'Payment',
                      value: 'Confirmed',
                      valueColor: AppColorsDark.success,
                      isDark: _isDark,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Timeline card ──────────────────────────────────────────
  Widget _buildTimelineCard() {
    return AnimatedBuilder(
      animation: _cardCtrl,
      builder: (_, _) => Opacity(
        opacity: _cardOpacity.value,
        child: Transform.translate(
          offset: Offset(0, _cardSlide.value * 1.3),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.timeline_outlined,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'What happens next?',
                      style: AppTextStyles.headingSm(
                        _isDark,
                      ).copyWith(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _TimelineStep(
                  icon: Icons.check_circle_rounded,
                  title: 'Order Confirmed',
                  subtitle: 'Your order has been placed successfully',
                  isActive: true,
                  isDone: true,
                  isDark: _isDark,
                  border: _border,
                  isLast: false,
                ),
                _TimelineStep(
                  icon: Icons.inventory_2_outlined,
                  title: 'Preparing Order',
                  subtitle: 'Seller is packing your items',
                  isActive: true,
                  isDone: false,
                  isDark: _isDark,
                  border: _border,
                  isLast: false,
                ),
                _TimelineStep(
                  icon: Icons.local_shipping_outlined,
                  title: 'Out for Delivery',
                  subtitle: 'Your order is on the way',
                  isActive: false,
                  isDone: false,
                  isDark: _isDark,
                  border: _border,
                  isLast: false,
                ),
                _TimelineStep(
                  icon: Icons.home_outlined,
                  title: 'Delivered',
                  subtitle: 'Enjoy your new parts!',
                  isActive: false,
                  isDone: false,
                  isDark: _isDark,
                  border: _border,
                  isLast: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Info card ──────────────────────────────────────────────
  Widget _buildInfoCard() {
    return AnimatedBuilder(
      animation: _cardCtrl,
      builder: (_, _) => Opacity(
        opacity: _cardOpacity.value,
        child: Transform.translate(
          offset: Offset(0, _cardSlide.value * 1.6),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColorsDark.info.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColorsDark.info.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: AppColorsDark.info,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'You\'ll receive SMS & app notifications '
                    'at every step. Track your order anytime from '
                    'the Orders tab.',
                    style: AppTextStyles.bodyMd(
                      _isDark,
                    ).copyWith(color: _txtSec, fontSize: 12, height: 1.45),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Bottom action buttons ──────────────────────────────────
  Widget _buildBottomActions() {
    return AnimatedBuilder(
      animation: _cardCtrl,
      builder: (_, _) => Opacity(
        opacity: _cardOpacity.value,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          decoration: BoxDecoration(
            color: _bgCard,
            border: Border(top: BorderSide(color: _border)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Primary CTA — Track Order
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: widget.orderId.isNotEmpty
                        ? () => context.push(
                            AppRoutes.orderDetailPath(widget.orderId),
                          )
                        : null,
                    icon: const Icon(
                      Icons.local_shipping_outlined,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Track My Order',
                      style: AppTextStyles.button,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Secondary CTAs
                Row(
                  children: [
                    Expanded(
                      child: _SecondaryBtn(
                        icon: Icons.receipt_long_outlined,
                        label: 'My Orders',
                        isDark: _isDark,
                        onTap: () => context.go(AppRoutes.orders),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SecondaryBtn(
                        icon: Icons.shopping_bag_outlined,
                        label: 'Continue Shopping',
                        isDark: _isDark,
                        onTap: () => context.go(AppRoutes.home),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────
  String _todayLabel() {
    final now = DateTime.now();
    return '${now.day} ${_month(now.month)} ${now.year}';
  }

  String _estDelivery() {
    final d = DateTime.now().add(const Duration(days: 3));
    return '${d.day}–${d.day + 2} ${_month(d.month)}';
  }

  String _month(int m) => const [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][m];
}

// ═══════════════════════════════════════════════════════════════
// Sub-widgets
// ═══════════════════════════════════════════════════════════════

class _StatCell extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color? valueColor;
  final bool isDark;

  const _StatCell({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final txtMut = isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;
    final txtPri = isDark
        ? AppColorsDark.textPrimary
        : AppColorsLight.textPrimary;
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: txtMut),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Syne',
              fontWeight: FontWeight.w700,
              fontSize: 11,
              color: valueColor ?? txtPri,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.bodyXs(
              isDark,
            ).copyWith(color: txtMut, fontSize: 9),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _VertDivider extends StatelessWidget {
  final Color color;

  const _VertDivider({required this.color});

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 40, color: color);
}

class _TimelineStep extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final bool isActive, isDone, isLast, isDark;
  final Color border;

  const _TimelineStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.isDone,
    required this.isLast,
    required this.isDark,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    final txtPri = isDark
        ? AppColorsDark.textPrimary
        : AppColorsLight.textPrimary;
    final txtSec = isDark
        ? AppColorsDark.textSecondary
        : AppColorsLight.textSecondary;
    final txtMut = isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;
    final iconColor = isDone
        ? AppColors.primary
        : isActive
        ? AppColorsDark.warning
        : txtMut;
    final iconBg = isDone
        ? AppColors.primary.withValues(alpha: 0.12)
        : isActive
        ? AppColorsDark.warning.withValues(alpha: 0.10)
        : (isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Line + dot column
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDone
                          ? AppColors.primary.withValues(alpha: 0.35)
                          : border,
                      width: isDone ? 1.5 : 1,
                    ),
                  ),
                  child: Icon(
                    isDone ? Icons.check_rounded : icon,
                    size: 13,
                    color: iconColor,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      color: isDone
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Text
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: (isDone || isActive) ? txtPri : txtMut,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyXs(
                      isDark,
                    ).copyWith(color: txtSec, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
          // Active badge
          if (isActive && !isDone)
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColorsDark.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'In Progress',
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                    color: AppColorsDark.warning,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SecondaryBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _SecondaryBtn({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgInput = isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;
    final txtSec = isDark
        ? AppColorsDark.textSecondary
        : AppColorsLight.textSecondary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: bgInput,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: txtSec),
            const SizedBox(width: 7),
            Text(
              label,
              style: AppTextStyles.labelSm(
                isDark,
              ).copyWith(color: txtSec, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Confetti
// ═══════════════════════════════════════════════════════════════

class _Particle {
  final double x; // 0..1 normalized start x
  final double startY; // 0..1 start y (above screen)
  final double speed; // fall speed multiplier
  final double size;
  final double rotSpeed;
  final Color color;
  final _Shape shape;

  _Particle({required math.Random rng})
    : x = rng.nextDouble(),
      startY = -(rng.nextDouble() * 0.4 + 0.05),
      speed = rng.nextDouble() * 0.6 + 0.4,
      size = rng.nextDouble() * 7 + 4,
      rotSpeed = (rng.nextDouble() - 0.5) * 12,
      color = _kColors[rng.nextInt(_kColors.length)],
      shape = _Shape.values[rng.nextInt(_Shape.values.length)];

  static const _kColors = [
    AppColors.primary,
    Color(0xFFFFB800),
    Color(0xFF22C55E),
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFFF472B6),
    Colors.white,
  ];
}

enum _Shape { circle, rect, triangle }

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  const _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = (progress * p.speed).clamp(0.0, 1.0);
      if (t <= 0) continue;

      final x = p.x * size.width;
      final y = (p.startY + t * 1.3) * size.height;
      final opacity = t < 0.7 ? 1.0 : (1.0 - t) / 0.3;

      final paint = Paint()
        ..color = p.color.withValues(alpha: (opacity * 0.85).clamp(0, 1))
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotSpeed * t * math.pi);

      switch (p.shape) {
        case _Shape.circle:
          canvas.drawCircle(Offset.zero, p.size * 0.5, paint);
          break;
        case _Shape.rect:
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: p.size,
              height: p.size * 0.55,
            ),
            paint,
          );
          break;
        case _Shape.triangle:
          final path = Path()
            ..moveTo(0, -p.size * 0.5)
            ..lineTo(p.size * 0.5, p.size * 0.4)
            ..lineTo(-p.size * 0.5, p.size * 0.4)
            ..close();
          canvas.drawPath(path, paint);
          break;
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
