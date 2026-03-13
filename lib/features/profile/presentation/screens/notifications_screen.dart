import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/domain/models/user_model.dart';

// ═══════════════════════════════════════════════════════════════
// Notification model
// ═══════════════════════════════════════════════════════════════

enum NotifType {
  order,
  payment,
  delivery,
  promo,
  system,
  newOrder,
  lowStock,
  payout,
  review,
}

class NotifItem {
  final String id;
  final NotifType type;
  final String title;
  final String body;
  final DateTime time;
  final bool isRead;
  final String? actionRoute;
  final String? actionId;

  const NotifItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    this.isRead = false,
    this.actionRoute,
    this.actionId,
  });

  NotifItem copyWith({bool? isRead}) => NotifItem(
    id: id,
    type: type,
    title: title,
    body: body,
    time: time,
    isRead: isRead ?? this.isRead,
    actionRoute: actionRoute,
    actionId: actionId,
  );
}

// ─── Notification metadata ────────────────────────────────────

IconData _notifIcon(NotifType t) {
  switch (t) {
    case NotifType.order:
      return Icons.shopping_bag_outlined;
    case NotifType.payment:
      return Icons.payment_outlined;
    case NotifType.delivery:
      return Icons.local_shipping_outlined;
    case NotifType.promo:
      return Icons.local_offer_outlined;
    case NotifType.system:
      return Icons.info_outline;
    case NotifType.newOrder:
      return Icons.add_shopping_cart_outlined;
    case NotifType.lowStock:
      return Icons.inventory_2_outlined;
    case NotifType.payout:
      return Icons.account_balance_wallet_outlined;
    case NotifType.review:
      return Icons.star_border_rounded;
  }
}

Color _notifColor(NotifType t) {
  switch (t) {
    case NotifType.order:
      return AppColorsDark.info;
    case NotifType.payment:
      return AppColorsDark.success;
    case NotifType.delivery:
      return Color(0xFF8B5CF6);
    case NotifType.promo:
      return AppColors.primary;
    case NotifType.system:
      return AppColorsDark.textSecondary;
    case NotifType.newOrder:
      return AppColorsDark.success;
    case NotifType.lowStock:
      return AppColorsDark.warning;
    case NotifType.payout:
      return Color(0xFF10B981);
    case NotifType.review:
      return AppColorsDark.warning;
  }
}

String _notifCategory(NotifType t) {
  switch (t) {
    case NotifType.order:
    case NotifType.payment:
    case NotifType.delivery:
      return 'Orders & Delivery';
    case NotifType.promo:
      return 'Offers & Promos';
    case NotifType.system:
      return 'System';
    case NotifType.newOrder:
      return 'New Orders';
    case NotifType.lowStock:
      return 'Inventory';
    case NotifType.payout:
      return 'Payments';
    case NotifType.review:
      return 'Reviews';
  }
}

// ─── Sample data generators ───────────────────────────────────

List<NotifItem> _customerNotifs() {
  final now = DateTime.now();
  return [
    NotifItem(
      id: 'n1',
      type: NotifType.delivery,
      isRead: false,
      title: 'Order Out for Delivery! 🚚',
      body:
          'Your order #ORD-2847 is out for delivery. Expected by 6:00 PM today.',
      time: now.subtract(const Duration(minutes: 14)),
      actionRoute: AppRoutes.orders,
    ),
    NotifItem(
      id: 'n2',
      type: NotifType.order,
      isRead: false,
      title: 'Order Confirmed',
      body:
          'Your order for Bosch Spark Plugs (×4) has been confirmed. '
          'Seller is preparing your shipment.',
      time: now.subtract(const Duration(hours: 1, minutes: 32)),
      actionRoute: AppRoutes.orders,
    ),
    NotifItem(
      id: 'n3',
      type: NotifType.promo,
      isRead: false,
      title: '20% Off on Brake Parts 🎉',
      body:
          'Flash sale! Use code BRAKE20 to save 20% on all brake pads, '
          'rotors and calipers. Ends midnight.',
      time: now.subtract(const Duration(hours: 3)),
    ),
    NotifItem(
      id: 'n4',
      type: NotifType.payment,
      isRead: true,
      title: 'Payment Successful',
      body: 'Payment of ₹2,450 for order #ORD-2847 was processed successfully.',
      time: now.subtract(const Duration(hours: 5, minutes: 10)),
    ),
    NotifItem(
      id: 'n5',
      type: NotifType.delivery,
      isRead: true,
      title: 'Order Delivered ✅',
      body:
          'Your order #ORD-2801 has been delivered. '
          'Hope you\'re satisfied with your purchase!',
      time: now.subtract(const Duration(days: 1, hours: 2)),
      actionRoute: AppRoutes.orders,
    ),
    NotifItem(
      id: 'n6',
      type: NotifType.promo,
      isRead: true,
      title: 'Your Wishlist Item is Back!',
      body:
          'K&N Air Filter for Honda City is back in stock. '
          'Order before it runs out again.',
      time: now.subtract(const Duration(days: 2)),
    ),
    NotifItem(
      id: 'n7',
      type: NotifType.order,
      isRead: true,
      title: 'Order Shipped',
      body:
          'Order #ORD-2801 has been shipped via Delhivery. '
          'Tracking ID: DEL9283746.',
      time: now.subtract(const Duration(days: 3, hours: 6)),
      actionRoute: AppRoutes.orders,
    ),
    NotifItem(
      id: 'n8',
      type: NotifType.system,
      isRead: true,
      title: 'Profile Verified',
      body:
          'Your account has been verified. You can now access '
          'all features including B2B pricing.',
      time: now.subtract(const Duration(days: 5)),
    ),
    NotifItem(
      id: 'n9',
      type: NotifType.promo,
      isRead: true,
      title: 'New Arrivals: Engine Parts',
      body: 'Check out 200+ newly listed engine parts from trusted sellers.',
      time: now.subtract(const Duration(days: 7)),
    ),
    NotifItem(
      id: 'n10',
      type: NotifType.payment,
      isRead: true,
      title: 'Refund Processed',
      body:
          'Refund of ₹850 for cancelled order #ORD-2790 has been initiated. '
          'Credit in 3–5 business days.',
      time: now.subtract(const Duration(days: 10)),
    ),
  ];
}

List<NotifItem> _dealerNotifs() {
  final now = DateTime.now();
  return [
    NotifItem(
      id: 'd1',
      type: NotifType.newOrder,
      isRead: false,
      title: 'New Order Received! 🛒',
      body:
          'You have a new order for Mahindra XUV700 Front Brake Pads (×2). '
          'Accept within 2 hours.',
      time: now.subtract(const Duration(minutes: 6)),
      actionRoute: AppRoutes.orders,
    ),
    NotifItem(
      id: 'd2',
      type: NotifType.newOrder,
      isRead: false,
      title: 'Urgent: Order Pending',
      body:
          'Order #ORD-5931 for Bosch Wiper Blades is awaiting your '
          'confirmation. 1h 24m remaining.',
      time: now.subtract(const Duration(minutes: 36)),
      actionRoute: AppRoutes.orders,
    ),
    NotifItem(
      id: 'd3',
      type: NotifType.payout,
      isRead: false,
      title: 'Payout Processed 💰',
      body:
          '₹18,450 has been transferred to your bank account ending 4521. '
          'Settlement ID: SET-3984.',
      time: now.subtract(const Duration(hours: 2)),
    ),
    NotifItem(
      id: 'd4',
      type: NotifType.lowStock,
      isRead: false,
      title: 'Low Stock Alert ⚠️',
      body:
          '3 products are running low: Bosch Spark Plugs (2 left), '
          'Havoline Engine Oil (1 left), WD-40 (3 left).',
      time: now.subtract(const Duration(hours: 4)),
    ),
    NotifItem(
      id: 'd5',
      type: NotifType.review,
      isRead: true,
      title: 'New 5-Star Review ⭐',
      body:
          'Rahul S. rated your store 5 stars: "Great quality parts, '
          'fast delivery!"',
      time: now.subtract(const Duration(hours: 18)),
    ),
    NotifItem(
      id: 'd6',
      type: NotifType.newOrder,
      isRead: true,
      title: 'Order Cancelled by Customer',
      body:
          'Order #ORD-5918 for Tata Nexon Clutch Kit was cancelled by the '
          'customer before dispatch.',
      time: now.subtract(const Duration(days: 1, hours: 3)),
      actionRoute: AppRoutes.orders,
    ),
    NotifItem(
      id: 'd7',
      type: NotifType.payout,
      isRead: true,
      title: 'Weekly Earnings Summary',
      body:
          'This week you earned ₹42,300 from 18 orders. '
          'View your detailed earnings report.',
      time: now.subtract(const Duration(days: 2)),
    ),
    NotifItem(
      id: 'd8',
      type: NotifType.lowStock,
      isRead: true,
      title: 'Product Out of Stock',
      body:
          'Castrol GTX 10W-30 Engine Oil (1L) is now out of stock. '
          'Update your inventory.',
      time: now.subtract(const Duration(days: 3)),
    ),
    NotifItem(
      id: 'd9',
      type: NotifType.system,
      isRead: true,
      title: 'Store Performance Report',
      body:
          'Your store rating improved to 4.7 ⭐ this month. '
          '96% on-time delivery rate.',
      time: now.subtract(const Duration(days: 5)),
    ),
    NotifItem(
      id: 'd10',
      type: NotifType.review,
      isRead: true,
      title: 'New Review Requires Response',
      body:
          'Priya M. left a 3-star review about delayed delivery. '
          'Respond to improve your rating.',
      time: now.subtract(const Duration(days: 6)),
    ),
  ];
}

// ─── Category tab labels ──────────────────────────────────────

const _kCustomerTabs = ['All', 'Orders', 'Offers', 'System'];
const _kDealerTabs = ['All', 'Orders', 'Inventory', 'Payments', 'Reviews'];

List<NotifItem> _filterByTab(List<NotifItem> items, String tab, bool isDealer) {
  if (tab == 'All') return items;
  if (isDealer) {
    switch (tab) {
      case 'Orders':
        return items.where((n) => n.type == NotifType.newOrder).toList();
      case 'Inventory':
        return items.where((n) => n.type == NotifType.lowStock).toList();
      case 'Payments':
        return items.where((n) => n.type == NotifType.payout).toList();
      case 'Reviews':
        return items.where((n) => n.type == NotifType.review).toList();
    }
  } else {
    switch (tab) {
      case 'Orders':
        return items
            .where(
              (n) =>
                  n.type == NotifType.order ||
                  n.type == NotifType.delivery ||
                  n.type == NotifType.payment,
            )
            .toList();
      case 'Offers':
        return items.where((n) => n.type == NotifType.promo).toList();
      case 'System':
        return items.where((n) => n.type == NotifType.system).toList();
    }
  }
  return items;
}

// ═══════════════════════════════════════════════════════════════
// NotificationsScreen
// ═══════════════════════════════════════════════════════════════

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  // ── Theme ──────────────────────────────────────────────────
  bool get _d => Theme.of(context).brightness == Brightness.dark;

  Color get _bg => _d ? AppColorsDark.bg : AppColorsLight.bg;

  Color get _bgCard => _d ? AppColorsDark.bgCard : AppColorsLight.bgCard;

  Color get _border => _d ? AppColorsDark.border : AppColorsLight.border;

  Color get _txtPri =>
      _d ? AppColorsDark.textPrimary : AppColorsLight.textPrimary;

  Color get _txtSec =>
      _d ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;

  Color get _txtMut => _d ? AppColorsDark.textMuted : AppColorsLight.textMuted;

  late TabController _tabCtrl;
  late List<NotifItem> _items;
  bool _isDealer = false;
  String _activeTab = 'All';
  bool _showUnreadOnly = false;

  @override
  void initState() {
    super.initState();
    // Determine role
    final auth = context.read<AuthProvider>();
    _isDealer = auth.user?.role == UserRole.dealer;
    _items = _isDealer ? _dealerNotifs() : _customerNotifs();
    final tabs = _isDealer ? _kDealerTabs : _kCustomerTabs;
    _tabCtrl = TabController(length: tabs.length, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        setState(() => _activeTab = tabs[_tabCtrl.index]);
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  // ── Computed lists ─────────────────────────────────────────
  List<NotifItem> get _filtered {
    var list = _filterByTab(_items, _activeTab, _isDealer);
    if (_showUnreadOnly) list = list.where((n) => !n.isRead).toList();
    return list;
  }

  int get _unreadCount => _items.where((n) => !n.isRead).length;

  // ── Actions ────────────────────────────────────────────────
  void _markRead(String id) => setState(() {
    final i = _items.indexWhere((n) => n.id == id);
    if (i != -1) _items[i] = _items[i].copyWith(isRead: true);
  });

  void _markAllRead() => setState(() {
    _items = _items.map((n) => n.copyWith(isRead: true)).toList();
  });

  void _dismiss(String id) => setState(() {
    _items.removeWhere((n) => n.id == id);
  });

  void _clearAll() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Clear All Notifications?',
          style: AppTextStyles.headingSm(_d),
        ),
        content: Text(
          'This will permanently remove all notifications from your list.',
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
              setState(() => _items.clear());
            },
            child: Text(
              'Clear All',
              style: AppTextStyles.labelMd(
                _d,
              ).copyWith(color: AppColorsDark.error),
            ),
          ),
        ],
      ),
    );
  }

  void _tapNotif(NotifItem n) {
    _markRead(n.id);
    if (n.actionRoute != null) {
      context.push(n.actionRoute!);
    }
  }

  // ── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final tabs = _isDealer ? _kDealerTabs : _kCustomerTabs;
    return Scaffold(
      backgroundColor: _bg,
      body: NestedScrollView(
        headerSliverBuilder: (_, _) => [_buildSliverHeader(tabs)],
        body: _buildBody(),
      ),
    );
  }

  // ── Sliver header (AppBar + tabs) ──────────────────────────
  Widget _buildSliverHeader(List<String> tabs) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: _bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      expandedHeight: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _txtPri),
        onPressed: () => context.pop(),
      ),
      title: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Notifications', style: AppTextStyles.heading(_d)),
                if (_unreadCount > 0)
                  Text(
                    '$_unreadCount unread',
                    style: AppTextStyles.labelXs(
                      _d,
                    ).copyWith(color: AppColors.primary, letterSpacing: 0.2),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Unread filter toggle
        GestureDetector(
          onTap: () => setState(() => _showUnreadOnly = !_showUnreadOnly),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(right: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _showUnreadOnly
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _showUnreadOnly
                    ? AppColors.primary.withValues(alpha: 0.4)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.mark_email_unread_outlined,
                  size: 15,
                  color: _showUnreadOnly ? AppColors.primary : _txtSec,
                ),
                const SizedBox(width: 4),
                Text(
                  'Unread',
                  style: AppTextStyles.labelXs(_d).copyWith(
                    color: _showUnreadOnly ? AppColors.primary : _txtSec,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Overflow menu
        PopupMenuButton<String>(
          color: _bgCard,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: _border),
          ),
          icon: Icon(Icons.more_vert_rounded, size: 20, color: _txtSec),
          onSelected: (v) {
            if (v == 'read_all') _markAllRead();
            if (v == 'clear') _clearAll();
          },
          itemBuilder: (_) => [
            _menuItem(
              'read_all',
              Icons.done_all_rounded,
              'Mark all as read',
              _txtPri,
            ),
            _menuItem(
              'clear',
              Icons.delete_sweep_outlined,
              'Clear all',
              AppColorsDark.error,
            ),
          ],
        ),
      ],
      // Tab bar
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
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
            tabs: tabs.map((t) {
              final count = _unreadInTab(t, tabs);
              return Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(t),
                    if (count > 0) ...[
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            fontFamily: 'Syne',
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                            color: Colors.white,
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

  int _unreadInTab(String tab, List<String> allTabs) {
    final list = _filterByTab(_items, tab, _isDealer);
    return list.where((n) => !n.isRead).length;
  }

  // ── Body ───────────────────────────────────────────────────
  Widget _buildBody() {
    final list = _filtered;
    if (list.isEmpty) return _emptyState();

    // Group by date
    final grouped = _groupByDate(list);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 40),
      physics: const BouncingScrollPhysics(),
      itemCount: grouped.length,
      itemBuilder: (_, i) {
        final entry = grouped.entries.elementAt(i);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DateHeader(label: entry.key, isDark: _d),
            ...entry.value.map(
              (n) => _NotifTile(
                item: n,
                isDark: _d,
                onTap: () => _tapNotif(n),
                onRead: () => _markRead(n.id),
                onDismiss: () => _dismiss(n.id),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Group notifications by relative date ──────────────────
  Map<String, List<NotifItem>> _groupByDate(List<NotifItem> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final groups = <String, List<NotifItem>>{};
    for (final n in items) {
      final d = DateTime(n.time.year, n.time.month, n.time.day);
      final diff = today.difference(d).inDays;
      final String key;
      if (diff == 0) {
        key = 'Today';
      } else if (diff == 1) {
        key = 'Yesterday';
      } else if (diff < 7) {
        key = 'This Week';
      } else if (diff < 30) {
        key = 'This Month';
      } else {
        key = 'Older';
      }
      groups.putIfAbsent(key, () => []).add(n);
    }
    return groups;
  }

  // ── Empty state ────────────────────────────────────────────
  Widget _emptyState() => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
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
            child: Icon(
              _showUnreadOnly
                  ? Icons.mark_email_read_outlined
                  : Icons.notifications_none_outlined,
              size: 44,
              color: _txtMut,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _showUnreadOnly ? 'All Caught Up!' : 'No Notifications',
            style: AppTextStyles.heading(_d),
          ),
          const SizedBox(height: 8),
          Text(
            _showUnreadOnly
                ? 'You have no unread notifications.'
                : 'You\'ll see order updates, offers, and '
                      '${_isDealer ? 'new orders' : 'delivery alerts'} here.',
            style: AppTextStyles.bodyMd(_d).copyWith(color: _txtSec),
            textAlign: TextAlign.center,
          ),
          if (_showUnreadOnly) ...[
            const SizedBox(height: 18),
            GestureDetector(
              onTap: () => setState(() => _showUnreadOnly = false),
              child: Text(
                'Show all notifications',
                style: AppTextStyles.labelMd(
                  _d,
                ).copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ],
      ),
    ),
  );

  PopupMenuItem<String> _menuItem(
    String v,
    IconData icon,
    String label,
    Color color,
  ) {
    return PopupMenuItem(
      value: v,
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Text(label, style: AppTextStyles.bodyMd(_d).copyWith(color: _txtPri)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Date section header
// ═══════════════════════════════════════════════════════════════

class _DateHeader extends StatelessWidget {
  final String label;
  final bool isDark;

  const _DateHeader({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final txtMut = isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.labelSm(isDark).copyWith(
              color: txtMut,
              letterSpacing: 0.6,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Container(height: 1, color: border)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Notification tile (swipeable)
// ═══════════════════════════════════════════════════════════════

class _NotifTile extends StatelessWidget {
  final NotifItem item;
  final bool isDark;
  final VoidCallback onTap, onRead, onDismiss;

  const _NotifTile({
    required this.item,
    required this.isDark,
    required this.onTap,
    required this.onRead,
    required this.onDismiss,
  });

  Color get _bgCard => isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;

  Color get _border => isDark ? AppColorsDark.border : AppColorsLight.border;

  Color get _txtPri =>
      isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary;

  Color get _txtSec =>
      isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;

  Color get _txtMut =>
      isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;

  @override
  Widget build(BuildContext context) {
    final color = _notifColor(item.type);
    final isRead = item.isRead;

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: _dismissBackground(),
      onDismissed: (_) => onDismiss(),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          decoration: BoxDecoration(
            color: isRead ? _bgCard : color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isRead ? _border : color.withValues(alpha: 0.2),
              width: isRead ? 1 : 1.2,
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Unread indicator strip
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 3,
                  decoration: BoxDecoration(
                    color: isRead ? Colors.transparent : color,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(14),
                    ),
                  ),
                ),
                // Icon
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 14, 0, 14),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_notifIcon(item.type), size: 20, color: color),
                  ),
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: AppTextStyles.labelMd(isDark).copyWith(
                                  color: _txtPri,
                                  fontWeight: isRead
                                      ? FontWeight.w500
                                      : FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _timeLabel(item.time),
                              style: AppTextStyles.bodyXs(
                                isDark,
                              ).copyWith(color: _txtMut, fontSize: 10),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.body,
                          style: AppTextStyles.bodyMd(
                            isDark,
                          ).copyWith(color: _txtSec, height: 1.4, fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // Category chip
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                _notifCategory(item.type),
                                style: TextStyle(
                                  fontFamily: 'DMSans',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                  color: color,
                                ),
                              ),
                            ),
                            const Spacer(),
                            // Action hint
                            if (item.actionRoute != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'View',
                                    style: AppTextStyles.labelXs(isDark)
                                        .copyWith(
                                          color: AppColors.primary,
                                          fontSize: 11,
                                        ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 9,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                            // Mark read button (if unread)
                            if (!isRead) ...[
                              if (item.actionRoute != null)
                                const SizedBox(width: 12),
                              GestureDetector(
                                onTap: onRead,
                                child: Text(
                                  'Mark read',
                                  style: AppTextStyles.labelXs(
                                    isDark,
                                  ).copyWith(color: _txtMut, fontSize: 10),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dismissBackground() => Container(
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.only(right: 20),
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
    decoration: BoxDecoration(
      color: AppColorsDark.error.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColorsDark.error.withValues(alpha: 0.3)),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.delete_outline_rounded,
          color: AppColorsDark.error,
          size: 22,
        ),
        const SizedBox(height: 3),
        Text(
          'Dismiss',
          style: TextStyle(
            fontFamily: 'DMSans',
            fontWeight: FontWeight.w600,
            fontSize: 10,
            color: AppColorsDark.error,
          ),
        ),
      ],
    ),
  );

  String _timeLabel(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${t.day}/${t.month}/${t.year}';
  }
}
