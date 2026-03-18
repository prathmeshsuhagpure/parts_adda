import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../domain/models/notification_model.dart';
import '../providers/notification_provider.dart';

// ═══════════════════════════════════════════════════════════════
// Notification metadata & helpers
// ═══════════════════════════════════════════════════════════════

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
      return const Color(0xFF8B5CF6);
    case NotifType.promo:
      return AppColors.primary;
    case NotifType.system:
      return AppColorsDark.textSecondary;
    case NotifType.newOrder:
      return AppColorsDark.success;
    case NotifType.lowStock:
      return AppColorsDark.warning;
    case NotifType.payout:
      return const Color(0xFF10B981);
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

// ─── Category tab labels ──────────────────────────────────────

const _kCustomerTabs = ['All', 'Orders', 'Offers', 'System'];
const _kDealerTabs = ['All', 'Orders', 'Inventory', 'Payments', 'Reviews'];

List<NotificationModel> _filterByTab(
    List<NotificationModel> items,
    String tab,
    bool isDealer,
    ) {
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
  late TabController _tabCtrl;
  bool _isDealer = false;
  String _activeTab = 'All';
  bool _showUnreadOnly = false;

  // ── Theme helpers ──────────────────────────────────────────
  bool get _d => Theme.of(context).brightness == Brightness.dark;

  Color get _bg => _d ? AppColorsDark.bg : AppColorsLight.bg;

  Color get _bgCard => _d ? AppColorsDark.bgCard : AppColorsLight.bgCard;

  Color get _border => _d ? AppColorsDark.border : AppColorsLight.border;

  Color get _txtPri =>
      _d ? AppColorsDark.textPrimary : AppColorsLight.textPrimary;

  Color get _txtSec =>
      _d ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;

  Color get _txtMut => _d ? AppColorsDark.textMuted : AppColorsLight.textMuted;

  @override
  void initState() {
    super.initState();
    // Determine role
    final auth = context.read<AuthProvider>();
    _isDealer = auth.user?.role == UserRole.dealer;

    final tabs = _isDealer ? _kDealerTabs : _kCustomerTabs;
    _tabCtrl = TabController(length: tabs.length, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        setState(() => _activeTab = tabs[_tabCtrl.index]);
      }
    });

    // Load notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  // ── Computed lists ─────────────────────────────────────────
  List<NotificationModel> _getFiltered(List<NotificationModel> items) {
    var list = _filterByTab(items, _activeTab, _isDealer);
    if (_showUnreadOnly) {
      list = list.where((n) => !n.isRead).toList();
    }
    return list;
  }

  // ── Actions ────────────────────────────────────────────────
  Future<void> _markRead(String id) async {
    await context.read<NotificationProvider>().markRead(id);
  }

  Future<void> _markAllRead() async {
    await context.read<NotificationProvider>().markAllRead();
  }

  void _tapNotif(NotificationModel n) async {
    await _markRead(n.id);
    if (_getRouteFromNotification(n) != null) {
      if (mounted) {
        context.push(_getRouteFromNotification(n)!);
      }
    }
  }

  String? _getRouteFromNotification(NotificationModel n) {
    // Map notification types to routes based on data
    switch (n.type) {
      case NotifType.order:
      case NotifType.newOrder:
      case NotifType.delivery:
      case NotifType.payment:
        return AppRoutes.orders;
      case NotifType.review:
        return AppRoutes.home;
      case NotifType.lowStock:
      case NotifType.payout:
      case NotifType.promo:
      case NotifType.system:
        return null;
    }
  }

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
              // TODO: Implement delete all on backend
              // context.read<NotificationProvider>().deleteAll();
            },
            child: Text(
              'Clear All',
              style: AppTextStyles.labelMd(_d)
                  .copyWith(color: AppColorsDark.error),
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final tabs = _isDealer ? _kDealerTabs : _kCustomerTabs;
    return Scaffold(
      backgroundColor: _bg,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [_buildSliverHeader(tabs)],
        body: _buildBody(),
      ),
    );
  }

  // ── Sliver header (AppBar + tabs) ──────────────────────────
  Widget _buildSliverHeader(List<String> tabs) {
    return Consumer<NotificationProvider>(
      builder: (_, provider, __) {
        final unreadCount = provider.unreadCount;

        return SliverAppBar(
          pinned: true,
          backgroundColor: _bg,
          elevation: 0,
          scrolledUnderElevation: 0,
          expandedHeight: 0,
          leading: IconButton(
            icon:
            Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _txtPri),
            onPressed: () => context.pop(),
          ),
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Notifications', style: AppTextStyles.heading(_d)),
                    if (unreadCount > 0)
                      Text(
                        '$unreadCount unread',
                        style: AppTextStyles.labelXs(_d).copyWith(
                          color: AppColors.primary,
                          letterSpacing: 0.2,
                        ),
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
                      color:
                      _showUnreadOnly ? AppColors.primary : _txtSec,
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
              child: Consumer<NotificationProvider>(
                builder: (_, provider, __) {
                  return TabBar(
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
                      final count = _unreadInTab(provider.notifications, t, tabs);
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
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  int _unreadInTab(
      List<NotificationModel> items,
      String tab,
      List<String> allTabs,
      ) {
    final list = _filterByTab(items, tab, _isDealer);
    return list.where((n) => !n.isRead).length;
  }

  // ── Body ───────────────────────────────────────────────────
  Widget _buildBody() {
    return Consumer<NotificationProvider>(
      builder: (_, provider, __) {
        if (provider.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        }

        final list = _getFiltered(provider.notifications);

        if (list.isEmpty) {
          return _emptyState();
        }

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
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ── Group notifications by relative date ──────────────────
  Map<String, List<NotificationModel>> _groupByDate(
      List<NotificationModel> items,
      ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final groups = <String, List<NotificationModel>>{};
    for (final n in items) {
      final d = DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);
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
                style: AppTextStyles.labelMd(_d)
                    .copyWith(color: AppColors.primary),
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
          Text(
            label,
            style: AppTextStyles.bodyMd(_d).copyWith(color: _txtPri),
          ),
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
// Notification tile
// ═══════════════════════════════════════════════════════════════

class _NotifTile extends StatefulWidget {
  final NotificationModel item;
  final bool isDark;
  final VoidCallback onTap, onRead;

  const _NotifTile({
    required this.item,
    required this.isDark,
    required this.onTap,
    required this.onRead,
  });

  @override
  State<_NotifTile> createState() => _NotifTileState();
}

class _NotifTileState extends State<_NotifTile> {
  bool _isMarking = false;

  Color get _bgCard =>
      widget.isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;

  Color get _border =>
      widget.isDark ? AppColorsDark.border : AppColorsLight.border;

  Color get _txtPri =>
      widget.isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary;

  Color get _txtSec =>
      widget.isDark
          ? AppColorsDark.textSecondary
          : AppColorsLight.textSecondary;

  Color get _txtMut =>
      widget.isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;

  @override
  Widget build(BuildContext context) {
    final color = _notifColor(widget.item.type);
    final isRead = widget.item.isRead;

    return GestureDetector(
      onTap: widget.onTap,
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
                  child: Icon(
                    _notifIcon(widget.item.type),
                    size: 20,
                    color: color,
                  ),
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
                              widget.item.title,
                              style: AppTextStyles.labelMd(widget.isDark)
                                  .copyWith(
                                color: _txtPri,
                                fontWeight:
                                isRead ? FontWeight.w500 : FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _timeLabel(widget.item.createdAt),
                            style: AppTextStyles.bodyXs(widget.isDark)
                                .copyWith(color: _txtMut, fontSize: 10),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.item.body,
                        style: AppTextStyles.bodyMd(widget.isDark).copyWith(
                          color: _txtSec,
                          height: 1.4,
                          fontSize: 12,
                        ),
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
                              _notifCategory(widget.item.type),
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                                color: color,
                              ),
                            ),
                          ),
                          const Spacer(),
                          // Mark read button (if unread)
                          if (!isRead)
                            GestureDetector(
                              onTap: () async {
                                setState(() => _isMarking = true);
                                widget.onRead();
                                setState(() => _isMarking = false);
                              },
                              child: _isMarking
                                  ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  valueColor:
                                  AlwaysStoppedAnimation<Color>(
                                    _txtMut,
                                  ),
                                ),
                              )
                                  : Text(
                                'Mark read',
                                style:
                                AppTextStyles.labelXs(widget.isDark)
                                    .copyWith(
                                  color: _txtMut,
                                  fontSize: 10,
                                ),
                              ),
                            ),
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
    );
  }

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