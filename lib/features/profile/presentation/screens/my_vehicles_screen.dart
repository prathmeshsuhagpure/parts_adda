import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_routes.dart';
import '../../domain/models/vehicle_model.dart';
import '../providers/profile_provider.dart';
import 'add_vehicle_screen.dart';

class MyVehiclesScreen extends StatefulWidget {
  const MyVehiclesScreen({super.key});

  @override
  State<MyVehiclesScreen> createState() => _MyVehiclesScreenState();
}

class _MyVehiclesScreenState extends State<MyVehiclesScreen> {
  bool get _d => Theme.of(context).brightness == Brightness.dark;

  Color get _bg => _d ? AppColorsDark.bg : AppColorsLight.bg;

  Color get _bgCard => _d ? AppColorsDark.bgCard : AppColorsLight.bgCard;

  Color get _border => _d ? AppColorsDark.border : AppColorsLight.border;

  Color get _txtPri =>
      _d ? AppColorsDark.textPrimary : AppColorsLight.textPrimary;

  Color get _txtSec =>
      _d ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;

  Color get _txtMut => _d ? AppColorsDark.textMuted : AppColorsLight.textMuted;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ProfileProvider>().loadVehicles(),
    );
  }

  void _openForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<ProfileProvider>(),
        child: AddVehicleScreen(isDark: _d),
      ),
    );
  }

  // ── Confirm remove ─────────────────────────────────────────
  void _confirmRemove(UserVehicleModel v) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Remove Vehicle?', style: AppTextStyles.headingSm(_d)),
        content: Text(
          'Remove ${v.variant.variantName} from your garage? '
          'You can always add it back later.',
          style: AppTextStyles.bodyMd(_d).copyWith(color: _txtSec),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelMd(_d).copyWith(color: _txtSec),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<ProfileProvider>().removeVehicle(v.id);
            },
            child: Text(
              'Remove',
              style: AppTextStyles.labelMd(
                _d,
              ).copyWith(color: AppColorsDark.error),
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ProfileProvider>();
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(prov),
      body: prov.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            )
          : prov.vehicles.isEmpty
          ? _emptyState()
          : _garageView(prov),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────
  AppBar _buildAppBar(ProfileProvider prov) => AppBar(
    backgroundColor: _bg,
    elevation: 0,
    scrolledUnderElevation: 0,
    leading: IconButton(
      icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _txtPri),
      onPressed: () => context.pop(),
    ),
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('My Garage', style: AppTextStyles.heading(_d)),
        Text(
          prov.vehicles.isEmpty
              ? 'No vehicles added'
              : '${prov.vehicles.length} vehicle${prov.vehicles.length == 1 ? '' : 's'} saved',
          style: AppTextStyles.labelXs(
            _d,
          ).copyWith(color: AppColors.primary, letterSpacing: 0.2),
        ),
      ],
    ),
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 12),
        child: GestureDetector(
          onTap: _openForm,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_rounded, size: 15, color: Colors.white),
                const SizedBox(width: 4),
                const Text('Add Vehicle', style: AppTextStyles.buttonSm),
              ],
            ),
          ),
        ),
      ),
    ],
  );

  // ── Vehicle garage list ────────────────────────────────────
  Widget _garageView(ProfileProvider prov) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Banner tip
        SliverToBoxAdapter(child: _GarageTipBanner(isDark: _d)),

        // ── Vehicle cards
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((_, i) {
              final vehicle = prov.vehicles[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _VehicleCard(
                  vehicle: vehicle,
                  isDark: _d,
                  onRemove: () => _confirmRemove(vehicle),
                  onFindParts: () => context.push(
                    AppRoutes.searchPath(query: vehicle.variant.variantName),
                  ),
                ),
              );
            }, childCount: prov.vehicles.length),
          ),
        ),

        // ── Add another CTA
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
          sliver: SliverToBoxAdapter(
            child: GestureDetector(
              onTap: _openForm,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: _bgCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _border, style: BorderStyle.solid),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Add Another Vehicle',
                      style: AppTextStyles.labelMd(
                        _d,
                      ).copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Empty state ────────────────────────────────────────────
  Widget _emptyState() => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: _bgCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _border),
            ),
            child: Center(
              child: Icon(
                Icons.directions_car_outlined,
                size: 48,
                color: _txtMut,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text('Your Garage is Empty', style: AppTextStyles.heading(_d)),
          const SizedBox(height: 10),
          Text(
            'Add your vehicles to get personalised '
            'part recommendations and compatibility checks.',
            style: AppTextStyles.bodyMd(
              _d,
            ).copyWith(color: _txtSec, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip('✅ Part Compatibility', _d),
              _Chip('🔔 Service Reminders', _d),
              _Chip('💡 Smart Suggestions', _d),
              _Chip('🔍 Quick Search', _d),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openForm,
              icon: const Icon(
                Icons.add_rounded,
                size: 18,
                color: Colors.white,
              ),
              label: const Text(
                'Add My First Vehicle',
                style: AppTextStyles.button,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════
// Vehicle Card  —  uses UserVehicleModel
// ═══════════════════════════════════════════════════════════════

class _VehicleCard extends StatelessWidget {
  final UserVehicleModel vehicle;
  final BrandModel? brand;
  final bool isDark;
  final VoidCallback onRemove, onFindParts;

  const _VehicleCard({
    required this.vehicle,
    required this.isDark,
    required this.onRemove,
    required this.onFindParts,
    this.brand,
  });

  Color get _bgCard => isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;

  Color get _border => isDark ? AppColorsDark.border : AppColorsLight.border;

  @override
  Widget build(BuildContext context) {
    final variant = vehicle.variant;
    final generation = variant.generation;
    final model = generation?.model;
    final brandName = model?.displayName ?? '—';

    return Container(
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            decoration: BoxDecoration(
              color: isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -16,
                  top: -16,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Car icon
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.directions_car_rounded,
                            size: 26,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("$brandName ${variant.generation!.name}",
                                style: const TextStyle(
                                  fontFamily: 'DMSans',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                variant.variantName,
                                style: const TextStyle(
                                  fontFamily: 'Syne',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Remove button
                        GestureDetector(
                          onTap: onRemove,
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 15,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Tags row
                    Row(
                      children: [
                        _HeaderTag(
                          '${variant.engineCC} cc',
                          Icons.engineering_outlined,
                        ),
                        const SizedBox(width: 8),
                        _HeaderTag(
                          variant.fuelType,
                          Icons.local_gas_station,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        _HeaderTag(
                          variant.transmission,
                          Icons.settings_outlined,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Details row ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Row(
              children: [
                Expanded(
                  child: _DetailCell(
                    label: 'Registration',
                    value: vehicle.registrationNumber ?? '—',
                    icon: Icons.pin_outlined,
                    isDark: isDark,
                  ),
                ),
                Container(width: 1, height: 32, color: _border),
                Expanded(
                  child: _DetailCell(
                    label: 'Emission',
                    value: variant.emissionStandard,
                    icon: Icons.eco_outlined,
                    isDark: isDark,
                  ),
                ),
                Container(width: 1, height: 32, color: _border),
                Expanded(
                  child: _DetailCell(
                    label: 'Trim',
                    value: variant.trimLevel,
                    icon: Icons.star_outline_rounded,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ),

          // ── Find Parts CTA ────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: GestureDetector(
              onTap: onFindParts,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Find Parts for this Vehicle',
                      style: AppTextStyles.labelMd(
                        isDark,
                      ).copyWith(color: AppColors.primary),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 11,
                      color: AppColors.primary,
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

// ─── Card sub-widgets ─────────────────────────────────────────

class _HeaderTag extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;

  const _HeaderTag(this.label, this.icon, {this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.white70;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: c),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w600,
              fontSize: 11,
              color: c,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailCell extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final bool isDark;
  final Color? valueColor;

  const _DetailCell({
    required this.label,
    required this.value,
    required this.icon,
    required this.isDark,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final txtPri = isDark
        ? AppColorsDark.textPrimary
        : AppColorsLight.textPrimary;
    final txtMut = isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Icon(icon, size: 14, color: txtMut),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.labelMd(
              isDark,
            ).copyWith(fontSize: 12, color: valueColor ?? txtPri),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.bodyXs(isDark).copyWith(color: txtMut),
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Garage Tip Banner
// ═══════════════════════════════════════════════════════════════

class _GarageTipBanner extends StatelessWidget {
  final bool isDark;

  const _GarageTipBanner({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final txtSec = isDark
        ? AppColorsDark.textSecondary
        : AppColorsLight.textSecondary;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.tips_and_updates_outlined,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Find compatible parts instantly by selecting your vehicle before searching.',
              style: AppTextStyles.bodyMd(
                isDark,
              ).copyWith(color: txtSec, height: 1.4, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Feature chip ─────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final bool isDark;

  const _Chip(this.label, this.isDark);

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;
    final bd = isDark ? AppColorsDark.border : AppColorsLight.border;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bd),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSm(isDark).copyWith(fontSize: 12),
      ),
    );
  }
}
