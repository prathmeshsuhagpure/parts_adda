import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../parts/domain/models/part_model.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

class ResultsView extends StatelessWidget {
  final List<PartModel> results;
  final bool hasMore, isLoadingMore, isDark;
  final ScrollController scrollCtrl;
  final ValueChanged<PartModel> onTap, onAddToCart, onToggleWishlist;
  final bool Function(PartModel) isWishlisted;

  const ResultsView({
    super.key,
    required this.results,
    required this.hasMore,
    required this.isLoadingMore,
    required this.isDark,
    required this.scrollCtrl,
    required this.onTap,
    required this.onAddToCart,
    required this.onToggleWishlist,
    required this.isWishlisted,
  });

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
        childAspectRatio: 0.58,
      ),
      itemCount: results.length + (isLoadingMore ? 2 : 0),
      itemBuilder: (_, i) {
        if (i >= results.length) return SkeletonCard(isDark: isDark);
        final p = results[i];
        return _GridCard(
          part: p,
          isDark: isDark,
          wishlisted: isWishlisted(p),
          onTap: () => onTap(p),
          onAddToCart: () => onAddToCart(p),
          onToggleWishlist: () => onToggleWishlist(p),
        );
      },
    );
  }
}

class _GridCard extends StatelessWidget {
  final PartModel part;
  final bool isDark, wishlisted;
  final VoidCallback onTap, onAddToCart, onToggleWishlist;

  const _GridCard({
    required this.part,
    required this.isDark,
    required this.wishlisted,
    required this.onTap,
    required this.onAddToCart,
    required this.onToggleWishlist,
  });

  Future<void> requireAuth(BuildContext context, VoidCallback onSuccess) async {
    final isLoggedIn = context.read<AuthProvider>().isLoggedIn;

    if (!isLoggedIn) {
      _showLoginBottomSheet(context);
    } else {
      onSuccess();
    }
  }

  String _fmt(double v) =>
      '₹${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  @override
  Widget build(BuildContext context) {
    final bgCard = isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;
    final bgInput = isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;
    final textMut = isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;
    final discount = (part.mrp != null && part.mrp! > part.price)
        ? (((part.mrp! - part.price) / part.mrp!) * 100).round()
        : 0;
    final inStock = part.stock > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgCard,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1.05,
                    child: Container(
                      color: bgInput,
                      child: part.images.isNotEmpty
                          ? Image.network(
                              part.images.first,
                              fit: BoxFit.contain,
                            )
                          : Center(
                              child: Icon(
                                Icons.settings_outlined,
                                size: 36,
                                color: textMut,
                              ),
                            ),
                    ),
                  ),
                ),
                if (discount > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _Badge(
                      label: '-$discount%',
                      color: AppColorsDark.success,
                    ),
                  ),
                if (part.partType == 'OEM')
                  Positioned(
                    top: 8,
                    right: 30,
                    child: _Badge(label: 'OEM', color: AppColorsDark.info),
                  ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () async {
                      await requireAuth(
                        context,
                        () => context.read<ProfileProvider>().toggleWishlist(
                          part.id,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: Consumer<ProfileProvider>(
                        builder: (context, provider, _) {
                          final isWishlisted = provider.isWishlisted(part.id);

                          return Icon(
                            isWishlisted
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 14,
                            color: isWishlisted
                                ? AppColors.primary
                                : Colors.white,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    part.brand.name.toUpperCase(),
                    style: AppTextStyles.labelXs(
                      isDark,
                    ).copyWith(color: textMut, letterSpacing: 0.8),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    part.name,
                    style: AppTextStyles.labelMd(isDark),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (part.rating != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 11,
                          color: Color(0xFFFFB800),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          part.rating!.toStringAsFixed(1),
                          style: AppTextStyles.bodyXs(isDark),
                        ),
                        Text(
                          ' (${part.reviewCount})',
                          style: AppTextStyles.bodyXs(
                            isDark,
                          ).copyWith(color: textMut),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(_fmt(part.price), style: AppTextStyles.priceSm()),
                  if (part.mrp != null && part.mrp! > part.price)
                    Text(
                      _fmt(part.mrp!),
                      style: AppTextStyles.strikethrough(isDark),
                    ),
                  const SizedBox(height: 7),
                  GestureDetector(
                    onTap: inStock ? onAddToCart : null,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        color: inStock ? AppColors.primary : bgInput,
                        borderRadius: BorderRadius.circular(8),
                        border: inStock ? null : Border.all(color: border),
                      ),
                      child: Center(
                        child: Text(
                          inStock ? 'Add to Cart' : 'Out of Stock',
                          style: AppTextStyles.buttonSm.copyWith(
                            fontSize: 11,
                            color: inStock ? Colors.white : textMut,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  final bool isDark;
  final Color? color;

  const SkeletonCard({super.key, required this.isDark, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? (isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard);
    final bgCard = isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;

    return Container(
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1.05,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Container(color: c),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 8,
                  width: 50,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 10,
                  width: 100,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final bool small;

  const _Badge({required this.label, required this.color, this.small = false});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: small ? 5 : 7,
      vertical: small ? 2 : 3,
    ),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontFamily: 'Syne',
        fontWeight: FontWeight.w800,
        fontSize: small ? 8 : 10,
        color: Colors.white,
      ),
    ),
  );
}

void _showLoginBottomSheet(BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    backgroundColor: isDarkMode ? AppColorsDark.bgCard : AppColorsLight.bgCard,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Login Required", style: AppTextStyles.heading(isDarkMode)),
            const SizedBox(height: 8),
            Text(
              "Please login to add items to your wishlist.",
              style: AppTextStyles.bodySm(isDarkMode),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                // Cancel
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12),

                // Login
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.go(AppRoutes.login); // your login route
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text("Login"),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
