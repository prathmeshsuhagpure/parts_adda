import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../category/presentation/providers/catalog_provider.dart';

class _Banner {
  final String title, subtitle, cta, color1, color2, emoji;

  const _Banner({
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.color1,
    required this.color2,
    required this.emoji,
  });
}

class _Deal {
  final String id, name, brand, price, mrp, discount, make, emoji;

  const _Deal({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.mrp,
    required this.discount,
    required this.make,
    required this.emoji,
  });
}

const _banners = [
  _Banner(
    title: 'Monsoon Ready?',
    subtitle: 'Wipers, brakes & lights — up to 30% off',
    cta: 'Shop Now',
    color1: '1A237E',
    color2: '3949AB',
    emoji: '🌧️',
  ),
  _Banner(
    title: 'OEM Originals',
    subtitle: 'Genuine parts. Zero compromise on quality.',
    cta: 'Explore',
    color1: 'B71C1C',
    color2: 'E53935',
    emoji: '⚙️',
  ),
  _Banner(
    title: 'B2B Trade Deals',
    subtitle: 'Bulk pricing for workshops & dealers',
    cta: 'Apply Now',
    color1: '1B5E20',
    color2: '388E3C',
    emoji: '🏭',
  ),
];

const _deals = [
  _Deal(
    id: '1',
    name: 'Bosch Wiper 18"',
    brand: 'Bosch',
    price: '₹349',
    mrp: '₹499',
    discount: '30%',
    make: 'Maruti',
    emoji: '🔧',
  ),
  _Deal(
    id: '2',
    name: 'Mahle Air Filter',
    brand: 'Mahle',
    price: '₹285',
    mrp: '₹380',
    discount: '25%',
    make: 'Hyundai',
    emoji: '🔩',
  ),
  _Deal(
    id: '3',
    name: 'Exide 45Ah Battery',
    brand: 'Exide',
    price: '₹3,499',
    mrp: '₹4,200',
    discount: '17%',
    make: 'Honda',
    emoji: '⚡',
  ),
  _Deal(
    id: '4',
    name: 'Minda Horn Kit',
    brand: 'Minda',
    price: '₹449',
    mrp: '₹600',
    discount: '25%',
    make: 'Tata',
    emoji: '📯',
  ),
];

final _brands = [
  ('Bosch', AppColors.primary),
  ('Exide', AppColorsDark.info),
  ('Mahle', AppColorsDark.success),
  ('Minda', AppColorsDark.warning),
  ('Monroe', const Color(0xFF9333EA)),
  ('Lumax', AppColors.primary),
];

const _makes = [
  'Maruti',
  'Hyundai',
  'Honda',
  'Tata',
  'Toyota',
  'Kia',
  'MG',
  'Ford',
];
const _modelMap = <String, List<String>>{
  'Maruti': ['Swift', 'Baleno', 'Vitara', 'Alto', 'Wagon R'],
  'Hyundai': ['i20', 'Creta', 'Verna', 'Venue', 'Tucson'],
  'Honda': ['City', 'Amaze', 'Jazz', 'WR-V', 'CR-V'],
  'Tata': ['Nexon', 'Punch', 'Tiago', 'Harrier', 'Safari'],
  'Toyota': ['Innova', 'Fortuner', 'Urban Cruiser', 'Camry'],
  'Kia': ['Seltos', 'Sonet', 'Carnival', 'Carens'],
  'MG': ['Hector', 'Astor', 'ZS EV', 'Gloster'],
  'Ford': ['Figo', 'EcoSport', 'Endeavour'],
};

// ─── Home Screen ──────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bannerIdx = 0;
  late final PageController _bannerCtrl;
  Timer? _timer;

  // Vehicle finder
  String? _make, _model, _year;
  bool _finderOpen = false;

  // Recent searches (in-memory demo)
  final _recent = <String>[];

  @override
  void initState() {
    super.initState();
    _bannerCtrl = PageController();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_bannerCtrl.hasClients) {
        final next = (_bannerIdx + 1) % _banners.length;
        _bannerCtrl.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
    Future.microtask(() {
      if (!mounted) return;
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bannerCtrl.dispose();
    super.dispose();
  }

  void _doSearch(String q) {
    if (q.trim().isNotEmpty && !_recent.contains(q)) {
      setState(() => _recent.insert(0, q));
    }
    context.push(AppRoutes.searchPath(query: q));
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? AppColorsDark.bg : AppColorsLight.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App bar ─────────────────────────────────────
          SliverAppBar(
            backgroundColor: isDarkMode ? AppColorsDark.bg : AppColorsLight.bg,
            elevation: 0,
            floating: true,
            snap: true,
            titleSpacing: 16,
            title: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Center(
                    child: Text(
                      'PA',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text("Parts Adda", style: AppTextStyles.displaySm(isDarkMode)),
              ],
            ),
            actions: [
              GestureDetector(
                onTap: () => context.push(AppRoutes.notifications),
                child: Container(
                  margin: const EdgeInsets.only(right: 14),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppColorsDark.bgCard
                        : AppColorsLight.bgCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDarkMode
                          ? AppColorsDark.border
                          : AppColorsLight.border,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Icon(
                        Icons.notifications_outlined,
                        color: isDarkMode
                            ? AppColorsDark.textPrimary
                            : AppColorsLight.textPrimary,
                        size: 20,
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(58),
              child: _SearchBar(onSearch: _doSearch),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // ── Vehicle Finder ────────────────────────
                _VehicleFinder(
                  make: _make,
                  model: _model,
                  year: _year,
                  isOpen: _finderOpen,
                  onToggle: () => setState(() => _finderOpen = !_finderOpen),
                  onMake: (v) => setState(() {
                    _make = v;
                    _model = null;
                    _year = null;
                  }),
                  onModel: (v) => setState(() {
                    _model = v;
                    _year = null;
                  }),
                  onYear: (v) => setState(() => _year = v),
                  onSearch: () {
                    if (_make == null) return;
                    _doSearch(
                      [_make, _model, _year].whereType<String>().join(' '),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // ── Banners ───────────────────────────────
                _Banners(
                  ctrl: _bannerCtrl,
                  idx: _bannerIdx,
                  onChange: (i) => setState(() => _bannerIdx = i),
                ),
                const SizedBox(height: 24),

                // ── Categories ────────────────────────────
                _SectionHeader(
                  title: 'Shop by Category',
                  onSeeAll: () {
                    LoaderService().show(context);

                    Future.delayed(const Duration(seconds: 2), () {
                      LoaderService().hide();
                      context.push(AppRoutes.allCategories);
                    });
                  },
                ),
                const SizedBox(height: 12),
                _CategoryRow(onTap: _doSearch),
                const SizedBox(height: 24),

                // ── Today's Deals ─────────────────────────
                _SectionHeader(
                  title: "Today's Deals 🔥",
                  onSeeAll: () => _doSearch('deals'),
                ),
                const SizedBox(height: 12),
                _DealsRow(
                  onTap: (id) => context.push(AppRoutes.partDetailPath(id)),
                ),
                const SizedBox(height: 24),

                // ── Top Brands ────────────────────────────
                _SectionHeader(title: 'Top Brands'),
                const SizedBox(height: 12),
                _BrandsRow(onTap: _doSearch),
                const SizedBox(height: 24),

                // ── Trust badges ──────────────────────────
                _TrustSection(),
                const SizedBox(height: 24),

                // ── Recent Searches ───────────────────────
                if (_recent.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Recent Searches',
                    trailing: GestureDetector(
                      onTap: () => setState(() => _recent.clear()),
                      child: Text(
                        'Clear all',
                        style: AppTextStyles.bodySm(isDarkMode).copyWith(
                          color: isDarkMode
                              ? AppColorsDark.error
                              : AppColorsLight.error,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _RecentSearchChips(
                    items: _recent,
                    onTap: _doSearch,
                    onRemove: (q) => setState(() => _recent.remove(q)),
                  ),
                ],
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Search Bar ───────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onSearch;

  const _SearchBar({required this.onSearch});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: GestureDetector(
        onTap: () => context.push(AppRoutes.search),
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: isDarkMode ? AppColorsDark.bgInput : AppColorsLight.bgInput,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? AppColorsDark.border : AppColorsLight.border,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Icon(
                Icons.search,
                color: isDarkMode
                    ? AppColorsDark.textMuted
                    : AppColorsLight.textMuted,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Part name, OEM number, brand…',
                  style: AppTextStyles.bodyMd(isDarkMode).copyWith(
                    color: isDarkMode
                        ? AppColorsDark.textMuted
                        : AppColorsLight.textMuted,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.qr_code_scanner,
                      color: AppColors.primary,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Scan',
                      style: AppTextStyles.labelXs(
                        isDarkMode,
                      ).copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Vehicle Finder ───────────────────────────────────────────

class _VehicleFinder extends StatelessWidget {
  final String? make, model, year;
  final bool isOpen;
  final VoidCallback onToggle, onSearch;
  final ValueChanged<String?> onMake, onModel, onYear;

  const _VehicleFinder({
    required this.make,
    required this.model,
    required this.year,
    required this.isOpen,
    required this.onToggle,
    required this.onSearch,
    required this.onMake,
    required this.onModel,
    required this.onYear,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final years = List.generate(28, (i) => '${DateTime.now().year - i}');
    final models = make != null ? (_modelMap[make] ?? <String>[]) : <String>[];

    return Padding(
      padding: AppSpacing.screenPadding,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColorsDark.bgCard : AppColorsLight.bgCard,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(
            color: isOpen
                ? AppColors.primary.withValues(alpha: 0.5)
                : (isDarkMode ? AppColorsDark.border : AppColorsLight.border),
          ),
        ),
        child: Column(
          children: [
            // Header
            InkWell(
              onTap: onToggle,
              borderRadius: AppRadius.cardRadius,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.directions_car,
                        color: AppColors.primary,
                        size: 17,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Find Parts for My Car',
                            style: AppTextStyles.labelMd(isDarkMode),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            make != null
                                ? [
                                    make,
                                    model,
                                    year,
                                  ].whereType<String>().join(' · ')
                                : 'Select make · model · year',
                            style: AppTextStyles.bodySm(isDarkMode),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isOpen ? Icons.expand_less : Icons.expand_more,
                      color: isDarkMode
                          ? AppColorsDark.textMuted
                          : AppColorsLight.textMuted,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),

            // Dropdown panel
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 220),
              crossFadeState: isOpen
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Column(
                  children: [
                    Divider(
                      height: 1,
                      color: isDarkMode
                          ? AppColorsDark.border
                          : AppColorsLight.border,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _DropField(
                            label: 'Make',
                            value: make,
                            items: _makes,
                            onChanged: onMake,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _DropField(
                            label: 'Model',
                            value: model,
                            items: models,
                            onChanged: make != null ? onModel : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _DropField(
                            label: 'Year',
                            value: year,
                            items: years,
                            onChanged: model != null ? onYear : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: make != null ? onSearch : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: isDarkMode
                              ? AppColorsDark.bgInput
                              : AppColorsLight.bgInput,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.search, size: 16, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              'Find My Parts',
                              style: AppTextStyles.buttonSm,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              secondChild: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DropField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?>? onChanged;

  const _DropField({
    required this.label,
    required this.value,
    required this.items,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final active = value != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: active
            ? AppColors.primary.withValues(alpha: 0.06)
            : (isDarkMode ? AppColorsDark.bgInput : AppColorsLight.bgInput),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active
              ? AppColors.primary.withValues(alpha: 0.35)
              : (isDarkMode ? AppColorsDark.border : AppColorsLight.border),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            label,
            style: AppTextStyles.bodyXs(isDarkMode).copyWith(
              color: isDarkMode
                  ? AppColorsDark.textMuted
                  : AppColorsLight.textMuted,
            ),
          ),
          isExpanded: true,
          dropdownColor: isDarkMode
              ? AppColorsDark.bgCard
              : AppColorsLight.bgCard,
          style: AppTextStyles.bodySm(isDarkMode).copyWith(
            color: isDarkMode
                ? AppColorsDark.textPrimary
                : AppColorsLight.textPrimary,
          ),
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 14,
            color: isDarkMode
                ? AppColorsDark.textMuted
                : AppColorsLight.textMuted,
          ),
          onChanged: onChanged,
          items: items
              .map(
                (s) => DropdownMenuItem(
                  value: s,
                  child: Text(
                    s,
                    style: AppTextStyles.bodySm(isDarkMode),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

// ─── Banners ──────────────────────────────────────────────────

class _Banners extends StatelessWidget {
  final PageController ctrl;
  final int idx;
  final ValueChanged<int> onChange;

  const _Banners({
    required this.ctrl,
    required this.idx,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: ctrl,
            onPageChanged: onChange,
            itemCount: _banners.length,
            itemBuilder: (_, i) => _BannerCard(b: _banners[i]),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: idx == i ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: idx == i
                    ? AppColors.primary
                    : (isDarkMode
                          ? AppColorsDark.textMuted
                          : AppColorsLight.textMuted),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  final _Banner b;

  const _BannerCard({required this.b});

  @override
  Widget build(BuildContext context) {
    final c1 = Color(int.parse('FF${b.color1}', radix: 16));
    final c2 = Color(int.parse('FF${b.color2}', radix: 16));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [c1, c2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppRadius.cardRadius,
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    b.title,
                    style: const TextStyle(
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w800,
                      fontSize: 19,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    b.subtitle,
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white38),
                    ),
                    child: Text(
                      b.cta,
                      style: const TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(b.emoji, style: const TextStyle(fontSize: 62)),
          ],
        ),
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  final Widget? trailing;

  const _SectionHeader({required this.title, this.onSeeAll, this.trailing});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: AppTextStyles.heading(isDarkMode)),
          ),
          if (trailing != null)
            trailing!
          else if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Row(
                children: [
                  Text(
                    'See all',
                    style: AppTextStyles.bodySm(
                      isDarkMode,
                    ).copyWith(color: AppColors.primary),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.primary,
                    size: 15,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Category Row ─────────────────────────────────────────────

class _CategoryRow extends StatelessWidget {
  final ValueChanged<String> onTap;

  const _CategoryRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<CategoryProvider>();

    if (provider.isCategoryLoading) {
      return const SizedBox(
        height: 94,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final categories = provider.categories;

    return SizedBox(
      height: 94,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final cat = categories[i];
          return GestureDetector(
            onTap: () =>
                context.push(AppRoutes.subCategoryPath(cat.id, cat.name)),
            child: Column(
              children: [
                Container(
                  width: 62,
                  height: 62,
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
                  child: Center(
                    child: Text(
                      cat.icon ?? '📦',
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  cat.name,
                  style: AppTextStyles.bodySm(isDarkMode),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Deals Row ────────────────────────────────────────────────

class _DealsRow extends StatelessWidget {
  final ValueChanged<String> onTap;

  const _DealsRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 218,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _deals.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _DealCard(deal: _deals[i], onTap: onTap),
      ),
    );
  }
}

class _DealCard extends StatelessWidget {
  final _Deal deal;
  final ValueChanged<String> onTap;

  const _DealCard({required this.deal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => onTap(deal.id),
      child: Container(
        width: 155,
        decoration: BoxDecoration(
          color: isDarkMode ? AppColorsDark.bgCard : AppColorsLight.bgCard,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(
            color: isDarkMode ? AppColorsDark.border : AppColorsLight.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image / icon placeholder
            Stack(
              children: [
                Container(
                  height: 108,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppColorsDark.bgInput
                        : AppColorsLight.bgInput,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      deal.emoji,
                      style: const TextStyle(fontSize: 44),
                    ),
                  ),
                ),
                // Discount badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppColorsDark.success
                          : AppColorsLight.success,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '-${deal.discount}',
                      style: const TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Car compat
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      deal.make,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.white70,
                        fontFamily: 'DMSans',
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deal.brand.toUpperCase(),
                    style: AppTextStyles.labelXs(isDarkMode).copyWith(
                      color: isDarkMode
                          ? AppColorsDark.textMuted
                          : AppColorsLight.textMuted,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    deal.name,
                    style: AppTextStyles.labelSm(isDarkMode),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(deal.price, style: AppTextStyles.priceSm()),
                      const SizedBox(width: 4),
                      Text(
                        deal.mrp,
                        style: AppTextStyles.strikethrough(
                          isDarkMode,
                        ).copyWith(fontSize: 10),
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

// ─── Brands Row ───────────────────────────────────────────────

class _BrandsRow extends StatelessWidget {
  final ValueChanged<String> onTap;

  const _BrandsRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _brands.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final (name, color) = _brands[i];
          return GestureDetector(
            onTap: () => onTap(name),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColorsDark.bgCard
                    : AppColorsLight.bgCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDarkMode
                      ? AppColorsDark.border
                      : AppColorsLight.border,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(name, style: AppTextStyles.labelMd(isDarkMode)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Trust Section ────────────────────────────────────────────

class _TrustSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    const items = [
      (Icons.verified_outlined, 'Genuine Parts', 'OEM & certified aftermarket'),
      (
        Icons.local_shipping_outlined,
        'Fast Delivery',
        'Same-day in 15+ cities',
      ),
      (Icons.currency_rupee, 'Best Price', 'Price-match guarantee'),
      (Icons.replay_outlined, 'Easy Returns', '7-day hassle-free policy'),
    ];

    return Padding(
      padding: AppSpacing.screenPadding,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColorsDark.bgCard : AppColorsLight.bgCard,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(
            color: isDarkMode ? AppColorsDark.border : AppColorsLight.border,
          ),
        ),
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 3.4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: items
              .map(
                (item) => Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(item.$1, color: AppColors.primary, size: 15),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item.$2,
                            style: AppTextStyles.labelSm(isDarkMode).copyWith(
                              fontSize: 11,
                              color: isDarkMode
                                  ? AppColorsDark.textPrimary
                                  : AppColorsLight.textPrimary,
                            ),
                          ),
                          Text(
                            item.$3,
                            style: AppTextStyles.bodyXs(isDarkMode),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

// ─── Recent Searches ─────────────────────────────────────────

class _RecentSearchChips extends StatelessWidget {
  final List<String> items;
  final ValueChanged<String> onTap;
  final ValueChanged<String> onRemove;

  const _RecentSearchChips({
    required this.items,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items
            .map(
              (q) => GestureDetector(
                onTap: () => onTap(q),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppColorsDark.bgCard
                        : AppColorsLight.bgCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDarkMode
                          ? AppColorsDark.border
                          : AppColorsLight.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.history,
                        size: 12,
                        color: isDarkMode
                            ? AppColorsDark.textMuted
                            : AppColorsLight.textMuted,
                      ),
                      const SizedBox(width: 5),
                      Text(q, style: AppTextStyles.bodySm(isDarkMode)),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () => onRemove(q),
                        child: Icon(
                          Icons.close,
                          size: 11,
                          color: isDarkMode
                              ? AppColorsDark.textMuted
                              : AppColorsLight.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
