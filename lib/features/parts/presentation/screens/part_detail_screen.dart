import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../category/presentation/providers/catalog_provider.dart';
import '../../../category/presentation/screens/widgets/compatibility_chips.dart';
import '../../../category/presentation/screens/widgets/review_widget.dart';
import '../../../category/presentation/screens/widgets/seller_listing_card.dart';
import '../../domain/models/part_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../shared/widgets/main_shell.dart';

class PartDetailScreen extends StatefulWidget {
  final String partId;

  const PartDetailScreen({super.key, required this.partId});

  @override
  State<PartDetailScreen> createState() => _PartDetailScreenState();
}

class _PartDetailScreenState extends State<PartDetailScreen> {
  bool _isWishlisted = false;
  int _imgIndex = 0;
  int _sellerIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadPartDetail(widget.partId);
    });
  }

  String _fmt(double v) =>
      '₹${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  void _toggleWishlist() {
    setState(() {
      _isWishlisted = !_isWishlisted;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isWishlisted
              ? 'Added to wishlist'
              : 'Removed from wishlist',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /*void _addToCart(PartModel part, bool isDarkMode) {
    final seller = part.sellerListings.isNotEmpty
        ? part.sellerListings[_sellerIndex]
        : null;
    context.read<CartProvider>().addItem(
      partId: part.id,
      sellerId: seller?.sellerId ?? '',
      quantity: 1,
      partName: '',
      partSku: '',
      partImage: '',
      sellerName: '',
      price: 5,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${part.name} added to cart'),
        backgroundColor: isDarkMode ? AppColorsDark.success : AppColorsLight.success,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () => context.push(AppRoutes.cart),
        ),
      ),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? AppColorsDark.bg : AppColorsLight.bg,
      body: Consumer<CategoryProvider>(
        builder: (context, catalog, _) {
          if (catalog.isDetailLoading) {
            return const Center(child: AppLoadingIndicator());
          }
          if (catalog.detailStatus == CatalogStatus.error) {
            return Center(
              child: Text(
                catalog.error ?? 'Error',
                style: AppTextStyles.bodyMd(isDarkMode),
              ),
            );
          }
          final part = catalog.selectedPart;
          if (part == null) return const SizedBox();
          return _buildBody(part);
        },
      ),
    );
  }

  Widget _buildBody(PartModel part) {
    final discount = (part.mrp != null && part.mrp! > part.price)
        ? (((part.mrp! - part.price) / part.mrp!) * 100).round()
        : 0;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      slivers: [
        // ── Image appbar
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          backgroundColor: isDarkMode
              ? AppColorsDark.bgCard
              : AppColorsLight.bgCard,
          leading: GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 18),
            ),
          ),
          actions: [
            _ActionBtn(
              icon: _isWishlisted ? Icons.favorite : Icons.favorite_border,
              iconColor: _isWishlisted ? Colors.red : Colors.white,
              onTap: _toggleWishlist,
            ),
            _ActionBtn(
              icon: Icons.share_outlined,
              onTap: () {},
              rightMargin: true,
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              children: [
                PageView.builder(
                  itemCount: part.images.isEmpty ? 1 : part.images.length,
                  onPageChanged: (i) => setState(() => _imgIndex = i),
                  itemBuilder: (_, i) => part.images.isEmpty
                      ? Container(
                          color: isDarkMode
                              ? AppColorsDark.bgInput
                              : AppColorsLight.bgInput,
                          child: Center(
                            child: Icon(
                              Icons.settings,
                              size: 80,
                              color: isDarkMode
                                  ? AppColorsDark.textMuted
                                  : AppColorsLight.textMuted,
                            ),
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: part.images[i],
                          fit: BoxFit.contain,
                          placeholder: (_, _) => const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (part.stock > 0
                                  ? (isDarkMode
                                        ? AppColorsDark.success
                                        : AppColorsLight.success)
                                  : (isDarkMode
                                        ? AppColorsDark.error
                                        : AppColorsLight.error))
                              .withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      part.stock > 0 ? 'IN STOCK' : 'OUT OF STOCK',
                      style: const TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (part.images.length > 1)
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        part.images.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: _imgIndex == i ? 18 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _imgIndex == i
                                ? AppColors.primary
                                : (isDarkMode
                                      ? AppColorsDark.textMuted
                                      : AppColorsLight.textMuted),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand + OEM
                Row(
                  children: [
                    Text(
                      part.brand.name.toUpperCase(),
                      style: AppTextStyles.labelXs(isDarkMode).copyWith(
                        letterSpacing: 1,
                        color: isDarkMode
                            ? AppColorsDark.textMuted
                            : AppColorsLight.textMuted,
                      ),
                    ),
                    if (part.oemNumber != null) ...[
                      Text(' · ', style: AppTextStyles.bodyXs(isDarkMode)),
                      Text(
                        'OEM: ${part.oemNumber}',
                        style: AppTextStyles.mono(isDarkMode),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(part.name, style: AppTextStyles.displaySm(isDarkMode)),
                const SizedBox(height: 10),
                // Price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_fmt(part.price), style: AppTextStyles.priceLg()),
                    if (part.mrp != null && part.mrp! > part.price) ...[
                      const SizedBox(width: 8),
                      Text(
                        _fmt(part.mrp!),
                        style: AppTextStyles.strikethrough(isDarkMode),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? AppColorsDark.success.withValues(alpha: 0.12)
                              : AppColorsLight.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Save $discount%',
                          style: AppTextStyles.bodyXs(isDarkMode).copyWith(
                            color: isDarkMode
                                ? AppColorsDark.success
                                : AppColorsLight.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                // Rating
                Row(
                  children: [
                    StarRatingWidget(rating: part.rating ?? 0),
                    const SizedBox(width: 8),
                    Text(
                      '${part.rating?.toStringAsFixed(1)} (${part.reviewCount} reviews)',
                      style: AppTextStyles.bodySm(isDarkMode),
                    ),
                    const Spacer(),
                    Text(
                      '${part.soldCount} sold',
                      style: AppTextStyles.bodySm(isDarkMode).copyWith(
                        color: isDarkMode
                            ? AppColorsDark.success
                            : AppColorsLight.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Delivery badge
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppColorsDark.success.withValues(alpha: 0.06)
                        : AppColorsLight.success.withValues(alpha: 0.06),
                    border: Border.all(
                      color: isDarkMode
                          ? AppColorsDark.success.withValues(alpha: 0.15)
                          : AppColorsLight.success.withValues(alpha: 0.15),
                    ),
                    borderRadius: AppRadius.cardRadius,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_shipping_outlined,
                        color: isDarkMode
                            ? AppColorsDark.success
                            : AppColorsLight.success,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: 'Free delivery by ',
                            style: AppTextStyles.bodyMd(isDarkMode).copyWith(
                              color: isDarkMode
                                  ? AppColorsDark.textSecondary
                                  : AppColorsLight.textSecondary,
                            ),
                            children: [
                              TextSpan(
                                text: 'Tomorrow',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: isDarkMode
                                      ? AppColorsDark.textPrimary
                                      : AppColorsLight.textPrimary,
                                ),
                              ),
                              TextSpan(text: ' if ordered in 4h 12m'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Compatibility
                if (part.compatibility.isNotEmpty) ...[
                  Text(
                    'Compatible Vehicles',
                    style: AppTextStyles.headingSm(isDarkMode),
                  ),
                  const SizedBox(height: 10),
                  CompatibilityChips(compatibility: part.compatibility),
                  const SizedBox(height: 20),
                ],

                // Sellers
                if (part.sellerListings.isNotEmpty) ...[
                  Text(
                    '${part.sellerListings.length} Sellers',
                    style: AppTextStyles.headingSm(isDarkMode),
                  ),
                  const SizedBox(height: 10),
                  ...List.generate(
                    part.sellerListings.length,
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _sellerIndex = i),
                        child: SellerListingCard(
                          listing: part.sellerListings[i],
                          isSelected: _sellerIndex == i,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Description
                if (part.description != null) ...[
                  Text(
                    'Description',
                    style: AppTextStyles.headingSm(isDarkMode),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    part.description!,
                    style: AppTextStyles.bodyMd(isDarkMode).copyWith(
                      color: isDarkMode
                          ? AppColorsDark.textSecondary
                          : AppColorsLight.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Specs
                if (part.specifications != null &&
                    part.specifications!.isNotEmpty) ...[
                  Text(
                    'Specifications',
                    style: AppTextStyles.headingSm(isDarkMode),
                  ),
                  const SizedBox(height: 10),
                  _SpecsTable(specs: part.specifications!),
                  const SizedBox(height: 20),
                ],

                Text('Reviews', style: AppTextStyles.headingSm(isDarkMode)),
                const SizedBox(height: 10),
                ReviewWidget(partId: part.id),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool rightMargin;
  final Color iconColor;

  const _ActionBtn({
    required this.icon,
    required this.onTap,
    this.rightMargin = false,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: EdgeInsets.only(right: rightMargin ? 8 : 4, top: 8, bottom: 8),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 20),
    ),
  );
}

class _SpecsTable extends StatelessWidget {
  final Map<String, dynamic> specs;

  const _SpecsTable({required this.specs});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final entries = specs.entries.toList();
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isDarkMode ? AppColorsDark.border : AppColorsLight.border,
        ),
        borderRadius: AppRadius.cardRadius,
      ),
      child: Column(
        children: List.generate(entries.length, (i) {
          final e = entries[i];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: i.isEven
                  ? (isDarkMode
                        ? AppColorsDark.bgInput
                        : AppColorsLight.bgInput)
                  : (isDarkMode ? AppColorsDark.bgCard : AppColorsLight.bgCard),
              borderRadius: i == 0
                  ? const BorderRadius.vertical(top: Radius.circular(12))
                  : i == entries.length - 1
                  ? const BorderRadius.vertical(bottom: Radius.circular(12))
                  : BorderRadius.zero,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(e.key, style: AppTextStyles.bodySm(isDarkMode)),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    '${e.value}',
                    style: AppTextStyles.labelMd(isDarkMode),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
