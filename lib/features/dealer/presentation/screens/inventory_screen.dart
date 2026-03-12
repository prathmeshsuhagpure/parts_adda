import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parts_adda/core/router/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../products/presentation/screens/edit_product_screen.dart';
import '../../domain/models/inventory_model.dart';
import '../providers/inventory_provider.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  late final TabController _tabCtrl;

  static const _tabs = [
    (label: 'All', filter: null),
    (label: 'Active', filter: ListingStatus.active),
    (label: 'Inactive', filter: ListingStatus.inactive),
    (label: 'Pending', filter: ListingStatus.pending),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        context.read<InventoryProvider>().setStatusFilter(
          _tabs[_tabCtrl.index].filter,
        );
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().loadInventory();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  // ── Theme helpers ─────────────────────────────────────────
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _bg => _isDark ? AppColorsDark.bg : AppColorsLight.bg;

  Color get _bgCard => _isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;

  Color get _bgInput =>
      _isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput;

  Color get _border => _isDark ? AppColorsDark.border : AppColorsLight.border;

  Color get _textSec =>
      _isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;

  Color get _textMuted =>
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

  /*void _openAddProduct() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ProductFormSheet(isDark: _isDark),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoryProvider>();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: _isDark
                ? AppColorsDark.textPrimary
                : AppColorsLight.textPrimary,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Inventory', style: AppTextStyles.headingSm(_isDark)),
            Text(
              'Dealer Panel',
              style: AppTextStyles.bodyXs(
                _isDark,
              ).copyWith(color: AppColors.primary),
            ),
          ],
        ),
        actions: [
          // Sort
          GestureDetector(
            onTap: _openSort,
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _bgCard,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: _border),
              ),
              child: Icon(Icons.sort, size: 18, color: _textSec),
            ),
          ),
          // Add product
          GestureDetector(
            onTap: () {
              context.go(AppRoutes.addProduct);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add, size: 15, color: Colors.white),
                  const SizedBox(width: 4),
                  const Text('Add', style: AppTextStyles.buttonSm),
                ],
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(96),
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
                    hintText: 'Search by name, SKU or OEM…',
                    hintStyle: AppTextStyles.bodyMd(
                      _isDark,
                    ).copyWith(color: _textMuted),
                    filled: true,
                    fillColor: _bgInput,
                    prefixIcon: Icon(Icons.search, size: 18, color: _textMuted),
                    suffixIcon: provider.searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchCtrl.clear();
                              provider.setSearch('');
                            },
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: _textMuted,
                            ),
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
              // Status tabs
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
                // ── Stats banner ────────────────────────────────
                _StatsBanner(provider: provider, isDark: _isDark),

                // ── Items list ──────────────────────────────────
                Expanded(
                  child: provider.items.isEmpty
                      ? _EmptyInventory(
                          isDark: _isDark,
                          onAdd: () {
                            context.go(AppRoutes.addProduct);
                          },
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                          physics: const BouncingScrollPhysics(),
                          itemCount: provider.items.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) => _InventoryCard(
                            item: provider.items[i],
                            isDark: _isDark,
                            onToggleStatus: () =>
                                provider.toggleStatus(provider.items[i].id),
                            onEdit: () => showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: _bgCard,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              builder: (_) => ProductFormSheet(
                                isDark: _isDark,
                                existing: provider.items[i],
                              ),
                            ),
                            onUpdateStock: () =>
                                _showStockEditor(context, provider.items[i]),
                            onDelete: () =>
                                _confirmDelete(context, provider.items[i]),
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  // ── Stock quick-edit dialog ──────────────────────────────
  void _showStockEditor(BuildContext ctx, InventoryItem item) {
    final ctrl = TextEditingController(text: item.stock.toString());
    showDialog(
      context: ctx,
      builder: (dCtx) => AlertDialog(
        backgroundColor: _bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Update Stock', style: AppTextStyles.heading(_isDark)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.name,
              style: AppTextStyles.bodySm(_isDark).copyWith(color: _textSec),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: ctrl,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: AppTextStyles.bodyMd(_isDark),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: 'New stock quantity',
                filled: true,
                fillColor: _bgInput,
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelMd(_isDark).copyWith(color: _textMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              final v = int.tryParse(ctrl.text);
              if (v != null) {
                context.read<InventoryProvider>().updateStock(item.id, v);
              }
              Navigator.pop(dCtx);
            },
            child: Text(
              'Update',
              style: AppTextStyles.labelMd(
                _isDark,
              ).copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  // ── Delete confirm ────────────────────────────────────────
  void _confirmDelete(BuildContext ctx, InventoryItem item) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (dCtx) => AlertDialog(
        backgroundColor: _bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Remove Listing?', style: AppTextStyles.heading(_isDark)),
        content: Text(
          '${item.name} will be permanently removed from your inventory.',
          style: AppTextStyles.bodyMd(_isDark).copyWith(color: _textSec),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelMd(_isDark).copyWith(color: _textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dCtx, true),
            child: Text(
              'Delete',
              style: AppTextStyles.labelMd(
                _isDark,
              ).copyWith(color: AppColorsDark.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<InventoryProvider>().deleteListing(item.id);
    }
  }
}

// ═════════════════════════════════════════════════════════════
// Stats Banner
// ═════════════════════════════════════════════════════════════

class _StatsBanner extends StatelessWidget {
  final InventoryProvider provider;
  final bool isDark;

  const _StatsBanner({required this.provider, required this.isDark});

  String _fmt(double v) =>
      '₹${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  @override
  Widget build(BuildContext context) {
    final bgCard = isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          _StatCell(
            label: 'Total',
            value: '${provider.totalListings}',
            isDark: isDark,
          ),
          _Divider(),
          _StatCell(
            label: 'Active',
            value: '${provider.activeListings}',
            valueColor: AppColorsDark.success,
            isDark: isDark,
          ),
          _Divider(),
          _StatCell(
            label: 'Low Stock',
            value: '${provider.lowStockCount}',
            valueColor: AppColorsDark.warning,
            isDark: isDark,
          ),
          _Divider(),
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
    child: Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Syne',
            fontWeight: FontWeight.w800,
            fontSize: small ? 13 : 18,
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
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 32,
    color: Theme.of(context).brightness == Brightness.dark
        ? AppColorsDark.border
        : AppColorsLight.border,
  );
}

// ═════════════════════════════════════════════════════════════
// Inventory Card
// ═════════════════════════════════════════════════════════════

class _InventoryCard extends StatelessWidget {
  final InventoryItem item;
  final bool isDark;
  final VoidCallback onToggleStatus, onEdit, onUpdateStock, onDelete;

  const _InventoryCard({
    required this.item,
    required this.isDark,
    required this.onToggleStatus,
    required this.onEdit,
    required this.onUpdateStock,
    required this.onDelete,
  });

  String _fmt(double v) =>
      '₹${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  Color get _statusColor {
    switch (item.status) {
      case ListingStatus.active:
        return AppColorsDark.success;
      case ListingStatus.inactive:
        return AppColorsDark.textMuted;
      case ListingStatus.pending:
        return AppColorsDark.warning;
      case ListingStatus.rejected:
        return AppColorsDark.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgCard = isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;
    final bgInput = isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;
    final textMuted = isDark
        ? AppColorsDark.textMuted
        : AppColorsLight.textMuted;

    final discount = (item.mrp != null && item.mrp! > item.price)
        ? (((item.mrp! - item.price) / item.mrp!) * 100).round()
        : 0;

    return Container(
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(
          color: item.stock == 0
              ? (isDark
                    ? AppColorsDark.error.withValues(alpha: 0.25)
                    : AppColorsLight.error.withValues(alpha: 0.25))
              : item.stock <= 5
              ? AppColorsDark.warning.withValues(alpha: 0.25)
              : border,
        ),
      ),
      child: Column(
        children: [
          // ── Main row ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: Container(
                    width: 72,
                    height: 72,
                    color: bgInput,
                    child: item.image != null
                        ? Image.network(item.image!, fit: BoxFit.contain)
                        : Center(
                            child: Icon(
                              Icons.inventory_2_outlined,
                              size: 30,
                              color: textMuted,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + status
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: AppTextStyles.labelMd(isDark),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _StatusBadge(
                            status: item.status,
                            color: _statusColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // SKU + OEM
                      Wrap(
                        spacing: 6,
                        children: [
                          Text(
                            'SKU: ${item.sku}',
                            style: AppTextStyles.mono(
                              isDark,
                            ).copyWith(fontSize: 10),
                          ),
                          if (item.oemNumber != null)
                            Text(
                              'OEM: ${item.oemNumber}',
                              style: AppTextStyles.mono(
                                isDark,
                              ).copyWith(fontSize: 10),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Price row
                      Row(
                        children: [
                          Text(
                            _fmt(item.price),
                            style: AppTextStyles.priceSm(),
                          ),
                          if (item.mrp != null && item.mrp! > item.price) ...[
                            const SizedBox(width: 5),
                            Text(
                              _fmt(item.mrp!),
                              style: AppTextStyles.strikethrough(
                                isDark,
                              ).copyWith(fontSize: 10),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '-$discount%',
                              style: AppTextStyles.labelXs(
                                isDark,
                              ).copyWith(color: AppColorsDark.success),
                            ),
                          ],
                          if (item.b2bPrice != null) ...[
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColorsDark.info.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'B2B ${_fmt(item.b2bPrice!)}',
                                style: AppTextStyles.labelXs(
                                  isDark,
                                ).copyWith(color: AppColorsDark.info),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // More menu
                PopupMenuButton<String>(
                  color: bgCard,
                  icon: Icon(Icons.more_vert, size: 18, color: textMuted),
                  onSelected: (v) {
                    switch (v) {
                      case 'edit':
                        onEdit();
                        break;
                      case 'stock':
                        onUpdateStock();
                        break;
                      case 'toggle':
                        onToggleStatus();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: _MenuItem(
                        icon: Icons.edit_outlined,
                        label: 'Edit Listing',
                        isDark: isDark,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'stock',
                      child: _MenuItem(
                        icon: Icons.inventory_outlined,
                        label: 'Update Stock',
                        isDark: isDark,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: _MenuItem(
                        icon: item.status == ListingStatus.active
                            ? Icons.pause_circle_outline
                            : Icons.play_circle_outline,
                        label: item.status == ListingStatus.active
                            ? 'Deactivate'
                            : 'Activate',
                        isDark: isDark,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: _MenuItem(
                        icon: Icons.delete_outline,
                        label: 'Remove',
                        isDark: isDark,
                        color: AppColorsDark.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Stats footer ──────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: bgInput.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
              border: Border(top: BorderSide(color: border)),
            ),
            child: Row(
              children: [
                // Stock
                GestureDetector(
                  onTap: onUpdateStock,
                  child: Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 13,
                        color: item.stock == 0
                            ? (isDark
                                  ? AppColorsDark.error
                                  : AppColorsLight.error)
                            : item.stock <= 5
                            ? AppColorsDark.warning
                            : AppColorsDark.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.stock == 0
                            ? 'Out of Stock'
                            : item.stock <= 5
                            ? '${item.stock} left (Low)'
                            : '${item.stock} in stock',
                        style: AppTextStyles.labelXs(isDark).copyWith(
                          color: item.stock == 0
                              ? (isDark
                                    ? AppColorsDark.error
                                    : AppColorsLight.error)
                              : item.stock <= 5
                              ? AppColorsDark.warning
                              : AppColorsDark.success,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Sold
                Icon(Icons.shopping_bag_outlined, size: 13, color: textMuted),
                const SizedBox(width: 4),
                Text(
                  '${item.soldCount} sold',
                  style: AppTextStyles.bodyXs(isDark),
                ),
                const SizedBox(width: 14),
                // Rating
                if (item.rating != null) ...[
                  Icon(Icons.star, size: 12, color: AppColorsDark.warning),
                  const SizedBox(width: 3),
                  Text(
                    '${item.rating!.toStringAsFixed(1)} (${item.reviewCount})',
                    style: AppTextStyles.bodyXs(isDark),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ListingStatus status;
  final Color color;

  const _StatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(
      status.label,
      style: TextStyle(
        fontFamily: 'DMSans',
        fontWeight: FontWeight.w700,
        fontSize: 10,
        color: color,
      ),
    ),
  );
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final Color? color;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.isDark,
    this.color,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(
        icon,
        size: 16,
        color:
            color ??
            (isDark
                ? AppColorsDark.textSecondary
                : AppColorsLight.textSecondary),
      ),
      const SizedBox(width: 10),
      Text(label, style: AppTextStyles.bodyMd(isDark).copyWith(color: color)),
    ],
  );
}

// ═════════════════════════════════════════════════════════════
// Sort Sheet
// ═════════════════════════════════════════════════════════════

class _SortSheet extends StatelessWidget {
  final bool isDark;

  const _SortSheet({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventoryProvider>();
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;

    const options = [
      ('updatedAt', 'Last Updated'),
      ('price', 'Price: Low → High'),
      ('stock', 'Stock: High → Low'),
      ('soldCount', 'Most Sold'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
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
          Text('Sort Inventory', style: AppTextStyles.heading(isDark)),
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
// Margin Preview widget
// ═════════════════════════════════════════════════════════════

class MarginPreview extends StatefulWidget {
  final TextEditingController priceCtrl, mrpCtrl;
  final bool isDark;

  const MarginPreview({
    super.key,
    required this.priceCtrl,
    required this.mrpCtrl,
    required this.isDark,
  });

  @override
  State<MarginPreview> createState() => MarginPreviewState();
}

class MarginPreviewState extends State<MarginPreview> {
  @override
  void initState() {
    super.initState();
    widget.priceCtrl.addListener(_rebuild);
    widget.mrpCtrl.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    widget.priceCtrl.removeListener(_rebuild);
    widget.mrpCtrl.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final price = double.tryParse(widget.priceCtrl.text);
    final mrp = double.tryParse(widget.mrpCtrl.text);
    if (price == null || mrp == null || mrp <= 0) {
      return const SizedBox.shrink();
    }

    final disc = mrp > price ? (((mrp - price) / mrp) * 100).round() : 0;
    final saving = mrp > price ? mrp - price : 0;
    final bgCard = widget.isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;
    final border = widget.isDark ? AppColorsDark.border : AppColorsLight.border;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.auto_graph_outlined,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Buyer saves ₹${saving.toStringAsFixed(0)} ($disc% off)',
              style: AppTextStyles.bodySm(
                widget.isDark,
              ).copyWith(color: AppColorsDark.success),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// Shared small widgets
// ═════════════════════════════════════════════════════════════

class _EmptyInventory extends StatelessWidget {
  final bool isDark;
  final VoidCallback onAdd;

  const _EmptyInventory({required this.isDark, required this.onAdd});

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
                  Icons.inventory_2_outlined,
                  size: 42,
                  color: isDark
                      ? AppColorsDark.textMuted
                      : AppColorsLight.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('No products yet', style: AppTextStyles.heading(isDark)),
            const SizedBox(height: 8),
            Text(
              'Add your first product to start selling on AutoParts.',
              style: AppTextStyles.bodyMd(isDark).copyWith(color: textSec),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18, color: Colors.white),
              label: const Text(
                'Add First Product',
                style: AppTextStyles.buttonSm,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
