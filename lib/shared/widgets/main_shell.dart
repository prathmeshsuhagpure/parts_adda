import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:badges/badges.dart' as badges;
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_routes.dart';
import '../../features/cart/presentation/providers/cart_provider.dart';
import 'loading_overlay.dart';

class CustomerMainShell extends StatefulWidget {
  final Widget child;

  const CustomerMainShell({super.key, required this.child});

  @override
  State<CustomerMainShell> createState() => _CustomerMainShellState();
}

class _CustomerMainShellState extends State<CustomerMainShell> {
  DateTime? _lastBackPress;

  int _locToIndex(String loc) {
    if (loc.startsWith('/wishlist')) return 1;
    if (loc.startsWith('/cart')) return 2;
    if (loc.startsWith('/orders')) return 3;
    if (loc.startsWith('/settings')) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int i) {
    const tabs = [
      AppRoutes.home,
      AppRoutes.wishlist,
      AppRoutes.cart,
      AppRoutes.orders,
      AppRoutes.settings,
    ];
    LoaderService().show(context);
    Future.delayed(const Duration(seconds: 1), () {
      LoaderService().hide();
      context.go(tabs[i]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final current = _locToIndex(location);
    final cartCount = context.select<CartProvider, int>((c) => c.itemCount);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;

        if (current != 0) {
          context.go(AppRoutes.home);
          return;
        }

        final now = DateTime.now();
        final isDoubleBack =
            _lastBackPress != null &&
            now.difference(_lastBackPress!) < const Duration(seconds: 2);

        if (isDoubleBack) {
          SystemNavigator.pop();
          return;
        }

        _lastBackPress = now;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Press back again to exit',
              style: TextStyle(
                color: isDarkMode
                    ? AppColorsDark.textPrimary
                    : AppColorsLight.textPrimary,
              ),
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: isDarkMode
                ? AppColorsDark.bgCard
                : AppColorsLight.bgCard,
          ),
        );
      },
      child: Scaffold(
        body: widget.child,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? AppColorsDark.bgCard2 : AppColorsLight.bgCard2,
            border: Border(
              top: BorderSide(
                color: isDarkMode
                    ? AppColorsDark.border
                    : AppColorsLight.border,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    label: 'Home',
                    isActive: current == 0,
                    onTap: () => _onTap(context, 0),
                  ),
                  _NavItem(
                    icon: Icons.favorite_outlined,
                    activeIcon: Icons.favorite,
                    label: 'Wishlist',
                    isActive: current == 1,
                    onTap: () => _onTap(context, 1),
                  ),
                  _NavItem(
                    icon: Icons.shopping_cart_outlined,
                    activeIcon: Icons.shopping_cart,
                    label: 'Cart',
                    isActive: current == 2,
                    onTap: () => _onTap(context, 2),
                    badge: cartCount > 0 ? '$cartCount' : null,
                  ),
                  _NavItem(
                    icon: Icons.receipt_long_outlined,
                    activeIcon: Icons.receipt_long,
                    label: 'Orders',
                    isActive: current == 3,
                    onTap: () => _onTap(context, 3),
                  ),
                  _NavItem(
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings,
                    label: 'Settings',
                    isActive: current == 4,
                    onTap: () => _onTap(context, 4),
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

class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final String? badge;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final color = isActive
        ? AppColors.primary
        : (isDarkMode ? AppColorsDark.textMuted : AppColorsLight.textMuted);
    final iconWidget = Icon(
      isActive ? activeIcon : icon,
      color: color,
      size: 22,
    );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            badge != null
                ? badges.Badge(
                    badgeContent: Text(
                      badge!,
                      style: const TextStyle(color: Colors.white, fontSize: 8),
                    ),
                    badgeStyle: const badges.BadgeStyle(
                      badgeColor: AppColors.primary,
                      padding: EdgeInsets.all(4),
                    ),
                    child: iconWidget,
                  )
                : iconWidget,
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTextStyles.bodyXs(isDarkMode).copyWith(
                color: color,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppLoadingIndicator extends StatelessWidget {
  final double size;

  const AppLoadingIndicator({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: const CircularProgressIndicator(
      color: AppColors.primary,
      strokeWidth: 2.5,
    ),
  );
}

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle, actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColorsDark.bgInput
                    : AppColorsLight.bgInput,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 40,
                color: isDarkMode
                    ? AppColorsDark.textMuted
                    : AppColorsLight.textMuted,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppTextStyles.heading(isDarkMode),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: AppTextStyles.bodyMd(isDarkMode).copyWith(
                  color: isDarkMode
                      ? AppColorsDark.textSecondary
                      : AppColorsLight.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class StarRatingWidget extends StatelessWidget {
  final double rating;
  final double size;
  final int maxStars;

  const StarRatingWidget({
    super.key,
    required this.rating,
    this.size = 14,
    this.maxStars = 5,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (i) {
        final filled = i < rating.floor();
        final half = !filled && i < rating;
        return Icon(
          filled
              ? Icons.star
              : half
              ? Icons.star_half
              : Icons.star_border,
          color: isDarkMode ? AppColorsDark.warning : AppColorsLight.warning,
          size: size,
        );
      }),
    );
  }
}

class PartCardWidget extends StatelessWidget {
  final String id, name;
  final String? brand, image;
  final double price;
  final double? mrp, rating;
  final bool inStock;
  final VoidCallback onTap;
  final VoidCallback? onAddToCart;

  const PartCardWidget({
    super.key,
    required this.id,
    required this.name,
    this.brand,
    this.image,
    required this.price,
    this.mrp,
    this.rating,
    this.inStock = true,
    required this.onTap,
    this.onAddToCart,
  });

  String _fmt(double v) =>
      '₹${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  @override
  Widget build(BuildContext context) {
    final discount = (mrp != null && mrp! > price)
        ? (((mrp! - price) / mrp!) * 100).round()
        : 0;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? AppColorsDark.bgCard : AppColorsLight.bgCard,
          border: Border.all(
            color: isDarkMode ? AppColorsDark.border : AppColorsLight.border,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
              child: AspectRatio(
                aspectRatio: 1.2,
                child: Stack(
                  children: [
                    Container(
                      color: isDarkMode
                          ? AppColorsDark.bgInput
                          : AppColorsLight.bgInput,
                      child: image != null
                          ? Image.network(image!, fit: BoxFit.contain)
                          : Center(
                              child: Icon(
                                Icons.settings,
                                size: 36,
                                color: isDarkMode
                                    ? AppColorsDark.textMuted
                                    : AppColorsLight.textMuted,
                              ),
                            ),
                    ),
                    if (discount > 0)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? AppColorsDark.success.withValues(alpha: 0.9)
                                : AppColorsLight.success.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$discount% off',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.labelMd(isDarkMode),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (brand != null) ...[
                    const SizedBox(height: 2),
                    Text(brand!, style: AppTextStyles.bodyXs(isDarkMode)),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_fmt(price), style: AppTextStyles.priceSm()),
                          if (mrp != null && mrp! > price)
                            Text(
                              _fmt(mrp!),
                              style: AppTextStyles.strikethrough(isDarkMode),
                            ),
                        ],
                      ),
                      if (onAddToCart != null)
                        GestureDetector(
                          onTap: onAddToCart,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '+ Add',
                              style: TextStyle(
                                fontFamily: 'Syne',
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
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
