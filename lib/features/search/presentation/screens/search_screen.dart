import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/router/app_routes.dart';
import '../../../catalog/domain/models/part_model.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/search_provider.dart';

const _kPopularSearches = [
  'Brake pads',
  'Oil filter',
  'Spark plugs',
  'Air filter',
  'Wiper blades',
  'Battery',
  'Shock absorber',
  'Clutch plate',
];

const _kCategories = [
  (label: 'Engine', icon: '⚙️'),
  (label: 'Brakes', icon: '🛑'),
  (label: 'Filters', icon: '🔵'),
  (label: 'Electrical', icon: '⚡'),
  (label: 'Suspension', icon: '🔧'),
  (label: 'Wipers', icon: '🌊'),
  (label: 'Batteries', icon: '🔋'),
  (label: 'Lighting', icon: '💡'),
  (label: 'Body', icon: '🚗'),
  (label: 'Tyres', icon: '⭕'),
];

const _kBrands = [
  'Bosch',
  'NGK',
  'Mahle',
  'Exide',
  'Monroe',
  'Lumax',
  'Valeo',
  'Denso',
  'Brembo',
  'KYB',
];

const _kMakes = [
  'Maruti',
  'Hyundai',
  'Honda',
  'Tata',
  'Toyota',
  'Kia',
  'MG',
  'Volkswagen',
  'Skoda',
  'Renault',
];

const _kSortOptions = [
  (value: 'relevance', label: 'Most Relevant'),
  (value: 'price_asc', label: 'Price: Low → High'),
  (value: 'price_desc', label: 'Price: High → Low'),
  (value: 'rating', label: 'Top Rated'),
  (value: 'newest', label: 'Newest First'),
];

class SearchScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  final _focusNode = FocusNode();
  final _scrollCtrl = ScrollController();
  Timer? _debounce;

  bool _showSuggestions = false;
  bool _isGridView = true;
  List<String> _recentSearches = [
    'Brake pads Swift',
    'Bosch wiper 18"',
    'Air filter i20',
    'NGK spark plug',
  ];

  bool _showFilterPanel = false;
  SearchFilter _pendingFilter = const SearchFilter();

  late final AnimationController _filterAnim;
  late final Animation<double> _filterSlide;

  @override
  void initState() {
    super.initState();
    _filterAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _filterSlide = CurvedAnimation(parent: _filterAnim, curve: Curves.easeOut);
    _scrollCtrl.addListener(_onScroll);
    _focusNode.addListener(() => setState(() {}));

    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchCtrl.text = widget.initialQuery!;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _doSearch(widget.initialQuery!),
      );
    } else {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _focusNode.requestFocus(),
      );
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    _scrollCtrl.dispose();
    _filterAnim.dispose();
    _debounce?.cancel();
    super.dispose();
  }

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

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 300) {
      context.read<SearchProvider>().loadMore();
    }
  }

  void _doSearch(String q) {
    if (q.trim().isEmpty) return;
    setState(() => _showSuggestions = false);
    _focusNode.unfocus();
    if (!_recentSearches.contains(q.trim())) {
      setState(() => _recentSearches.insert(0, q.trim()));
      if (_recentSearches.length > 10) _recentSearches.removeLast();
    }
    context.read<SearchProvider>().search(q.trim(), filter: _pendingFilter);
  }

  void _onQueryChanged(String q) {
    _debounce?.cancel();
    if (q.length >= 2) {
      setState(() => _showSuggestions = true);
      _debounce = Timer(
        const Duration(milliseconds: 350),
        () => context.read<SearchProvider>().fetchSuggestions(q),
      );
    } else {
      setState(() => _showSuggestions = false);
    }
  }

  void _toggleFilter() {
    setState(() => _showFilterPanel = !_showFilterPanel);
    _showFilterPanel ? _filterAnim.forward() : _filterAnim.reverse();
  }

  void _applyFilter(SearchFilter f) {
    setState(() {
      _pendingFilter = f;
      _showFilterPanel = false;
    });
    _filterAnim.reverse();
    if (context.read<SearchProvider>().query.isNotEmpty) {
      context.read<SearchProvider>().applyFilter(f);
    }
  }

  void _clearAllFilters() {
    setState(() => _pendingFilter = const SearchFilter());
    context.read<SearchProvider>().applyFilter(const SearchFilter());
  }

  void _showSort() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _SortSheet(
        current: _pendingFilter.sortBy,
        isDark: _isDark,
        onSelect: (v) {
          _applyFilter(_pendingFilter.copyWith(sortBy: v));
          Navigator.pop(context);
        },
      ),
    );
  }

  int _countActiveFilters(SearchFilter f) {
    int c = 0;
    if (f.make != null) c++;
    c += f.brands.length + f.categories.length;
    if (f.minPrice != null || f.maxPrice != null) c++;
    if (f.inStockOnly == true) c++;
    if (f.partType != null) c++;
    return c;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SearchProvider>();
    final hasResults = provider.results.isNotEmpty;
    final hasQuery = provider.query.isNotEmpty;
    final filterCount = _countActiveFilters(_pendingFilter);

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _SearchBar(
            ctrl: _searchCtrl,
            focusNode: _focusNode,
            isDark: _isDark,
            bgInput: _bgInput,
            border: _border,
            textMuted: _textMut,
            textPrimary: _textPri,
            onChanged: _onQueryChanged,
            onSubmit: _doSearch,
            onClear: () {
              _searchCtrl.clear();
              setState(() => _showSuggestions = false);
              context.read<SearchProvider>().clearAll();
            },
            onBack: () => context.pop(),
          ),
          Expanded(
            child: Stack(
              children: [
                Column(
                  children: [
                    if (hasQuery && hasResults) ...[
                      _ResultsToolbar(
                        total: provider.total,
                        isGridView: _isGridView,
                        isDark: _isDark,
                        activeFilterCount: filterCount,
                        sortBy: _pendingFilter.sortBy,
                        onToggleView: () =>
                            setState(() => _isGridView = !_isGridView),
                        onFilter: _toggleFilter,
                        onSort: _showSort,
                      ),
                      if (filterCount > 0)
                        _ActiveFiltersRow(
                          filter: _pendingFilter,
                          isDark: _isDark,
                          onClearAll: _clearAllFilters,
                          onClearMake: () => _applyFilter(
                            SearchFilter(
                              brands: _pendingFilter.brands,
                              categories: _pendingFilter.categories,
                              minPrice: _pendingFilter.minPrice,
                              maxPrice: _pendingFilter.maxPrice,
                              inStockOnly: _pendingFilter.inStockOnly,
                              partType: _pendingFilter.partType,
                              sortBy: _pendingFilter.sortBy,
                            ),
                          ),
                          onClearPrice: () => _applyFilter(
                            _pendingFilter.copyWith(
                              minPrice: null,
                              maxPrice: null,
                            ),
                          ),
                          onClearStock: () => _applyFilter(
                            _pendingFilter.copyWith(inStockOnly: null),
                          ),
                          onClearPartType: () => _applyFilter(
                            _pendingFilter.copyWith(partType: null),
                          ),
                          onRemoveBrand: (b) => _applyFilter(
                            _pendingFilter.copyWith(
                              brands: _pendingFilter.brands
                                  .where((x) => x != b)
                                  .toList(),
                            ),
                          ),
                          onRemoveCategory: (c) => _applyFilter(
                            _pendingFilter.copyWith(
                              categories: _pendingFilter.categories
                                  .where((x) => x != c)
                                  .toList(),
                            ),
                          ),
                        ),
                    ],
                    Expanded(child: _buildBody(provider)),
                  ],
                ),

                // Suggestion overlay
                if (_showSuggestions && _focusNode.hasFocus)
                  _SuggestionsOverlay(
                    query: _searchCtrl.text,
                    suggestions: provider.suggestions,
                    recent: _recentSearches,
                    isDark: _isDark,
                    bgCard: _bgCard,
                    border: _border,
                    textSec: _textSec,
                    textMut: _textMut,
                    onTap: (q) {
                      _searchCtrl.text = q;
                      _doSearch(q);
                    },
                    onRemoveRecent: (q) =>
                        setState(() => _recentSearches.remove(q)),
                  ),

                // Filter backdrop
                if (_showFilterPanel || _filterAnim.value > 0)
                  AnimatedBuilder(
                    animation: _filterSlide,
                    builder: (_, _) => GestureDetector(
                      onTap: _toggleFilter,
                      child: Container(
                        color: Colors.black.withValues(
                          alpha: 0.45 * _filterSlide.value,
                        ),
                      ),
                    ),
                  ),

                // Filter panel
                if (_showFilterPanel || _filterAnim.value > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: MediaQuery.of(context).size.width * 0.86,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(_filterSlide),
                      child: _FilterPanel(
                        filter: _pendingFilter,
                        isDark: _isDark,
                        onApply: _applyFilter,
                        onClose: _toggleFilter,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(SearchProvider provider) {
    if (provider.isLoading) {
      return _SearchSkeleton(isDark: _isDark, isGrid: _isGridView);
    }
    if (provider.status == SearchStatus.error) {
      return _ErrorState(
        isDark: _isDark,
        onRetry: () => _doSearch(_searchCtrl.text),
      );
    }
    if (provider.status == SearchStatus.initial || provider.query.isEmpty) {
      return _IdleState(
        isDark: _isDark,
        recentSearches: _recentSearches,
        onSearch: (q) {
          _searchCtrl.text = q;
          _doSearch(q);
        },
        onClearRecent: () => setState(() => _recentSearches.clear()),
        onRemoveRecent: (q) => setState(() => _recentSearches.remove(q)),
      );
    }
    if (provider.results.isEmpty) {
      return _NoResults(
        query: provider.query,
        isDark: _isDark,
        onClearFilters: _pendingFilter.hasActiveFilters
            ? _clearAllFilters
            : null,
        onSearchRelated: (q) {
          _searchCtrl.text = q;
          _doSearch(q);
        },
      );
    }
    return _ResultsView(
      results: provider.results,
      hasMore: provider.hasMore,
      isLoadingMore: provider.isLoadingMore,
      isGridView: _isGridView,
      isDark: _isDark,
      scrollCtrl: _scrollCtrl,
      onTap: (p) => context.push(AppRoutes.partDetailPath(p.id)),
      onAddToCart: (p) {
        final seller = p.sellerListings.isNotEmpty
            ? p.sellerListings.first
            : null;
        context.read<CartProvider>().addItem(
          partId: p.id,
          sellerId: seller?.sellerId ?? "",
          partName: p.name,
          partSku: p.sku,
          partImage: p.images.isNotEmpty ? p.images.first : '',
          sellerName: seller?.sellerName ?? '',
          price: seller?.price ?? p.price,
          mrp: seller?.mrp ?? p.mrp,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${p.name} added to cart',
              style: AppTextStyles.bodyMd(_isDark),
            ),
            backgroundColor: _bgCard,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'View Cart',
              textColor: AppColors.primary,
              onPressed: () => context.go(AppRoutes.cart),
            ),
          ),
        );
      },
      onToggleWishlist: (p) =>
          context.read<ProfileProvider>().toggleWishlist(p.id),
      isWishlisted: (p) => context.read<ProfileProvider>().isWishlisted(p.id),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// Search Bar
// ═════════════════════════════════════════════════════════════

class _SearchBar extends StatelessWidget {
  final TextEditingController ctrl;
  final FocusNode focusNode;
  final bool isDark;
  final Color bgInput, border, textMuted, textPrimary;
  final ValueChanged<String> onChanged, onSubmit;
  final VoidCallback onClear, onBack;

  const _SearchBar({
    required this.ctrl,
    required this.focusNode,
    required this.isDark,
    required this.bgInput,
    required this.border,
    required this.textMuted,
    required this.textPrimary,
    required this.onChanged,
    required this.onSubmit,
    required this.onClear,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColorsDark.bg : AppColorsLight.bg;
    return SafeArea(
      bottom: false,
      child: Container(
        color: bg,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Row(
          children: [
            GestureDetector(
              onTap: onBack,
              child: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: bgInput,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: border),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: bgInput,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: focusNode.hasFocus
                        ? AppColors.primary.withValues(alpha: 0.6)
                        : border,
                    width: focusNode.hasFocus ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Icon(Icons.search, size: 18, color: textMuted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: ctrl,
                        focusNode: focusNode,
                        onChanged: onChanged,
                        onSubmitted: onSubmit,
                        textInputAction: TextInputAction.search,
                        style: AppTextStyles.bodyMd(isDark),
                        decoration: InputDecoration(
                          hintText: 'Search parts, SKU, OEM number…',
                          hintStyle: AppTextStyles.bodyMd(
                            isDark,
                          ).copyWith(color: textMuted),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    if (ctrl.text.isNotEmpty)
                      GestureDetector(
                        onTap: onClear,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Icon(Icons.close, size: 16, color: textMuted),
                        ),
                      )
                    else
                      const SizedBox(width: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// Suggestions Overlay
// ═════════════════════════════════════════════════════════════

class _SuggestionsOverlay extends StatelessWidget {
  final String query;
  final List<String> suggestions, recent;
  final bool isDark;
  final Color bgCard, border, textSec, textMut;
  final ValueChanged<String> onTap, onRemoveRecent;

  const _SuggestionsOverlay({
    required this.query,
    required this.suggestions,
    required this.recent,
    required this.isDark,
    required this.bgCard,
    required this.border,
    required this.textSec,
    required this.textMut,
    required this.onTap,
    required this.onRemoveRecent,
  });

  @override
  Widget build(BuildContext context) {
    final items = suggestions.isNotEmpty
        ? suggestions
        : recent
              .where((r) => r.toLowerCase().contains(query.toLowerCase()))
              .toList();
    if (items.isEmpty) return const SizedBox.shrink();
    final label = suggestions.isNotEmpty ? 'Suggestions' : 'Recent Matches';
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 320),
        decoration: BoxDecoration(
          color: bgCard,
          border: Border(bottom: BorderSide(color: border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: Text(
                label,
                style: AppTextStyles.labelXs(
                  isDark,
                ).copyWith(color: textMut, letterSpacing: 0.8),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 8),
                itemCount: items.length,
                itemBuilder: (_, i) => InkWell(
                  onTap: () => onTap(items[i]),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 11,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          suggestions.isNotEmpty ? Icons.search : Icons.history,
                          size: 15,
                          color: textMut,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _HighlightText(
                            text: items[i],
                            query: query,
                            isDark: isDark,
                          ),
                        ),
                        if (suggestions.isEmpty)
                          GestureDetector(
                            onTap: () => onRemoveRecent(items[i]),
                            child: Icon(Icons.close, size: 14, color: textMut),
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
}

class _HighlightText extends StatelessWidget {
  final String text, query;
  final bool isDark;

  const _HighlightText({
    required this.text,
    required this.query,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final idx = text.toLowerCase().indexOf(query.toLowerCase());
    if (idx == -1 || query.isEmpty) {
      return Text(text, style: AppTextStyles.bodyMd(isDark));
    }
    return RichText(
      text: TextSpan(
        children: [
          if (idx > 0)
            TextSpan(
              text: text.substring(0, idx),
              style: AppTextStyles.bodyMd(isDark),
            ),
          TextSpan(
            text: text.substring(idx, idx + query.length),
            style: AppTextStyles.bodyMd(
              isDark,
            ).copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
          ),
          if (idx + query.length < text.length)
            TextSpan(
              text: text.substring(idx + query.length),
              style: AppTextStyles.bodyMd(isDark),
            ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// Results Toolbar
// ═════════════════════════════════════════════════════════════

class _ResultsToolbar extends StatelessWidget {
  final int total, activeFilterCount;
  final bool isGridView, isDark;
  final String sortBy;
  final VoidCallback onToggleView, onFilter, onSort;

  const _ResultsToolbar({
    required this.total,
    required this.isGridView,
    required this.isDark,
    required this.activeFilterCount,
    required this.sortBy,
    required this.onToggleView,
    required this.onFilter,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    final bgCard = isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;
    final textSec = isDark
        ? AppColorsDark.textSecondary
        : AppColorsLight.textSecondary;
    final sortLabel = _kSortOptions
        .firstWhere((s) => s.value == sortBy, orElse: () => _kSortOptions.first)
        .label;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: bgCard,
        border: Border(bottom: BorderSide(color: border)),
      ),
      child: Row(
        children: [
          Text(
            '$total result${total == 1 ? '' : 's'}',
            style: AppTextStyles.labelSm(
              isDark,
            ).copyWith(color: textSec, fontSize: 12),
          ),
          const Spacer(),
          // Sort
          GestureDetector(
            onTap: onSort,
            child: Row(
              children: [
                Icon(Icons.swap_vert, size: 14, color: textSec),
                const SizedBox(width: 4),
                Text(
                  sortLabel.split(':').first,
                  style: AppTextStyles.labelXs(
                    isDark,
                  ).copyWith(color: textSec, letterSpacing: 0.3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Filter
          GestureDetector(
            onTap: onFilter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: activeFilterCount > 0
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: activeFilterCount > 0
                      ? AppColors.primary.withValues(alpha: 0.4)
                      : border,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.tune,
                    size: 14,
                    color: activeFilterCount > 0 ? AppColors.primary : textSec,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Filter${activeFilterCount > 0 ? ' ($activeFilterCount)' : ''}',
                    style: AppTextStyles.labelXs(isDark).copyWith(
                      color: activeFilterCount > 0
                          ? AppColors.primary
                          : textSec,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Grid/List toggle
          GestureDetector(
            onTap: onToggleView,
            child: Icon(
              isGridView ? Icons.view_list : Icons.grid_view,
              size: 18,
              color: textSec,
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// Active Filters Row
// ═════════════════════════════════════════════════════════════

class _ActiveFiltersRow extends StatelessWidget {
  final SearchFilter filter;
  final bool isDark;
  final VoidCallback onClearAll,
      onClearMake,
      onClearPrice,
      onClearStock,
      onClearPartType;
  final ValueChanged<String> onRemoveBrand, onRemoveCategory;

  const _ActiveFiltersRow({
    required this.filter,
    required this.isDark,
    required this.onClearAll,
    required this.onClearMake,
    required this.onClearPrice,
    required this.onClearStock,
    required this.onClearPartType,
    required this.onRemoveBrand,
    required this.onRemoveCategory,
  });

  @override
  Widget build(BuildContext context) {
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;
    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: border)),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        children: [
          _FChip(
            label: 'Clear all',
            isDark: isDark,
            color: AppColors.primary,
            onRemove: onClearAll,
            isClose: false,
            icon: Icons.clear_all,
          ),
          if (filter.make != null) ...[
            const SizedBox(width: 6),
            _FChip(label: filter.make!, isDark: isDark, onRemove: onClearMake),
          ],
          ...filter.brands.map(
            (b) => Padding(
              padding: const EdgeInsets.only(left: 6),
              child: _FChip(
                label: b,
                isDark: isDark,
                onRemove: () => onRemoveBrand(b),
              ),
            ),
          ),
          ...filter.categories.map(
            (c) => Padding(
              padding: const EdgeInsets.only(left: 6),
              child: _FChip(
                label: c,
                isDark: isDark,
                onRemove: () => onRemoveCategory(c),
              ),
            ),
          ),
          if (filter.minPrice != null || filter.maxPrice != null) ...[
            const SizedBox(width: 6),
            _FChip(
              label:
                  '₹${filter.minPrice?.toInt() ?? 0}–₹${filter.maxPrice?.toInt() ?? '∞'}',
              isDark: isDark,
              onRemove: onClearPrice,
            ),
          ],
          if (filter.inStockOnly == true) ...[
            const SizedBox(width: 6),
            _FChip(label: 'In Stock', isDark: isDark, onRemove: onClearStock),
          ],
          if (filter.partType != null) ...[
            const SizedBox(width: 6),
            _FChip(
              label: filter.partType == 'OEM' ? 'OEM' : 'Aftermarket',
              isDark: isDark,
              onRemove: onClearPartType,
            ),
          ],
        ],
      ),
    );
  }
}

class _FChip extends StatelessWidget {
  final String label;
  final bool isDark, isClose;
  final VoidCallback onRemove;
  final Color? color;
  final IconData? icon;

  const _FChip({
    required this.label,
    required this.isDark,
    required this.onRemove,
    this.color,
    this.isClose = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return GestureDetector(
      onTap: isClose ? null : onRemove,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 11, color: c),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTextStyles.labelXs(
                isDark,
              ).copyWith(color: c, letterSpacing: 0.3),
            ),
            if (isClose) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onRemove,
                child: Icon(Icons.close, size: 11, color: c),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// Sort Sheet
// ═════════════════════════════════════════════════════════════

class _SortSheet extends StatelessWidget {
  final String current;
  final bool isDark;
  final ValueChanged<String> onSelect;

  const _SortSheet({
    required this.current,
    required this.isDark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text('Sort By', style: AppTextStyles.heading(isDark)),
          const SizedBox(height: 12),
          ..._kSortOptions.map(
            (s) => InkWell(
              onTap: () => onSelect(s.value),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 13,
                  horizontal: 4,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(s.label, style: AppTextStyles.bodyMd(isDark)),
                    ),
                    if (s.value == current)
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        size: 18,
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

// ═════════════════════════════════════════════════════════════
// Filter Panel
// ═════════════════════════════════════════════════════════════

class _FilterPanel extends StatefulWidget {
  final SearchFilter filter;
  final bool isDark;
  final ValueChanged<SearchFilter> onApply;
  final VoidCallback onClose;

  const _FilterPanel({
    required this.filter,
    required this.isDark,
    required this.onApply,
    required this.onClose,
  });

  @override
  State<_FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<_FilterPanel> {
  late String? _make;
  late List<String> _brands, _categories;
  late double _minPrice, _maxPrice;
  late bool? _inStockOnly;
  late String? _partType;
  static const double _maxLimit = 50000;

  @override
  void initState() {
    super.initState();
    final f = widget.filter;
    _make = f.make;
    _brands = List.from(f.brands);
    _categories = List.from(f.categories);
    _minPrice = f.minPrice ?? 0;
    _maxPrice = f.maxPrice ?? _maxLimit;
    _inStockOnly = f.inStockOnly;
    _partType = f.partType;
  }

  bool get _isDark => widget.isDark;

  Color get _bgCard => _isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;

  Color get _bgInput =>
      _isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput;

  Color get _border => _isDark ? AppColorsDark.border : AppColorsLight.border;

  Color get _textSec =>
      _isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;

  int get _activeCount {
    int c = 0;
    if (_make != null) c++;
    c += _brands.length + _categories.length;
    if (_minPrice > 0 || _maxPrice < _maxLimit) c++;
    if (_inStockOnly == true) c++;
    if (_partType != null) c++;
    return c;
  }

  void _apply() => widget.onApply(
    SearchFilter(
      make: _make,
      brands: _brands,
      categories: _categories,
      minPrice: _minPrice > 0 ? _minPrice : null,
      maxPrice: _maxPrice < _maxLimit ? _maxPrice : null,
      inStockOnly: _inStockOnly,
      partType: _partType,
    ),
  );

  void _reset() => setState(() {
    _make = null;
    _brands = [];
    _categories = [];
    _minPrice = 0;
    _maxPrice = _maxLimit;
    _inStockOnly = null;
    _partType = null;
  });

  @override
  Widget build(BuildContext context) {
    final textPri = _isDark
        ? AppColorsDark.textPrimary
        : AppColorsLight.textPrimary;
    return Material(
      color: _bgCard,
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: _border)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onClose,
                    child: Icon(Icons.close, size: 20, color: textPri),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Filters',
                      style: AppTextStyles.heading(_isDark),
                    ),
                  ),
                  if (_activeCount > 0)
                    GestureDetector(
                      onTap: _reset,
                      child: Text(
                        'Reset ($_activeCount)',
                        style: AppTextStyles.labelSm(
                          _isDark,
                        ).copyWith(color: AppColors.primary, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _FSection(
                  title: 'Vehicle Make',
                  isDark: _isDark,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _kMakes.map((m) {
                      final sel = _make == m;
                      return _TChip(
                        label: m,
                        selected: sel,
                        isDark: _isDark,
                        onTap: () => setState(() => _make = sel ? null : m),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                _FSection(
                  title: 'Part Type',
                  isDark: _isDark,
                  child: Row(
                    children: ['OEM', 'aftermarket'].map((t) {
                      final label = t == 'OEM'
                          ? 'OEM / Genuine'
                          : 'Aftermarket';
                      final sel = _partType == t;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: t == 'OEM' ? 8 : 0),
                          child: _TChip(
                            label: label,
                            selected: sel,
                            isDark: _isDark,
                            onTap: () =>
                                setState(() => _partType = sel ? null : t),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                _FSection(
                  title: 'Availability',
                  isDark: _isDark,
                  child: _TRow(
                    label: 'In Stock Only',
                    value: _inStockOnly == true,
                    isDark: _isDark,
                    onChanged: (v) =>
                        setState(() => _inStockOnly = v ? true : null),
                  ),
                ),
                const SizedBox(height: 20),

                _FSection(
                  title: 'Price Range',
                  isDark: _isDark,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Min',
                                  style: AppTextStyles.labelXs(
                                    _isDark,
                                  ).copyWith(color: _textSec),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 9,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _bgInput,
                                    borderRadius: BorderRadius.circular(9),
                                    border: Border.all(color: _border),
                                  ),
                                  child: Text(
                                    '₹${_minPrice.toInt()}',
                                    style: AppTextStyles.labelMd(
                                      _isDark,
                                    ).copyWith(color: AppColors.primary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '–',
                              style: AppTextStyles.labelMd(_isDark),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Max',
                                  style: AppTextStyles.labelXs(
                                    _isDark,
                                  ).copyWith(color: _textSec),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 9,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _bgInput,
                                    borderRadius: BorderRadius.circular(9),
                                    border: Border.all(color: _border),
                                  ),
                                  child: Text(
                                    _maxPrice >= _maxLimit
                                        ? 'Any'
                                        : '₹${_maxPrice.toInt()}',
                                    style: AppTextStyles.labelMd(
                                      _isDark,
                                    ).copyWith(color: AppColors.primary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      RangeSlider(
                        values: RangeValues(_minPrice, _maxPrice),
                        min: 0,
                        max: _maxLimit,
                        divisions: 100,
                        activeColor: AppColors.primary,
                        inactiveColor: _border,
                        onChanged: (v) => setState(() {
                          _minPrice = v.start;
                          _maxPrice = v.end;
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                _FSection(
                  title: 'Category',
                  isDark: _isDark,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _kCategories.map((c) {
                      final sel = _categories.contains(c.label);
                      return _TChip(
                        label: '${c.icon} ${c.label}',
                        selected: sel,
                        isDark: _isDark,
                        onTap: () => setState(
                          () => sel
                              ? _categories.remove(c.label)
                              : _categories.add(c.label),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                _FSection(
                  title: 'Brand',
                  isDark: _isDark,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _kBrands.map((b) {
                      final sel = _brands.contains(b);
                      return _TChip(
                        label: b,
                        selected: sel,
                        isDark: _isDark,
                        onTap: () => setState(
                          () => sel ? _brands.remove(b) : _brands.add(b),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: _border)),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _apply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _activeCount > 0
                        ? 'Apply Filters ($_activeCount)'
                        : 'Apply Filters',
                    style: AppTextStyles.button,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// Results View — Grid + List
// ═════════════════════════════════════════════════════════════

class _ResultsView extends StatelessWidget {
  final List<PartModel> results;
  final bool hasMore, isLoadingMore, isGridView, isDark;
  final ScrollController scrollCtrl;
  final ValueChanged<PartModel> onTap, onAddToCart, onToggleWishlist;
  final bool Function(PartModel) isWishlisted;

  const _ResultsView({
    required this.results,
    required this.hasMore,
    required this.isLoadingMore,
    required this.isGridView,
    required this.isDark,
    required this.scrollCtrl,
    required this.onTap,
    required this.onAddToCart,
    required this.onToggleWishlist,
    required this.isWishlisted,
  });

  @override
  Widget build(BuildContext context) {
    if (isGridView) {
      return GridView.builder(
        controller: scrollCtrl,
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.58,
        ),
        itemCount: results.length + (isLoadingMore ? 2 : 0),
        itemBuilder: (_, i) {
          if (i >= results.length) return _SkeletonCard(isDark: isDark);
          final p = results[i];
          return _GridCard(
            part: p,
            isDark: isDark,
            wishlisted: isWishlisted(p),
            onTap: () => onTap(p),
            onAddToCart: () => onAddToCart(p),
            onToggleWishlist: () => onToggleWishlist(p),
          );
        },
      );
    }
    return ListView.separated(
      controller: scrollCtrl,
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: results.length + (isLoadingMore ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        if (i >= results.length) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          );
        }
        final p = results[i];
        return _ListCard(
          part: p,
          isDark: isDark,
          wishlisted: isWishlisted(p),
          onTap: () => onTap(p),
          onAddToCart: () => onAddToCart(p),
          onToggleWishlist: () => onToggleWishlist(p),
        );
      },
    );
  }
}

// ── Grid card ─────────────────────────────────────────────────

class _GridCard extends StatelessWidget {
  final PartModel part;
  final bool isDark, wishlisted;
  final VoidCallback onTap, onAddToCart, onToggleWishlist;

  const _GridCard({
    required this.part,
    required this.isDark,
    required this.wishlisted,
    required this.onTap,
    required this.onAddToCart,
    required this.onToggleWishlist,
  });

  String _fmt(double v) =>
      '₹${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  @override
  Widget build(BuildContext context) {
    final bgCard = isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;
    final bgInput = isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;
    final textMut = isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;
    final discount = (part.mrp != null && part.mrp! > part.price)
        ? (((part.mrp! - part.price) / part.mrp!) * 100).round()
        : 0;
    final inStock = part.stock > 0;

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
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1.05,
                    child: Container(
                      color: bgInput,
                      child: part.images.isNotEmpty
                          ? Image.network(
                              part.images.first,
                              fit: BoxFit.contain,
                            )
                          : Center(
                              child: Icon(
                                Icons.settings_outlined,
                                size: 36,
                                color: textMut,
                              ),
                            ),
                    ),
                  ),
                ),
                if (discount > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _Badge(
                      label: '-$discount%',
                      color: AppColorsDark.success,
                    ),
                  ),
                if (part.partType == 'OEM')
                  Positioned(
                    top: 8,
                    right: 30,
                    child: _Badge(label: 'OEM', color: AppColorsDark.info),
                  ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: onToggleWishlist,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        wishlisted ? Icons.favorite : Icons.favorite_border,
                        size: 14,
                        color: wishlisted ? AppColors.primary : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    part.brand.name.toUpperCase(),
                    style: AppTextStyles.labelXs(
                      isDark,
                    ).copyWith(color: textMut, letterSpacing: 0.8),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    part.name,
                    style: AppTextStyles.labelMd(isDark),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (part.rating != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 11,
                          color: Color(0xFFFFB800),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          part.rating!.toStringAsFixed(1),
                          style: AppTextStyles.bodyXs(isDark),
                        ),
                        Text(
                          ' (${part.reviewCount})',
                          style: AppTextStyles.bodyXs(
                            isDark,
                          ).copyWith(color: textMut),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(_fmt(part.price), style: AppTextStyles.priceSm()),
                  if (part.mrp != null && part.mrp! > part.price)
                    Text(
                      _fmt(part.mrp!),
                      style: AppTextStyles.strikethrough(isDark),
                    ),
                  const SizedBox(height: 7),
                  GestureDetector(
                    onTap: inStock ? onAddToCart : null,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        color: inStock ? AppColors.primary : bgInput,
                        borderRadius: BorderRadius.circular(8),
                        border: inStock ? null : Border.all(color: border),
                      ),
                      child: Center(
                        child: Text(
                          inStock ? 'Add to Cart' : 'Out of Stock',
                          style: AppTextStyles.buttonSm.copyWith(
                            fontSize: 11,
                            color: inStock ? Colors.white : textMut,
                          ),
                        ),
                      ),
                    ),
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

// ── List card ─────────────────────────────────────────────────

class _ListCard extends StatelessWidget {
  final PartModel part;
  final bool isDark, wishlisted;
  final VoidCallback onTap, onAddToCart, onToggleWishlist;

  const _ListCard({
    required this.part,
    required this.isDark,
    required this.wishlisted,
    required this.onTap,
    required this.onAddToCart,
    required this.onToggleWishlist,
  });

  String _fmt(double v) =>
      '₹${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  @override
  Widget build(BuildContext context) {
    final bgCard = isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;
    final bgInput = isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;
    final textSec = isDark
        ? AppColorsDark.textSecondary
        : AppColorsLight.textSecondary;
    final textMut = isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;
    final discount = (part.mrp != null && part.mrp! > part.price)
        ? (((part.mrp! - part.price) / part.mrp!) * 100).round()
        : 0;
    final inStock = part.stock > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgCard,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: Container(
                    width: 82,
                    height: 82,
                    color: bgInput,
                    child: part.images.isNotEmpty
                        ? Image.network(part.images.first, fit: BoxFit.contain)
                        : Center(
                            child: Icon(
                              Icons.settings_outlined,
                              size: 32,
                              color: textMut,
                            ),
                          ),
                  ),
                ),
                if (discount > 0)
                  Positioned(
                    top: 4,
                    left: 4,
                    child: _Badge(
                      label: '-$discount%',
                      color: AppColorsDark.success,
                      small: true,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        part.brand.name,
                        style: AppTextStyles.labelXs(
                          isDark,
                        ).copyWith(color: textSec, letterSpacing: 0.5),
                      ),
                      if (part.partType == 'OEM') ...[
                        const SizedBox(width: 6),
                        _Badge(
                          label: 'OEM',
                          color: AppColorsDark.info,
                          small: true,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    part.name,
                    style: AppTextStyles.labelMd(isDark),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'SKU: ${part.sku}',
                    style: AppTextStyles.mono(isDark).copyWith(fontSize: 10),
                  ),
                  const SizedBox(height: 5),
                  if (part.rating != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 11,
                          color: Color(0xFFFFB800),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${part.rating!.toStringAsFixed(1)} (${part.reviewCount})',
                          style: AppTextStyles.bodyXs(isDark),
                        ),
                        const Spacer(),
                        Text(
                          inStock ? 'In Stock' : 'Out of Stock',
                          style: AppTextStyles.labelXs(isDark).copyWith(
                            color: inStock
                                ? AppColorsDark.success
                                : AppColorsDark.error,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _fmt(part.price),
                            style: AppTextStyles.priceSm(),
                          ),
                          if (part.mrp != null && part.mrp! > part.price)
                            Text(
                              _fmt(part.mrp!),
                              style: AppTextStyles.strikethrough(isDark),
                            ),
                        ],
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: onToggleWishlist,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: wishlisted
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : bgInput,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: wishlisted
                                  ? AppColors.primary.withValues(alpha: 0.3)
                                  : border,
                            ),
                          ),
                          child: Icon(
                            wishlisted ? Icons.favorite : Icons.favorite_border,
                            size: 15,
                            color: wishlisted ? AppColors.primary : textMut,
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      GestureDetector(
                        onTap: inStock ? onAddToCart : null,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: inStock ? AppColors.primary : bgInput,
                            borderRadius: BorderRadius.circular(8),
                            border: inStock ? null : Border.all(color: border),
                          ),
                          child: Icon(
                            Icons.add_shopping_cart_outlined,
                            size: 15,
                            color: inStock ? Colors.white : textMut,
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

// ═════════════════════════════════════════════════════════════
// Idle State
// ═════════════════════════════════════════════════════════════

class _IdleState extends StatelessWidget {
  final bool isDark;
  final List<String> recentSearches;
  final ValueChanged<String> onSearch;
  final VoidCallback onClearRecent;
  final ValueChanged<String> onRemoveRecent;

  const _IdleState({
    required this.isDark,
    required this.recentSearches,
    required this.onSearch,
    required this.onClearRecent,
    required this.onRemoveRecent,
  });

  @override
  Widget build(BuildContext context) {
    final textSec = isDark
        ? AppColorsDark.textSecondary
        : AppColorsLight.textSecondary;
    final textMut = isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;
    final bgCard = isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;

    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        if (recentSearches.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  'Recent Searches',
                  style: AppTextStyles.labelMd(isDark),
                ),
              ),
              GestureDetector(
                onTap: onClearRecent,
                child: Text(
                  'Clear all',
                  style: AppTextStyles.labelXs(
                    isDark,
                  ).copyWith(color: AppColors.primary, letterSpacing: 0.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...recentSearches
              .take(6)
              .map(
                (q) => InkWell(
                  onTap: () => onSearch(q),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 4,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.history, size: 16, color: textMut),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(q, style: AppTextStyles.bodyMd(isDark)),
                        ),
                        GestureDetector(
                          onTap: () => onRemoveRecent(q),
                          child: Icon(Icons.close, size: 15, color: textMut),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          const SizedBox(height: 24),
        ],

        Text('Popular Searches', style: AppTextStyles.labelMd(isDark)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _kPopularSearches
              .map(
                (s) => GestureDetector(
                  onTap: () => onSearch(s),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: bgCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.trending_up,
                          size: 13,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          s,
                          style: AppTextStyles.bodySm(
                            isDark,
                          ).copyWith(color: textSec),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 24),

        Text('Browse by Category', style: AppTextStyles.labelMd(isDark)),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.9,
          children: _kCategories
              .take(8)
              .map(
                (c) => GestureDetector(
                  onTap: () => onSearch(c.label),
                  child: Container(
                    decoration: BoxDecoration(
                      color: bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: border),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(c.icon, style: const TextStyle(fontSize: 24)),
                        const SizedBox(height: 5),
                        Text(
                          c.label,
                          style: AppTextStyles.bodyXs(isDark),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 24),

        Text('Popular Brands', style: AppTextStyles.labelMd(isDark)),
        const SizedBox(height: 10),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _kBrands.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => onSearch(_kBrands[i]),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: bgCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: border),
                ),
                child: Center(
                  child: Text(
                    _kBrands[i],
                    style: AppTextStyles.labelSm(isDark).copyWith(fontSize: 12),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════
// No Results & Error
// ═════════════════════════════════════════════════════════════

class _NoResults extends StatelessWidget {
  final String query;
  final bool isDark;
  final VoidCallback? onClearFilters;
  final ValueChanged<String> onSearchRelated;

  const _NoResults({
    required this.query,
    required this.isDark,
    this.onClearFilters,
    required this.onSearchRelated,
  });

  @override
  Widget build(BuildContext context) {
    final bgCard = isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;
    final textSec = isDark
        ? AppColorsDark.textSecondary
        : AppColorsLight.textSecondary;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 20),
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: bgCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border),
            ),
            child: Center(
              child: Icon(
                Icons.search_off_outlined,
                size: 38,
                color: isDark
                    ? AppColorsDark.textMuted
                    : AppColorsLight.textMuted,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'No results for "$query"',
            style: AppTextStyles.heading(isDark),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Try a different keyword, check spelling or use OEM number.',
            style: AppTextStyles.bodyMd(isDark).copyWith(color: textSec),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        if (onClearFilters != null) ...[
          Center(
            child: GestureDetector(
              onTap: onClearFilters,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  'Clear Filters & Retry',
                  style: AppTextStyles.labelMd(
                    isDark,
                  ).copyWith(color: AppColors.primary),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
        Text('Try searching for', style: AppTextStyles.labelMd(isDark)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _kPopularSearches
              .map(
                (s) => GestureDetector(
                  onTap: () => onSearchRelated(s),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: bgCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: border),
                    ),
                    child: Text(s, style: AppTextStyles.bodySm(isDark)),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final bool isDark;
  final VoidCallback onRetry;

  const _ErrorState({required this.isDark, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.wifi_off_outlined,
          size: 48,
          color: isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted,
        ),
        const SizedBox(height: 14),
        Text('Search failed', style: AppTextStyles.heading(isDark)),
        const SizedBox(height: 8),
        Text(
          'Check your connection and try again.',
          style: AppTextStyles.bodyMd(isDark).copyWith(
            color: isDark
                ? AppColorsDark.textSecondary
                : AppColorsLight.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
          label: const Text('Try Again', style: AppTextStyles.buttonSm),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    ),
  );
}

// ═════════════════════════════════════════════════════════════
// Skeleton loader
// ═════════════════════════════════════════════════════════════

class _SearchSkeleton extends StatefulWidget {
  final bool isDark, isGrid;

  const _SearchSkeleton({required this.isDark, required this.isGrid});

  @override
  State<_SearchSkeleton> createState() => _SearchSkeletonState();
}

class _SearchSkeletonState extends State<_SearchSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, _) {
      final base = widget.isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;
      final shimmer = widget.isDark
          ? AppColorsDark.bgInput
          : AppColorsLight.bgInput;
      final c = Color.lerp(base, shimmer, _anim.value)!;
      if (widget.isGrid) {
        return GridView.count(
          padding: const EdgeInsets.all(16),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.58,
          children: List.generate(
            6,
            (_) => _SkeletonCard(isDark: widget.isDark, color: c),
          ),
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, _) =>
            _SkeletonListCard(isDark: widget.isDark, color: c),
      );
    },
  );
}

class _SkeletonCard extends StatelessWidget {
  final bool isDark;
  final Color? color;

  const _SkeletonCard({required this.isDark, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? (isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard);
    final bgCard = isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;

    return Container(
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1.05,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Container(color: c),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 8,
                  width: 50,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 10,
                  width: 100,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonListCard extends StatelessWidget {
  final bool isDark;
  final Color? color;

  const _SkeletonListCard({required this.isDark, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? (isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard);
    final bgCard = isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 82,
            height: 82,
            color: c,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(9)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 8,
                  width: 60,
                  color: c,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 10,
                  color: c,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 10,
                  width: 120,
                  color: c,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      height: 20,
                      width: 60,
                      color: c,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      height: 30,
                      width: 30,
                      color: c,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 7),
                    Container(
                      height: 30,
                      width: 30,
                      color: c,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// Micro widgets
// ═════════════════════════════════════════════════════════════

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final bool small;

  const _Badge({required this.label, required this.color, this.small = false});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: small ? 5 : 7,
      vertical: small ? 2 : 3,
    ),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontFamily: 'Syne',
        fontWeight: FontWeight.w800,
        fontSize: small ? 8 : 10,
        color: Colors.white,
      ),
    ),
  );
}

class _FSection extends StatelessWidget {
  final String title;
  final bool isDark;
  final Widget child;

  const _FSection({
    required this.title,
    required this.isDark,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: AppTextStyles.labelMd(isDark)),
      const SizedBox(height: 10),
      child,
    ],
  );
}

class _TChip extends StatelessWidget {
  final String label;
  final bool selected, isDark;
  final VoidCallback onTap;

  const _TChip({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgInput = isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.1) : bgInput,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary.withValues(alpha: 0.4) : border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSm(isDark).copyWith(
            color: selected
                ? AppColors.primary
                : (isDark
                      ? AppColorsDark.textSecondary
                      : AppColorsLight.textSecondary),
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _TRow extends StatelessWidget {
  final String label;
  final bool value, isDark;
  final ValueChanged<bool> onChanged;

  const _TRow({
    required this.label,
    required this.value,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bgCard = isDark ? AppColorsDark.bgCard2 : AppColorsLight.bgCard2;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bgCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: value ? AppColors.primary.withValues(alpha: 0.4) : border,
          ),
        ),
        child: Row(
          children: [
            Text(label, style: AppTextStyles.bodyMd(isDark)),
            const Spacer(),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 42,
              height: 23,
              decoration: BoxDecoration(
                color: value
                    ? AppColors.primary
                    : (isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: value ? AppColors.primary : border),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 180),
                    left: value ? 21 : 2,
                    top: 2,
                    child: Container(
                      width: 19,
                      height: 19,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
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
