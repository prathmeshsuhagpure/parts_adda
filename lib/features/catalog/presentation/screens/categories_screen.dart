/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_routes.dart';
import '../providers/catalog_provider.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CatalogProvider>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<CatalogProvider>();
    final categories = provider.categories;
    final error = provider.error;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColorsDark.bg : AppColorsLight.bg,
      appBar: AppBar(
        title: Text(
          'All Categories',
          style: AppTextStyles.headingSm(isDarkMode),
        ),
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
      ),
      body: error != null
          ? Center(child: Text('Error: $error'))
          : categories.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: categories.length,
              itemBuilder: (_, i) {
                final cat = categories[i];
                return GestureDetector(
                  onTap: () => context.push(
                    AppRoutes.categoryPath(cat.id, cat.name),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppColorsDark.bgCard
                          : AppColorsLight.bgCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDarkMode
                            ? AppColorsDark.border
                            : AppColorsLight.border,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          cat.icon ?? '📦', // fallback if icon is null
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cat.name,
                          style: AppTextStyles.bodySm(isDarkMode),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/router/app_routes.dart';

// ─── Full category catalogue (grouped by super-category) ─────

class _SubCat {
  final String id, name;
  final int partCount;

  const _SubCat({
    required this.id,
    required this.name,
    required this.partCount,
  });
}

class _Cat {
  final String id, name, emoji;
  final Color accent;
  final List<_SubCat> subs;
  final int partCount;

  const _Cat({
    required this.id,
    required this.name,
    required this.emoji,
    required this.accent,
    required this.subs,
    required this.partCount,
  });
}

const _kAllCategories = [
  _Cat(
    id: '1',
    name: 'Engine',
    emoji: '⚙️',
    accent: Color(0xFFE8290B),
    partCount: 2840,
    subs: [
      _SubCat(id: '1a', name: 'Pistons & Rings', partCount: 310),
      _SubCat(id: '1b', name: 'Gaskets & Seals', partCount: 480),
      _SubCat(id: '1c', name: 'Camshaft & Valves', partCount: 220),
      _SubCat(id: '1d', name: 'Crankshaft', partCount: 190),
      _SubCat(id: '1e', name: 'Timing Belt/Chain', partCount: 270),
      _SubCat(id: '1f', name: 'Engine Mounts', partCount: 140),
      _SubCat(id: '1g', name: 'Oil Pan & Sump', partCount: 115),
      _SubCat(id: '1h', name: 'Turbocharger', partCount: 185),
    ],
  ),
  _Cat(
    id: '2',
    name: 'Brakes',
    emoji: '🛑',
    accent: Color(0xFFEF4444),
    partCount: 1620,
    subs: [
      _SubCat(id: '2a', name: 'Brake Pads', partCount: 410),
      _SubCat(id: '2b', name: 'Brake Discs/Rotors', partCount: 340),
      _SubCat(id: '2c', name: 'Brake Shoes', partCount: 190),
      _SubCat(id: '2d', name: 'Brake Callipers', partCount: 120),
      _SubCat(id: '2e', name: 'Brake Lines & Hoses', partCount: 160),
      _SubCat(id: '2f', name: 'Master Cylinder', partCount: 85),
      _SubCat(id: '2g', name: 'Brake Fluid', partCount: 60),
      _SubCat(id: '2h', name: 'ABS Sensors', partCount: 255),
    ],
  ),
  _Cat(
    id: '3',
    name: 'Filters',
    emoji: '🔩',
    accent: Color(0xFF22C55E),
    partCount: 980,
    subs: [
      _SubCat(id: '3a', name: 'Oil Filters', partCount: 320),
      _SubCat(id: '3b', name: 'Air Filters', partCount: 260),
      _SubCat(id: '3c', name: 'Cabin Air Filters', partCount: 180),
      _SubCat(id: '3d', name: 'Fuel Filters', partCount: 145),
      _SubCat(id: '3e', name: 'Transmission Filters', partCount: 75),
    ],
  ),
  _Cat(
    id: '4',
    name: 'Electrical',
    emoji: '⚡',
    accent: Color(0xFFFFB800),
    partCount: 1750,
    subs: [
      _SubCat(id: '4a', name: 'Spark Plugs', partCount: 290),
      _SubCat(id: '4b', name: 'Alternators', partCount: 180),
      _SubCat(id: '4c', name: 'Starter Motors', partCount: 165),
      _SubCat(id: '4d', name: 'Sensors & Switches', partCount: 420),
      _SubCat(id: '4e', name: 'Relays & Fuses', partCount: 210),
      _SubCat(id: '4f', name: 'Ignition Coils', partCount: 145),
      _SubCat(id: '4g', name: 'ECU & Control Units', partCount: 95),
      _SubCat(id: '4h', name: 'Wiring Harness', partCount: 245),
    ],
  ),
  _Cat(
    id: '5',
    name: 'Suspension',
    emoji: '🔄',
    accent: Color(0xFF8B5CF6),
    partCount: 1290,
    subs: [
      _SubCat(id: '5a', name: 'Shock Absorbers', partCount: 340),
      _SubCat(id: '5b', name: 'Coil Springs', partCount: 210),
      _SubCat(id: '5c', name: 'Control Arms', partCount: 195),
      _SubCat(id: '5d', name: 'Ball Joints', partCount: 175),
      _SubCat(id: '5e', name: 'Tie Rods', partCount: 145),
      _SubCat(id: '5f', name: 'Stabiliser Bars', partCount: 115),
      _SubCat(id: '5g', name: 'Wheel Bearings', partCount: 110),
    ],
  ),
  _Cat(
    id: '6',
    name: 'Lighting',
    emoji: '💡',
    accent: Color(0xFF06B6D4),
    partCount: 870,
    subs: [
      _SubCat(id: '6a', name: 'Headlights', partCount: 240),
      _SubCat(id: '6b', name: 'Tail Lights', partCount: 185),
      _SubCat(id: '6c', name: 'Fog Lights', partCount: 130),
      _SubCat(id: '6d', name: 'Indicator Lights', partCount: 95),
      _SubCat(id: '6e', name: 'Bulbs & LEDs', partCount: 220),
    ],
  ),
  _Cat(
    id: '7',
    name: 'Cooling',
    emoji: '🌡️',
    accent: Color(0xFF3B82F6),
    partCount: 720,
    subs: [
      _SubCat(id: '7a', name: 'Radiators', partCount: 190),
      _SubCat(id: '7b', name: 'Water Pumps', partCount: 160),
      _SubCat(id: '7c', name: 'Thermostats', partCount: 115),
      _SubCat(id: '7d', name: 'Cooling Fans', partCount: 130),
      _SubCat(id: '7e', name: 'Coolant Hoses', partCount: 125),
    ],
  ),
  _Cat(
    id: '8',
    name: 'Transmission',
    emoji: '🔁',
    accent: Color(0xFFF97316),
    partCount: 1100,
    subs: [
      _SubCat(id: '8a', name: 'Clutch Kits', partCount: 280),
      _SubCat(id: '8b', name: 'Gearbox Parts', partCount: 195),
      _SubCat(id: '8c', name: 'Drive Shafts', partCount: 210),
      _SubCat(id: '8d', name: 'CV Joints', partCount: 175),
      _SubCat(id: '8e', name: 'Differential Parts', partCount: 140),
      _SubCat(id: '8f', name: 'Flywheel', partCount: 100),
    ],
  ),
  _Cat(
    id: '9',
    name: 'Fuel System',
    emoji: '⛽',
    accent: Color(0xFFEC4899),
    partCount: 640,
    subs: [
      _SubCat(id: '9a', name: 'Fuel Pumps', partCount: 180),
      _SubCat(id: '9b', name: 'Fuel Injectors', partCount: 195),
      _SubCat(id: '9c', name: 'Carburettors', partCount: 90),
      _SubCat(id: '9d', name: 'Throttle Bodies', partCount: 95),
      _SubCat(id: '9e', name: 'Fuel Tanks', partCount: 80),
    ],
  ),
  _Cat(
    id: '10',
    name: 'Exhaust',
    emoji: '💨',
    accent: Color(0xFF64748B),
    partCount: 530,
    subs: [
      _SubCat(id: '10a', name: 'Exhaust Pipes', partCount: 160),
      _SubCat(id: '10b', name: 'Catalytic Converters', partCount: 115),
      _SubCat(id: '10c', name: 'Mufflers/Silencers', partCount: 140),
      _SubCat(id: '10d', name: 'Exhaust Manifolds', partCount: 115),
    ],
  ),
  _Cat(
    id: '11',
    name: 'Body & Exterior',
    emoji: '🚗',
    accent: Color(0xFF14B8A6),
    partCount: 1960,
    subs: [
      _SubCat(id: '11a', name: 'Bumpers', partCount: 290),
      _SubCat(id: '11b', name: 'Bonnets/Hoods', partCount: 185),
      _SubCat(id: '11c', name: 'Doors & Panels', partCount: 310),
      _SubCat(id: '11d', name: 'Mirrors', partCount: 270),
      _SubCat(id: '11e', name: 'Wipers & Washers', partCount: 240),
      _SubCat(id: '11f', name: 'Grilles & Spoilers', partCount: 190),
      _SubCat(id: '11g', name: 'Mudguards & Flaps', partCount: 145),
      _SubCat(id: '11h', name: 'Windscreens', partCount: 130),
      _SubCat(id: '11i', name: 'Door Handles & Locks', partCount: 200),
    ],
  ),
  _Cat(
    id: '12',
    name: 'Batteries',
    emoji: '🔋',
    accent: Color(0xFF22C55E),
    partCount: 480,
    subs: [
      _SubCat(id: '12a', name: 'Car Batteries', partCount: 220),
      _SubCat(id: '12b', name: 'Battery Terminals', partCount: 95),
      _SubCat(id: '12c', name: 'Battery Chargers', partCount: 85),
      _SubCat(id: '12d', name: 'Jump Starters', partCount: 80),
    ],
  ),
  _Cat(
    id: '13',
    name: 'Tyres & Wheels',
    emoji: '⭕',
    accent: Color(0xFF6366F1),
    partCount: 890,
    subs: [
      _SubCat(id: '13a', name: 'Tyres', partCount: 320),
      _SubCat(id: '13b', name: 'Alloy Wheels', partCount: 215),
      _SubCat(id: '13c', name: 'Steel Wheels', partCount: 110),
      _SubCat(id: '13d', name: 'Wheel Caps', partCount: 130),
      _SubCat(id: '13e', name: 'Tyre Inflators', partCount: 115),
    ],
  ),
  _Cat(
    id: '14',
    name: 'AC & Heating',
    emoji: '❄️',
    accent: Color(0xFF06B6D4),
    partCount: 540,
    subs: [
      _SubCat(id: '14a', name: 'Compressors', partCount: 160),
      _SubCat(id: '14b', name: 'Condensers', partCount: 115),
      _SubCat(id: '14c', name: 'Evaporators', partCount: 90),
      _SubCat(id: '14d', name: 'Blower Motors', partCount: 95),
      _SubCat(id: '14e', name: 'AC Hoses', partCount: 80),
    ],
  ),
  _Cat(
    id: '15',
    name: 'Interior',
    emoji: '🪑',
    accent: Color(0xFFA78BFA),
    partCount: 1120,
    subs: [
      _SubCat(id: '15a', name: 'Seat Covers', partCount: 310),
      _SubCat(id: '15b', name: 'Floor Mats', partCount: 240),
      _SubCat(id: '15c', name: 'Dashboard Parts', partCount: 185),
      _SubCat(id: '15d', name: 'Steering Wheels', partCount: 130),
      _SubCat(id: '15e', name: 'Sun Visors', partCount: 95),
      _SubCat(id: '15f', name: 'Car Fresheners', partCount: 160),
    ],
  ),
  _Cat(
    id: '16',
    name: 'Tools & Accessories',
    emoji: '🧰',
    accent: Color(0xFFD97706),
    partCount: 760,
    subs: [
      _SubCat(id: '16a', name: 'Tool Kits', partCount: 195),
      _SubCat(id: '16b', name: 'Jack & Stands', partCount: 110),
      _SubCat(id: '16c', name: 'Lubricants & Oils', partCount: 210),
      _SubCat(id: '16d', name: 'Cleaning Products', partCount: 145),
      _SubCat(id: '16e', name: 'Dash Cams', partCount: 100),
    ],
  ),
];

// ═════════════════════════════════════════════════════════════
// AllCategoriesScreen
// ═════════════════════════════════════════════════════════════

class AllCategoriesScreen extends StatefulWidget {
  const AllCategoriesScreen({super.key});

  @override
  State<AllCategoriesScreen> createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen>
    with SingleTickerProviderStateMixin {
  // ── View mode ─────────────────────────────────────────────
  bool _isGridView = true;

  // ── Search ────────────────────────────────────────────────
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  // ── Expanded state for list view subcategory rows ─────────
  final Set<String> _expanded = {};

  // ── Tab controller for A–Z sorting / popular ─────────────
  late final TabController _tabCtrl;
  int _tabIndex = 0; // 0 = All, 1 = Popular, 2 = A-Z

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this)
      ..addListener(() {
        if (!_tabCtrl.indexIsChanging) {
          setState(() => _tabIndex = _tabCtrl.index);
        }
      });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _bg => _isDark ? AppColorsDark.bg : AppColorsLight.bg;

  Color get _bgCard => _isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;

  Color get _bgInput =>
      _isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput;

  Color get _border => _isDark ? AppColorsDark.border : AppColorsLight.border;

  Color get _textPri =>
      _isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary;

  Color get _textSec =>
      _isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;

  Color get _textMut =>
      _isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;

  List<_Cat> get _filtered {
    var list = List<_Cat>.from(_kAllCategories);
    // Apply search
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where(
            (c) =>
                c.name.toLowerCase().contains(q) ||
                c.subs.any((s) => s.name.toLowerCase().contains(q)),
          )
          .toList();
    }
    // Apply sort/tab
    switch (_tabIndex) {
      case 1: // Popular — by partCount desc
        list.sort((a, b) => b.partCount.compareTo(a.partCount));
        break;
      case 2: // A–Z
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    return list;
  }

  int get _totalParts => _kAllCategories.fold(0, (s, c) => s + c.partCount);

  void _onCategoryTap(_Cat cat) {
    context.push(AppRoutes.categoryPath(cat.id, cat.name));
  }

  void _onSubCategoryTap(_SubCat sub, _Cat parent) {
    context.push(AppRoutes.categoryPath(sub.id, sub.name));
  }

  void _onSearchTap() {
    context.push(AppRoutes.search);
  }

  @override
  Widget build(BuildContext context) {
    final cats = _filtered;

    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // ── Search bar ──────────────────────────────────────
          _buildSearchBar(),

          // ── Stats + toggle row ──────────────────────────────
          _buildStatsRow(cats.length),

          // ── Tab bar ─────────────────────────────────────────
          _buildTabBar(),

          // ── Body ────────────────────────────────────────────
          Expanded(
            child: cats.isEmpty
                ? _buildEmptyState()
                : _isGridView
                ? _buildGrid(cats)
                : _buildList(cats),
          ),
        ],
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────
  AppBar _buildAppBar() => AppBar(
    backgroundColor: _bg,
    elevation: 0,
    leading: GestureDetector(
      onTap: () => context.pop(),
      child: Icon(Icons.arrow_back_ios_new, size: 18, color: _textPri),
    ),
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Categories',
          style: TextStyle(
            fontFamily: 'Syne',
            fontWeight: FontWeight.w800,
            fontSize: 17,
            color: _textPri,
          ),
        ),
        Text(
          '${_formatCount(_totalParts)} parts available',
          style: TextStyle(
            fontFamily: 'DMSans',
            fontWeight: FontWeight.w400,
            fontSize: 11,
            color: AppColors.primary,
          ),
        ),
      ],
    ),
    actions: [
      // View toggle
      GestureDetector(
        onTap: () => setState(() => _isGridView = !_isGridView),
        child: Container(
          margin: const EdgeInsets.only(right: 14),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _bgCard,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: _border),
          ),
          child: Icon(
            _isGridView ? Icons.view_list_outlined : Icons.grid_view_outlined,
            size: 18,
            color: _textSec,
          ),
        ),
      ),
    ],
  );

  // ── Search bar ────────────────────────────────────────────
  Widget _buildSearchBar() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
    child: GestureDetector(
      // Tapping the input either filters locally or pushes search
      onTap: _searchQuery.isEmpty ? _onSearchTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: _bgInput,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(Icons.search, size: 18, color: _textMut),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 13,
                  color: _textPri,
                ),
                decoration: InputDecoration(
                  hintText: 'Search categories…',
                  hintStyle: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 13,
                    color: _textMut,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchCtrl.clear();
                  setState(() => _searchQuery = '');
                },
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(Icons.close, size: 16, color: _textMut),
                ),
              )
            else
              const SizedBox(width: 12),
          ],
        ),
      ),
    ),
  );

  // ── Stats row ─────────────────────────────────────────────
  Widget _buildStatsRow(int catCount) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
    child: Row(
      children: [
        _StatPill(
          label: '$catCount Categories',
          icon: Icons.category_outlined,
          isDark: _isDark,
        ),
        const SizedBox(width: 8),
        _StatPill(
          label: '${_formatCount(_totalParts)} Parts',
          icon: Icons.settings_outlined,
          isDark: _isDark,
          accent: true,
        ),
      ],
    ),
  );

  // ── Tab bar ───────────────────────────────────────────────
  Widget _buildTabBar() => Container(
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: _border)),
    ),
    child: TabBar(
      controller: _tabCtrl,
      labelStyle: const TextStyle(
        fontFamily: 'Syne',
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: 'DMSans',
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      labelColor: AppColors.primary,
      unselectedLabelColor: _textSec,
      indicatorColor: AppColors.primary,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.transparent,
      tabs: const [
        Tab(text: 'All'),
        Tab(text: '🔥 Popular'),
        Tab(text: 'A – Z'),
      ],
    ),
  );

  // ═══════════════════════════════════════════════════════════
  // Grid View
  // ═══════════════════════════════════════════════════════════

  Widget _buildGrid(List<_Cat> cats) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: cats.length,
      itemBuilder: (_, i) => _CategoryGridCard(
        cat: cats[i],
        isDark: _isDark,
        bgCard: _bgCard,
        border: _border,
        textSec: _textSec,
        textMut: _textMut,
        onTap: () => _onCategoryTap(cats[i]),
        onSubTap: (s) => _onSubCategoryTap(s, cats[i]),
        searchQuery: _searchQuery,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // List View (expandable)
  // ═══════════════════════════════════════════════════════════

  Widget _buildList(List<_Cat> cats) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      physics: const BouncingScrollPhysics(),
      itemCount: cats.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final cat = cats[i];
        final isExpanded = _expanded.contains(cat.id);
        return _CategoryListCard(
          cat: cat,
          isDark: _isDark,
          bgCard: _bgCard,
          border: _border,
          textSec: _textSec,
          textMut: _textMut,
          isExpanded: isExpanded,
          searchQuery: _searchQuery,
          onTap: () => _onCategoryTap(cat),
          onToggle: () => setState(
            () => isExpanded ? _expanded.remove(cat.id) : _expanded.add(cat.id),
          ),
          onSubTap: (s) => _onSubCategoryTap(s, cat),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Empty state
  // ═══════════════════════════════════════════════════════════

  Widget _buildEmptyState() => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _bgCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _border),
            ),
            child: Center(
              child: Icon(Icons.search_off_outlined, size: 38, color: _textMut),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'No categories found',
            style: TextStyle(
              fontFamily: 'Syne',
              fontWeight: FontWeight.w700,
              fontSize: 17,
              color: _textPri,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term.',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 13,
              color: _textSec,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              _searchCtrl.clear();
              setState(() => _searchQuery = '');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
              ),
              child: Text(
                'Clear Search',
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  String _formatCount(int v) => v >= 1000
      ? '${(v / 1000).toStringAsFixed(v % 1000 == 0 ? 0 : 1)}K'
      : '$v';
}

// ═════════════════════════════════════════════════════════════
// Category Grid Card
// ═════════════════════════════════════════════════════════════

class _CategoryGridCard extends StatelessWidget {
  final _Cat cat;
  final bool isDark;
  final Color bgCard, border, textSec, textMut;
  final VoidCallback onTap;
  final ValueChanged<_SubCat> onSubTap;
  final String searchQuery;

  const _CategoryGridCard({
    required this.cat,
    required this.isDark,
    required this.bgCard,
    required this.border,
    required this.textSec,
    required this.textMut,
    required this.onTap,
    required this.onSubTap,
    required this.searchQuery,
  });

  // Show top 3 subcategories matching query (or just top 3)
  List<_SubCat> get _visibleSubs {
    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase();
      final matched = cat.subs
          .where((s) => s.name.toLowerCase().contains(q))
          .take(3)
          .toList();
      if (matched.isNotEmpty) return matched;
    }
    return cat.subs.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
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
            // ── Coloured header ──────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cat.accent.withValues(alpha: isDark ? 0.18 : 0.10),
                    cat.accent.withValues(alpha: isDark ? 0.06 : 0.03),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(11),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cat.emoji, style: const TextStyle(fontSize: 28)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: cat.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _fmtCount(cat.partCount),
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w800,
                        fontSize: 9,
                        color: cat.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Name ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              child: Text(
                cat.name,
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: isDark
                      ? AppColorsDark.textPrimary
                      : AppColorsLight.textPrimary,
                ),
              ),
            ),

            // ── Subcategory pills ─────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ..._visibleSubs.map(
                      (s) => GestureDetector(
                        onTap: () {
                          onSubTap(s);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Row(
                            children: [
                              Container(
                                width: 3,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: cat.accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  s.name,
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 11,
                                    color: textSec,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (cat.subs.length > 3) ...[
                      const SizedBox(height: 2),
                      Text(
                        '+${cat.subs.length - 3} more',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                          color: cat.accent,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ── Browse button ─────────────────────────────────
            Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: cat.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: cat.accent.withValues(alpha: 0.25)),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Browse',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: cat.accent,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, size: 9, color: cat.accent),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtCount(int v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}K parts' : '$v parts';
}

// ═════════════════════════════════════════════════════════════
// Category List Card (expandable)
// ═════════════════════════════════════════════════════════════

class _CategoryListCard extends StatelessWidget {
  final _Cat cat;
  final bool isDark, isExpanded;
  final Color bgCard, border, textSec, textMut;
  final String searchQuery;
  final VoidCallback onTap, onToggle;
  final ValueChanged<_SubCat> onSubTap;

  const _CategoryListCard({
    required this.cat,
    required this.isDark,
    required this.isExpanded,
    required this.bgCard,
    required this.border,
    required this.textSec,
    required this.textMut,
    required this.searchQuery,
    required this.onTap,
    required this.onToggle,
    required this.onSubTap,
  });

  List<_SubCat> get _matchedSubs {
    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase();
      return cat.subs.where((s) => s.name.toLowerCase().contains(q)).toList();
    }
    return cat.subs;
  }

  @override
  Widget build(BuildContext context) {
    final textPri = isDark
        ? AppColorsDark.textPrimary
        : AppColorsLight.textPrimary;
    final bgInput = isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput;
    final subs = _matchedSubs;
    final hasSearchedSubs = searchQuery.trim().isNotEmpty && subs.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(
          color: isExpanded ? cat.accent.withValues(alpha: 0.35) : border,
          width: isExpanded ? 1.5 : 1,
        ),
        boxShadow: isExpanded
            ? [
                BoxShadow(
                  color: cat.accent.withValues(alpha: 0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          // ── Header row ────────────────────────────────────
          InkWell(
            onTap: onToggle,
            borderRadius: AppRadius.cardRadius,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
              child: Row(
                children: [
                  // Coloured icon container
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          cat.accent.withValues(alpha: isDark ? 0.22 : 0.12),
                          cat.accent.withValues(alpha: isDark ? 0.08 : 0.04),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cat.accent.withValues(alpha: 0.2)),
                    ),
                    child: Center(
                      child: Text(
                        cat.emoji,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name + count
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat.name,
                          style: TextStyle(
                            fontFamily: 'Syne',
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: textPri,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${cat.subs.length} sub-categories  ·  ${_fmtCount(cat.partCount)}',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 11,
                            color: textSec,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Browse directly + chevron
                  GestureDetector(
                    onTap: onTap,
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: cat.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: cat.accent.withValues(alpha: 0.25)),
                      ),
                      child: Text(
                        'All',
                        style: TextStyle(
                          fontFamily: 'Syne',
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          color: cat.accent,
                        ),
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: isExpanded ? cat.accent : textSec,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded subcategories ────────────────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            child: isExpanded || hasSearchedSubs
                ? Container(
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: border)),
                    ),
                    child: Column(
                      children: [
                        // Top part-count bar
                        Container(
                          margin: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: cat.accent.withValues(alpha: isDark ? 0.08 : 0.04),
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(
                              color: cat.accent.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 13,
                                color: cat.accent,
                              ),
                              const SizedBox(width: 7),
                              Text(
                                '${_fmtCount(cat.partCount)} parts across ${subs.length} sub-categories',
                                style: TextStyle(
                                  fontFamily: 'DMSans',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                  color: cat.accent,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Sub-category grid
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                          child: GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 3.6,
                            children: subs
                                .map(
                                  (s) => GestureDetector(
                                    onTap: () => onSubTap(s),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: bgInput,
                                        borderRadius: BorderRadius.circular(9),
                                        border: Border.all(color: border),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 4,
                                            height: 4,
                                            decoration: BoxDecoration(
                                              color: cat.accent,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              s.name,
                                              style: TextStyle(
                                                fontFamily: 'DMSans',
                                                fontSize: 11,
                                                color: textSec,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  String _fmtCount(int v) => v >= 1000
      ? '${(v / 1000).toStringAsFixed(v % 1000 == 0 ? 0 : 1)}K'
      : '$v';
}

// ═════════════════════════════════════════════════════════════
// Stat Pill
// ═════════════════════════════════════════════════════════════

class _StatPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDark, accent;

  const _StatPill({
    required this.label,
    required this.icon,
    required this.isDark,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgCard = isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;
    final textSec = isDark
        ? AppColorsDark.textSecondary
        : AppColorsLight.textSecondary;
    final color = accent ? AppColors.primary : textSec;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: accent ? AppColors.primary.withValues(alpha: 0.08) : bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accent ? AppColors.primary.withValues(alpha: 0.3) : border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.w600,
              fontSize: 11,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
