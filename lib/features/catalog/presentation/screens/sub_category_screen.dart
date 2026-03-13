import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../data/catalog_repository.dart';
import '../../domain/models/category_model.dart';

// Accent & icon palette for visual variety
const _kAccents = [
  Color(0xFFE8290B), Color(0xFFEF4444), Color(0xFF22C55E), Color(0xFFFFB800),
  Color(0xFF8B5CF6), Color(0xFF06B6D4), Color(0xFF3B82F6), Color(0xFFF97316),
  Color(0xFFEC4899), Color(0xFF64748B),
];

const _kIcons = [
  Icons.settings_rounded,       Icons.electrical_services_rounded,
  Icons.tire_repair_rounded,    Icons.oil_barrel_rounded,
  Icons.car_repair_rounded,     Icons.build_rounded,
  Icons.battery_charging_full_rounded, Icons.speed_rounded,
  Icons.air_rounded,            Icons.thermostat_rounded,
];

// ═════════════════════════════════════════════════════════════
// SubCategoryScreen
//
// Flow: root category → this screen shows its subcategories.
// Tapping a subcategory → pushes ANOTHER SubCategoryScreen for
// that child. When there are no further subcategories the user
// lands on CategoryScreen (parts list).
// ═════════════════════════════════════════════════════════════

class SubCategoryScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const SubCategoryScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  List<CategoryModel> _subs = [];
  bool _isLoading = true;
  String? _error;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final repo = context.read<CatalogRepository>();
      final data = await repo.getSubCategories(widget.categoryId);
      if (mounted) setState(() { _subs = data; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _error = 'Failed to load. Tap to retry.'; _isLoading = false; });
    }
  }

  /// When a subcategory is tapped:
  /// - If it has children → go deeper (another SubCategoryScreen)
  /// - If it has no children / we don't know → go to parts list (CategoryScreen)
  void _onSubTap(CategoryModel sub) {
    // We push SubCategoryScreen; if the API returns no subs, it will
    // automatically show the "Browse all parts" CTA which navigates to CategoryScreen.
    context.push(AppRoutes.subCategoryPath(sub.id, sub.name));
  }

  void _browseAllParts() {
    context.push(AppRoutes.categoryPath(widget.categoryId, widget.categoryName));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark;
    final bg = isDark ? const Color(0xFF0D0D0F) : const Color(0xFFF4F5F7);
    final bgCard = isDark ? const Color(0xFF1A1A1F) : Colors.white;
    final border = isDark ? const Color(0xFF2A2A32) : const Color(0xFFE8EAF0);
    final textPri = isDark ? const Color(0xFFF0F0F5) : const Color(0xFF0F0F14);
    final textSec = isDark ? const Color(0xFF9090A0) : const Color(0xFF5A5A6E);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Icon(Icons.arrow_back_ios_new, size: 18, color: textPri),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.categoryName,
              style: TextStyle(
                fontFamily: 'Syne',
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: textPri,
              ),
            ),
            if (!_isLoading && _subs.isNotEmpty)
              Text(
                '${_subs.length} sub-categories',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 11,
                  color: AppColors.primary,
                ),
              ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () => context.push(AppRoutes.search),
            child: Container(
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: border),
              ),
              child: Icon(Icons.search, size: 18, color: textSec),
            ),
          ),
        ],
      ),

      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
      )
          : _error != null
          ? _ErrorState(message: _error!, onRetry: _load)
      // No subcategories → jump straight to parts list
          : _subs.isEmpty
          ? _NoSubsState(
        categoryName: widget.categoryName,
        onBrowse: _browseAllParts,
      )
          : CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Sub-category grid ──────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.88,
              ),
              delegate: SliverChildBuilderDelegate(
                    (_, i) {
                  final sub = _subs[i];
                  final accent = _kAccents[i % _kAccents.length];
                  final icon = _kIcons[i % _kIcons.length];
                  return _SubTile(
                    name: sub.name,
                    icon: icon,
                    accent: accent,
                    isDark: isDark,
                    bgCard: bgCard,
                    border: border,
                    textPri: textPri,
                    onTap: () => _onSubTap(sub),
                  );
                },
                childCount: _subs.length,
              ),
            ),
          ),

          // ── "Browse all parts" CTA ────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
            sliver: SliverToBoxAdapter(
              child: GestureDetector(
                onTap: _browseAllParts,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 18, horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE8290B), Color(0xFFC01F00)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE8290B).withValues(alpha: 0.3),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.grid_view_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Browse All Parts',
                              style: TextStyle(
                                fontFamily: 'Syne',
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'All ${widget.categoryName} parts in one place',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
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

// ─── Sub-category Tile ────────────────────────────────────────

class _SubTile extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color accent, bgCard, border, textPri;
  final bool isDark;
  final VoidCallback onTap;

  const _SubTile({
    required this.name,
    required this.icon,
    required this.accent,
    required this.isDark,
    required this.bgCard,
    required this.border,
    required this.textPri,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: isDark ? 0.12 : 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accent.withValues(alpha: 0.18)),
              ),
              child: Icon(icon, size: 20, color: accent),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                name,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: textPri,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── No Subs State (leaf category → go straight to parts) ────

class _NoSubsState extends StatelessWidget {
  final String categoryName;
  final VoidCallback onBrowse;

  const _NoSubsState({required this.categoryName, required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              categoryName,
              style: const TextStyle(
                fontFamily: 'Syne',
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'No further sub-categories.\nBrowse all available parts below.',
              style: TextStyle(fontFamily: 'DMSans', fontSize: 13, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onBrowse,
              icon: const Icon(Icons.grid_view_rounded, size: 16),
              label: const Text(
                'Browse All Parts',
                style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w700, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Error State ──────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontFamily: 'DMSans', fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Retry', style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}