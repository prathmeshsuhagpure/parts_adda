import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_routes.dart';
import '../../domain/models/order_model.dart';
import '../../presentation/providers/order_provider.dart';

// ─── Status config ────────────────────────────────────────────

const _kTabs = ['All', 'Active', 'Delivered', 'Cancelled'];

const _kFilterMap = {
  'All': null,
  'Active': 'active',
  'Delivered': 'delivered',
  'Cancelled': 'cancelled',
};

Color _statusColor(String s) {
  switch (s.toLowerCase()) {
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

String _statusLabel(String s) {
  switch (s.toLowerCase()) {
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
      return s[0].toUpperCase() + s.substring(1);
  }
}

bool _isActive(String s) =>
    ['placed', 'confirmed', 'processing', 'shipped'].contains(s.toLowerCase());

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  int _activeTab = 0;

  bool get _d => Theme.of(context).brightness == Brightness.dark;

  Color get _bg => _d ? AppColorsDark.bg : AppColorsLight.bg;

  Color get _bgCard => _d ? AppColorsDark.bgCard : AppColorsLight.bgCard;

  Color get _border => _d ? AppColorsDark.border : AppColorsLight.border;

  Color get _txtSec =>
      _d ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;

  Color get _txtMut => _d ? AppColorsDark.textMuted : AppColorsLight.textMuted;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _kTabs.length, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        setState(() => _activeTab = _tabCtrl.index);
        final filter = _kFilterMap[_kTabs[_tabCtrl.index]];
        context.read<OrderProvider>().loadOrders(statusFilter: filter);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrders();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final filter = _kFilterMap[_kTabs[_activeTab]];
    await context.read<OrderProvider>().loadOrders(statusFilter: filter);
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<OrderProvider>();

    return Scaffold(
      backgroundColor: _bg,
      body: NestedScrollView(
        headerSliverBuilder: (_, _) => [_buildSliverHeader(prov)],
        body: _buildBody(prov),
      ),
    );
  }

  Widget _buildSliverHeader(OrderProvider prov) {
    final activeCount = prov.orders.where((o) => _isActive(o.status)).length;

    return SliverAppBar(
      pinned: true,
      backgroundColor: _bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Orders', style: AppTextStyles.heading(_d)),
          if (activeCount > 0)
            Text(
              '$activeCount active order${activeCount == 1 ? '' : 's'}',
              style: AppTextStyles.labelXs(
                _d,
              ).copyWith(color: AppColors.primary, letterSpacing: 0.2),
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search_rounded, size: 22, color: _txtSec),
          onPressed: () => context.push(AppRoutes.search),
          tooltip: 'Search parts',
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(46),
        child: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: _border)),
          ),
          child: TabBar(
            controller: _tabCtrl,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColors.primary,
            indicatorWeight: 2.5,
            labelColor: AppColors.primary,
            unselectedLabelColor: _txtSec,
            dividerColor: Colors.transparent,
            labelStyle: const TextStyle(
              fontFamily: 'Syne',
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            tabs: _kTabs.map((t) {
              final cnt = _tabCount(t, prov.orders);
              return Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(t),
                    if (cnt > 0) ...[
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: t == 'Active'
                              ? AppColors.primary
                              : (_d
                                    ? AppColorsDark.bgInput
                                    : AppColorsLight.bgInput),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$cnt',
                          style: TextStyle(
                            fontFamily: 'Syne',
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                            color: t == 'Active' ? Colors.white : _txtSec,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  int _tabCount(String tab, List<OrderModel> orders) {
    switch (tab) {
      case 'Active':
        return orders.where((o) => _isActive(o.status)).length;
      case 'Delivered':
        return orders
            .where((o) => o.status.toLowerCase() == 'delivered')
            .length;
      case 'Cancelled':
        return orders
            .where((o) => o.status.toLowerCase() == 'cancelled')
            .length;
      default:
        return orders.length;
    }
  }

  // ── Body ───────────────────────────────────────────────────
  Widget _buildBody(OrderProvider prov) {
    if (prov.isListLoading) return _shimmerList();
    if (prov.listStatus == OrderStatus.error) return _errorState(prov);

    return TabBarView(
      controller: _tabCtrl,
      children: _kTabs.map((tab) {
        final filtered = _filterOrders(prov.orders, tab);
        if (filtered.isEmpty) return _emptyState(tab);
        return RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: _bgCard,
          onRefresh: _refresh,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 40),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            itemCount: filtered.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _OrderCard(
              order: filtered[i],
              isDark: _d,
              onTap: () =>
                  context.push(AppRoutes.orderDetailPath(filtered[i].id)),
              onTrack: _isActive(filtered[i].status)
                  ? () => context.push(AppRoutes.trackingPath(filtered[i].id))
                  : null,
              onReorder: filtered[i].status.toLowerCase() == 'delivered'
                  ? () => _showReorderDialog(filtered[i])
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }

  List<OrderModel> _filterOrders(List<OrderModel> all, String tab) {
    switch (tab) {
      case 'Active':
        return all.where((o) => _isActive(o.status)).toList();
      case 'Delivered':
        return all.where((o) => o.status.toLowerCase() == 'delivered').toList();
      case 'Cancelled':
        return all.where((o) => o.status.toLowerCase() == 'cancelled').toList();
      default:
        return all;
    }
  }

  // ── Shimmer loading ────────────────────────────────────────
  Widget _shimmerList() => ListView.separated(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 40),
    physics: const NeverScrollableScrollPhysics(),
    itemCount: 5,
    separatorBuilder: (_, _) => const SizedBox(height: 12),
    itemBuilder: (_, _) => _ShimmerCard(isDark: _d),
  );

  // ── Error state ────────────────────────────────────────────
  Widget _errorState(OrderProvider prov) => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 52, color: _txtMut),
          const SizedBox(height: 16),
          Text('Failed to load orders', style: AppTextStyles.heading(_d)),
          const SizedBox(height: 8),
          Text(
            prov.error ?? 'Something went wrong.',
            style: AppTextStyles.bodyMd(_d).copyWith(color: _txtSec),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _refresh,
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

  // ── Empty state (per tab) ──────────────────────────────────
  Widget _emptyState(String tab) => RefreshIndicator(
    color: AppColors.primary,
    backgroundColor: _bgCard,
    onRefresh: _refresh,
    child: ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: _bgCard,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: _border),
                    ),
                    child: Icon(_emptyIcon(tab), size: 44, color: _txtMut),
                  ),
                  const SizedBox(height: 20),
                  Text(_emptyTitle(tab), style: AppTextStyles.heading(_d)),
                  const SizedBox(height: 8),
                  Text(
                    _emptySubtitle(tab),
                    style: AppTextStyles.bodyMd(_d).copyWith(color: _txtSec),
                    textAlign: TextAlign.center,
                  ),
                  if (tab == 'All') ...[
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.home),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.shopping_bag_outlined,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Start Shopping',
                              style: AppTextStyles.button,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );

  IconData _emptyIcon(String tab) {
    switch (tab) {
      case 'Active':
        return Icons.pending_outlined;
      case 'Delivered':
        return Icons.check_circle_outline;
      case 'Cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.shopping_bag_outlined;
    }
  }

  String _emptyTitle(String tab) {
    switch (tab) {
      case 'Active':
        return 'No Active Orders';
      case 'Delivered':
        return 'No Delivered Orders';
      case 'Cancelled':
        return 'No Cancelled Orders';
      default:
        return 'No Orders Yet';
    }
  }

  String _emptySubtitle(String tab) {
    switch (tab) {
      case 'Active':
        return 'You have no orders in progress right now.';
      case 'Delivered':
        return 'Your delivered orders will appear here.';
      case 'Cancelled':
        return 'No orders have been cancelled.';
      default:
        return 'Your order history will appear here\nonce you place your first order.';
    }
  }

  // ── Reorder dialog ─────────────────────────────────────────
  void _showReorderDialog(OrderModel order) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Reorder?', style: AppTextStyles.headingSm(_d)),
        content: Text(
          'Add the same items from this order to your cart?',
          style: AppTextStyles.bodyMd(_d).copyWith(color: _txtSec),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelMd(_d).copyWith(color: _txtSec),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.push(AppRoutes.cart);
            },
            child: Text(
              'Reorder',
              style: AppTextStyles.labelMd(
                _d,
              ).copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback? onTrack;
  final VoidCallback? onReorder;

  const _OrderCard({
    required this.order,
    required this.isDark,
    required this.onTap,
    this.onTrack,
    this.onReorder,
  });

  Color get _bgCard => isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;

  Color get _bgInput => isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput;

  Color get _border => isDark ? AppColorsDark.border : AppColorsLight.border;

  Color get _txtSec =>
      isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;

  Color get _txtMut =>
      isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;

  String _fmt(double v) =>
      '₹${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

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

  String _shortId(String id) {
    final raw = order.orderNumber ?? id;
    return raw.length > 12
        ? raw.substring(raw.length - 12).toUpperCase()
        : raw.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final statusC = _statusColor(order.status);
    final isActive = _isActive(order.status);
    final isCancelled = order.status.toLowerCase() == 'cancelled';

    // Extract first item details
    final firstItem = order.items.isNotEmpty
        ? order.items[0] as Map<String, dynamic>? ?? {}
        : <String, dynamic>{};
    final firstName = firstItem['partName'] as String? ?? 'Auto Part';
    final firstImage = firstItem['image'] as String?;
    final moreCount = order.items.length - 1;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? statusC.withValues(alpha: 0.3) : _border,
            width: isActive ? 1.2 : 1,
          ),
          boxShadow: isActive && !isDark
              ? [
                  BoxShadow(
                    color: statusC.withValues(alpha: 0.07),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 12, 10),
              child: Row(
                children: [
                  // Status dot + label
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusC.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: statusC.withValues(alpha: 0.28),
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
                            color: statusC,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _statusLabel(order.status),
                          style: TextStyle(
                            fontFamily: 'Syne',
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            color: statusC,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Date
                  Text(
                    _formatDate(order.createdAt),
                    style: AppTextStyles.bodyXs(
                      isDark,
                    ).copyWith(color: _txtMut, fontSize: 11),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right_rounded, size: 16, color: _txtMut),
                ],
              ),
            ),

            // ── Product row ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image stack
                  _ItemImageStack(items: order.items, isDark: isDark),
                  const SizedBox(width: 12),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          moreCount > 0
                              ? '$firstName + $moreCount more item${moreCount == 1 ? '' : 's'}'
                              : firstName,
                          style: AppTextStyles.labelMd(isDark),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${order.items.length} item${order.items.length == 1 ? '' : 's'}',
                          style: AppTextStyles.bodyXs(
                            isDark,
                          ).copyWith(color: _txtSec),
                        ),
                        const SizedBox(height: 6),
                        // Order ID
                        Row(
                          children: [
                            Icon(Icons.tag_rounded, size: 11, color: _txtMut),
                            const SizedBox(width: 4),
                            Text(
                              _shortId(order.id),
                              style: AppTextStyles.mono(isDark).copyWith(
                                fontSize: 10,
                                color: _txtMut,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Total
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _fmt(order.total),
                        style: const TextStyle(
                          fontFamily: 'Syne',
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Payment method chip
                      if (order.paymentMethod != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _bgInput,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: _border),
                          ),
                          child: Text(
                            _payLabel(order.paymentMethod!),
                            style: AppTextStyles.bodyXs(
                              isDark,
                            ).copyWith(color: _txtMut, fontSize: 9),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Action strip ──────────────────────────────────
            if (onTrack != null || onReorder != null)
              Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: _border)),
                ),
                child: Row(
                  children: [
                    // View details always available
                    _ActionBtn(
                      icon: Icons.receipt_long_outlined,
                      label: 'View Details',
                      color: _txtSec,
                      isDark: isDark,
                      onTap: onTap,
                    ),
                    if (onTrack != null) ...[
                      Container(width: 1, height: 34, color: _border),
                      _ActionBtn(
                        icon: Icons.location_on_outlined,
                        label: 'Track',
                        color: statusC,
                        isDark: isDark,
                        onTap: onTrack!,
                      ),
                    ],
                    if (onReorder != null) ...[
                      Container(width: 1, height: 34, color: _border),
                      _ActionBtn(
                        icon: Icons.replay_rounded,
                        label: 'Reorder',
                        color: AppColors.primary,
                        isDark: isDark,
                        onTap: onReorder!,
                      ),
                    ],
                  ],
                ),
              )
            else
              // Just view details strip
              Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: _border)),
                ),
                child: _ActionBtn(
                  icon: Icons.receipt_long_outlined,
                  label: 'View Order Details',
                  color: _txtSec,
                  isDark: isDark,
                  onTap: onTap,
                  fullWidth: true,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _payLabel(String method) {
    switch (method) {
      case 'online':
        return 'CARD';
      case 'upi':
        return 'UPI';
      case 'cod':
        return 'COD';
      default:
        return method.toUpperCase();
    }
  }
}

// ─── Item image stack ──────────────────────────────────────────

class _ItemImageStack extends StatelessWidget {
  final List<dynamic> items;
  final bool isDark;

  const _ItemImageStack({required this.items, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final count = items.length.clamp(0, 3);

    if (count == 1) {
      return _ItemThumb(
        item: items[0] as Map<String, dynamic>? ?? {},
        size: 52,
        isDark: isDark,
      );
    }

    // Stack up to 3 thumbnails
    return SizedBox(
      width: 52 + (count - 1) * 14.0,
      height: 52,
      child: Stack(
        children: List.generate(
          count,
          (i) => Positioned(
            left: i * 14.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard,
                  width: 1.5,
                ),
              ),
              child: _ItemThumb(
                item: items[i] as Map<String, dynamic>? ?? {},
                size: 42,
                isDark: isDark,
              ),
            ),
          ),
        ).reversed.toList(),
      ),
    );
  }
}

class _ItemThumb extends StatelessWidget {
  final Map<String, dynamic> item;
  final double size;
  final bool isDark;

  const _ItemThumb({
    required this.item,
    required this.size,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bgInput = isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput;
    final txtMut = isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;
    final image = item['image'] as String?;

    return ClipRRect(
      borderRadius: BorderRadius.circular(9),
      child: Container(
        width: size,
        height: size,
        color: bgInput,
        child: image != null && image.isNotEmpty
            ? Image.network(
                image,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Icon(
                  Icons.settings_outlined,
                  size: size * 0.45,
                  color: txtMut,
                ),
              )
            : Icon(Icons.settings_outlined, size: size * 0.45, color: txtMut),
      ),
    );
  }
}

// ─── Action button ─────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;
  final bool fullWidth;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelSm(
                isDark,
              ).copyWith(color: color, fontSize: 12),
            ),
          ],
        ),
      ),
    );
    return fullWidth ? child : Expanded(child: child);
  }
}

// ═══════════════════════════════════════════════════════════════
// Shimmer Card
// ═══════════════════════════════════════════════════════════════

class _ShimmerCard extends StatefulWidget {
  final bool isDark;

  const _ShimmerCard({required this.isDark});

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
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
                  _Bone(
                    width: 90,
                    height: 22,
                    base: base,
                    bright: bright,
                    t: t,
                  ),
                  const Spacer(),
                  _Bone(
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
                  _Bone(
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
                        _Bone(
                          width: double.infinity,
                          height: 14,
                          base: base,
                          bright: bright,
                          t: t,
                        ),
                        const SizedBox(height: 8),
                        _Bone(
                          width: 100,
                          height: 12,
                          base: base,
                          bright: bright,
                          t: t,
                        ),
                        const SizedBox(height: 8),
                        _Bone(
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
                  _Bone(
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
                  _Bone(
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

class _Bone extends StatelessWidget {
  final double width, height;
  final Color base, bright;
  final double t;
  final double radius;

  const _Bone({
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
      color: Color.lerp(base, bright, (math_sin(t * 3.14159)).abs())!,
      borderRadius: BorderRadius.circular(radius),
    ),
  );

  double math_sin(double x) {
    final nx = x / 3.14159;
    return 4 * nx * (1 - nx);
  }
}
