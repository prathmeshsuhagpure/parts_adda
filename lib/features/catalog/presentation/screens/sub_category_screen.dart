import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:parts_adda/features/catalog/domain/models/part_model.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/router/app_routes.dart';
import '../../data/catalog_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SubCategoryScreen — Modern Automotive UI
// Design direction: Dark industrial, sharp geometry, frosted glass, bold type
// ─────────────────────────────────────────────────────────────────────────────

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

class _SubCategoryScreenState extends State<SubCategoryScreen>
    with SingleTickerProviderStateMixin {
  // ── Theme ──────────────────────────────────────────────────────────────────
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _bg => _isDark ? const Color(0xFF0D0D0F) : const Color(0xFFF4F5F7);
  Color get _bgCard =>
      _isDark ? const Color(0xFF1A1A1F) : const Color(0xFFFFFFFF);
  Color get _border =>
      _isDark ? const Color(0xFF2A2A32) : const Color(0xFFE8EAF0);
  Color get _textPri =>
      _isDark ? const Color(0xFFF0F0F5) : const Color(0xFF0F0F14);
  Color get _textSec =>
      _isDark ? const Color(0xFF9090A0) : const Color(0xFF5A5A6E);
  Color get _textMut =>
      _isDark ? const Color(0xFF55555F) : const Color(0xFFA0A0B0);
  static const _accent = Color(0xFFE8290B);
  static const _accentGlow = Color(0xFFFF4422);

  List<CategoryModel> subCategories = [];
  bool isLoading = true;

  late final ScrollController _scrollController;
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  double _scrollFraction = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    loadSubCategories();
  }

  void _onScroll() {
    final maxScroll = 200.0 - kToolbarHeight;
    final fraction = (_scrollController.offset / maxScroll).clamp(0.0, 1.0);
    if ((fraction - _scrollFraction).abs() > 0.01) {
      setState(() => _scrollFraction = fraction);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> loadSubCategories() async {
    final repo = context.read<CatalogRepository>();
    final data = await repo.getSubCategories(widget.categoryId);
    setState(() {
      subCategories = data;
      isLoading = false;
    });
    _animCtrl.forward();
  }

  void _onSubTap(CategoryModel sub) =>
      context.push(AppRoutes.categoryPath(sub.id, sub.name));

  void _onViewAllTap() =>
      context.push(AppRoutes.partsPath(widget.categoryId, widget.categoryName));

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _bg,
        body: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverHeader(),
            _buildSectionLabel(),
            _buildSubGrid(),
            _buildViewAllSliver(),
            const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  SliverAppBar _buildSliverHeader() {
    final topPad = MediaQuery.of(context).padding.top;

    return SliverAppBar(
      expandedHeight: 260 + topPad,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 0,
      leadingWidth: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        stretchModes: const [StretchMode.zoomBackground],
        background: _HeroHeader(
          categoryName: widget.categoryName,
          accent: _accent,
          accentGlow: _accentGlow,
          isDark: _isDark,
          topPad: topPad,
          onBack: () => context.pop(),
          onSearch: () => context.push(AppRoutes.search),
        ),
      ),
    );
  }

  // ── Section label ──────────────────────────────────────────────────────────
  SliverToBoxAdapter _buildSectionLabel() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left red tick mark
            Container(
              width: 3,
              height: 20,
              decoration: BoxDecoration(
                color: _accent,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: _accent.withValues(alpha: 0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Sub-Categories',
              style: TextStyle(
                fontFamily: 'Syne',
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: _textPri,
                letterSpacing: -0.3,
              ),
            ),
            const Spacer(),
            if (!isLoading && subCategories.isNotEmpty)
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                  border:
                  Border.all(color: _accent.withValues(alpha: 0.25)),
                ),
                child: Text(
                  '${subCategories.length} types',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: _accent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Grid ───────────────────────────────────────────────────────────────────
  Widget _buildSubGrid() {
    if (isLoading) {
      return SliverPadding(
        padding: const EdgeInsets.all(40),
        sliver: SliverToBoxAdapter(
          child: Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: _accent,
              ),
            ),
          ),
        ),
      );
    }

    if (subCategories.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.all(40),
        sliver: SliverToBoxAdapter(
          child: Center(
            child: Text(
              'No subcategories found',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 14,
                color: _textSec,
              ),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.88,
        ),
        delegate: SliverChildBuilderDelegate(
              (context, i) {
            return FadeTransition(
              opacity: _fadeAnim,
              child: _SubCategoryCard(
                sub: subCategories[i],
                isDark: _isDark,
                bgCard: _bgCard,
                border: _border,
                textPri: _textPri,
                textMut: _textMut,
                accent: _accent,
                index: i,
                onTap: () => _onSubTap(subCategories[i]),
              ),
            );
          },
          childCount: subCategories.length,
        ),
      ),
    );
  }

  // ── View All CTA ───────────────────────────────────────────────────────────
  SliverPadding _buildViewAllSliver() => SliverPadding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
    sliver: SliverToBoxAdapter(
      child: GestureDetector(
        onTap: _onViewAllTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _accent,
                const Color(0xFFC01F00),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _accent.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
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
                        letterSpacing: -0.2,
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
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Header — full bleed, no FlexibleSpaceBar title duplication
// ─────────────────────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  final String categoryName;
  final Color accent, accentGlow;
  final bool isDark;
  final double topPad;
  final VoidCallback onBack, onSearch;

  const _HeroHeader({
    required this.categoryName,
    required this.accent,
    required this.accentGlow,
    required this.isDark,
    required this.topPad,
    required this.onBack,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E12),
      ),
      child: Stack(
        children: [
          // ── Diagonal mesh background ──────────────────────
          Positioned.fill(child: _MeshBackground(accent: accent)),

          // ── Top navigation bar ────────────────────────────
          Positioned(
            top: topPad + 8,
            left: 16,
            right: 16,
            child: Row(
              children: [
                // Back button
                GestureDetector(
                  onTap: onBack,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                // Search button
                GestureDetector(
                  onTap: onSearch,
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          size: 16,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Search parts',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom content: category label ────────────────
          Positioned(
            left: 20,
            right: 20,
            bottom: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category pill
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(6),
                    border:
                    Border.all(color: accent.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    'CATEGORY',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontWeight: FontWeight.w700,
                      fontSize: 9,
                      letterSpacing: 1.8,
                      color: accentGlow,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Category name — large headline
                Text(
                  categoryName,
                  style: const TextStyle(
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w900,
                    fontSize: 32,
                    height: 1.1,
                    color: Colors.white,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 14),
                // Stats strip
                Row(
                  children: [
                    _StatChip(label: 'OEM+', sublabel: 'Genuine'),
                    const SizedBox(width: 8),
                    _StatChip(label: 'Fast', sublabel: 'Delivery'),
                    const SizedBox(width: 8),
                    _StatChip(label: 'Verified', sublabel: 'Sellers'),
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

// ─────────────────────────────────────────────────────────────────────────────
// Mesh background — geometric accent shapes
// ─────────────────────────────────────────────────────────────────────────────

class _MeshBackground extends StatelessWidget {
  final Color accent;
  const _MeshBackground({required this.accent});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _MeshPainter(accent: accent));
  }
}

class _MeshPainter extends CustomPainter {
  final Color accent;
  const _MeshPainter({required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    // Large diagonal gradient blob top-right
    final Paint blobPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          accent.withValues(alpha: 0.28),
          accent.withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.85, size.height * 0.2),
          radius: size.width * 0.55,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.2),
      size.width * 0.55,
      blobPaint,
    );

    // Secondary subtle blob bottom-left
    final Paint blob2 = Paint()
      ..shader = RadialGradient(
        colors: [
          accent.withValues(alpha: 0.10),
          accent.withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.1, size.height * 0.85),
          radius: size.width * 0.4,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.85),
      size.width * 0.4,
      blob2,
    );

    // Geometric grid lines — faint
    final Paint gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Diagonal accent slash — top-right
    final Paint slashPaint = Paint()
      ..color = accent.withValues(alpha: 0.12)
      ..strokeWidth = 60
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.6, -20),
      Offset(size.width * 1.1, size.height * 0.55),
      slashPaint,
    );
  }

  @override
  bool shouldRepaint(_MeshPainter old) => old.accent != accent;
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat chip in the hero
// ─────────────────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String label, sublabel;
  const _StatChip({required this.label, required this.sublabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
        border:
        Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Syne',
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: Colors.white,
            ),
          ),
          Text(
            sublabel,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 9,
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SubCategory Card — frosted glass modern tile
// ─────────────────────────────────────────────────────────────────────────────

class _SubCategoryCard extends StatefulWidget {
  final CategoryModel sub;
  final bool isDark;
  final Color bgCard, border, textPri, textMut, accent;
  final int index;
  final VoidCallback onTap;

  const _SubCategoryCard({
    required this.sub,
    required this.isDark,
    required this.bgCard,
    required this.border,
    required this.textPri,
    required this.textMut,
    required this.accent,
    required this.index,
    required this.onTap,
  });

  @override
  State<_SubCategoryCard> createState() => _SubCategoryCardState();
}

class _SubCategoryCardState extends State<_SubCategoryCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnim = Tween(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          decoration: BoxDecoration(
            color: widget.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: widget.border),
            boxShadow: widget.isDark
                ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
                : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon container with accent bg
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: widget.accent.withValues(alpha: widget.isDark ? 0.12 : 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.accent.withValues(alpha: 0.18),
                  ),
                ),
                child: Icon(
                  _iconForIndex(widget.index),
                  size: 20,
                  color: widget.accent,
                ),
              ),
              const SizedBox(height: 10),
              // Name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  widget.sub.name,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    color: widget.textPri,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 6),
              // Part count
              Text(
                _fmtCount(widget.sub.partCount),
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontWeight: FontWeight.w500,
                  fontSize: 9,
                  color: widget.textMut,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Rotate through meaningful auto-part icons
  IconData _iconForIndex(int i) {
    const icons = [
      Icons.settings_rounded,
      Icons.electrical_services_rounded,
      Icons.tire_repair_rounded,
      Icons.oil_barrel_rounded,
      Icons.car_repair_rounded,
      Icons.build_rounded,
      Icons.battery_charging_full_rounded,
      Icons.speed_rounded,
      Icons.air_rounded,
    ];
    return icons[i % icons.length];
  }

  String _fmtCount(int v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}K parts' : '$v parts';
}