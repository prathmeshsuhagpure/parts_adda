import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../features/cart/presentation/providers/cart_provider.dart';
import '../providers/profile_provider.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  _SortMode _sort = _SortMode.dateAdded;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadWishlist();
    });
  }

  String _fmt(double v) =>
      '₹${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  List<dynamic> _sorted(List<dynamic> raw) {
    final list = List<dynamic>.from(raw);
    switch (_sort) {
      case _SortMode.dateAdded:
        return list;
      case _SortMode.priceLow:
        list.sort((a, b) => (a['price'] as num).compareTo(b['price'] as num));
        break;
      case _SortMode.priceHigh:
        list.sort((a, b) => (b['price'] as num).compareTo(a['price'] as num));
        break;
      case _SortMode.name:
        list.sort(
          (a, b) => (a['name'] as String).compareTo(b['name'] as String),
        );
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<ProfileProvider>();
    final isLoading = provider.isLoading;
    final items = _sorted(context.watch<ProfileProvider>().wishlist);

    return Scaffold(
      backgroundColor: isDarkMode ? AppColorsDark.bg : AppColorsLight.bg,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppColorsDark.bg : AppColorsLight.bg,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: isDarkMode
                ? AppColorsDark.textPrimary
                : AppColorsLight.textPrimary,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Wishlist', style: AppTextStyles.headingSm(isDarkMode)),
            if (!isLoading && items.isNotEmpty)
              Text(
                '${items.length} saved item${items.length == 1 ? '' : 's'}',
                style: AppTextStyles.bodyXs(isDarkMode),
              ),
          ],
        ),
        actions: [
          if (items.isNotEmpty)
            GestureDetector(
              onTap: () => _showSortSheet(context, isDarkMode),
              child: Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppColorsDark.bgCard
                        : AppColorsLight.bgCard,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDarkMode
                          ? AppColorsDark.border
                          : AppColorsLight.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.sort,
                        size: 14,
                        color: isDarkMode
                            ? AppColorsDark.textMuted
                            : AppColorsLight.textMuted,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _sort.label,
                        style: AppTextStyles.labelXs(isDarkMode).copyWith(
                          letterSpacing: 0.3,
                          color: isDarkMode
                              ? AppColorsDark.textSecondary
                              : AppColorsLight.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),

      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: isDarkMode
            ? AppColorsDark.bgCard
            : AppColorsLight.bgCard,
        onRefresh: () => context.read<ProfileProvider>().loadWishlist(),
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              )
            : items.isEmpty
            ? _EmptyState(isDark: isDarkMode)
            : _WishlistGrid(
                items: items,
                isDark: isDarkMode,
                fmt: _fmt,
                onRemove: (id) =>
                    context.read<ProfileProvider>().toggleWishlist(id),
                onAddToCart: (item) {
                  context.read<CartProvider>().addItem(
                    partId: item['id'] as String,
                    sellerId: (item['sellerId'] as String?) ?? '',
                    partName: item['name'] as String,
                    partSku: (item['sku'] as String?) ?? '',
                    partImage: item['image'] as String?,
                    sellerName: (item['sellerName'] as String?) ?? '',
                    price: (item['price'] as num).toDouble(),
                    mrp: item['mrp'] != null
                        ? (item['mrp'] as num).toDouble()
                        : null,
                  );
                  _toast(context, '${item['name']} added to cart', isDarkMode);
                },
              ),
      ),
    );
  }

  void _showSortSheet(BuildContext context, bool isDark) {
    final bgCard = isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;

    showModalBottomSheet(
      context: context,
      backgroundColor: bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
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
            Text('Sort by', style: AppTextStyles.heading(isDark)),
            const SizedBox(height: 12),
            ..._SortMode.values.map(
              (s) => InkWell(
                onTap: () {
                  setState(() => _sort = s);
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
                        child: Text(
                          s.label,
                          style: AppTextStyles.bodyMd(isDark),
                        ),
                      ),
                      if (s == _sort)
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
      ),
    );
  }

  void _toast(BuildContext context, String msg, bool isDark) {
    final bgCard = isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: AppTextStyles.bodyMd(isDark)),
        backgroundColor: bgCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: AppColors.primary,
          onPressed: () => context.push(AppRoutes.cart),
        ),
      ),
    );
  }
}

// ─── Sort enum ────────────────────────────────────────────────

enum _SortMode { dateAdded, priceLow, priceHigh, name }

extension _SortLabel on _SortMode {
  String get label {
    switch (this) {
      case _SortMode.dateAdded:
        return 'Date Added';
      case _SortMode.priceLow:
        return 'Price: Low → High';
      case _SortMode.priceHigh:
        return 'Price: High → Low';
      case _SortMode.name:
        return 'Name A–Z';
    }
  }
}

// ─── Wishlist Grid ────────────────────────────────────────────

class _WishlistGrid extends StatelessWidget {
  final List<dynamic> items;
  final bool isDark;
  final String Function(double) fmt;
  final ValueChanged<String> onRemove;
  final ValueChanged<Map<String, dynamic>> onAddToCart;

  const _WishlistGrid({
    required this.items,
    required this.isDark,
    required this.fmt,
    required this.onRemove,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.60,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = Map<String, dynamic>.from(items[i] as Map);
        final id = item['id']?.toString();
        return _WishlistCard(
          item: Map<String, dynamic>.from(items[i] as Map),
          isDark: isDark,
          fmt: fmt,
          onRemove: () {
            final id = (item['_id'] ?? item['id'])?.toString();
            if (id != null) onRemove(id);
          },
          onAddToCart: () =>
              onAddToCart(Map<String, dynamic>.from(items[i] as Map)),
          onTap: () {
            final id = item['_id'] ?? item['id'];
            if (id != null) {
              context.push(AppRoutes.partDetailPath(id.toString()));
            }
          },
        );
      },
    );
  }
}

class _WishlistCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final bool isDark;
  final String Function(double) fmt;
  final VoidCallback onRemove, onAddToCart, onTap;

  const _WishlistCard({
    required this.item,
    required this.isDark,
    required this.fmt,
    required this.onRemove,
    required this.onAddToCart,
    required this.onTap,
  });

  @override
  State<_WishlistCard> createState() => _WishlistCardState();
}

class _WishlistCardState extends State<_WishlistCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _heartCtrl;
  late final Animation<double> _heartAnim;
  bool _removed = false;
  bool _isRemoving = false;

  @override
  void initState() {
    super.initState();
    _heartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _heartAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _heartCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _heartCtrl.dispose();
    super.dispose();
  }

  void _animateAndRemove() async {
    if (_isRemoving) return;
    setState(() => _isRemoving = true);

    await _heartCtrl.forward(from: 0);
    widget.onRemove();

    if (mounted) {
      setState(() => _isRemoving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Removed from wishlist"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final bgCard = isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;
    final bgInput = isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;
    final textMuted = isDark
        ? AppColorsDark.textMuted
        : AppColorsLight.textMuted;

    final item = widget.item;
    final price = (item['price'] as num?)?.toDouble() ?? 0.0;
    final mrp = (item['mrp'] as num?)?.toDouble();
    final inStock = (item['stock'] as int? ?? 1) > 0;
    final discount = (mrp != null && mrp > price)
        ? (((mrp - price) / mrp) * 100).round()
        : 0;
    final brand = item['brand'] as String? ?? '';
    final name = item['name'] as String? ?? '';
    final image = item['image'] as String?;
    final partType = item['partType'] as String?;

    return GestureDetector(
      onTap: widget.onTap,
      child: _isRemoving
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Container(
              decoration: BoxDecoration(
                color: bgCard,
                borderRadius: AppRadius.cardRadius,
                border: Border.all(color: border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Image + heart + badges ──────────────────────
                  Stack(
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: AspectRatio(
                          aspectRatio: 1.1,
                          child: Container(
                            color: bgInput,
                            child: image != null
                                ? Image.network(image, fit: BoxFit.contain)
                                : Center(
                                    child: Icon(
                                      Icons.settings_outlined,
                                      size: 40,
                                      color: isDark
                                          ? AppColorsDark.textMuted
                                          : AppColorsLight.textMuted,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      // Discount badge
                      if (discount > 0)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColorsDark.success,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '-$discount%',
                              style: const TextStyle(
                                fontFamily: 'Syne',
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                      // OEM badge
                      if (partType == 'OEM')
                        Positioned(
                          top: 8,
                          right: 36,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColorsDark.info.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text(
                              'OEM',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontWeight: FontWeight.w700,
                                fontSize: 9,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: _animateAndRemove,
                          child: ScaleTransition(
                            scale: _heartAnim,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.38),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _removed
                                    ? Icons.favorite_border
                                    : Icons.favorite,
                                color: _removed
                                    ? Colors.grey
                                    : AppColors.primary,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ── Info ──────────────────────────────────────────
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (brand.isNotEmpty)
                            Text(
                              brand.toUpperCase(),
                              style: AppTextStyles.labelXs(
                                isDark,
                              ).copyWith(color: textMuted, letterSpacing: 0.8),
                            ),
                          const SizedBox(height: 3),
                          Text(
                            name,
                            style: AppTextStyles.labelMd(isDark),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),

                          // Price row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                widget.fmt(price),
                                style: AppTextStyles.priceSm(),
                              ),
                              if (mrp != null && mrp > price) ...[
                                const SizedBox(width: 4),
                                Text(
                                  widget.fmt(mrp),
                                  style: AppTextStyles.strikethrough(
                                    isDark,
                                  ).copyWith(fontSize: 10),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Stock + Add to Cart
                          Row(
                            children: [
                              // Stock badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: inStock
                                      ? AppColorsDark.success.withValues(
                                          alpha: 0.1,
                                        )
                                      : AppColorsLight.error.withValues(
                                          alpha: 0.1,
                                        ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  inStock ? 'In Stock' : 'Out of Stock',
                                  style: AppTextStyles.labelXs(isDark).copyWith(
                                    color: inStock
                                        ? AppColorsDark.success
                                        : AppColorsLight.error,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              const Spacer(),

                              // Add to cart icon
                              GestureDetector(
                                onTap: inStock ? widget.onAddToCart : null,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: inStock
                                        ? AppColors.primary
                                        : (isDark
                                              ? AppColorsDark.bgInput
                                              : AppColorsLight.bgInput),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.add_shopping_cart_outlined,
                                    size: 15,
                                    color: inStock ? Colors.white : textMuted,
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
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────

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

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: constraints.maxHeight,
          // fills the viewport so pull registers
          child: Center(
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
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 44,
                            color: isDark
                                ? AppColorsDark.textMuted
                                : AppColorsLight.textMuted,
                          ),
                          Positioned(
                            right: 14,
                            bottom: 14,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Your wishlist is empty',
                    style: AppTextStyles.heading(isDark),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the ♡ on any part to save it here for later.',
                    style: AppTextStyles.bodyMd(
                      isDark,
                    ).copyWith(color: textSec),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: () => context.push(AppRoutes.search),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Browse Parts',
                      style: AppTextStyles.buttonSm,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
