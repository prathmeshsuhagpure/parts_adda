import 'package:flutter/material.dart';
import '../../../../parts/domain/models/part_model.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/constants/app_theme.dart';

class SellerListingCard extends StatelessWidget {
  final SellerListing listing;
  final bool isSelected;

  const SellerListingCard({
    super.key,
    required this.listing,
    required this.isSelected,
  });

  String _fmt(double v) =>
      '₹${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.06)
            : AppColorsDark.bgCard,
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : (isDarkMode ? AppColorsDark.border : AppColorsLight.border),
          width: isSelected ? 1.5 : 1,
        ),
        borderRadius: AppRadius.cardRadius,
      ),
      child: Row(
        children: [
          // Seller info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      listing.sellerName,
                      style: AppTextStyles.labelMd(isDarkMode),
                    ),
                    const SizedBox(width: 6),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'SELECTED',
                          style: AppTextStyles.labelXs(isDarkMode).copyWith(
                            color: AppColors.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 12,
                      color: isDarkMode
                          ? AppColorsDark.warning
                          : AppColorsLight.warning,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      listing.rating.toStringAsFixed(1),
                      style: AppTextStyles.bodySm(isDarkMode).copyWith(
                        color: isDarkMode
                            ? AppColorsDark.warning
                            : AppColorsLight.warning,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.local_shipping_outlined,
                      size: 12,
                      color: isDarkMode
                          ? AppColorsDark.textMuted
                          : AppColorsLight.textMuted,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      listing.isFreeDelivery
                          ? 'Free delivery'
                          : (listing.deliveryInfo ?? 'Standard delivery'),
                      style: AppTextStyles.bodySm(isDarkMode),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${listing.stock} in stock',
                  style: AppTextStyles.bodyXs(isDarkMode).copyWith(
                    color: listing.stock > 5
                        ? (isDarkMode
                              ? AppColorsDark.success
                              : AppColorsLight.success)
                        : (isDarkMode
                              ? AppColorsDark.warning
                              : AppColorsLight.warning),
                  ),
                ),
              ],
            ),
          ),
          // Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_fmt(listing.price), style: AppTextStyles.priceSm()),
              if (listing.mrp != null && listing.mrp! > listing.price)
                Text(
                  _fmt(listing.mrp!),
                  style: AppTextStyles.strikethrough(isDarkMode),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
