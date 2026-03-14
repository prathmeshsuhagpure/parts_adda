import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../domain/models/category_model.dart';
import '../providers/catalog_provider.dart';

const _kEmojis = [
  '⚙️',
  '🛑',
  '🔩',
  '⚡',
  '🔄',
  '💡',
  '🌡️',
  '🔁',
  '⛽',
  '💨',
  '🚗',
  '🔋',
];

String _emoji(CategoryModel c, int i) =>
    c.icon ?? _kEmojis[i % _kEmojis.length];

class AllCategoriesScreen extends StatefulWidget {
  const AllCategoriesScreen({super.key});

  @override
  State<AllCategoriesScreen> createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;

      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  List<CategoryModel> _filtered(List<CategoryModel> all) {
    if (_query.trim().isEmpty) return all;
    final q = _query.toLowerCase();
    return all.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark;
    final bg = isDark ? AppColorsDark.bg : AppColorsLight.bg;
    final bgCard = isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;
    final textPri = isDark
        ? AppColorsDark.textPrimary
        : AppColorsLight.textPrimary;
    final textSec = isDark
        ? AppColorsDark.textSecondary
        : AppColorsLight.textSecondary;
    final textMut = isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;

    final provider = context.watch<CategoryProvider>();
    final categories = _filtered(provider.categories);
    final isLoading = provider.isDetailLoading;

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
              'All Categories',
              style: TextStyle(
                fontFamily: 'Syne',
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: textPri,
              ),
            ),
            if (!isLoading)
              Text(
                '${provider.categories.length} categories',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 11,
                  color: AppColors.primary,
                ),
              ),
          ],
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: GestureDetector(
              onTap: () => context.push(AppRoutes.search),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Icon(Icons.search, size: 18, color: textMut),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Search parts, brands, OEM numbers…',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 13,
                          color: textMut,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
            ),
          ),

          // ── Grid ─────────────────────────────────────────────
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2.5,
                    ),
                  )
                : categories.isEmpty
                ? _EmptyState(
                    onClear: () {
                      _searchCtrl.clear();
                      setState(() => _query = '');
                    },
                    textPri: textPri,
                    textSec: textSec,
                    bgCard: bgCard,
                    border: border,
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.9,
                        ),
                    itemCount: categories.length,
                    itemBuilder: (_, i) {
                      final cat = categories[i];
                      return _CategoryTile(
                        cat: cat,
                        emoji: _emoji(cat, i),
                        accent: AppColors.primary,
                        isDark: isDark,
                        bgCard: bgCard,
                        border: border,
                        textPri: textPri,
                        onTap: () => context.push(
                          AppRoutes.subCategoryPath(cat.id, cat.name),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Category Tile ────────────────────────────────────────────

class _CategoryTile extends StatelessWidget {
  final CategoryModel cat;
  final String emoji;
  final Color accent, bgCard, border, textPri;
  final bool isDark;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.cat,
    required this.emoji,
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
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: accent.withValues(alpha: 0.2)),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                cat.name,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: textPri,
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

// ─── Empty State ──────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onClear;
  final Color textPri, textSec, bgCard, border;

  const _EmptyState({
    required this.onClear,
    required this.textPri,
    required this.textSec,
    required this.bgCard,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: bgCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: border),
              ),
              child: Icon(Icons.search_off_outlined, size: 34, color: textSec),
            ),
            const SizedBox(height: 16),
            Text(
              'No categories found',
              style: TextStyle(
                fontFamily: 'Syne',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: textPri,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term.',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 13,
                color: textSec,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: onClear,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                  ),
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
  }
}
