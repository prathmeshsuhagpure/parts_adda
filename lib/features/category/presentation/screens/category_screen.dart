import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../features/cart/presentation/providers/cart_provider.dart';
import '../../../../shared/widgets/main_shell.dart';
import '../providers/catalog_provider.dart';
import '../../../parts/domain/models/part_model.dart';

// ─── Sort options ─────────────────────────────────────────────

enum _SortBy { newest, priceLow, priceHigh, rating, popular }

extension _SortLabel on _SortBy {
  String get label => switch (this) {
    _SortBy.newest => 'Newest',
    _SortBy.priceLow => 'Price: Low → High',
    _SortBy.priceHigh => 'Price: High → Low',
    _SortBy.rating => 'Top Rated',
    _SortBy.popular => 'Most Popular',
  };
}

// ═════════════════════════════════════════════════════════════
// CategoryScreen — shows parts for a given category/sub-category.
// Reached from SubCategoryScreen when the user taps "Browse All"
// or taps a leaf sub-category.
// ═════════════════════════════════════════════════════════════

class CategoryScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const CategoryScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _scrollCtrl = ScrollController();

  _SortBy _sortBy = _SortBy.newest;
  bool _inStockOnly = false;
  bool _oemOnly = false;
  RangeValues _priceRange = const RangeValues(0, 50000);
  String? _selectedBrand;
  bool _isGridView = true;

  Map<String, dynamic> get _filters => {
    'sortBy': _sortBy.name,
    if (_inStockOnly) 'inStock': true,
    if (_oemOnly) 'partType': 'OEM',
    'minPrice': _priceRange.start.round(),
    'maxPrice': _priceRange.end.round(),
    if (_selectedBrand != null) 'brand': _selectedBrand,
  };

  int get _activeFilterCount =>
      (_inStockOnly ? 1 : 0) +
          (_oemOnly ? 1 : 0) +
          (_selectedBrand != null ? 1 : 0) +
          (_priceRange.start > 0 || _priceRange.end < 50000 ? 1 : 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _reload() => context.read<CategoryProvider>().loadCategory(
    categoryId: widget.categoryId,
    filters: _filters,
  );

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      context.read<CategoryProvider>().loadMore(
        categoryId: widget.categoryId,
        filters: _filters,
      );
    }
  }

  void _openSortSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _SortSheet(
        current: _sortBy,
        onSelect: (s) {
          Navigator.pop(context);
          setState(() => _sortBy = s);
          _reload();
        },
      ),
    );
  }

  void _openFilterSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FilterSheet(
        inStockOnly: _inStockOnly,
        oemOnly: _oemOnly,
        priceRange: _priceRange,
        selectedBrand: _selectedBrand,
        onApply: (inStock, oem, price, brand) {
          Navigator.pop(context);
          setState(() {
            _inStockOnly = inStock;
            _oemOnly = oem;
            _priceRange = price;
            _selectedBrand = brand;
          });
          _reload();
        },
        onReset: () {
          Navigator.pop(context);
          setState(() {
            _inStockOnly = false;
            _oemOnly = false;
            _priceRange = const RangeValues(0, 50000);
            _selectedBrand = null;
          });
          _reload();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryProvider>();
    final parts = provider.parts;
    final isLoading = provider.isListLoading;
    final isLoadingMore = provider.isLoadingMore;
    final total = provider.totalParts;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColorsDark.bg : AppColorsLight.bg,
      appBar: AppBar(
        backgroundColor: isDark ? AppColorsDark.bg : AppColorsLight.bg,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.categoryName, style: AppTextStyles.headingSm(isDark)),
            if (!isLoading && total > 0)
              Text(
                '$total parts found',
                style: AppTextStyles.bodyXs(isDark).copyWith(
                  color: isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted,
                ),
              ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () => context.push(AppRoutes.search),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.search,
                color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary,
                size: 20,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _isGridView = !_isGridView),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(
                _isGridView ? Icons.view_list_outlined : Icons.grid_view_outlined,
                color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary,
                size: 20,
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // ── Filter / Sort bar ────────────────────────────────
          _FilterBar(
            sortLabel: _sortBy.label,
            filterCount: _activeFilterCount,
            inStockOnly: _inStockOnly,
            oemOnly: _oemOnly,
            onSort: _openSortSheet,
            onFilter: _openFilterSheet,
            onToggleInStock: () { setState(() => _inStockOnly = !_inStockOnly); _reload(); },
            onToggleOem: () { setState(() => _oemOnly = !_oemOnly); _reload(); },
          ),

          // ── Parts list / grid ────────────────────────────────
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : parts.isEmpty
                ? EmptyStateWidget(
              icon: Icons.search_off,
              title: 'No parts found',
              subtitle: 'Try adjusting your filters or search differently.',
              actionLabel: 'Clear Filters',
              onAction: () {
                setState(() {
                  _inStockOnly = false;
                  _oemOnly = false;
                  _priceRange = const RangeValues(0, 50000);
                  _selectedBrand = null;
                });
                _reload();
              },
            )
                : _isGridView
                ? _GridBody(
              parts: parts,
              scrollCtrl: _scrollCtrl,
              isLoadingMore: isLoadingMore,
            )
                : _ListBody(
              parts: parts,
              scrollCtrl: _scrollCtrl,
              isLoadingMore: isLoadingMore,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Filter / Sort Bar ────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final String sortLabel;
  final int filterCount;
  final bool inStockOnly, oemOnly;
  final VoidCallback onSort, onFilter, onToggleInStock, onToggleOem;

  const _FilterBar({
    required this.sortLabel,
    required this.filterCount,
    required this.inStockOnly,
    required this.oemOnly,
    required this.onSort,
    required this.onFilter,
    required this.onToggleInStock,
    required this.onToggleOem,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: isDark ? AppColorsDark.bgSection : AppColorsLight.bgSection,
        border: Border(
          bottom: BorderSide(color: isDark ? AppColorsDark.border : AppColorsLight.border),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _BarChip(icon: Icons.sort, label: sortLabel, onTap: onSort),
          const SizedBox(width: 8),
          _BarChip(
            icon: Icons.tune,
            label: 'Filters',
            badge: filterCount > 0 ? '$filterCount' : null,
            isActive: filterCount > 0,
            onTap: onFilter,
          ),
          const SizedBox(width: 8),
          _BarChip(label: 'In Stock', isActive: inStockOnly, onTap: onToggleInStock),
          const SizedBox(width: 8),
          _BarChip(label: 'OEM', isActive: oemOnly, onTap: onToggleOem),
        ],
      ),
    );
  }
}

class _BarChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? badge;
  final bool isActive;
  final VoidCallback onTap;

  const _BarChip({
    required this.label,
    this.icon,
    this.badge,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = AppColors.primary;
    final inactiveColor = isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withValues(alpha: 0.12)
              : (isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? activeColor.withValues(alpha: 0.5)
                : (isDark ? AppColorsDark.border : AppColorsLight.border),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: isActive ? activeColor : inactiveColor),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: AppTextStyles.labelSm(isDark).copyWith(
                color: isActive ? activeColor : inactiveColor,
                fontSize: 11,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 5),
              Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    badge!,
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Grid Body ────────────────────────────────────────────────

class _GridBody extends StatelessWidget {
  final List<PartModel> parts;
  final ScrollController scrollCtrl;
  final bool isLoadingMore;

  const _GridBody({required this.parts, required this.scrollCtrl, required this.isLoadingMore});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: scrollCtrl,
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.62,
      ),
      itemCount: parts.length + (isLoadingMore ? 2 : 0),
      itemBuilder: (_, i) {
        if (i >= parts.length) return _ShimmerCard();
        final p = parts[i];
        return PartCardWidget(
          id: p.id,
          name: p.name,
          brand: p.brand.name,
          image: p.images.isNotEmpty ? p.images.first : null,
          price: p.price,
          mrp: p.mrp,
          rating: p.rating,
          inStock: p.stock > 0,
          onTap: () => context.push(AppRoutes.partDetailPath(p.id)),
          onAddToCart: p.stock > 0
              ? () => context.read<CartProvider>().addItem(
            partId: p.id,
            sellerId: p.sellerListings.isNotEmpty ? p.sellerListings.first.sellerId : '',
            partName: p.name,
            partSku: p.sku,
            partImage: p.images.isNotEmpty ? p.images.first : null,
            sellerName: p.sellerListings.isNotEmpty ? p.sellerListings.first.sellerName : '',
            price: p.price,
            mrp: p.mrp,
          )
              : null,
        );
      },
    );
  }
}

// ─── List Body ────────────────────────────────────────────────

class _ListBody extends StatelessWidget {
  final List<PartModel> parts;
  final ScrollController scrollCtrl;
  final bool isLoadingMore;

  const _ListBody({required this.parts, required this.scrollCtrl, required this.isLoadingMore});

  String _fmt(double v) => '₹${v.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
  )}';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.separated(
      controller: scrollCtrl,
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: parts.length + (isLoadingMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        if (i >= parts.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
            ),
          );
        }

        final p = parts[i];
        final discount = (p.mrp != null && p.mrp! > p.price)
            ? (((p.mrp! - p.price) / p.mrp!) * 100).round()
            : 0;

        return GestureDetector(
          onTap: () => context.push(AppRoutes.partDetailPath(p.id)),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard,
              borderRadius: AppRadius.cardRadius,
              border: Border.all(color: isDark ? AppColorsDark.border : AppColorsLight.border),
            ),
            child: Row(
              children: [
                // Image
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                  child: Container(
                    width: 100,
                    height: 100,
                    color: isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput,
                    child: p.images.isNotEmpty
                        ? Image.network(p.images.first, fit: BoxFit.contain)
                        : Icon(
                      Icons.settings_outlined,
                      size: 32,
                      color: isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted,
                    ),
                  ),
                ),

                // Info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.brand.name.isNotEmpty ? p.brand.name : 'Unknown',
                          style: AppTextStyles.labelXs(isDark).copyWith(
                            color: isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          p.name,
                          style: AppTextStyles.labelMd(isDark),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        if (p.rating != null)
                          Row(
                            children: [
                              StarRatingWidget(rating: p.rating!, size: 12),
                              const SizedBox(width: 4),
                              Text('(${p.reviewCount})', style: AppTextStyles.bodyXs(isDark)),
                            ],
                          ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(_fmt(p.price), style: AppTextStyles.priceSm()),
                            if (p.mrp != null && p.mrp! > p.price) ...[
                              const SizedBox(width: 6),
                              Text(_fmt(p.mrp!), style: AppTextStyles.strikethrough(isDark)),
                              const SizedBox(width: 6),
                              Text(
                                '$discount% off',
                                style: AppTextStyles.labelXs(isDark).copyWith(
                                  color: isDark ? AppColorsDark.success : AppColorsLight.success,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _Badge(
                              label: p.stock > 0 ? 'In Stock' : 'Out of Stock',
                              color: p.stock > 0
                                  ? (isDark ? AppColorsDark.success : AppColorsLight.success)
                                  : (isDark ? AppColorsDark.error : AppColorsLight.error),
                            ),
                            if (p.partType == 'OEM') ...[
                              const SizedBox(width: 6),
                              _Badge(
                                label: 'OEM',
                                color: isDark ? AppColorsDark.info : AppColorsLight.info,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Cart button
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: p.stock > 0
                        ? () => context.read<CartProvider>().addItem(
                      partId: p.id,
                      sellerId: p.sellerListings.isNotEmpty ? p.sellerListings.first.sellerId : '',
                      partName: p.name,
                      partSku: p.sku,
                      partImage: p.images.isNotEmpty ? p.images.first : null,
                      sellerName: p.sellerListings.isNotEmpty ? p.sellerListings.first.sellerName : '',
                      price: p.price,
                      mrp: p.mrp,
                    )
                        : null,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: p.stock > 0
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : (isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: p.stock > 0
                              ? AppColors.primary.withValues(alpha: 0.3)
                              : (isDark ? AppColorsDark.border : AppColorsLight.border),
                        ),
                      ),
                      child: Icon(
                        Icons.add_shopping_cart_outlined,
                        size: 18,
                        color: p.stock > 0
                            ? AppColors.primary
                            : (isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'DMSans',
          fontWeight: FontWeight.w600,
          fontSize: 10,
          color: color,
        ),
      ),
    );
  }
}

// ─── Shimmer placeholder card ─────────────────────────────────

class _ShimmerCard extends StatefulWidget {
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
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween(begin: 0.4, end: 0.9).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final shimmer = isDark
            ? AppColorsDark.bgInput.withValues(alpha: _anim.value)
            : AppColorsLight.bgInput.withValues(alpha: _anim.value);
        return Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColorsDark.bgCard.withValues(alpha: _anim.value)
                : AppColorsLight.bgCard.withValues(alpha: _anim.value),
            borderRadius: AppRadius.cardRadius,
            border: Border.all(color: isDark ? AppColorsDark.border : AppColorsLight.border),
          ),
          child: Column(
            children: [
              Expanded(flex: 5, child: Container(color: shimmer)),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 10, width: 60, decoration: BoxDecoration(color: shimmer, borderRadius: BorderRadius.circular(4))),
                      const SizedBox(height: 6),
                      Container(height: 12, decoration: BoxDecoration(color: shimmer, borderRadius: BorderRadius.circular(4))),
                      const SizedBox(height: 4),
                      Container(height: 12, width: 100, decoration: BoxDecoration(color: shimmer, borderRadius: BorderRadius.circular(4))),
                      const Spacer(),
                      Container(height: 14, width: 70, decoration: BoxDecoration(color: shimmer, borderRadius: BorderRadius.circular(4))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Sort Bottom Sheet ────────────────────────────────────────

class _SortSheet extends StatelessWidget {
  final _SortBy current;
  final ValueChanged<_SortBy> onSelect;

  const _SortSheet({required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sort by', style: AppTextStyles.heading(isDark)),
          const SizedBox(height: 16),
          ..._SortBy.values.map(
                (s) => InkWell(
              onTap: () => onSelect(s),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
                child: Row(
                  children: [
                    Expanded(child: Text(s.label, style: AppTextStyles.bodyMd(isDark))),
                    if (s == current) const Icon(Icons.check_circle, color: AppColors.primary, size: 18),
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

// ─── Filter Bottom Sheet ──────────────────────────────────────

class _FilterSheet extends StatefulWidget {
  final bool inStockOnly, oemOnly;
  final RangeValues priceRange;
  final String? selectedBrand;
  final Function(bool, bool, RangeValues, String?) onApply;
  final VoidCallback onReset;

  const _FilterSheet({
    required this.inStockOnly,
    required this.oemOnly,
    required this.priceRange,
    required this.selectedBrand,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late bool _inStock;
  late bool _oem;
  late RangeValues _price;
  String? _brand;

  static const _brands = ['Bosch', 'Exide', 'Mahle', 'Minda', 'Monroe', 'Lumax', 'NGK', 'Valeo'];

  @override
  void initState() {
    super.initState();
    _inStock = widget.inStockOnly;
    _oem = widget.oemOnly;
    _price = widget.priceRange;
    _brand = widget.selectedBrand;
  }

  String _fmt(double v) => '₹${v.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
  )}';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      builder: (_, ctrl) => ListView(
        controller: ctrl,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColorsDark.border : AppColorsLight.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Text('Filters', style: AppTextStyles.heading(isDark))),
              GestureDetector(
                onTap: widget.onReset,
                child: Text(
                  'Reset all',
                  style: AppTextStyles.bodySm(isDark).copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Text('Availability', style: AppTextStyles.labelMd(isDark)),
          const SizedBox(height: 10),
          _FilterToggleRow(
            label: 'In Stock only',
            value: _inStock,
            onChanged: (v) => setState(() => _inStock = v),
          ),
          const SizedBox(height: 16),

          Text('Part Type', style: AppTextStyles.labelMd(isDark)),
          const SizedBox(height: 10),
          _FilterToggleRow(
            label: 'OEM / Genuine only',
            value: _oem,
            onChanged: (v) => setState(() => _oem = v),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(child: Text('Price Range', style: AppTextStyles.labelMd(isDark))),
              Text(
                '${_fmt(_price.start)} — ${_fmt(_price.end)}',
                style: AppTextStyles.bodySm(isDark).copyWith(
                  color: isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.12),
              rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 8),
              trackHeight: 3,
            ),
            child: RangeSlider(
              values: _price,
              min: 0,
              max: 50000,
              divisions: 100,
              onChanged: (v) => setState(() => _price = v),
            ),
          ),
          const SizedBox(height: 16),

          Text('Brand', style: AppTextStyles.labelMd(isDark)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _brands.map((b) {
              final selected = _brand == b;
              return GestureDetector(
                onTap: () => setState(() => _brand = selected ? null : b),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withValues(alpha: 0.12)
                        : (isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.5)
                          : (isDark ? AppColorsDark.border : AppColorsLight.border),
                    ),
                  ),
                  child: Text(
                    b,
                    style: AppTextStyles.labelSm(isDark).copyWith(
                      color: selected
                          ? AppColors.primary
                          : (isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary),
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onApply(_inStock, _oem, _price, _brand),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _FilterToggleRow({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.bodyMd(isDark))),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: value ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: value
                    ? AppColors.primary
                    : (isDark ? AppColorsDark.border : AppColorsLight.border),
                width: 1.5,
              ),
            ),
            child: value ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
          ),
        ],
      ),
    );
  }
}