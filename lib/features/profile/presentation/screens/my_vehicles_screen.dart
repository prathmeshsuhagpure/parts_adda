import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_routes.dart';
import '../../domain/models/vehicle_model.dart';
import '../providers/profile_provider.dart';

// ─── Static catalogue data ────────────────────────────────────

const _kMakes = [
  'Maruti Suzuki',
  'Hyundai',
  'Tata',
  'Mahindra',
  'Honda',
  'Toyota',
  'Kia',
  'MG',
  'Skoda',
  'Volkswagen',
  'Ford',
  'Renault',
  'Nissan',
  'Jeep',
  'BMW',
  'Mercedes-Benz',
  'Audi',
  'Volvo',
  'Isuzu',
  'Force',
];

const _kModelsByMake = {
  'Maruti Suzuki': [
    'Swift',
    'Baleno',
    'Wagon R',
    'Dzire',
    'Vitara Brezza',
    'Ertiga',
    'Alto',
    'Celerio',
    'Ciaz',
    'S-Cross',
    'XL6',
    'Grand Vitara',
  ],
  'Hyundai': [
    'i20',
    'Creta',
    'Venue',
    'Verna',
    'Alcazar',
    'Tucson',
    'i10 Nios',
    'Aura',
    'Exter',
    'Ioniq 5',
  ],
  'Tata': [
    'Nexon',
    'Harrier',
    'Safari',
    'Punch',
    'Tiago',
    'Tigor',
    'Altroz',
    'Curvv',
    'Nexon EV',
    'Punch EV',
  ],
  'Mahindra': [
    'Scorpio-N',
    'Scorpio Classic',
    'XUV700',
    'XUV300',
    'XUV400',
    'Thar',
    'Bolero',
    'BE 6e',
    'XEV 9e',
  ],
  'Honda': ['City', 'Amaze', 'Elevate', 'WR-V', 'Jazz', 'HR-V', 'Accord'],
  'Toyota': [
    'Fortuner',
    'Innova Crysta',
    'Innova HyCross',
    'Glanza',
    'Urban Cruiser',
    'Camry',
    'Vellfire',
    'Hilux',
  ],
  'Kia': ['Seltos', 'Sonet', 'Carens', 'EV6', 'Carnival'],
  'MG': ['Hector', 'Astor', 'Gloster', 'ZS EV', 'Comet EV'],
  'Skoda': ['Slavia', 'Kushaq', 'Octavia', 'Superb', 'Kodiaq', 'Karoq'],
  'Volkswagen': ['Taigun', 'Virtus', 'Tiguan', 'Polo', 'Vento'],
  'Ford': ['EcoSport', 'Endeavour', 'Figo', 'Aspire', 'Freestyle'],
  'Renault': ['Kwid', 'Triber', 'Kiger', 'Duster'],
  'Nissan': ['Magnite', 'Kicks', 'X-Trail', 'Terrano'],
  'Jeep': ['Compass', 'Meridian', 'Wrangler', 'Grand Cherokee'],
  'BMW': ['3 Series', '5 Series', 'X1', 'X3', 'X5', 'X7', 'M3', 'M5'],
  'Mercedes-Benz': ['C-Class', 'E-Class', 'GLA', 'GLC', 'GLE', 'S-Class'],
  'Audi': ['A4', 'A6', 'Q3', 'Q5', 'Q7', 'Q8', 'e-tron'],
  'Volvo': ['XC40', 'XC60', 'XC90', 'S60', 'S90'],
  'Isuzu': ['D-Max', 'mu-X'],
  'Force': ['Gurkha', 'Trax'],
};

const _kFuelTypes = ['Petrol', 'Diesel', 'CNG', 'Electric', 'Hybrid', 'LPG'];

// Vehicle brand accent colours (for card gradient)
const _kBrandColors = {
  'Maruti Suzuki': Color(0xFF003DA5),
  'Hyundai': Color(0xFF002C5F),
  'Tata': Color(0xFF1D3E7C),
  'Mahindra': Color(0xFFCC0000),
  'Honda': Color(0xFFCC0000),
  'Toyota': Color(0xFFEB0A1E),
  'Kia': Color(0xFF05141F),
  'MG': Color(0xFFBF1722),
  'Skoda': Color(0xFF4BA82E),
  'Volkswagen': Color(0xFF001E50),
  'Ford': Color(0xFF003099),
  'Renault': Color(0xFFFFCD00),
  'Nissan': Color(0xFFC3002F),
  'Jeep': Color(0xFF2A3439),
  'BMW': Color(0xFF0066B2),
  'Mercedes-Benz': Color(0xFF00A19B),
  'Audi': Color(0xFFBB0A30),
  'Volvo': Color(0xFF003057),
  'Isuzu': Color(0xFFB8162A),
  'Force': Color(0xFF1A4F8A),
};

Color _brandColor(String make) => _kBrandColors[make] ?? AppColors.primary;

// Fuel type icons
IconData _fuelIcon(String? fuel) {
  switch (fuel?.toLowerCase()) {
    case 'electric':
      return Icons.electric_bolt_rounded;
    case 'hybrid':
      return Icons.eco_rounded;
    case 'cng':
      return Icons.gas_meter_outlined;
    case 'lpg':
      return Icons.local_fire_department_outlined;
    default:
      return Icons.local_gas_station_outlined;
  }
}

Color _fuelColor(String? fuel) {
  switch (fuel?.toLowerCase()) {
    case 'electric':
      return AppColorsDark.info;
    case 'hybrid':
      return AppColorsDark.success;
    case 'cng':
      return Color(0xFF22D3EE);
    default:
      return AppColorsDark.warning;
  }
}

// ═══════════════════════════════════════════════════════════════
// MyVehiclesScreen
// ═══════════════════════════════════════════════════════════════

class MyVehiclesScreen extends StatefulWidget {
  const MyVehiclesScreen({super.key});

  @override
  State<MyVehiclesScreen> createState() => _MyVehiclesScreenState();
}

class _MyVehiclesScreenState extends State<MyVehiclesScreen> {
  // ── Theme ──────────────────────────────────────────────────
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
        child: _AddVehicleSheet(isDark: _d),
      ),
    );
  }

  // ── Confirm remove ─────────────────────────────────────────
  void _confirmRemove(VehicleModel v) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Remove Vehicle?', style: AppTextStyles.headingSm(_d)),
        content: Text(
          'Remove ${v.displayName} from your garage? '
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
          ? Center(
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
            delegate: SliverChildBuilderDelegate(
              (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _VehicleCard(
                  vehicle: prov.vehicles[i],
                  isDark: _d,
                  onRemove: () => _confirmRemove(prov.vehicles[i]),
                  onFindParts: () => context.push(
                    AppRoutes.searchPath(query: prov.vehicles[i].displayName),
                  ),
                ),
              ),
              childCount: prov.vehicles.length,
            ),
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
          // Car icon
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
          // Feature chips
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
// Vehicle Card
// ═══════════════════════════════════════════════════════════════

class _VehicleCard extends StatelessWidget {
  final VehicleModel vehicle;
  final bool isDark;
  final VoidCallback onRemove, onFindParts;

  const _VehicleCard({
    required this.vehicle,
    required this.isDark,
    required this.onRemove,
    required this.onFindParts,
  });

  Color get _bgCard => isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;

  Color get _border => isDark ? AppColorsDark.border : AppColorsLight.border;

  @override
  Widget build(BuildContext context) {
    final brand = _brandColor(vehicle.make);
    final fuel = vehicle.fuelType;
    final fIcon = _fuelIcon(fuel);
    final fColor = _fuelColor(fuel);

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
          // ── Gradient header ───────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  brand.withValues(alpha: isDark ? 0.85 : 0.80),
                  brand.withValues(alpha: isDark ? 0.60 : 0.65),
                  Colors.black.withValues(alpha: 0.55),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
            ),
            child: Stack(
              children: [
                // Background circle decoration
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
                // Content
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
                              Text(
                                vehicle.make,
                                style: const TextStyle(
                                  fontFamily: 'DMSans',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                vehicle.model,
                                style: const TextStyle(
                                  fontFamily: 'Syne',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
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
                          '${vehicle.year}',
                          Icons.calendar_today_outlined,
                        ),
                        const SizedBox(width: 8),
                        if (fuel != null) ...[
                          _HeaderTag(fuel, fIcon, color: fColor),
                          const SizedBox(width: 8),
                        ],
                        if (vehicle.variant != null)
                          _HeaderTag(vehicle.variant!, Icons.tune_outlined),
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
                    label: 'Fuel Type',
                    value: fuel ?? '—',
                    icon: fIcon,
                    isDark: isDark,
                    valueColor: fuel != null ? fColor : null,
                  ),
                ),
                Container(width: 1, height: 32, color: _border),
                Expanded(
                  child: _DetailCell(
                    label: 'Year',
                    value: '${vehicle.year}',
                    icon: Icons.calendar_month_outlined,
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

// ═══════════════════════════════════════════════════════════════
// Add Vehicle Sheet
// ═══════════════════════════════════════════════════════════════

class _AddVehicleSheet extends StatefulWidget {
  final bool isDark;

  const _AddVehicleSheet({required this.isDark});

  @override
  State<_AddVehicleSheet> createState() => _AddVehicleSheetState();
}

class _AddVehicleSheetState extends State<_AddVehicleSheet> {
  final _formKey = GlobalKey<FormState>();
  final _regCtrl = TextEditingController();

  String? _make;
  String? _model;
  String? _fuelType;
  String? _variant;
  int _year = DateTime.now().year;

  bool get _d => widget.isDark;

  Color get _bgCard => _d ? AppColorsDark.bgCard : AppColorsLight.bgCard;

  Color get _bgInput => _d ? AppColorsDark.bgInput : AppColorsLight.bgInput;

  Color get _border => _d ? AppColorsDark.border : AppColorsLight.border;

  Color get _txtPri =>
      _d ? AppColorsDark.textPrimary : AppColorsLight.textPrimary;

  Color get _txtSec =>
      _d ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;

  Color get _txtMut => _d ? AppColorsDark.textMuted : AppColorsLight.textMuted;

  List<String> get _models =>
      (_make != null ? _kModelsByMake[_make] : null) ?? [];

  // Steps: 0=make, 1=model, 2=details
  int _step = 0;

  @override
  void dispose() {
    _regCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    if (_make == null || _model == null) return;

    final ok = await context.read<ProfileProvider>().addVehicle({
      'make': _make!,
      'model': _model!,
      'year': _year,
      'fuelType': _fuelType,
      'variant': _variant?.trim().isEmpty == true ? null : _variant?.trim(),
      'registrationNumber': _regCtrl.text.trim().isEmpty
          ? null
          : _regCtrl.text.trim().toUpperCase(),
    });
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: _bgCard,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: AppColorsDark.success,
                size: 17,
              ),
              const SizedBox(width: 10),
              Text(
                '$_make $_model added to your garage!',
                style: AppTextStyles.bodyMd(_d),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final saving = context.watch<ProfileProvider>().isSaving;

    return Container(
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.88,
        maxChildSize: 0.96,
        builder: (_, sc) => Column(
          children: [
            // ── Handle + title ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      if (_step > 0)
                        GestureDetector(
                          onTap: () => setState(() => _step--),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 16,
                              color: _txtSec,
                            ),
                          ),
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add Vehicle',
                              style: AppTextStyles.heading(_d),
                            ),
                            Text(
                              'Step ${_step + 1} of 3 — ${_stepLabel()}',
                              style: AppTextStyles.bodyXs(
                                _d,
                              ).copyWith(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                      if (saving)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Progress bar
                  _StepProgressBar(current: _step, total: 3, isDark: _d),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // ── Step content ────────────────────────────────
            Expanded(
              child: Form(
                key: _formKey,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  transitionBuilder: (child, anim) => SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0.15, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: anim,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: _step == 0
                      ? _step0Make(sc)
                      : _step == 1
                      ? _step1Model(sc)
                      : _step2Details(sc),
                ),
              ),
            ),

            // ── Bottom button ───────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: _border)),
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _canProceed() ? (saving ? null : _onNext) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.primary.withValues(
                        alpha: 0.3,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _step < 2 ? 'Next' : 'Add to Garage',
                                style: AppTextStyles.button,
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                _step < 2
                                    ? Icons.arrow_forward_rounded
                                    : Icons.garage_outlined,
                                size: 16,
                                color: Colors.white,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 0: Select Make ────────────────────────────────────
  Widget _step0Make(ScrollController sc) => ListView(
    key: const ValueKey(0),
    controller: sc,
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
    children: [
      Text('Select Make / Brand', style: AppTextStyles.headingSm(_d)),
      const SizedBox(height: 6),
      Text(
        'Choose your vehicle manufacturer',
        style: AppTextStyles.bodyMd(_d).copyWith(color: _txtSec),
      ),
      const SizedBox(height: 18),
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.1,
        children: _kMakes.map((m) {
          final sel = _make == m;
          final brand = _brandColor(m);
          return GestureDetector(
            onTap: () => setState(() {
              _make = m;
              _model = null; // reset model on make change
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                color: sel ? brand.withValues(alpha: 0.12) : _bgInput,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: sel ? brand.withValues(alpha: 0.55) : _border,
                  width: sel ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: sel
                          ? brand.withValues(alpha: 0.18)
                          : _border.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        m[0],
                        style: TextStyle(
                          fontFamily: 'Syne',
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: sel ? brand : _txtMut,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    m,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                      color: sel ? brand : _txtSec,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    ],
  );

  // ── Step 1: Select Model ───────────────────────────────────
  Widget _step1Model(ScrollController sc) {
    final models = _models;
    return ListView(
      key: const ValueKey(1),
      controller: sc,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        // Selected make banner
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 18),
          decoration: BoxDecoration(
            color: _brandColor(_make!).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _brandColor(_make!).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _brandColor(_make!).withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _make![0],
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: _brandColor(_make!),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Make',
                    style: AppTextStyles.bodyXs(_d).copyWith(color: _txtMut),
                  ),
                  Text(_make!, style: AppTextStyles.headingSm(_d)),
                ],
              ),
            ],
          ),
        ),

        Text('Select Model', style: AppTextStyles.headingSm(_d)),
        const SizedBox(height: 6),
        Text(
          '${models.length} models available for $_make',
          style: AppTextStyles.bodyMd(_d).copyWith(color: _txtSec),
        ),
        const SizedBox(height: 16),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: models.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final m = models[i];
            final sel = _model == m;
            return GestureDetector(
              onTap: () => setState(() => _model = m),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: sel
                      ? AppColors.primary.withValues(alpha: 0.08)
                      : _bgInput,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: sel
                        ? AppColors.primary.withValues(alpha: 0.45)
                        : _border,
                    width: sel ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        m,
                        style: AppTextStyles.labelMd(
                          _d,
                        ).copyWith(color: sel ? AppColors.primary : _txtPri),
                      ),
                    ),
                    if (sel)
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ── Step 2: Year, Fuel, Variant, Reg ──────────────────────
  Widget _step2Details(ScrollController sc) => ListView(
    key: const ValueKey(2),
    controller: sc,
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
    children: [
      // Summary chip
      Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: _brandColor(_make!).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _brandColor(_make!).withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.directions_car_rounded,
              size: 22,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$_make $_model', style: AppTextStyles.headingSm(_d)),
                Text(
                  'Fill in more details below',
                  style: AppTextStyles.bodyXs(_d).copyWith(color: _txtSec),
                ),
              ],
            ),
          ],
        ),
      ),

      // Year
      _fLabel('Manufacturing Year'),
      const SizedBox(height: 10),
      _YearScroller(
        selected: _year,
        isDark: _d,
        onChanged: (y) => setState(() => _year = y),
      ),
      const SizedBox(height: 20),

      // Fuel type
      _fLabel('Fuel Type'),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _kFuelTypes.map((f) {
          final sel = _fuelType == f;
          final fc = _fuelColor(f);
          return GestureDetector(
            onTap: () => setState(() => _fuelType = f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: sel ? fc.withValues(alpha: 0.12) : _bgInput,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: sel ? fc.withValues(alpha: 0.5) : _border,
                  width: sel ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_fuelIcon(f), size: 14, color: sel ? fc : _txtSec),
                  const SizedBox(width: 6),
                  Text(
                    f,
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: sel ? fc : _txtSec,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 20),

      // Variant (optional)
      _fLabel('Variant (Optional)'),
      const SizedBox(height: 7),
      TextFormField(
        onChanged: (v) => _variant = v,
        style: AppTextStyles.bodyMd(_d),
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          hintText: 'e.g. ZXI, VXI, Alpha, ZX+',
          hintStyle: AppTextStyles.bodyMd(_d).copyWith(color: _txtMut),
          filled: true,
          fillColor: _bgInput,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Icon(Icons.tune_outlined, size: 18, color: _txtMut),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
      const SizedBox(height: 16),

      // Registration number (optional)
      _fLabel('Registration Number (Optional)'),
      const SizedBox(height: 7),
      TextFormField(
        controller: _regCtrl,
        style: AppTextStyles.bodyMd(_d),
        textCapitalization: TextCapitalization.characters,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9 ]')),
          LengthLimitingTextInputFormatter(13),
        ],
        decoration: InputDecoration(
          hintText: 'e.g. MH 12 AB 1234',
          hintStyle: AppTextStyles.bodyMd(_d).copyWith(color: _txtMut),
          filled: true,
          fillColor: _bgInput,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Icon(Icons.pin_outlined, size: 18, color: _txtMut),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
      const SizedBox(height: 24),
    ],
  );

  // ── Helpers ────────────────────────────────────────────────
  Widget _fLabel(String t) => Text(
    t,
    style: AppTextStyles.labelSm(_d).copyWith(fontSize: 12, letterSpacing: 0.2),
  );

  bool _canProceed() {
    if (_step == 0) return _make != null;
    if (_step == 1) return _model != null;
    return true;
  }

  void _onNext() {
    if (_step < 2) {
      setState(() => _step++);
    } else {
      _save();
    }
  }

  String _stepLabel() {
    switch (_step) {
      case 0:
        return 'Select Make';
      case 1:
        return 'Select Model';
      default:
        return 'Vehicle Details';
    }
  }
}

// ─── Step progress bar ────────────────────────────────────────

class _StepProgressBar extends StatelessWidget {
  final int current, total;
  final bool isDark;

  const _StepProgressBar({
    required this.current,
    required this.total,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput;
    return Row(
      children: List.generate(total, (i) {
        final done = i <= current;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < total - 1 ? 6 : 0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 3,
              decoration: BoxDecoration(
                color: done ? AppColors.primary : bg,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ─── Year scroller ────────────────────────────────────────────

class _YearScroller extends StatefulWidget {
  final int selected;
  final bool isDark;
  final ValueChanged<int> onChanged;

  const _YearScroller({
    required this.selected,
    required this.isDark,
    required this.onChanged,
  });

  @override
  State<_YearScroller> createState() => _YearScrollerState();
}

class _YearScrollerState extends State<_YearScroller> {
  late final ScrollController _sc;
  static const _itemW = 60.0;
  static const _pad = 8.0;

  final int _startYear = 1990;
  late int _endYear;

  @override
  void initState() {
    super.initState();
    _endYear = DateTime.now().year;
    final years = List.generate(
      _endYear - _startYear + 1,
      (i) => _startYear + i,
    ).reversed.toList();
    final idx = years.indexOf(widget.selected);
    _sc = ScrollController(
      initialScrollOffset: idx > 0 ? idx * (_itemW + _pad) : 0,
    );
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final years = List.generate(
      _endYear - _startYear + 1,
      (i) => _startYear + i,
    ).reversed.toList();
    final bgInput = widget.isDark
        ? AppColorsDark.bgInput
        : AppColorsLight.bgInput;
    final border = widget.isDark ? AppColorsDark.border : AppColorsLight.border;
    final txtSec = widget.isDark
        ? AppColorsDark.textSecondary
        : AppColorsLight.textSecondary;

    return SizedBox(
      height: 48,
      child: ListView.builder(
        controller: _sc,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: years.length,
        itemBuilder: (_, i) {
          final y = years[i];
          final sel = y == widget.selected;
          return GestureDetector(
            onTap: () => widget.onChanged(y),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: _itemW,
              margin: EdgeInsets.only(right: _pad),
              decoration: BoxDecoration(
                color: sel ? AppColors.primary.withValues(alpha: 0.1) : bgInput,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: sel
                      ? AppColors.primary.withValues(alpha: 0.5)
                      : border,
                  width: sel ? 1.5 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  '$y',
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: sel ? AppColors.primary : txtSec,
                  ),
                ),
              ),
            ),
          );
        },
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
