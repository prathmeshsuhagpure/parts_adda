import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/order_provider.dart';
import '../../domain/models/order_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../shared/widgets/main_shell.dart';

class TrackingScreen extends StatefulWidget {
  final String orderId;

  const TrackingScreen({super.key, required this.orderId});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadTracking(widget.orderId);
    });
  }

  String _fmtDate(DateTime d) {
    const m = [
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
    ];
    return '${m[d.month - 1]} ${d.day}, ${d.year}';
  }

  Color _statusColor(String s) => switch (s) {
    'delivered' => AppColorsDark.success,
    'cancelled' || 'returned' => AppColorsDark.error,
    'out_for_delivery' => AppColorsDark.info,
    _ => AppColorsDark.warning,
  };

  String _statusLabel(String s) => switch (s) {
    'placed' => 'Order Placed',
    'confirmed' => 'Confirmed',
    'packed' => 'Packed',
    'shipped' => 'Shipped',
    'out_for_delivery' => 'Out for Delivery',
    'delivered' => 'Delivered',
    'cancelled' => 'Cancelled',
    'returned' => 'Returned',
    _ => s,
  };

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? AppColorsDark.bg : AppColorsLight.bg,
      body: Consumer<OrderProvider>(
        builder: (context, orders, _) {
          if (orders.isTrackingLoading) {
            return const Center(child: AppLoadingIndicator());
          }
          final order = orders.selectedOrder;
          final tracking = orders.tracking;
          print("Order: $order");
          print("Tracking: $tracking");
          if (order == null || tracking == null) {
            return const Center(child: Text('No tracking data'));
          }
          return _buildBody(order, tracking);
        },
      ),
    );
  }

  Widget _buildBody(OrderModel order, OrderTracking tracking) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 160,
          pinned: true,
          backgroundColor: isDarkMode
              ? AppColorsDark.bgCard2
              : AppColorsLight.bgCard2,
          leading: GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back_ios_new, size: 18),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1a0808),
                    (isDarkMode ? AppColorsDark.bg : AppColorsLight.bg),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order.id.substring(0, 8).toUpperCase()}',
                    style: AppTextStyles.mono(isDarkMode),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _PulsingDot(status: order.status),
                      const SizedBox(width: 8),
                      Text(
                        _statusLabel(order.status),
                        style: AppTextStyles.displaySm(
                          isDarkMode,
                        ).copyWith(color: _statusColor(order.status)),
                      ),
                    ],
                  ),
                  if (tracking.estimatedDelivery != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Expected: ${_fmtDate(tracking.estimatedDelivery!)}',
                      style: AppTextStyles.bodySm(isDarkMode),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (tracking.agentName != null) ...[
                  _AgentCard(tracking: tracking),
                  const SizedBox(height: 20),
                ],
                Text(
                  'Shipment Timeline',
                  style: AppTextStyles.headingSm(isDarkMode),
                ),
                const SizedBox(height: 16),
                _Timeline(events: tracking.events),
                const SizedBox(height: 20),
                Text(
                  'Items in this order',
                  style: AppTextStyles.headingSm(isDarkMode),
                ),
                const SizedBox(height: 10),
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? AppColorsDark.bgCard
                            : AppColorsLight.bgCard,
                        border: Border.all(
                          color: isDarkMode
                              ? AppColorsDark.border
                              : AppColorsLight.border,
                        ),
                        borderRadius: AppRadius.cardRadius,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? AppColorsDark.bgInput
                                  : AppColorsLight.bgInput,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.settings,
                              color: isDarkMode
                                  ? AppColorsDark.textMuted
                                  : AppColorsLight.textMuted,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'] ?? '',
                                  style: AppTextStyles.labelMd(isDarkMode),
                                ),
                                Text(
                                  'Qty: ${item['quantity']}',
                                  style: AppTextStyles.bodyXs(isDarkMode),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '₹${(item['price'] ?? 0).toString()}',
                            style: AppTextStyles.priceSm(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.headset_mic_outlined, size: 18),
                  label: const Text('Need Help?'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    side: BorderSide(
                      color: isDarkMode
                          ? AppColorsDark.border
                          : AppColorsLight.border,
                    ),
                    foregroundColor: isDarkMode
                        ? AppColorsDark.textSecondary
                        : AppColorsLight.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Pulsing dot ────────────────────────────────────────────────────────────

class _PulsingDot extends StatefulWidget {
  final String status;

  const _PulsingDot({required this.status});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.status == 'out_for_delivery' || widget.status == 'shipped') {
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final active =
        widget.status == 'out_for_delivery' || widget.status == 'shipped';
    if (!active) return const SizedBox();
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: isDarkMode ? AppColorsDark.info : AppColorsLight.info,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? AppColorsDark.info.withValues(alpha: 0.5 * (1 - _c.value))
                  : AppColorsLight.info.withValues(alpha: 0.5 * (1 - _c.value)),
              blurRadius: 6 + 6 * _c.value,
              spreadRadius: 2 * _c.value,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Agent card ─────────────────────────────────────────────────────────────

class _AgentCard extends StatelessWidget {
  final OrderTracking tracking;

  const _AgentCard({required this.tracking});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColorsDark.bgCard : AppColorsLight.bgCard,
        border: Border.all(
          color: isDarkMode ? AppColorsDark.border : AppColorsLight.border,
        ),
        borderRadius: AppRadius.cardRadius,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppColorsDark.info.withValues(alpha: 0.1)
                  : AppColorsLight.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              Icons.person_outline,
              color: isDarkMode ? AppColorsDark.info : AppColorsLight.info,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Delivery Agent', style: AppTextStyles.bodyXs(isDarkMode)),
                Text(
                  tracking.agentName ?? '',
                  style: AppTextStyles.labelMd(isDarkMode),
                ),
                if (tracking.etaMinutes != null)
                  Text(
                    '${tracking.etaMinutes} min away',
                    style: AppTextStyles.bodySm(isDarkMode).copyWith(
                      color: isDarkMode
                          ? AppColorsDark.success
                          : AppColorsLight.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          if (tracking.agentPhone != null)
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppColorsDark.info.withValues(alpha: 0.1)
                      : AppColorsLight.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.call_outlined,
                  color: isDarkMode ? AppColorsDark.info : AppColorsLight.info,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Timeline ───────────────────────────────────────────────────────────────

class _Timeline extends StatelessWidget {
  final List<TrackingEvent> events;

  const _Timeline({required this.events});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: List.generate(events.length, (i) {
        final e = events[i];
        final isLast = i == events.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  _Dot(isDone: e.isDone, isActive: e.isActive),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: e.isDone
                            ? (isDarkMode
                                  ? AppColorsDark.success
                                  : AppColorsLight.success)
                            : (isDarkMode
                                  ? AppColorsDark.border
                                  : AppColorsLight.border),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.title,
                        style: AppTextStyles.labelMd(isDarkMode).copyWith(
                          color: e.isDone || e.isActive
                              ? (isDarkMode
                                    ? AppColorsDark.textPrimary
                                    : AppColorsLight.textPrimary)
                              : (isDarkMode
                                    ? AppColorsDark.textMuted
                                    : AppColorsLight.textMuted),
                        ),
                      ),
                      if (e.timestamp != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          e.timestamp!,
                          style: AppTextStyles.bodyXs(isDarkMode),
                        ),
                      ],
                      if (e.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          e.description!,
                          style: AppTextStyles.bodySm(isDarkMode),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _Dot extends StatefulWidget {
  final bool isDone, isActive;

  const _Dot({required this.isDone, required this.isActive});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    if (widget.isActive) _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    if (widget.isDone) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isDarkMode ? AppColorsDark.success : AppColorsLight.success,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 14, color: Colors.white),
      );
    }
    if (widget.isActive) {
      return AnimatedBuilder(
        animation: _c,
        builder: (_, _) => Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(
                  alpha: 0.5 * (1 - _c.value),
                ),
                blurRadius: 8 + 8 * _c.value,
                spreadRadius: 2 * _c.value,
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isDarkMode ? AppColorsDark.bgInput : AppColorsLight.bgInput,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDarkMode ? AppColorsDark.border : AppColorsLight.border,
        ),
      ),
    );
  }
}
