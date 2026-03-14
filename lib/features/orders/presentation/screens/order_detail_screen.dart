import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_routes.dart';
import '../../domain/models/order_model.dart';
import '../../presentation/providers/order_provider.dart';

Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'placed':
      return AppColorsDark.info;
    case 'confirmed':
      return AppColorsDark.info;
    case 'processing':
      return AppColorsDark.warning;
    case 'shipped':
      return Color(0xFF8B5CF6);
    case 'delivered':
      return AppColorsDark.success;
    case 'cancelled':
      return AppColorsDark.error;
    case 'returned':
      return AppColorsDark.warning;
    default:
      return AppColorsDark.textSecondary;
  }
}

IconData _statusIcon(String status) {
  switch (status.toLowerCase()) {
    case 'placed':
      return Icons.receipt_outlined;
    case 'confirmed':
      return Icons.check_circle_outline;
    case 'processing':
      return Icons.inventory_2_outlined;
    case 'shipped':
      return Icons.local_shipping_outlined;
    case 'delivered':
      return Icons.home_outlined;
    case 'cancelled':
      return Icons.cancel_outlined;
    case 'returned':
      return Icons.assignment_return_outlined;
    default:
      return Icons.info_outline;
  }
}

String _statusLabel(String status) {
  switch (status.toLowerCase()) {
    case 'placed':
      return 'Order Placed';
    case 'confirmed':
      return 'Confirmed';
    case 'processing':
      return 'Preparing';
    case 'shipped':
      return 'Shipped';
    case 'delivered':
      return 'Delivered';
    case 'cancelled':
      return 'Cancelled';
    case 'returned':
      return 'Returned';
    default:
      return status;
  }
}

bool _isCancellable(String status) =>
    ['placed', 'confirmed'].contains(status.toLowerCase());

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool get _d => Theme.of(context).brightness == Brightness.dark;

  Color get _bg => _d ? AppColorsDark.bg : AppColorsLight.bg;

  Color get _bgCard => _d ? AppColorsDark.bgCard : AppColorsLight.bgCard;

  Color get _bgInput => _d ? AppColorsDark.bgInput : AppColorsLight.bgInput;

  Color get _border => _d ? AppColorsDark.border : AppColorsLight.border;

  Color get _txtPri =>
      _d ? AppColorsDark.textPrimary : AppColorsLight.textPrimary;

  Color get _txtSec =>
      _d ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;

  Color get _txtMut => _d ? AppColorsDark.textMuted : AppColorsLight.textMuted;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrderDetail(widget.orderId);
    });
  }

  String _fmt(double v) =>
      '₹${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  // ── Cancel order flow ──────────────────────────────────────
  void _confirmCancel(OrderModel order) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Cancel Order?', style: AppTextStyles.headingSm(_d)),
        content: Text(
          'Cancel order ${_shortId(order.id)}? '
          'This action cannot be undone.',
          style: AppTextStyles.bodyMd(_d).copyWith(color: _txtSec),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Keep Order',
              style: AppTextStyles.labelMd(_d).copyWith(color: _txtSec),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final ok = await context.read<OrderProvider>().cancelOrder(
                order.id,
              );
              if (!mounted) return;
              if (ok) {
                _toast('Order cancelled successfully');
                context.go(AppRoutes.orders);
              } else {
                _toast('Failed to cancel. Try again.');
              }
            },
            child: Text(
              'Cancel Order',
              style: AppTextStyles.labelMd(
                _d,
              ).copyWith(color: AppColorsDark.error),
            ),
          ),
        ],
      ),
    );
  }

  void _toast(String msg, {bool isError = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg, style: AppTextStyles.bodyMd(_d)),
          backgroundColor: _bgCard,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );

  void _copyId(String id) {
    Clipboard.setData(ClipboardData(text: id));
    _toast('Order ID copied');
  }

  String _shortId(String id) => id.length > 8
      ? '…${id.substring(id.length - 8).toUpperCase()}'
      : id.toUpperCase();

  // ── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final prov = context.watch<OrderProvider>();

    if (prov.isDetailLoading) {
      return Scaffold(
        backgroundColor: _bg,
        appBar: _simpleAppBar('Order Details'),
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (prov.detailStatus == OrderStatus.error || prov.selectedOrder == null) {
      return Scaffold(
        backgroundColor: _bg,
        appBar: _simpleAppBar('Order Details'),
        body: _errorState(prov),
      );
    }

    final order = prov.selectedOrder!;

    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(order),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),
                _buildStatusBanner(order),
                const SizedBox(height: 16),
                _buildOrderMetaCard(order),
                const SizedBox(height: 14),
                _buildItemsCard(order),
                const SizedBox(height: 14),
                _buildPriceCard(order),
                const SizedBox(height: 14),
                _buildTimelineCard(order),
                const SizedBox(height: 14),
                _buildPaymentCard(order),
                const SizedBox(height: 14),
                if (_isCancellable(order.status)) _buildCancelCard(order),
              ]),
            ),
          ),
        ],
      ),
      // Track order FAB (only for active orders)
      floatingActionButton: _shouldShowTrack(order.status)
          ? _TrackFab(
              onTap: () => context.push(AppRoutes.trackingPath(order.id)),
            )
          : null,
    );
  }

  bool _shouldShowTrack(String status) =>
      ['shipped', 'processing', 'confirmed'].contains(status.toLowerCase());

  // ── Sliver app bar ─────────────────────────────────────────
  Widget _buildSliverAppBar(OrderModel order) {
    final statusC = _statusColor(order.status);

    return SliverAppBar(
      pinned: true,
      backgroundColor: _bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _txtPri),
        onPressed: () => context.pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Details', style: AppTextStyles.heading(_d)),
          Row(
            children: [
              Text(
                _shortId(order.id),
                style: AppTextStyles.mono(
                  _d,
                ).copyWith(fontSize: 11, color: AppColors.primary),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _copyId(order.id),
                child: Icon(Icons.copy_rounded, size: 12, color: _txtMut),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Share button
        IconButton(
          icon: Icon(Icons.ios_share_outlined, size: 19, color: _txtSec),
          onPressed: () => _toast('Share coming soon'),
        ),
        // Help button
        IconButton(
          icon: Icon(Icons.headset_mic_outlined, size: 19, color: _txtSec),
          onPressed: () => _toast('Support coming soon'),
          padding: const EdgeInsets.only(right: 4),
        ),
      ],
    );
  }

  // ── Status banner ──────────────────────────────────────────
  Widget _buildStatusBanner(OrderModel order) {
    final statusC = _statusColor(order.status);
    final isCancelled = order.status.toLowerCase() == 'cancelled';
    final isDelivered = order.status.toLowerCase() == 'delivered';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusC.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusC.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: statusC.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(_statusIcon(order.status), size: 22, color: statusC),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _statusLabel(order.status),
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: statusC,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isDelivered
                      ? 'Your order was delivered successfully.'
                      : isCancelled
                      ? 'This order has been cancelled.'
                      : 'Your order is being processed. '
                            'You\'ll get updates shortly.',
                  style: AppTextStyles.bodyMd(
                    _d,
                  ).copyWith(color: _txtSec, fontSize: 12),
                ),
              ],
            ),
          ),
          // Track CTA inside banner for shipped
          if (_shouldShowTrack(order.status))
            GestureDetector(
              onTap: () => context.push(AppRoutes.trackingPath(order.id)),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: statusC.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: statusC.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.location_on_outlined, size: 16, color: statusC),
                    const SizedBox(height: 2),
                    Text(
                      'Track',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        color: statusC,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Order meta card ────────────────────────────────────────
  Widget _buildOrderMetaCard(OrderModel order) {
    final raw = order.id;
    // Try to get orderNumber from items map if present
    final orderNumber = _extractField(order, 'orderNumber') ?? _shortId(raw);

    return _Card(
      isDark: _d,
      bgCard: _bgCard,
      border: _border,
      child: Column(
        children: [
          _MetaRow(
            icon: Icons.tag_rounded,
            label: 'Order Number',
            value: orderNumber,
            isDark: _d,
            trailing: GestureDetector(
              onTap: () => _copyId(order.id),
              child: Icon(Icons.copy_rounded, size: 13, color: _txtMut),
            ),
          ),
          _Divider(color: _border),
          _MetaRow(
            icon: Icons.calendar_today_outlined,
            label: 'Order Date',
            value: _formatDate(order.createdAt),
            isDark: _d,
          ),
          _Divider(color: _border),
          _MetaRow(
            icon: Icons.local_shipping_outlined,
            label: 'Est. Delivery',
            value: _estDelivery(order),
            isDark: _d,
          ),
          _Divider(color: _border),
          _MetaRow(
            icon: Icons.inventory_2_outlined,
            label: 'Items',
            value:
                '${order.items.length} item${order.items.length == 1 ? '' : 's'}',
            isDark: _d,
          ),
        ],
      ),
    );
  }

  // ── Items card ─────────────────────────────────────────────
  Widget _buildItemsCard(OrderModel order) {
    return _Card(
      isDark: _d,
      bgCard: _bgCard,
      border: _border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(label: 'Order Items', isDark: _d),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items.length,
            separatorBuilder: (_, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, color: _border),
            ),
            itemBuilder: (_, i) {
              final item = order.items[i] as Map<String, dynamic>? ?? {};
              return _OrderItemRow(item: item, fmt: _fmt, isDark: _d);
            },
          ),
        ],
      ),
    );
  }

  // ── Price breakdown card ───────────────────────────────────
  Widget _buildPriceCard(OrderModel order) {
    // Extract financial fields from order — they live at top level in real API
    final subtotal = _toDouble(order, 'subtotal');
    final discount = _toDouble(order, 'discount');
    final deliveryCharge = _toDouble(order, 'deliveryCharge');
    final gst = _toDouble(order, 'gst');

    return _Card(
      isDark: _d,
      bgCard: _bgCard,
      border: _border,
      child: Column(
        children: [
          _SectionTitle(label: 'Price Breakdown', isDark: _d),
          const SizedBox(height: 14),
          _PriceRow(
            label: 'Subtotal',
            value: _fmt(subtotal),
            isDark: _d,
            txtSec: _txtSec,
            txtPri: _txtPri,
          ),
          if (discount > 0) ...[
            const SizedBox(height: 8),
            _PriceRow(
              label: 'Discount',
              value: '-${_fmt(discount)}',
              isDark: _d,
              txtSec: _txtSec,
              txtPri: _txtPri,
              valueColor: AppColorsDark.success,
            ),
          ],
          const SizedBox(height: 8),
          _PriceRow(
            label: 'Delivery',
            value: deliveryCharge == 0 ? 'FREE' : _fmt(deliveryCharge),
            isDark: _d,
            txtSec: _txtSec,
            txtPri: _txtPri,
            valueColor: deliveryCharge == 0 ? AppColorsDark.success : null,
          ),
          const SizedBox(height: 8),
          _PriceRow(
            label: 'GST',
            value: _fmt(gst),
            isDark: _d,
            txtSec: _txtSec,
            txtPri: _txtPri,
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: _border),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Text('Total', style: AppTextStyles.heading(_d))),
              Text(
                _fmt(order.total),
                style: const TextStyle(
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Timeline card ──────────────────────────────────────────
  Widget _buildTimelineCard(OrderModel order) {
    // Build timeline from order status progression + any real timeline events
    final events = _buildTimeline(order);

    return _Card(
      isDark: _d,
      bgCard: _bgCard,
      border: _border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(label: 'Order Timeline', isDark: _d),
          const SizedBox(height: 14),
          ...events.asMap().entries.map(
            (e) => _TimelineRow(
              event: e.value,
              isLast: e.key == events.length - 1,
              isDark: _d,
              border: _border,
            ),
          ),
        ],
      ),
    );
  }

  // ── Payment card ───────────────────────────────────────────
  Widget _buildPaymentCard(OrderModel order) {
    final method = _extractField(order, 'paymentMethod') ?? 'cod';
    final pStatus = _extractField(order, 'paymentStatus') ?? 'pending';
    final isOnline = method == 'online' || method == 'upi';
    final isPaid = pStatus == 'paid';

    return _Card(
      isDark: _d,
      bgCard: _bgCard,
      border: _border,
      child: Column(
        children: [
          _SectionTitle(label: 'Payment', isDark: _d),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _bgInput,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _border),
                ),
                child: Icon(
                  isOnline
                      ? Icons.credit_card_outlined
                      : Icons.payments_outlined,
                  size: 20,
                  color: _txtSec,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _payMethodLabel(method),
                      style: AppTextStyles.labelMd(_d),
                    ),
                    Text(
                      _payMethodSubtitle(method),
                      style: AppTextStyles.bodyXs(_d).copyWith(color: _txtMut),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isPaid
                      ? AppColorsDark.success.withValues(alpha: 0.1)
                      : AppColorsDark.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isPaid
                        ? AppColorsDark.success.withValues(alpha: 0.3)
                        : AppColorsDark.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isPaid
                            ? AppColorsDark.success
                            : AppColorsDark.warning,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isPaid ? 'Paid' : 'Pending',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: isPaid
                            ? AppColorsDark.success
                            : AppColorsDark.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Cancel card ────────────────────────────────────────────
  Widget _buildCancelCard(OrderModel order) {
    return GestureDetector(
      onTap: () => _confirmCancel(order),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColorsDark.error.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColorsDark.error.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: AppColorsDark.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.cancel_outlined,
                size: 18,
                color: AppColorsDark.error,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cancel Order',
                    style: AppTextStyles.labelMd(
                      _d,
                    ).copyWith(color: AppColorsDark.error),
                  ),
                  Text(
                    'You can cancel before it ships',
                    style: AppTextStyles.bodyXs(
                      _d,
                    ).copyWith(color: _txtMut, fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColorsDark.error,
            ),
          ],
        ),
      ),
    );
  }

  // ── Error state ────────────────────────────────────────────
  Widget _errorState(OrderProvider prov) => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 52, color: _txtMut),
          const SizedBox(height: 16),
          Text('Could not load order', style: AppTextStyles.heading(_d)),
          const SizedBox(height: 8),
          Text(
            prov.error ?? 'Something went wrong.',
            style: AppTextStyles.bodyMd(_d).copyWith(color: _txtSec),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => prov.loadOrderDetail(widget.orderId),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Retry', style: AppTextStyles.button),
            ),
          ),
        ],
      ),
    ),
  );

  AppBar _simpleAppBar(String title) => AppBar(
    backgroundColor: _bg,
    elevation: 0,
    leading: IconButton(
      icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _txtPri),
      onPressed: () => context.pop(),
    ),
    title: Text(title, style: AppTextStyles.heading(_d)),
  );

  // ── Data helpers ───────────────────────────────────────────

  String? _extractField(OrderModel order, String field) {
    switch (field) {
      case 'orderNumber':
        return order.orderNumber;
      case 'paymentMethod':
        return order.paymentMethod;
      case 'paymentStatus':
        return order.paymentStatus;
      default:
        return null;
    }
  }

  double _toDouble(OrderModel order, String field) {
    switch (field) {
      case 'subtotal':
        return order.subtotal;
      case 'discount':
        return order.discount;
      case 'deliveryCharge':
        return order.deliveryCharge;
      case 'gst':
        return order.gst;
      default:
        return 0.0;
    }
  }

  String _formatDate(DateTime d) {
    const months = [
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
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  String _estDelivery(OrderModel order) {
    if (order.status.toLowerCase() == 'delivered') return 'Delivered';
    if (order.status.toLowerCase() == 'cancelled') return 'Cancelled';
    final est = order.createdAt.add(const Duration(days: 4));
    const months = [
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
    ];
    return '${est.day}–${est.day + 2} ${months[est.month]}';
  }

  String _payMethodLabel(String method) {
    switch (method) {
      case 'online':
        return 'Card / Net Banking';
      case 'upi':
        return 'UPI';
      case 'cod':
        return 'Cash on Delivery';
      default:
        return 'Online Payment';
    }
  }

  String _payMethodSubtitle(String method) {
    switch (method) {
      case 'online':
        return 'Razorpay — Visa, Mastercard, NetBanking';
      case 'upi':
        return 'GPay, PhonePe, Paytm';
      case 'cod':
        return 'Pay when order arrives';
      default:
        return '';
    }
  }

  List<_TimelineEvent> _buildTimeline(OrderModel order) {
    final status = order.status.toLowerCase();

    // Use real timeline events from API if available
    if (order.timeline.isNotEmpty) {
      final realEvents = order.timeline.map((e) {
        final ts = e['timestamp'] as String?;
        DateTime? parsed;
        try {
          parsed = ts != null ? DateTime.parse(ts) : null;
        } catch (_) {}
        return _TimelineEvent(
          title: _statusLabel(e['status'] as String? ?? 'placed'),
          subtitle: e['message'] as String? ?? '',
          icon: _statusIcon(e['status'] as String? ?? 'placed'),
          timestamp: parsed != null ? _formatDate(parsed) : null,
          isDone: true,
          isActive: false,
          isError: (e['status'] as String?)?.toLowerCase() == 'cancelled',
        );
      }).toList();

      // Add pending future steps if order is not terminal
      if (!['delivered', 'cancelled', 'returned'].contains(status)) {
        final doneStatuses = realEvents
            .map((e) => e.title.toLowerCase())
            .toSet();
        final allSteps = _standardSteps(order);
        for (final step in allSteps) {
          if (!doneStatuses.contains(step.title.toLowerCase())) {
            realEvents.add(step);
          }
        }
      }
      return realEvents;
    }

    // Fallback: infer from status
    if (status == 'cancelled') {
      return [
        _TimelineEvent(
          title: 'Order Placed',
          subtitle: 'Your order has been received',
          icon: Icons.receipt_outlined,
          timestamp: _formatDate(order.createdAt),
          isDone: true,
        ),
        _TimelineEvent(
          title: 'Order Cancelled',
          subtitle: 'Your order has been cancelled',
          icon: Icons.cancel_outlined,
          isDone: true,
          isError: true,
        ),
      ];
    }

    return _standardSteps(order);
  }

  List<_TimelineEvent> _standardSteps(OrderModel order) {
    final status = order.status.toLowerCase();
    return [
      _TimelineEvent(
        title: 'Order Placed',
        subtitle: 'Your order has been received',
        icon: Icons.receipt_outlined,
        timestamp: _formatDate(order.createdAt),
        isDone: true,
      ),
      _TimelineEvent(
        title: 'Order Confirmed',
        subtitle: 'Seller confirmed your order',
        icon: Icons.check_circle_outline,
        isDone: [
          'confirmed',
          'processing',
          'shipped',
          'delivered',
        ].contains(status),
        isActive: status == 'confirmed',
      ),
      _TimelineEvent(
        title: 'Preparing',
        subtitle: 'Seller is packing your items',
        icon: Icons.inventory_2_outlined,
        isDone: ['processing', 'shipped', 'delivered'].contains(status),
        isActive: status == 'processing',
      ),
      _TimelineEvent(
        title: 'Shipped',
        subtitle: 'Order is on the way',
        icon: Icons.local_shipping_outlined,
        isDone: ['shipped', 'delivered'].contains(status),
        isActive: status == 'shipped',
      ),
      _TimelineEvent(
        title: 'Delivered',
        subtitle: 'Enjoy your new parts!',
        icon: Icons.home_outlined,
        isDone: status == 'delivered',
      ),
    ];
  }
}

// ═══════════════════════════════════════════════════════════════
// Data class for timeline
// ═══════════════════════════════════════════════════════════════

class _TimelineEvent {
  final String title, subtitle;
  final IconData icon;
  final String? timestamp;
  final bool isDone, isActive, isError;

  const _TimelineEvent({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.timestamp,
    this.isDone = false,
    this.isActive = false,
    this.isError = false,
  });
}

// ═══════════════════════════════════════════════════════════════
// Track FAB
// ═══════════════════════════════════════════════════════════════

class _TrackFab extends StatelessWidget {
  final VoidCallback onTap;

  const _TrackFab({required this.onTap});

  @override
  Widget build(BuildContext context) => FloatingActionButton.extended(
    onPressed: onTap,
    backgroundColor: AppColors.primary,
    elevation: 4,
    icon: const Icon(Icons.location_on_outlined, size: 18, color: Colors.white),
    label: const Text('Track Order', style: AppTextStyles.buttonSm),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  );
}

// ═══════════════════════════════════════════════════════════════
// Reusable card widgets
// ═══════════════════════════════════════════════════════════════

class _Card extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final Color bgCard, border;

  const _Card({
    required this.child,
    required this.isDark,
    required this.bgCard,
    required this.border,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: bgCard,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: border),
    ),
    child: child,
  );
}

class _SectionTitle extends StatelessWidget {
  final String label;
  final bool isDark;

  const _SectionTitle({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 3,
        height: 14,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 8),
      Text(
        label,
        style: AppTextStyles.headingSm(isDark).copyWith(fontSize: 14),
      ),
    ],
  );
}

class _Divider extends StatelessWidget {
  final Color color;

  const _Divider({required this.color});

  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, color: color, indent: 0, endIndent: 0);
}

// ── MetaRow ────────────────────────────────────────────────────

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final bool isDark;
  final Widget? trailing;

  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final txtMut = isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;
    final txtPri = isDark
        ? AppColorsDark.textPrimary
        : AppColorsLight.textPrimary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Icon(icon, size: 15, color: txtMut),
          const SizedBox(width: 10),
          Text(
            label,
            style: AppTextStyles.bodyMd(
              isDark,
            ).copyWith(color: txtMut, fontSize: 12),
          ),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: AppTextStyles.labelMd(
                  isDark,
                ).copyWith(fontSize: 13, color: txtPri),
              ),
              if (trailing != null) ...[const SizedBox(width: 6), trailing!],
            ],
          ),
        ],
      ),
    );
  }
}

// ── OrderItemRow ───────────────────────────────────────────────

class _OrderItemRow extends StatelessWidget {
  final Map<String, dynamic> item;
  final String Function(double) fmt;
  final bool isDark;

  const _OrderItemRow({
    required this.item,
    required this.fmt,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bgInput = isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput;
    final txtMut = isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;
    final txtSec = isDark
        ? AppColorsDark.textSecondary
        : AppColorsLight.textSecondary;
    final image = item['image'] as String?;
    final name = item['partName'] as String? ?? 'Auto Part';
    final sku = item['partSku'] as String?;
    final price = (item['price'] ?? 0).toDouble();
    final qty = (item['quantity'] ?? 1) as int;
    final subtotal = (item['subtotal'] ?? price * qty).toDouble();
    final sellerName = item['sellerName'] as String?;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product image / placeholder
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 58,
            height: 58,
            color: bgInput,
            child: image != null && image.isNotEmpty
                ? Image.network(
                    image,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) =>
                        Icon(Icons.settings_outlined, size: 26, color: txtMut),
                  )
                : Icon(Icons.settings_outlined, size: 26, color: txtMut),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppTextStyles.labelMd(isDark),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (sku != null && sku.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  'SKU: $sku',
                  style: AppTextStyles.mono(
                    isDark,
                  ).copyWith(fontSize: 10, color: txtMut),
                ),
              ],
              if (sellerName != null && sellerName.isNotEmpty) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.store_outlined, size: 11, color: txtMut),
                    const SizedBox(width: 4),
                    Text(
                      sellerName,
                      style: AppTextStyles.bodyXs(
                        isDark,
                      ).copyWith(color: txtSec, fontSize: 11),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    '${fmt(price)} × $qty',
                    style: AppTextStyles.bodyXs(isDark).copyWith(color: txtSec),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              fmt(subtotal),
              style: const TextStyle(
                fontFamily: 'Syne',
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: bgInput,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: isDark ? AppColorsDark.border : AppColorsLight.border,
                ),
              ),
              child: Text(
                'Qty: $qty',
                style: AppTextStyles.bodyXs(
                  isDark,
                ).copyWith(color: txtMut, fontSize: 10),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── PriceRow ───────────────────────────────────────────────────

class _PriceRow extends StatelessWidget {
  final String label, value;
  final bool isDark;
  final Color txtSec, txtPri;
  final Color? valueColor;

  const _PriceRow({
    required this.label,
    required this.value,
    required this.isDark,
    required this.txtSec,
    required this.txtPri,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: AppTextStyles.bodyMd(isDark).copyWith(color: txtSec),
        ),
      ),
      Text(
        value,
        style: AppTextStyles.labelMd(
          isDark,
        ).copyWith(color: valueColor ?? txtPri),
      ),
    ],
  );
}

// ── TimelineRow ────────────────────────────────────────────────

class _TimelineRow extends StatelessWidget {
  final _TimelineEvent event;
  final bool isLast, isDark;
  final Color border;

  const _TimelineRow({
    required this.event,
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

    final Color iconColor;
    final Color iconBg;
    if (event.isError) {
      iconColor = AppColorsDark.error;
      iconBg = AppColorsDark.error.withValues(alpha: 0.12);
    } else if (event.isDone) {
      iconColor = AppColors.primary;
      iconBg = AppColors.primary.withValues(alpha: 0.12);
    } else if (event.isActive) {
      iconColor = AppColorsDark.warning;
      iconBg = AppColorsDark.warning.withValues(alpha: 0.10);
    } else {
      iconColor = txtMut;
      iconBg = isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput;
    }

    final lineColor = event.isDone
        ? AppColors.primary.withValues(alpha: 0.3)
        : border;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icon + connector
          SizedBox(
            width: 38,
            child: Column(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: event.isDone
                          ? iconColor.withValues(alpha: 0.35)
                          : border,
                      width: event.isDone ? 1.5 : 1,
                    ),
                  ),
                  child: Icon(
                    event.isDone
                        ? (event.isError
                              ? Icons.close_rounded
                              : Icons.check_rounded)
                        : event.icon,
                    size: 14,
                    color: iconColor,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      color: lineColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Text content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: TextStyle(
                            fontFamily: 'Syne',
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: (event.isDone || event.isActive)
                                ? (event.isError ? AppColorsDark.error : txtPri)
                                : txtMut,
                          ),
                        ),
                      ),
                      if (event.isActive && !event.isDone)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColorsDark.warning.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            'Now',
                            style: TextStyle(
                              fontFamily: 'Syne',
                              fontWeight: FontWeight.w800,
                              fontSize: 9,
                              color: AppColorsDark.warning,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    event.subtitle,
                    style: AppTextStyles.bodyXs(
                      isDark,
                    ).copyWith(color: txtSec, fontSize: 11),
                  ),
                  if (event.timestamp != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      event.timestamp!,
                      style: AppTextStyles.bodyXs(
                        isDark,
                      ).copyWith(color: txtMut, fontSize: 10),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
