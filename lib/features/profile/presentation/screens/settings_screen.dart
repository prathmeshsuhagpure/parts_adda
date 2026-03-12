import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/provider/theme_provider.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Local toggle states (wire to shared_preferences in production)
  bool _pushOrders = true;
  bool _pushPromos = false;
  bool _emailOffers = true;
  bool _biometric = false;

  // ── Logout confirmation ──────────────────────────────────────
  Future<void> _confirmLogout() async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDarkMode
            ? AppColorsDark.bgCard
            : AppColorsLight.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Log out?', style: AppTextStyles.displaySm(isDarkMode)),
        content: Text(
          'You will need to sign in again to place orders.',
          style: AppTextStyles.bodyMd(isDarkMode).copyWith(
            color: isDarkMode
                ? AppColorsDark.textSecondary
                : AppColorsLight.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelMd(isDarkMode).copyWith(
                color: isDarkMode
                    ? AppColorsDark.textMuted
                    : AppColorsLight.textMuted,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Log out',
              style: AppTextStyles.labelMd(isDarkMode).copyWith(
                color: isDarkMode ? AppColorsDark.error : AppColorsLight.error,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) context.go(AppRoutes.home);
    }
  }

  // ── Delete account confirmation ──────────────────────────────
  Future<void> _confirmDelete() async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDarkMode
            ? AppColorsDark.bgCard
            : AppColorsLight.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete account?',
          style: AppTextStyles.displaySm(isDarkMode),
        ),
        content: Text(
          'All your orders, addresses and profile data will be permanently deleted. This cannot be undone.',
          style: AppTextStyles.bodyMd(isDarkMode).copyWith(
            color: isDarkMode
                ? AppColorsDark.textSecondary
                : AppColorsLight.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelMd(isDarkMode).copyWith(
                color: isDarkMode
                    ? AppColorsDark.textMuted
                    : AppColorsLight.textMuted,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Delete',
              style: AppTextStyles.labelMd(isDarkMode).copyWith(
                color: isDarkMode ? AppColorsDark.error : AppColorsLight.error,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      // TODO: call delete account API
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deletion requested.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final isLoggedIn = auth.status == AuthStatus.authenticated;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        title: Text(
          'Settings',
          style: AppTextStyles.headingSm(
            isDarkMode,
          ).copyWith(color: isDarkMode ? Colors.white : Colors.black),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          // ── Account card ─────────────────────────────────────
          if (isLoggedIn) ...[
            _AccountCard(
              name: user?.name ?? 'User',
              phone: user?.phone ?? '',
              email: user?.email,
              role: user?.role.toString() ?? 'customer',
              onEdit: () => context.push(AppRoutes.settings),
            ),
          ] else ...[
            _GuestCard(
              onLogin: () => context.push(AppRoutes.login),
              onRegister: () => context.push(AppRoutes.register),
            ),
          ],
          const SizedBox(height: 8),

          // ── Account section ───────────────────────────────────
          if (isLoggedIn) ...[
            _SectionLabel('Account'),
            _SettingsTile(
              icon: Icons.person_outline,
              label: 'Edit Profile',
              onTap: () => context.push(AppRoutes.editProfile),
            ),
            _SettingsTile(
              icon: Icons.location_on_outlined,
              label: 'Saved Addresses',
              onTap: () => context.push(AppRoutes.savedAddresses),
            ),
            _SettingsTile(
              icon: Icons.directions_car_outlined,
              label: 'My Vehicles',
              onTap: () => context.push(AppRoutes.myVehicles),
            ),
            _SettingsTile(
              icon: Icons.favorite_border,
              label: 'Wishlist',
              onTap: () => context.push(AppRoutes.wishlist),
            ),
            if (user?.role == 'customer' || user?.role == 'dealer')
              _SettingsTile(
                icon: Icons.store_outlined,
                label: 'Apply for B2B / Dealer Account',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppColorsDark.warning.withValues(alpha: 0.14)
                        : AppColorsLight.warning.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'NEW',
                    style: AppTextStyles.labelXs(isDarkMode).copyWith(
                      color: isDarkMode
                          ? AppColorsDark.warning
                          : AppColorsLight.warning,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                onTap: () => context.push(AppRoutes.b2bRegister),
              ),
            const SizedBox(height: 8),
          ],

          // ── Notifications ─────────────────────────────────────
          _SectionLabel('Notifications'),
          _ToggleTile(
            icon: Icons.receipt_long_outlined,
            label: 'Order updates',
            subtitle: 'Shipped, delivered, cancelled',
            value: _pushOrders,
            onChanged: (v) => setState(() => _pushOrders = v),
          ),
          _ToggleTile(
            icon: Icons.local_offer_outlined,
            label: 'Deals & promotions',
            subtitle: 'Flash sales, coupons',
            value: _pushPromos,
            onChanged: (v) => setState(() => _pushPromos = v),
          ),
          _ToggleTile(
            icon: Icons.email_outlined,
            label: 'Email offers',
            subtitle: 'Weekly digest & newsletters',
            value: _emailOffers,
            onChanged: (v) => setState(() => _emailOffers = v),
          ),
          const SizedBox(height: 8),

          // ── Security ──────────────────────────────────────────
          _SectionLabel('Security'),
          _ToggleTile(
            icon: Icons.fingerprint,
            label: 'Biometric login',
            subtitle: 'Use fingerprint to sign in',
            value: _biometric,
            onChanged: (v) => setState(() => _biometric = v),
          ),
          _SectionLabel('Theme'),
          _ToggleTile(
            icon: Icons.dark_mode,
            label: 'Dark Mode',
            subtitle: 'Switch between light and dark theme',
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
          ),
          if (isLoggedIn)
            _SettingsTile(
              icon: Icons.lock_outline,
              label: 'Change Password',
              onTap: () {
                // TODO: navigate to change password screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Change password — coming soon'),
                  ),
                );
              },
            ),
          const SizedBox(height: 8),

          // ── Support ───────────────────────────────────────────
          _SectionLabel('Support'),
          _SettingsTile(
            icon: Icons.help_outline,
            label: 'Help & FAQ',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.chat_bubble_outline,
            label: 'Contact Support',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.star_border,
            label: 'Rate the App',
            onTap: () {},
          ),
          const SizedBox(height: 8),

          // ── Legal ─────────────────────────────────────────────
          _SectionLabel('Legal'),
          _SettingsTile(
            icon: Icons.description_outlined,
            label: 'Terms of Service',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy Policy',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.article_outlined,
            label: 'Refund Policy',
            onTap: () {},
          ),
          const SizedBox(height: 8),

          // ── App info ──────────────────────────────────────────
          _SectionLabel('App'),
          _InfoTile(label: 'Version', value: '1.0.0'),
          _InfoTile(
            label: 'Platform',
            value: Theme.of(context).platform.name.capitalize(),
          ),
          const SizedBox(height: 8),

          // ── Auth actions ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                if (isLoggedIn) ...[
                  _ActionButton(
                    label: 'Log out',
                    icon: Icons.logout,
                    color: isDarkMode
                        ? AppColorsDark.error
                        : AppColorsLight.error,
                    isLoading: auth.isLoading,
                    onTap: _confirmLogout,
                  ),
                  const SizedBox(height: 10),
                  _ActionButton(
                    label: 'Delete Account',
                    icon: Icons.delete_forever_outlined,
                    color: isDarkMode
                        ? AppColorsDark.textMuted
                        : AppColorsLight.textMuted,
                    isLoading: false,
                    onTap: _confirmDelete,
                    outlined: true,
                  ),
                ] else ...[
                  _ActionButton(
                    label: 'Login',
                    icon: Icons.login,
                    color: AppColors.primary,
                    isLoading: false,
                    onTap: () => context.push(AppRoutes.login),
                  ),
                  const SizedBox(height: 10),
                  _ActionButton(
                    label: 'Create Account / Signup ',
                    icon: Icons.person_add_outlined,
                    color: isDarkMode
                        ? AppColorsDark.textSecondary
                        : AppColorsLight.textSecondary,
                    isLoading: false,
                    onTap: () => context.push(AppRoutes.register),
                    outlined: true,
                  ),
                  const SizedBox(height: 10),
                  _ActionButton(
                    label: 'Login with Google',
                    icon: FontAwesomeIcons.google,
                    color: isDarkMode
                        ? AppColorsDark.textSecondary
                        : AppColorsLight.textSecondary,
                    isLoading: false,
                    onTap: () => context.push(AppRoutes.register),
                    outlined: true,
                  ),
                ],
              ],
            ),
          ),

          // ── Footer ────────────────────────────────────────────
          const SizedBox(height: 32),
          Center(
            child: Text(
              'PartsAdda Marketplace © 2026',
              style: AppTextStyles.bodyXs(isDarkMode).copyWith(
                color: isDarkMode
                    ? AppColorsDark.textMuted
                    : AppColorsLight.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── Account Card ─────────────────────────────────────────────

class _AccountCard extends StatelessWidget {
  final String name, phone, role;
  final String? email;
  final VoidCallback onEdit;

  const _AccountCard({
    required this.name,
    required this.phone,
    required this.role,
    this.email,
    required this.onEdit,
  });

  Color get _roleColor {
    switch (role) {
      case 'vendor':
        return AppColorsDark.warning;
      case 'dealer':
        return AppColorsDark.info;
      case 'admin':
        return AppColorsDark.error;
      default:
        return AppColorsDark.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColorsDark.bgCard : AppColorsLight.bgCard,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(
            color: isDarkMode ? AppColorsDark.border : AppColorsLight.border,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTextStyles.heading(isDarkMode)),
                  const SizedBox(height: 2),
                  Text(
                    email ?? phone,
                    style: AppTextStyles.bodySm(isDarkMode).copyWith(
                      color: isDarkMode
                          ? AppColorsDark.textSecondary
                          : AppColorsLight.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _roleColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      role.toUpperCase(),
                      style: AppTextStyles.labelXs(
                        isDarkMode,
                      ).copyWith(color: _roleColor, letterSpacing: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onEdit,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppColorsDark.bgInput
                      : AppColorsLight.bgInput,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: isDarkMode
                        ? AppColorsDark.border
                        : AppColorsLight.border,
                  ),
                ),
                child: Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: isDarkMode
                      ? AppColorsDark.textSecondary
                      : AppColorsLight.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Guest Card ───────────────────────────────────────────────

class _GuestCard extends StatelessWidget {
  final VoidCallback onLogin, onRegister;

  const _GuestCard({required this.onLogin, required this.onRegister});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColorsDark.bgCard : AppColorsLight.bgCard,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColorsDark.bgInput
                    : AppColorsLight.bgInput,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDarkMode
                      ? AppColorsDark.border
                      : AppColorsLight.border,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.person_outline,
                  color: isDarkMode
                      ? AppColorsDark.textMuted
                      : AppColorsLight.textMuted,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'You\'re not signed in',
              style: AppTextStyles.heading(isDarkMode),
            ),
            const SizedBox(height: 4),
            Text(
              'Sign in to track orders, manage addresses and access deals.',
              style: AppTextStyles.bodySm(isDarkMode).copyWith(
                color: isDarkMode
                    ? AppColorsDark.textSecondary
                    : AppColorsLight.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Sign In', style: AppTextStyles.buttonSm),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onRegister,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isDarkMode
                            ? AppColorsDark.border
                            : AppColorsLight.border,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Register',
                      style: AppTextStyles.buttonSm.copyWith(
                        color: isDarkMode
                            ? AppColorsDark.textPrimary
                            : AppColorsLight.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.labelXs(isDarkMode).copyWith(
          color: isDarkMode
              ? AppColorsDark.textMuted
              : AppColorsLight.textMuted,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

// ─── Settings Tile ────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDarkMode
                  ? AppColorsDark.textSecondary
                  : AppColorsLight.textSecondary,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: AppTextStyles.bodyMd(isDarkMode)),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: isDarkMode
                      ? AppColorsDark.textMuted
                      : AppColorsLight.textMuted,
                ),
          ],
        ),
      ),
    );
  }
}

// ─── Toggle Tile ──────────────────────────────────────────────

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDarkMode
                ? AppColorsDark.textSecondary
                : AppColorsLight.textSecondary,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.bodyMd(isDarkMode)),
                Text(subtitle, style: AppTextStyles.bodyXs(isDarkMode)),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: isDarkMode
                ? AppColorsDark.bgInput
                : AppColorsLight.bgInput,
          ),
        ],
      ),
    );
  }
}

// ─── Info Tile ────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  final String label, value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.bodyMd(isDarkMode))),
          Text(
            value,
            style: AppTextStyles.bodySm(isDarkMode).copyWith(
              color: isDarkMode
                  ? AppColorsDark.textMuted
                  : AppColorsLight.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Action Button ────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isLoading, outlined;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isLoading,
    required this.onTap,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: outlined ? color : Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.buttonSm.copyWith(
                  color: outlined ? color : Colors.white,
                ),
              ),
            ],
          );

    if (outlined) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: isLoading ? null : onTap,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: color.withValues(alpha: 0.4)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: child,
      ),
    );
  }
}

// ─── String extension ─────────────────────────────────────────

extension _StringExt on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
