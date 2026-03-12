import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class DealerDashboardScreen extends StatefulWidget {
  const DealerDashboardScreen({super.key});

  @override
  State<DealerDashboardScreen> createState() => _DealerDashboardScreenState();
}

class _DealerDashboardScreenState extends State<DealerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late List<Animation<double>> _fadeAnims;

  // Mock stats — replace with real API data
  final List<_StatItem> _stats = const [
    _StatItem(
      label: 'Revenue',
      value: '₹1.24L',
      icon: Icons.trending_up,
      delta: '+12%',
    ),
    _StatItem(
      label: 'Orders',
      value: '38',
      icon: Icons.receipt_long_outlined,
      delta: '+5',
    ),
    _StatItem(
      label: 'Inventory',
      value: '214',
      icon: Icons.inventory_2_outlined,
      delta: '',
    ),
    _StatItem(
      label: 'Pending',
      value: '6',
      icon: Icons.hourglass_top_outlined,
      delta: '',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnims = List.generate(
      6,
      (i) => CurvedAnimation(
        parent: _animCtrl,
        curve: Interval(i * 0.08, (i * 0.08) + 0.5, curve: Curves.easeOut),
      ),
    );
    _animCtrl.forward();
    Future.microtask(() {
      context.read<AuthProvider>().getDealerStatus();
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dealerStatus = auth.dealerStatus.toString();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bg = isDarkMode ? AppColorsDark.bg : AppColorsLight.bg;

    if (auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(isDarkMode),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),
                _animated(0, _buildStatusBanner(isDarkMode, dealerStatus)),
                const SizedBox(height: 28),
                if (dealerStatus == "approved") ...[
                  _animated(1, _buildSectionLabel('Today\'s Overview', isDarkMode)),
                  const SizedBox(height: 14),
                  _animated(2, _buildStatsGrid(isDarkMode)),
                  const SizedBox(height: 28),
                  _animated(3, _buildSectionLabel('Quick Actions', isDarkMode)),
                  const SizedBox(height: 14),
                  _animated(4, _buildActionGrid(isDarkMode)),
                ] else ...[
                  _animated(1, _buildPendingIllustration(isDarkMode)),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _animated(int idx, Widget child) => FadeTransition(
    opacity: _fadeAnims[idx],
    child: SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.06),
        end: Offset.zero,
      ).animate(_fadeAnims[idx]),
      child: child,
    ),
  );

  Widget _buildSliverAppBar(bool isDarkMode) {
    final themeBg = isDarkMode ? AppColorsDark.bg : AppColorsLight.bg;
    final cardBg = isDarkMode ? AppColorsDark.bgCard : AppColorsLight.bgCard;
    final borderColor = isDarkMode ? AppColorsDark.border : AppColorsLight.border;

    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      stretch: true,
      elevation: 0,
      backgroundColor: themeBg,

      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.blurBackground, StretchMode.zoomBackground],
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withValues(alpha: isDarkMode ? 0.15 : 0.08),
                themeBg,
              ],
            ),
            border: Border(
              bottom: BorderSide(color: borderColor, width: 1),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    _buildBrandLogo(),
                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Parts Adda',
                            style: AppTextStyles.displaySm(isDarkMode).copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Official Dealer Store',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode ? Colors.white60 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Notification Icon with Badge
                    _buildNotificationButton(cardBg, borderColor, isDarkMode),
                  ],
                ),
                const SizedBox(height: 20), // Spacing for the "title" below
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandLogo() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'PA',
          style: TextStyle(
            fontFamily: 'Syne',
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationButton(Color bg, Color border, bool isDarkMode) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
          child: IconButton(
            icon: Icon(
              Icons.notifications_none_rounded,
              color: isDarkMode ? Colors.white70 : Colors.black87,
              size: 24,
            ),
            onPressed: () {},
          ),
        ),
        // Active notification dot
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.redAccent,
              shape: BoxShape.circle,
              border: Border.all(color: bg, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // ── Status Banner ──────────────────────────────────────────────────────────

  Widget _buildStatusBanner(bool isDarkMode, String dealerStatus) {
    final cfg = _statusConfig(dealerStatus);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cfg.color.withValues(alpha: isDarkMode ? 0.12 : 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cfg.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cfg.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(cfg.icon, color: cfg.color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cfg.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: cfg.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  cfg.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: cfg.color.withValues(alpha: 0.75),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (dealerStatus == 'rejected')
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(foregroundColor: cfg.color),
              child: const Text('Re-apply', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }

  // ── Stats Grid ─────────────────────────────────────────────────────────────

  Widget _buildStatsGrid(bool isDarkMode) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.55,
      ),
      itemBuilder: (_, i) => _StatCard(item: _stats[i], isDarkMode: isDarkMode),
    );
  }

  // ── Action Grid ────────────────────────────────────────────────────────────

  Widget _buildActionGrid(bool isDarkMode) {
    final actions = [
      _ActionItem(Icons.inventory_2_outlined, 'Inventory', AppColors.primary),
      _ActionItem(Icons.receipt_long_outlined, 'Orders', Colors.indigo),
      _ActionItem(Icons.bar_chart_rounded, 'Analytics', Colors.teal),
      _ActionItem(Icons.support_agent_outlined, 'Support', Colors.orange),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.9,
      ),
      itemBuilder: (_, i) => _ActionCard(item: actions[i], isDarkMode: isDarkMode),
    );
  }

  // ── Pending illustration ───────────────────────────────────────────────────

  Widget _buildPendingIllustration(bool isDarkMode) {
    final sub = isDarkMode
        ? AppColorsDark.textSecondary
        : AppColorsLight.textSecondary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hourglass_bottom_rounded,
              color: Colors.orange,
              size: 44,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Application Under Review',
            style: AppTextStyles.headingSm(isDarkMode),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Our team is verifying your documents.\nThis usually takes 1–2 business days.',
            style: TextStyle(fontSize: 13, color: sub, height: 1.6),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.headset_mic_outlined, size: 16),
            label: const Text('Contact Support'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, bool isDarkMode) => Text(
    label,
    style: AppTextStyles.headingSm(isDarkMode).copyWith(fontSize: 15),
  );

  // ── Helpers ────────────────────────────────────────────────────────────────

  _StatusConfig _statusConfig(String status) {
    switch (status) {
      case 'approved':
        return _StatusConfig(
          color: Colors.green,
          icon: Icons.verified_rounded,
          title: 'Account Approved',
          subtitle: 'You\'re all set. Start listing your inventory.',
        );
      case 'rejected':
        return _StatusConfig(
          color: Colors.red,
          icon: Icons.cancel_outlined,
          title: 'Application Rejected',
          subtitle:
              'Your application didn\'t meet our criteria. Please re-apply.',
        );
      default:
        return _StatusConfig(
          color: Colors.orange,
          icon: Icons.hourglass_top_rounded,
          title: 'Verification Pending',
          subtitle: 'We\'re reviewing your dealer application.',
        );
    }
  }
}

// ── Data models ───────────────────────────────────────────────────────────────

class _StatusConfig {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;

  const _StatusConfig({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final String delta;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.delta,
  });
}

class _ActionItem {
  final IconData icon;
  final String label;
  final Color color;

  const _ActionItem(this.icon, this.label, this.color);
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final _StatItem item;
  final bool isDarkMode;

  const _StatCard({required this.item, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final cardBg = isDarkMode ? AppColorsDark.bgCard : AppColorsLight.bgCard;
    final border = isDarkMode ? AppColorsDark.border : AppColorsLight.border;
    final sub = isDarkMode ? AppColorsDark.textMuted : AppColorsLight.textMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(item.icon, color: AppColors.primary, size: 20),
              if (item.delta.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.delta,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.value,
                style: AppTextStyles.displaySm(
                  isDarkMode,
                ).copyWith(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              Text(item.label, style: TextStyle(fontSize: 12, color: sub)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final _ActionItem item;
  final bool isDarkMode;

  const _ActionCard({required this.item, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final cardBg = isDarkMode ? AppColorsDark.bgCard : AppColorsLight.bgCard;
    final border = isDarkMode ? AppColorsDark.border : AppColorsLight.border;

    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: item.color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(item.label, style: AppTextStyles.labelMd(isDarkMode)),
          ],
        ),
      ),
    );
  }
}
