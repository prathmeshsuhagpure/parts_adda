import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_routes.dart';

class DealerShell extends StatelessWidget {
  final Widget child;

  const DealerShell({super.key, required this.child});

  int _locToIndex(String loc) {
    if (loc.startsWith('/dealer/orders')) return 1;
    if (loc.startsWith('/dealer/inventory')) return 2;
    if (loc.startsWith('/dealer/profile')) return 3;
    return 0;
  }

  void _onTap(BuildContext context, int i) {
    const tabs = [
      AppRoutes.dealerHome,
      AppRoutes.dealerOrders,
      AppRoutes.dealerInventory,
      AppRoutes.dealerProfile,
    ];
    context.go(tabs[i]);
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final current = _locToIndex(location);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? AppColorsDark.bgCard2 : AppColorsLight.bgCard2,
          border: Border(
            top: BorderSide(
              color: isDarkMode ? AppColorsDark.border : AppColorsLight.border,
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
                  label: 'Dashboard',
                  isActive: current == 0,
                  onTap: () => _onTap(context, 0),
                ),
                _NavItem(
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long,
                  label: 'Orders',
                  isActive: current == 1,
                  onTap: () => _onTap(context, 1),
                  //badge: ,
                ),
                _NavItem(
                  icon: Icons.shopping_cart_outlined,
                  activeIcon: Icons.shopping_cart,
                  label: 'Inventory',
                  isActive: current == 2,
                  onTap: () => _onTap(context, 2),
                ),
                _NavItem(
                  icon: Icons.person_outlined,
                  activeIcon: Icons.person,
                  label: 'Profile',
                  isActive: current == 3,
                  onTap: () => _onTap(context, 3),
                ),
              ],
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