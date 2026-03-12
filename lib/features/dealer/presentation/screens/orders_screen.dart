import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_theme.dart';
import '../../domain/models/dealer_order_model.dart';
import '../providers/dealer_order_provider.dart';

class DealerOrdersScreen extends StatefulWidget {
  const DealerOrdersScreen({super.key});

  @override
  State<DealerOrdersScreen> createState() => _DealerOrdersScreenState();
}

class _DealerOrdersScreenState extends State<DealerOrdersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  final _searchCtrl = TextEditingController();

  static const _tabs = [
    (label: 'All', filter: null),
    (label: 'New', filter: DealerOrderStatus.newOrder),
    (label: 'Confirmed', filter: DealerOrderStatus.confirmed),
    (label: 'Packed', filter: DealerOrderStatus.packed),
    (label: 'Shipped', filter: DealerOrderStatus.shipped),
    (label: 'Delivered', filter: DealerOrderStatus.delivered),
    (label: 'Returns', filter: DealerOrderStatus.returnRequested),
    (label: 'Cancelled', filter: DealerOrderStatus.cancelled),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        context.read<DealerOrderProvider>().setStatusFilter(
          _tabs[_tabCtrl.index].filter,
        );
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DealerOrderProvider>().loadOrders();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Theme helpers ─────────────────────────────────────────
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _bg => _isDark ? AppColorsDark.bg : AppColorsLight.bg;

  Color get _bgCard => _isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;

  Color get _bgInput =>
      _isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput;

  Color get _border => _isDark ? AppColorsDark.border : AppColorsLight.border;

  Color get _textPri =>
      _isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary;

  Color get _textSec =>
      _isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;

  Color get _textMut =>
      _isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;

  void _openSort() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _SortSheet(isDark: _isDark),
    );
  }

  void _openDetail(DealerOrder order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _OrderDetailSheet(order: order, isDark: _isDark),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DealerOrderProvider>();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Icon(Icons.arrow_back_ios_new, size: 18, color: _textPri),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Orders', style: AppTextStyles.headingSm(_isDark)),
            Text(
              'Dealer Panel',
              style: AppTextStyles.bodyXs(
                _isDark,
              ).copyWith(color: AppColors.primary),
            ),
          ],
        ),
        actions: [
          // New orders badge
          if (provider.newOrderCount > 0)
            Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${provider.newOrderCount} New',
                    style: AppTextStyles.labelXs(
                      _isDark,
                    ).copyWith(color: AppColors.primary, letterSpacing: 0.3),
                  ),
                ],
              ),
            ),
          GestureDetector(
            onTap: _openSort,
            child: Container(
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _bgCard,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: _border),
              ),
              child: Icon(Icons.sort, size: 18, color: _textSec),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: provider.setSearch,
                  style: AppTextStyles.bodyMd(_isDark),
                  decoration: InputDecoration(
                    hintText: 'Search order no., buyer, SKU…',
                    hintStyle: AppTextStyles.bodyMd(
                      _isDark,
                    ).copyWith(color: _textMut),
                    filled: true,
                    fillColor: _bgInput,
                    prefixIcon: Icon(Icons.search, size: 18, color: _textMut),
                    suffixIcon: provider.searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchCtrl.clear();
                              provider.setSearch('');
                            },
                            child: Icon(Icons.close, size: 16, color: _textMut),
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: _border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: _border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              // Tab bar
              TabBar(
                controller: _tabCtrl,
                isScrollable: true,
                labelStyle: AppTextStyles.labelSm(
                  _isDark,
                ).copyWith(color: AppColors.primary, fontSize: 12),
                unselectedLabelStyle: AppTextStyles.labelSm(
                  _isDark,
                ).copyWith(fontSize: 12),
                indicatorColor: AppColors.primary,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: _border,
                tabAlignment: TabAlignment.start,
                tabs: _tabs.map((t) => Tab(text: t.label)).toList(),
              ),
            ],
          ),
        ),
      ),

      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Column(
              children: [
                // ── Stats row ────────────────────────────────────
                _StatsRow(provider: provider, isDark: _isDark),

                // ── Order list ───────────────────────────────────
                Expanded(
                  child: provider.orders.isEmpty
                      ? _EmptyState(isDark: _isDark)
                      : RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: () => provider.loadOrders(),
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            itemCount: provider.orders.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (_, i) => _OrderCard(
                              order: provider.orders[i],
                              isDark: _isDark,
                              onTap: () => _openDetail(provider.orders[i]),
                              onAdvance: () =>
                                  provider.advanceStatus(provider.orders[i].id),
                            ),
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// Stats Row
// ═════════════════════════════════════════════════════════════

class _StatsRow extends StatelessWidget {
  final DealerOrderProvider provider;
  final bool isDark;

  const _StatsRow({required this.provider, required this.isDark});

  String _fmt(double v) => v >= 1000
      ? '₹${(v / 1000).toStringAsFixed(1)}K'
      : '₹${v.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    final bgCard = isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          _StatCell(
            label: 'Pending',
            value: '${provider.pendingCount}',
            isDark: isDark,
          ),
          _VDivider(isDark: isDark),
          _StatCell(
            label: 'Delivered',
            value: '${provider.deliveredCount}',
            isDark: isDark,
            valueColor: AppColorsDark.success,
          ),
          _VDivider(isDark: isDark),
          _StatCell(
            label: 'Returns',
            value: '${provider.returnCount}',
            isDark: isDark,
            valueColor: provider.returnCount > 0 ? AppColorsDark.warning : null,
          ),
          _VDivider(isDark: isDark),
          _StatCell(
            label: 'Revenue',
            value: _fmt(provider.totalRevenue),
            isDark: isDark,
            small: true,
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  final bool isDark, small;

  const _StatCell({
    required this.label,
    required this.value,
    this.valueColor,
    required this.isDark,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Syne',
              fontWeight: FontWeight.w800,
              fontSize: small ? 13 : 20,
              color:
                  valueColor ??
                  (isDark
                      ? AppColorsDark.textPrimary
                      : AppColorsLight.textPrimary),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.bodyXs(isDark),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class _VDivider extends StatelessWidget {
  final bool isDark;

  const _VDivider({required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 36,
    color: isDark ? AppColorsDark.border : AppColorsLight.border,
  );
}

// ═════════════════════════════════════════════════════════════
// Order Card
// ═════════════════════════════════════════════════════════════

class _OrderCard extends StatelessWidget {
  final DealerOrder order;
  final bool isDark;
  final VoidCallback onTap, onAdvance;

  const _OrderCard({
    required this.order,
    required this.isDark,
    required this.onTap,
    required this.onAdvance,
  });

  String _fmt(double v) =>
      '₹${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Color _statusColor(DealerOrderStatus s) {
    switch (s) {
      case DealerOrderStatus.newOrder:
        return AppColors.primary;
      case DealerOrderStatus.confirmed:
        return AppColorsDark.info;
      case DealerOrderStatus.processing:
      case DealerOrderStatus.packed:
        return AppColorsDark.warning;
      case DealerOrderStatus.shipped:
      case DealerOrderStatus.outForDelivery:
        return const Color(0xFF8B5CF6);
      case DealerOrderStatus.delivered:
        return AppColorsDark.success;
      case DealerOrderStatus.cancelled:
        return AppColorsDark.error;
      case DealerOrderStatus.returnRequested:
        return AppColorsDark.warning;
      case DealerOrderStatus.returned:
        return AppColorsDark.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgCard = isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;
    final bgInput = isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;
    final textSec = isDark
        ? AppColorsDark.textSecondary
        : AppColorsLight.textSecondary;
    final textMut = isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;

    final sColor = _statusColor(order.status);
    final isNew = order.status == DealerOrderStatus.newOrder;
    final nextAction = order.status.nextActionLabel;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgCard,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(
            color: isNew ? AppColors.primary.withValues(alpha: 0.4) : border,
            width: isNew ? 1.5 : 1,
          ),
          boxShadow: isNew
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Row(
                children: [
                  // Order number + time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (isNew)
                              Container(
                                width: 7,
                                height: 7,
                                margin: const EdgeInsets.only(right: 5),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            Text(
                              order.orderNumber,
                              style: AppTextStyles.labelMd(
                                isDark,
                              ).copyWith(fontFamily: 'Syne'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            // Buyer name
                            Text(
                              order.buyer.name,
                              style: AppTextStyles.bodySm(
                                isDark,
                              ).copyWith(color: textSec),
                            ),
                            if (order.buyer.isB2b) ...[
                              const SizedBox(width: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColorsDark.info.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'B2B',
                                  style: TextStyle(
                                    fontFamily: 'Syne',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 9,
                                    color: AppColorsDark.info,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Status + time
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: sColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          order.status.label,
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            color: sColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _timeAgo(order.createdAt),
                        style: AppTextStyles.bodyXs(isDark),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Items summary ──────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgInput.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: border),
              ),
              child: Column(
                children:
                    order.items
                        .take(2)
                        .map(
                          (item) => Padding(
                            padding: EdgeInsets.only(
                              bottom:
                                  order.items.indexOf(item) <
                                      order.items.length - 1
                                  ? 6
                                  : 0,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.partName,
                                    style: AppTextStyles.bodySm(isDark),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '×${item.quantity}',
                                  style: AppTextStyles.labelXs(isDark).copyWith(
                                    color: textMut,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _fmt(item.lineTotal),
                                  style: AppTextStyles.priceSm(),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList()
                      ..addAll(
                        order.items.length > 2
                            ? [
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    '+${order.items.length - 2} more item(s)',
                                    style: AppTextStyles.bodyXs(isDark),
                                  ),
                                ),
                              ]
                            : [],
                      ),
              ),
            ),

            // ── Footer row ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Row(
                children: [
                  // Payment
                  Icon(
                    order.isPaid ? Icons.check_circle : Icons.schedule,
                    size: 13,
                    color: order.isPaid
                        ? AppColorsDark.success
                        : AppColorsDark.warning,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    order.isPaid
                        ? 'Paid · ${order.paymentMethod}'
                        : 'Pending · ${order.paymentMethod}',
                    style: AppTextStyles.bodyXs(isDark).copyWith(
                      color: order.isPaid
                          ? AppColorsDark.success
                          : AppColorsDark.warning,
                    ),
                  ),
                  const Spacer(),
                  // Total
                  Text(
                    '${order.totalQuantity} item${order.totalQuantity > 1 ? 's' : ''} · ',
                    style: AppTextStyles.bodyXs(isDark),
                  ),
                  Text(
                    _fmt(order.total),
                    style: AppTextStyles.priceSm().copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            // ── Action button (if applicable) ──────────────────
            if (nextAction != null)
              Container(
                margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Row(
                  children: [
                    // Detail button
                    GestureDetector(
                      onTap: onTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: bgInput,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(color: border),
                        ),
                        child: Text(
                          'View Details',
                          style: AppTextStyles.labelSm(
                            isDark,
                          ).copyWith(fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Advance button
                    Expanded(
                      child: GestureDetector(
                        onTap: onAdvance,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _actionIcon(order.status),
                                  size: 13,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  nextAction,
                                  style: AppTextStyles.buttonSm.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Tracking chip (if shipped) ─────────────────────
            if (order.trackingNumber != null &&
                order.status == DealerOrderStatus.shipped)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_shipping_outlined,
                        size: 13,
                        color: Color(0xFF8B5CF6),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${order.courierPartner} · ${order.trackingNumber}',
                        style: AppTextStyles.labelXs(isDark).copyWith(
                          color: const Color(0xFF8B5CF6),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Clipboard.setData(
                          ClipboardData(text: order.trackingNumber!),
                        ),
                        child: const Icon(
                          Icons.copy,
                          size: 12,
                          color: Color(0xFF8B5CF6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _actionIcon(DealerOrderStatus s) {
    if (s == DealerOrderStatus.newOrder) return Icons.check_outlined;
    if (s == DealerOrderStatus.confirmed || s == DealerOrderStatus.processing) {
      return Icons.inventory_2_outlined;
    }
    if (s == DealerOrderStatus.packed) return Icons.local_shipping_outlined;
    if (s.canDeliver) return Icons.done_all;
    if (s == DealerOrderStatus.returnRequested) {
      return Icons.assignment_return_outlined;
    }
    return Icons.arrow_forward;
  }
}

// ═════════════════════════════════════════════════════════════
// Order Detail Sheet
// ═════════════════════════════════════════════════════════════

class _OrderDetailSheet extends StatefulWidget {
  final DealerOrder order;
  final bool isDark;

  const _OrderDetailSheet({required this.order, required this.isDark});

  @override
  State<_OrderDetailSheet> createState() => _OrderDetailSheetState();
}

class _OrderDetailSheetState extends State<_OrderDetailSheet> {
  bool get _isDark => widget.isDark;

  Color get _border => _isDark ? AppColorsDark.border : AppColorsLight.border;

  Color get _textSec =>
      _isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;

  String _fmt(double v) =>
      '₹${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DealerOrderProvider>();
    // Get the live order from provider (status might have changed)
    final order = provider.orders.firstWhere(
      (o) => o.id == widget.order.id,
      orElse: () => widget.order,
    );

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.88,
      maxChildSize: 0.97,
      builder: (_, ctrl) => Column(
        children: [
          // ── Handle ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
            child: Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: _border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // ── Title bar ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.orderNumber,
                        style: AppTextStyles.heading(_isDark),
                      ),
                      Text(
                        _formatDate(order.createdAt),
                        style: AppTextStyles.bodyXs(_isDark),
                      ),
                    ],
                  ),
                ),
                _StatusPill(status: order.status),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              controller: ctrl,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                // ── Timeline ─────────────────────────────────────
                _SectionCard(
                  title: 'Order Timeline',
                  icon: Icons.timeline,
                  isDark: _isDark,
                  child: _Timeline(events: order.timeline, isDark: _isDark),
                ),
                const SizedBox(height: 12),

                // ── Items ─────────────────────────────────────────
                _SectionCard(
                  title: 'Items (${order.items.length})',
                  icon: Icons.inventory_2_outlined,
                  isDark: _isDark,
                  child: Column(
                    children: order.items
                        .asMap()
                        .entries
                        .map(
                          (e) => Padding(
                            padding: EdgeInsets.only(
                              top: e.key > 0 ? 10 : 0,
                              bottom: e.key < order.items.length - 1 ? 10 : 0,
                            ),
                            child: Column(
                              children: [
                                if (e.key > 0)
                                  Divider(height: 0, color: _border),
                                if (e.key > 0) const SizedBox(height: 10),
                                _ItemRow(
                                  item: e.value,
                                  isDark: _isDark,
                                  fmt: _fmt,
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Price breakdown ───────────────────────────────
                _SectionCard(
                  title: 'Price Breakdown',
                  icon: Icons.currency_rupee,
                  isDark: _isDark,
                  child: Column(
                    children: [
                      _PriceRow(
                        'Subtotal',
                        _fmt(order.subtotal),
                        isDark: _isDark,
                      ),
                      if (order.discount > 0)
                        _PriceRow(
                          'Discount',
                          '-${_fmt(order.discount)}',
                          isDark: _isDark,
                          color: AppColorsDark.success,
                        ),
                      if (order.deliveryCharge > 0)
                        _PriceRow(
                          'Delivery',
                          _fmt(order.deliveryCharge),
                          isDark: _isDark,
                        )
                      else
                        _PriceRow(
                          'Delivery',
                          'FREE',
                          isDark: _isDark,
                          color: AppColorsDark.success,
                        ),
                      Divider(color: _border, height: 20),
                      _PriceRow(
                        'Total',
                        _fmt(order.total),
                        isDark: _isDark,
                        bold: true,
                        large: true,
                      ),
                      const SizedBox(height: 6),
                      _PriceRow(
                        'Payment',
                        '${order.isPaid ? "Paid" : "Pending"} · ${order.paymentMethod}',
                        isDark: _isDark,
                        color: order.isPaid
                            ? AppColorsDark.success
                            : AppColorsDark.warning,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ── Buyer & Address ───────────────────────────────
                _SectionCard(
                  title: 'Buyer',
                  icon: Icons.person_outline,
                  isDark: _isDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                order.buyer.name[0].toUpperCase(),
                                style: const TextStyle(
                                  fontFamily: 'Syne',
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      order.buyer.name,
                                      style: AppTextStyles.labelMd(_isDark),
                                    ),
                                    if (order.buyer.isB2b) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColorsDark.info.withValues(
                                            alpha: 0.12,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          'B2B',
                                          style: TextStyle(
                                            fontFamily: 'Syne',
                                            fontWeight: FontWeight.w800,
                                            fontSize: 9,
                                            color: AppColorsDark.info,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                if (order.buyer.businessName != null)
                                  Text(
                                    order.buyer.businessName!,
                                    style: AppTextStyles.bodySm(
                                      _isDark,
                                    ).copyWith(color: _textSec),
                                  ),
                                Text(
                                  order.buyer.phone,
                                  style: AppTextStyles.mono(
                                    _isDark,
                                  ).copyWith(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          // Call / WhatsApp buttons
                          Row(
                            children: [
                              _CircleIconBtn(
                                icon: Icons.call_outlined,
                                isDark: _isDark,
                                color: AppColorsDark.success,
                                onTap: () {},
                              ),
                              const SizedBox(width: 6),
                              _CircleIconBtn(
                                icon: Icons.message_outlined,
                                isDark: _isDark,
                                color: AppColorsDark.info,
                                onTap: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                      Divider(color: _border, height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 15,
                            color: _textSec,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${order.address.line1}${order.address.line2 != null ? ", ${order.address.line2}" : ""}, '
                              '${order.address.city}, ${order.address.state} – ${order.address.pincode}',
                              style: AppTextStyles.bodySm(_isDark),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ── Tracking (if shipped) ─────────────────────────
                if (order.trackingNumber != null)
                  _SectionCard(
                    title: 'Shipment',
                    icon: Icons.local_shipping_outlined,
                    isDark: _isDark,
                    child: Column(
                      children: [
                        _PriceRow(
                          'Courier',
                          order.courierPartner ?? '—',
                          isDark: _isDark,
                        ),
                        _PriceRow(
                          'Tracking',
                          order.trackingNumber!,
                          isDark: _isDark,
                          mono: true,
                        ),
                      ],
                    ),
                  ),

                if (order.trackingNumber != null) const SizedBox(height: 12),

                // ── Actions ──────────────────────────────────────
                _ActionsSection(order: order, isDark: _isDark),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
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
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ═════════════════════════════════════════════════════════════
// Actions Section (inside detail sheet)
// ═════════════════════════════════════════════════════════════

class _ActionsSection extends StatelessWidget {
  final DealerOrder order;
  final bool isDark;

  const _ActionsSection({required this.order, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DealerOrderProvider>();
    final isActing = provider.isActing;

    final nextAction = order.status.nextActionLabel;
    final canCancel = order.status.canCancel;
    final isShipped = order.status == DealerOrderStatus.packed; // about to ship

    return Column(
      children: [
        // Primary advance action
        if (nextAction != null && !isShipped)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isActing
                  ? null
                  : () async {
                      await context.read<DealerOrderProvider>().advanceStatus(
                        order.id,
                      );
                    },
              icon: const Icon(
                Icons.arrow_forward,
                size: 16,
                color: Colors.white,
              ),
              label: Text(nextAction, style: AppTextStyles.buttonSm),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

        // Ship action (needs tracking info)
        if (isShipped)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isActing ? null : () => _showShipDialog(context),
              icon: const Icon(
                Icons.local_shipping_outlined,
                size: 16,
                color: Colors.white,
              ),
              label: const Text(
                'Mark as Shipped',
                style: AppTextStyles.buttonSm,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

        if (nextAction != null) const SizedBox(height: 10),

        // Return accept
        if (order.status == DealerOrderStatus.returnRequested)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isActing
                  ? null
                  : () async {
                      await context.read<DealerOrderProvider>().acceptReturn(
                        order.id,
                      );
                    },
              icon: const Icon(
                Icons.assignment_return_outlined,
                size: 16,
                color: Colors.white,
              ),
              label: const Text('Accept Return', style: AppTextStyles.buttonSm),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorsDark.warning,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

        // Cancel button
        if (canCancel) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isActing ? null : () => _showCancelDialog(context),
              icon: Icon(
                Icons.cancel_outlined,
                size: 16,
                color: AppColorsDark.error,
              ),
              label: Text(
                'Cancel Order',
                style: AppTextStyles.buttonSm.copyWith(
                  color: AppColorsDark.error,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: AppColorsDark.error.withValues(alpha: 0.5),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showShipDialog(BuildContext ctx) {
    final trackCtrl = TextEditingController();
    final courierCtrl = TextEditingController();
    final isDark = this.isDark;
    final bgCard = isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;
    final bgInput = isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput;
    final textMut = isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sCtx) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(sCtx).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text('Add Tracking Details', style: AppTextStyles.heading(isDark)),
            const SizedBox(height: 16),
            _LabeledField(
              label: 'Courier Partner',
              ctrl: courierCtrl,
              hint: 'e.g. Delhivery, Shiprocket',
              isDark: isDark,
              bgInput: bgInput,
              border: border,
              textMuted: textMut,
            ),
            const SizedBox(height: 12),
            _LabeledField(
              label: 'Tracking Number',
              ctrl: trackCtrl,
              hint: 'e.g. SHP1234567890',
              isDark: isDark,
              bgInput: bgInput,
              border: border,
              textMuted: textMut,
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (trackCtrl.text.trim().isEmpty ||
                      courierCtrl.text.trim().isEmpty) {
                    return;
                  }
                  await ctx.read<DealerOrderProvider>().addTracking(
                    order.id,
                    trackingNumber: trackCtrl.text.trim(),
                    courier: courierCtrl.text.trim(),
                  );
                  if (sCtx.mounted) Navigator.pop(sCtx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Confirm Shipment',
                  style: AppTextStyles.button,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext ctx) {
    String? reason;
    final isDark = this.isDark;
    final bgCard = isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;

    const reasons = [
      'Out of stock',
      'Item damaged / defective',
      'Buyer requested cancellation',
      'Incorrect order',
      'Unable to deliver to address',
      'Other',
    ];

    showModalBottomSheet(
      context: ctx,
      backgroundColor: bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sCtx) => StatefulBuilder(
        builder: (_, setSheet) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Reason for Cancellation',
                style: AppTextStyles.heading(isDark),
              ),
              const SizedBox(height: 12),
              ...reasons.map(
                (r) => GestureDetector(
                  onTap: () => setSheet(() => reason = r),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: reason == r
                          ? AppColors.primary.withValues(alpha: 0.08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: reason == r
                            ? AppColors.primary.withValues(alpha: 0.4)
                            : border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(r, style: AppTextStyles.bodyMd(isDark)),
                        ),
                        if (reason == r)
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                            size: 16,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: reason == null
                      ? null
                      : () async {
                          await ctx.read<DealerOrderProvider>().cancelOrder(
                            order.id,
                            reason!,
                          );
                          if (sCtx.mounted) Navigator.pop(sCtx);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColorsDark.error,
                    disabledBackgroundColor: isDark
                        ? AppColorsDark.bgInput
                        : AppColorsLight.bgInput,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancel Order',
                    style: AppTextStyles.button,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// Timeline widget
// ═════════════════════════════════════════════════════════════

class _Timeline extends StatelessWidget {
  final List<OrderTimelineEvent> events;
  final bool isDark;

  const _Timeline({required this.events, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textMut = isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;
    return Column(
      children: events.asMap().entries.map((e) {
        final ev = e.value;
        final isLast = e.key == events.length - 1;
        final color = ev.isActive
            ? AppColors.primary
            : ev.isDone
            ? AppColorsDark.success
            : textMut;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dot + line
            Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: ev.isDone ? 0.15 : 0.06),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color,
                      width: ev.isActive ? 2 : 1.5,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      ev.isDone ? Icons.check : Icons.radio_button_unchecked,
                      size: 10,
                      color: color,
                    ),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 1.5,
                    height: 36,
                    color: ev.isDone
                        ? AppColorsDark.success.withValues(alpha: 0.3)
                        : textMut.withValues(alpha: 0.2),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 1, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ev.title,
                      style: AppTextStyles.labelSm(isDark).copyWith(
                        color: ev.isActive ? AppColors.primary : null,
                        fontSize: 13,
                      ),
                    ),
                    if (ev.description != null)
                      Text(
                        ev.description!,
                        style: AppTextStyles.bodyXs(isDark).copyWith(
                          color: isDark
                              ? AppColorsDark.textMuted
                              : AppColorsLight.textMuted,
                        ),
                      ),
                    if (ev.timestamp != null)
                      Text(
                        _fmtTime(ev.timestamp!),
                        style: AppTextStyles.bodyXs(isDark),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  String _fmtTime(DateTime dt) {
    const months = [
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
    return '${dt.day} ${months[dt.month - 1]}, '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ═════════════════════════════════════════════════════════════
// Sort Sheet
// ═════════════════════════════════════════════════════════════

class _SortSheet extends StatelessWidget {
  final bool isDark;

  const _SortSheet({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DealerOrderProvider>();
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;

    const options = [
      ('newest', 'Newest First'),
      ('oldest', 'Oldest First'),
      ('totalHigh', 'Order Value: High → Low'),
      ('totalLow', 'Order Value: Low → High'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text('Sort Orders', style: AppTextStyles.heading(isDark)),
          const SizedBox(height: 12),
          ...options.map(
            (o) => InkWell(
              onTap: () {
                provider.setSortBy(o.$1);
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 13,
                  horizontal: 4,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(o.$2, style: AppTextStyles.bodyMd(isDark)),
                    ),
                    if (provider.sortBy == o.$1)
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        size: 18,
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

// ═════════════════════════════════════════════════════════════
// Empty State
// ═════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  final bool isDark;

  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bgCard = isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;
    final textSec = isDark
        ? AppColorsDark.textSecondary
        : AppColorsLight.textSecondary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: bgCard,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: border),
              ),
              child: Center(
                child: Icon(
                  Icons.receipt_long_outlined,
                  size: 44,
                  color: isDark
                      ? AppColorsDark.textMuted
                      : AppColorsLight.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('No orders found', style: AppTextStyles.heading(isDark)),
            const SizedBox(height: 8),
            Text(
              'Incoming orders from buyers will appear here.',
              style: AppTextStyles.bodyMd(isDark).copyWith(color: textSec),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// Reusable small widgets
// ═════════════════════════════════════════════════════════════

class _StatusPill extends StatelessWidget {
  final DealerOrderStatus status;

  const _StatusPill({required this.status});

  Color get _color {
    switch (status) {
      case DealerOrderStatus.newOrder:
        return AppColors.primary;
      case DealerOrderStatus.confirmed:
        return AppColorsDark.info;
      case DealerOrderStatus.processing:
      case DealerOrderStatus.packed:
        return AppColorsDark.warning;
      case DealerOrderStatus.shipped:
      case DealerOrderStatus.outForDelivery:
        return const Color(0xFF8B5CF6);
      case DealerOrderStatus.delivered:
        return AppColorsDark.success;
      case DealerOrderStatus.cancelled:
        return AppColorsDark.error;
      case DealerOrderStatus.returnRequested:
        return AppColorsDark.warning;
      case DealerOrderStatus.returned:
        return AppColorsDark.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(
      color: _color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _color.withValues(alpha: 0.3)),
    ),
    child: Text(
      status.label,
      style: TextStyle(
        fontFamily: 'DMSans',
        fontWeight: FontWeight.w700,
        fontSize: 11,
        color: _color,
      ),
    ),
  );
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isDark;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.isDark,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bgCard = isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;

    return Container(
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                Icon(icon, size: 15, color: AppColors.primary),
                const SizedBox(width: 7),
                Text(
                  title,
                  style: AppTextStyles.labelMd(
                    isDark,
                  ).copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
          Divider(height: 0, color: border),
          Padding(padding: const EdgeInsets.all(14), child: child),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final DealerOrderItem item;
  final bool isDark;
  final String Function(double) fmt;

  const _ItemRow({required this.item, required this.isDark, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final bgInput = isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput;
    final textMut = isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 48,
            height: 48,
            color: bgInput,
            child: item.partImage != null
                ? Image.network(item.partImage!, fit: BoxFit.contain)
                : Center(
                    child: Icon(
                      Icons.settings_outlined,
                      size: 20,
                      color: textMut,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.partName,
                style: AppTextStyles.labelMd(isDark),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'SKU: ${item.partSku}',
                style: AppTextStyles.mono(isDark).copyWith(fontSize: 10),
              ),
              Text(
                '${fmt(item.unitPrice)} × ${item.quantity}',
                style: AppTextStyles.bodyXs(isDark),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(fmt(item.lineTotal), style: AppTextStyles.priceSm()),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label, value;
  final bool isDark, bold, large;
  final Color? color;
  final bool mono;

  const _PriceRow(
    this.label,
    this.value, {
    required this.isDark,
    this.bold = false,
    this.large = false,
    this.color,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    final textSec = isDark
        ? AppColorsDark.textSecondary
        : AppColorsLight.textSecondary;
    final labelStyle = bold
        ? AppTextStyles.labelMd(isDark)
        : AppTextStyles.bodySm(isDark).copyWith(color: textSec);
    final valueStyle = mono
        ? AppTextStyles.mono(isDark).copyWith(fontSize: 11, color: color)
        : bold
        ? TextStyle(
            fontFamily: 'Syne',
            fontWeight: FontWeight.w800,
            fontSize: large ? 18 : 14,
            color:
                color ??
                (isDark
                    ? AppColorsDark.textPrimary
                    : AppColorsLight.textPrimary),
          )
        : AppTextStyles.bodySm(isDark).copyWith(color: color);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(label, style: labelStyle),
          const Spacer(),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
}

class _CircleIconBtn extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final Color color;
  final VoidCallback onTap;

  const _CircleIconBtn({
    required this.icon,
    required this.isDark,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Icon(icon, size: 16, color: color),
    ),
  );
}

class _LabeledField extends StatelessWidget {
  final String label, hint;
  final TextEditingController ctrl;
  final bool isDark;
  final Color bgInput, border, textMuted;
  final TextCapitalization textCapitalization;

  const _LabeledField({
    required this.label,
    required this.ctrl,
    required this.hint,
    required this.isDark,
    required this.bgInput,
    required this.border,
    required this.textMuted,
    this.textCapitalization = TextCapitalization.words,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: AppTextStyles.labelSm(isDark).copyWith(
          fontSize: 12,
          color: isDark
              ? AppColorsDark.textSecondary
              : AppColorsLight.textSecondary,
        ),
      ),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        textCapitalization: textCapitalization,
        style: AppTextStyles.bodyMd(isDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMd(isDark).copyWith(color: textMuted),
          filled: true,
          fillColor: bgInput,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    ],
  );
}
