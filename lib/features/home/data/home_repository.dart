/*
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/router/app_routes.dart';
import '../../../category/presentation/providers/catalog_provider.dart';
import '../../../profile/domain/models/vehicle_model.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../profile/presentation/providers/notification_provider.dart';

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

  // Vehicle finder state
  String? _selectedBrandId, _selectedModelId, _selectedGenerationId, _selectedVariantId;
  bool _finderOpen = false;

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
      // Load categories
      context.read<CategoryProvider>().loadCategories();
      // Load vehicle brands
      context.read<ProfileProvider>().loadBrands();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bannerCtrl.dispose();
    super.dispose();
  }

  void _resetVehicleSelection() {
    setState(() {
      _selectedBrandId = null;
      _selectedModelId = null;
      _selectedGenerationId = null;
      _selectedVariantId = null;
    });
  }

  void _searchByVehicle() {
    if (_selectedBrandId == null) return;

    final profileProvider = context.read<ProfileProvider>();
    final brand = profileProvider.brands.firstWhere(
          (b) => b.id == _selectedBrandId,
      orElse: () => BrandModel(id: _selectedBrandId!, name: 'Brand'),
    );

    String query = brand.name;

    if (_selectedModelId != null) {
      final model = profileProvider.models.firstWhere(
            (m) => m.id == _selectedModelId,
        orElse: () => VehicleModel(id: _selectedModelId!, name: 'Model',),
      );
      query += ' ${model.name}';
    }

    if (_selectedGenerationId != null) {
      final generation = profileProvider.generations.firstWhere(
            (g) => g.id == _selectedGenerationId,
        orElse: () => GenerationModel(id: _selectedGenerationId!, name: 'Gen', modelId: '', startYear: 5),
      );
      query += ' ${generation.name}';
    }

    context.push(AppRoutes.searchPath(query: query.trim()));
    _resetVehicleSelection();
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
            floating: false,
            pinned: true,
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
                onTap: () => context.go('/notifications'),
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
              child: _SearchBar(),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // ── Vehicle Finder with API ────────────────
                _VehicleFinderWithAPI(
                  selectedBrandId: _selectedBrandId,
                  selectedModelId: _selectedModelId,
                  selectedGenerationId: _selectedGenerationId,
                  selectedVariantId: _selectedVariantId,
                  isOpen: _finderOpen,
                  onToggle: () => setState(() => _finderOpen = !_finderOpen),
                  onBrandSelected: (brandId) => setState(() {
                    _selectedBrandId = brandId;
                    _selectedModelId = null;
                    _selectedGenerationId = null;
                    _selectedVariantId = null;
                    if (brandId != null) {
                      context.read<ProfileProvider>().loadModels(brandId);
                    }
                  }),
                  onModelSelected: (modelId) => setState(() {
                    _selectedModelId = modelId;
                    _selectedGenerationId = null;
                    _selectedVariantId = null;
                    if (modelId != null) {
                      context.read<ProfileProvider>().loadVehicleGenerations(modelId);
                    }
                  }),
                  onGenerationSelected: (generationId) => setState(() {
                    _selectedGenerationId = generationId;
                    _selectedVariantId = null;
                    if (generationId != null) {
                      context.read<ProfileProvider>().loadVariants(generationId);
                    }
                  }),
                  onVariantSelected: (variantId) => setState(() {
                    _selectedVariantId = variantId;
                  }),
                  onSearch: _searchByVehicle,
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
                  onSeeAll: () => context.push('/all-categories'),
                ),
                const SizedBox(height: 12),
                _CategoryGrid(),
                const SizedBox(height: 24),

                // ── Today's Deals ─────────────────────────
                _SectionHeader(
                  title: "Today's Deals 🔥",
                  onSeeAll: () => context.push(AppRoutes.searchPath(query: 'deals')),
                ),
                const SizedBox(height: 12),
                _DealsRow(),
                const SizedBox(height: 24),

                // ── Recently Viewed ───────────────────────
                _RecentlyViewedSection(),
                const SizedBox(height: 24),

                // ── Top Brands ────────────────────────────
                _SectionHeader(title: 'Top Brands'),
                const SizedBox(height: 12),
                _BrandsRow(),
                const SizedBox(height: 24),

                // ── Trust badges ──────────────────────────
                _TrustSection(),
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
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: GestureDetector(
        onTap: () => context.push('/search'),
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
                      style: AppTextStyles.labelXs(isDarkMode)
                          .copyWith(color: AppColors.primary),
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

// ─── Vehicle Finder with API ──────────────────────────────────

class _VehicleFinderWithAPI extends StatelessWidget {
  final String? selectedBrandId, selectedModelId, selectedGenerationId, selectedVariantId;
  final bool isOpen;
  final VoidCallback onToggle, onSearch;
  final ValueChanged<String?> onBrandSelected, onModelSelected, onGenerationSelected, onVariantSelected;

  const _VehicleFinderWithAPI({
    required this.selectedBrandId,
    required this.selectedModelId,
    required this.selectedGenerationId,
    required this.selectedVariantId,
    required this.isOpen,
    required this.onToggle,
    required this.onSearch,
    required this.onBrandSelected,
    required this.onModelSelected,
    required this.onGenerationSelected,
    required this.onVariantSelected,
  });

  String _getDisplayText(BuildContext context) {
    final items = <String>[];

    if (selectedBrandId != null) {
      final provider = context.read<ProfileProvider>();
      final brand = provider.brands.firstWhere(
            (b) => b.id == selectedBrandId,
        orElse: () => BrandModel(id: '', name: ''),
      );
      if (brand.name.isNotEmpty) items.add(brand.name);
    }

    if (selectedModelId != null) {
      final provider = context.read<ProfileProvider>();
      final model = provider.models.firstWhere(
            (m) => m.id == selectedModelId,
        orElse: () => VehicleModel(id: '', name: ''),
      );
      if (model.name.isNotEmpty) items.add(model.name);
    }

    if (selectedGenerationId != null) {
      final provider = context.read<ProfileProvider>();
      final generation = provider.generations.firstWhere(
            (g) => g.id == selectedGenerationId,
        orElse: () => GenerationModel(id: '', name: '', modelId: '', startYear: 5),
      );
      if (generation.name.isNotEmpty) items.add(generation.name);
    }

    return items.isNotEmpty ? items.join(' · ') : 'Select make · model · year';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final profileProvider = context.watch<ProfileProvider>();

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
                            _getDisplayText(context),
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

                    // Brand Dropdown
                    _APIDropField(
                      label: 'Make',
                      value: selectedBrandId,
                      isLoading: profileProvider.brandsLoading,
                      items: profileProvider.brands
                          .map((b) => (b.id, b.name))
                          .toList(),
                      onChanged: onBrandSelected,
                    ),
                    const SizedBox(height: 12),

                    // Model Dropdown
                    _APIDropField(
                      label: 'Model',
                      value: selectedModelId,
                      isLoading: profileProvider.modelsLoading,
                      items: profileProvider.models
                          .map((m) => (m.id, m.name))
                          .toList(),
                      onChanged: selectedBrandId != null ? onModelSelected : null,
                    ),
                    const SizedBox(height: 12),

                    // Generation Dropdown
                    _APIDropField(
                      label: 'Year',
                      value: selectedGenerationId,
                      isLoading: profileProvider.generationsLoading,
                      items: profileProvider.generations
                          .map((g) => (g.id, g.name))
                          .toList(),
                      onChanged: selectedModelId != null ? onGenerationSelected : null,
                    ),
                    const SizedBox(height: 12),

                    // Variant Dropdown (Optional)
                    if (profileProvider.variants.isNotEmpty) ...[
                      _APIDropField(
                        label: 'Variant',
                        value: selectedVariantId,
                        isLoading: profileProvider.variantsLoading,
                        items: profileProvider.variants
                            .map((v) => (v.id, v.variantName))
                            .toList(),
                        onChanged: selectedGenerationId != null ? onVariantSelected : null,
                      ),
                      const SizedBox(height: 12),
                    ],

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: selectedBrandId != null ? onSearch : null,
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

// ─── API Dropdown Field ───────────────────────────────────────

class _APIDropField extends StatelessWidget {
  final String label;
  final String? value;
  final bool isLoading;
  final List<(String, String)> items;
  final ValueChanged<String?>? onChanged;

  const _APIDropField({
    required this.label,
    required this.value,
    required this.isLoading,
    required this.items,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final active = value != null;
    final isDisabled = onChanged == null;

    if (isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColorsDark.bgInput : AppColorsLight.bgInput,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDarkMode ? AppColorsDark.border : AppColorsLight.border,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Loading $label...',
              style: AppTextStyles.bodySm(isDarkMode),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: active
            ? AppColors.primary.withValues(alpha: 0.06)
            : (isDisabled
            ? (isDarkMode
            ? AppColorsDark.bgInput.withValues(alpha: 0.5)
            : AppColorsLight.bgInput.withValues(alpha: 0.5))
            : (isDarkMode
            ? AppColorsDark.bgInput
            : AppColorsLight.bgInput)),
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
          disabledHint: Text(
            'Select ${label.toLowerCase()} first',
            style: AppTextStyles.bodyXs(isDarkMode).copyWith(
              color: isDarkMode
                  ? AppColorsDark.textMuted
                  : AppColorsLight.textMuted,
            ),
          ),
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
          onChanged: isDisabled ? null : onChanged,
          items: items
              .map(
                (item) => DropdownMenuItem(
              value: item.$1,
              child: Text(
                item.$2,
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

  const _SectionHeader({
    required this.title,
    this.onSeeAll,
  });

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
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Row(
                children: [
                  Text(
                    'See all',
                    style: AppTextStyles.bodySm(isDarkMode)
                        .copyWith(color: AppColors.primary),
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

// ─── Category Grid ────────────────────────────────────────────

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<CategoryProvider>();

    if (provider.isCategoryLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final categories = provider.categories;
    final displayCategories = categories.take(3).toList();
    final hasMore = categories.length > 3;

    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.0,
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
            ),
            itemCount: displayCategories.length,
            itemBuilder: (_, i) {
              final cat = displayCategories[i];
              return GestureDetector(
                onTap: () => context.push('/sub-category/${cat.id}/${cat.name}'),
                child: Column(
                  children: [
                    Expanded(
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
                        child: Center(
                          child: Text(
                            cat.icon ?? '📦',
                            style: const TextStyle(fontSize: 48),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cat.name,
                      style: AppTextStyles.bodySm(isDarkMode),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
          if (hasMore) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.push('/all-categories'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(
                    color: isDarkMode
                        ? AppColorsDark.border
                        : AppColorsLight.border,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'See All Categories',
                      style: AppTextStyles.labelMd(isDarkMode)
                          .copyWith(color: AppColors.primary),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.arrow_forward,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Deals Row ────────────────────────────────────────────────

class _DealsRow extends StatelessWidget {
  const _DealsRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 218,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _deals.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _DealCard(deal: _deals[i]),
      ),
    );
  }
}

class _DealCard extends StatelessWidget {
  final _Deal deal;

  const _DealCard({required this.deal});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => context.push('/part-detail/${deal.id}'),
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
                        style: AppTextStyles.strikethrough(isDarkMode)
                            .copyWith(fontSize: 10),
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

// ─── Recently Viewed Section ──────────────────────────────────

class _RecentlyViewedSection extends StatelessWidget {
  const _RecentlyViewedSection();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // TODO: Replace with actual data from SharedPreferences or provider
    // For now showing mock data
    final recentItems = [
      {
        'id': '1',
        'name': 'MODULE ASSY,AIRB...',
        'price': '₹4,033.00',
        'mrp': null,
        'discount': null,
        'make': 'MARUTI SUZUKI',
        'sku': '4815OM...01-C48',
        'image': null,
      },
    ];

    if (recentItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Recently Viewed'),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: recentItems.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final item = recentItems[i];
              return _RecentlyViewedCard(
                item: item,
                isDarkMode: isDarkMode,
                onTap: () => context.push('/part-detail/${item['id']}'),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RecentlyViewedCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _RecentlyViewedCard({
    required this.item,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
            Stack(
              children: [
                Container(
                  height: 90,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppColorsDark.bgInput
                        : AppColorsLight.bgInput,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: item['image'] != null
                      ? CachedNetworkImage(
                    imageUrl: item['image'],
                    fit: BoxFit.contain,
                  )
                      : Icon(
                    Icons.settings,
                    color: isDarkMode
                        ? AppColorsDark.textMuted
                        : AppColorsLight.textMuted,
                  ),
                ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColorsDark.info,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'OEM',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w800,
                        fontSize: 9,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'] as String,
                    style: AppTextStyles.labelSm(isDarkMode),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['price'] as String,
                    style: AppTextStyles.priceSm(),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['make'] as String,
                    style: AppTextStyles.bodyXs(isDarkMode).copyWith(
                      color: isDarkMode
                          ? AppColorsDark.textMuted
                          : AppColorsLight.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
  const _BrandsRow();

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
            onTap: () => context.push(AppRoutes.searchPath(query: name)),
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
  const _TrustSection();

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
                  child: Icon(item.$1,
                      color: AppColors.primary, size: 15),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.$2,
                        style: AppTextStyles.labelSm(isDarkMode)
                            .copyWith(
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
}*/
