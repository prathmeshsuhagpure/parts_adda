import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/models/vehicle_model.dart';
import '../providers/profile_provider.dart';

class AddVehicleScreen extends StatefulWidget {
  final bool isDark;

  const AddVehicleScreen({super.key, required this.isDark});

  @override
  State<AddVehicleScreen> createState() => AddVehicleScreenState();
}

class AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _regCtrl = TextEditingController();

  BrandModel? _selectedBrand;
  VehicleModel? _selectedModel;
  GenerationModel? _selectedGeneration;
  VariantModel? _selectedVariant;

  // Steps: 0=make, 1=model, 2=details
  int _step = 0;

  bool get _d => widget.isDark;

  Color get _bgCard => _d ? AppColorsDark.bgCard : AppColorsLight.bgCard;

  Color get _border => _d ? AppColorsDark.border : AppColorsLight.border;

  Color get _txtSec =>
      _d ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ProfileProvider>().loadBrands());
  }

  @override
  void dispose() {
    _regCtrl.dispose();
    super.dispose();
  }

  // ── Called whenever brand changes ─────────────────────────
  void _onBrandSelected(BrandModel brand) {
    setState(() {
      _selectedBrand = brand;
      _selectedModel = null;
      _selectedGeneration = null;
      _selectedVariant = null;
    });
    context.read<ProfileProvider>().loadModels(brand.id);
  }

  // ── Called whenever model changes ─────────────────────────
  void _onModelSelected(VehicleModel model) {
    setState(() {
      _selectedModel = model;
      _selectedGeneration = null;
      _selectedVariant = null;
    });
    context.read<ProfileProvider>().loadVehicleGenerations(model.id);
  }

  // ── Called whenever generation changes ────────────────────
  void _onGenerationSelected(GenerationModel generation) {
    setState(() {
      _selectedGeneration = generation;
      _selectedVariant = null;
    });
    context.read<ProfileProvider>().loadVariants(generation.id);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    if (_selectedBrand == null || _selectedModel == null) return;

    final ok = await context.read<ProfileProvider>().addVehicle({
      'variantId': _selectedVariant?.id,
      'registrationNumber': _regCtrl.text.trim().isEmpty
          ? null
          : _regCtrl.text.trim().toUpperCase(),
    });
    print("addVehicle result: $ok");

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
                '${_selectedBrand!.name} ${_selectedModel!.name} added to your garage!',
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
                      ? _Step0Make(
                          key: const ValueKey(0),
                          sc: sc,
                          isDark: _d,
                          selectedBrand: _selectedBrand,
                          onBrandSelected: _onBrandSelected,
                        )
                      : _step == 1
                      ? _Step1Model(
                          key: const ValueKey(1),
                          sc: sc,
                          isDark: _d,
                          brand: _selectedBrand!,
                          selectedModel: _selectedModel,
                          onModelSelected: _onModelSelected,
                        )
                      : _Step2Details(
                          key: const ValueKey(2),
                          sc: sc,
                          isDark: _d,
                          brand: _selectedBrand!,
                          model: _selectedModel!,
                          selectedGeneration: _selectedGeneration,
                          selectedVariant: _selectedVariant,
                          regCtrl: _regCtrl,
                          onGenerationSelected: _onGenerationSelected,
                          onVariantSelected: (v) =>
                              setState(() => _selectedVariant = v),
                        ),
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

  bool _canProceed() {
    if (_step == 0) return _selectedBrand != null;
    if (_step == 1) return _selectedModel != null;
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

// ═════════════════════════════════════════════════════════════
// Step 0 — Select Make (dynamic from API)
// ═════════════════════════════════════════════════════════════

class _Step0Make extends StatelessWidget {
  final ScrollController sc;
  final bool isDark;
  final BrandModel? selectedBrand;
  final ValueChanged<BrandModel> onBrandSelected;

  const _Step0Make({
    super.key,
    required this.sc,
    required this.isDark,
    required this.selectedBrand,
    required this.onBrandSelected,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final brands = provider.brands;
    final loading = provider.brandsLoading;

    final bgInput = isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;
    final txtSec = isDark
        ? AppColorsDark.textSecondary
        : AppColorsLight.textSecondary;
    final txtMut = isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;

    return ListView(
      controller: sc,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Text('Select Make / Brand', style: AppTextStyles.headingSm(isDark)),
        const SizedBox(height: 6),
        Text(
          'Choose your vehicle manufacturer',
          style: AppTextStyles.bodyMd(isDark).copyWith(color: txtSec),
        ),
        const SizedBox(height: 18),

        if (loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          )
        else if (brands.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Text(
                'No makes available',
                style: AppTextStyles.bodyMd(isDark).copyWith(color: txtMut),
              ),
            ),
          )
        else
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.1,
            children: brands.map((brand) {
              final sel = selectedBrand?.id == brand.id;
              return GestureDetector(
                onTap: () => onBrandSelected(brand),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: sel
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : bgInput,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: sel
                          ? AppColors.primary.withValues(alpha: 0.5)
                          : border,
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
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : border.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            brand.name[0],
                            style: TextStyle(
                              fontFamily: 'Syne',
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: sel ? AppColors.primary : txtMut,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        brand.name,
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                          color: sel ? AppColors.primary : txtSec,
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
  }
}

// ═════════════════════════════════════════════════════════════
// Step 1 — Select Model (dynamic from API)
// ═════════════════════════════════════════════════════════════

class _Step1Model extends StatelessWidget {
  final ScrollController sc;
  final bool isDark;
  final BrandModel brand;
  final VehicleModel? selectedModel;
  final ValueChanged<VehicleModel> onModelSelected;

  const _Step1Model({
    super.key,
    required this.sc,
    required this.isDark,
    required this.brand,
    required this.selectedModel,
    required this.onModelSelected,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final models = provider.models;
    final loading = provider.modelsLoading;

    final bgInput = isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;
    final txtPri = isDark
        ? AppColorsDark.textPrimary
        : AppColorsLight.textPrimary;
    final txtSec = isDark
        ? AppColorsDark.textSecondary
        : AppColorsLight.textSecondary;
    final txtMut = isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;

    return ListView(
      controller: sc,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        // Selected brand banner
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 18),
          decoration: BoxDecoration(
            color: isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: border,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    brand.name[0],
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: txtPri,
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
                    style: AppTextStyles.bodyXs(isDark).copyWith(color: txtMut),
                  ),
                  Text(brand.name, style: AppTextStyles.headingSm(isDark)),
                ],
              ),
            ],
          ),
        ),

        Text('Select Model', style: AppTextStyles.headingSm(isDark)),
        const SizedBox(height: 6),

        if (loading) ...[
          const SizedBox(height: 40),
          const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          ),
        ] else if (models.isEmpty) ...[
          const SizedBox(height: 20),
          Center(
            child: Text(
              'No models found for ${brand.name}',
              style: AppTextStyles.bodyMd(isDark).copyWith(color: txtMut),
            ),
          ),
        ] else ...[
          Text(
            '${models.length} model${models.length == 1 ? '' : 's'} available for ${brand.name}',
            style: AppTextStyles.bodyMd(isDark).copyWith(color: txtSec),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: models.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final m = models[i];
              final sel = selectedModel?.id == m.id;
              return GestureDetector(
                onTap: () => onModelSelected(m),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: sel
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : bgInput,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: sel
                          ? AppColors.primary.withValues(alpha: 0.45)
                          : border,
                      width: sel ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          m.name,
                          style: AppTextStyles.labelMd(
                            isDark,
                          ).copyWith(color: sel ? AppColors.primary : txtPri),
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
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════
// Step 2 — Vehicle Details (generation, variant, reg)
// ═════════════════════════════════════════════════════════════

class _Step2Details extends StatelessWidget {
  final ScrollController sc;
  final bool isDark;
  final BrandModel brand;
  final VehicleModel model;
  final GenerationModel? selectedGeneration;
  final VariantModel? selectedVariant;
  final TextEditingController regCtrl;
  final ValueChanged<GenerationModel> onGenerationSelected;
  final ValueChanged<VariantModel?> onVariantSelected;

  const _Step2Details({
    super.key,
    required this.sc,
    required this.isDark,
    required this.brand,
    required this.model,
    required this.selectedGeneration,
    required this.selectedVariant,
    required this.regCtrl,
    required this.onGenerationSelected,
    required this.onVariantSelected,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final generations = provider.generations;
    final variants = provider.variants;
    final generationsLoading = provider.generationsLoading;
    final variantsLoading = provider.variantsLoading;

    final bgInput = isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;
    final txtSec = isDark
        ? AppColorsDark.textSecondary
        : AppColorsLight.textSecondary;
    final txtMut = isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;
    final txtPri = isDark
        ? AppColorsDark.textPrimary
        : AppColorsLight.textPrimary;

    return ListView(
      controller: sc,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        // Summary chip
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border.withValues(alpha: 0.3)),
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
                  Text(
                    '${brand.name} ${model.name}',
                    style: AppTextStyles.headingSm(isDark),
                  ),
                  Text(
                    'Fill in more details below',
                    style: AppTextStyles.bodyXs(isDark).copyWith(color: txtSec),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Generation ────────────────────────────────────────
        _fLabel('Generation / Year Range', isDark),
        const SizedBox(height: 10),
        if (generationsLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          )
        else if (generations.isEmpty)
          Text(
            'No generations available',
            style: AppTextStyles.bodySm(isDark).copyWith(color: txtMut),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: generations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final g = generations[i];
              final sel = selectedGeneration?.id == g.id;
              final yearRange = g.endYear != null
                  ? '${g.startYear} – ${g.endYear}'
                  : '${g.startYear} – present';
              return GestureDetector(
                onTap: () => onGenerationSelected(g),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: sel
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : bgInput,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: sel
                          ? AppColors.primary.withValues(alpha: 0.45)
                          : border,
                      width: sel ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              g.name,
                              style: AppTextStyles.labelMd(isDark).copyWith(
                                color: sel ? AppColors.primary : txtPri,
                              ),
                            ),
                            Text(
                              yearRange,
                              style: AppTextStyles.bodyXs(
                                isDark,
                              ).copyWith(color: txtSec),
                            ),
                          ],
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
        const SizedBox(height: 20),

        // ── Variant ───────────────────────────────────────────
        _fLabel('Variant (Optional)', isDark),
        const SizedBox(height: 10),
        if (variantsLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          )
        else if (variants.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: variants.map((v) {
              final sel = selectedVariant?.id == v.id;
              return GestureDetector(
                onTap: () => onVariantSelected(sel ? null : v),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: sel
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : bgInput,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: sel
                          ? AppColors.primary.withValues(alpha: 0.5)
                          : border,
                      width: sel ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (sel) ...[
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 13,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 5),
                      ],
                      Text(
                        v.displayName,
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: sel ? AppColors.primary : txtPri,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          )
        else if (selectedGeneration != null)
          Text(
            'No variants available for this generation',
            style: AppTextStyles.bodySm(isDark).copyWith(color: txtMut),
          )
        else
          Text(
            'Select a generation above to see variants',
            style: AppTextStyles.bodySm(isDark).copyWith(color: txtMut),
          ),
        const SizedBox(height: 20),

        // ── Registration number ────────────────────────────────
        _fLabel('Registration Number (Optional)', isDark),
        const SizedBox(height: 7),
        TextFormField(
          controller: regCtrl,
          style: AppTextStyles.bodyMd(isDark),
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9 ]')),
            LengthLimitingTextInputFormatter(13),
          ],
          decoration: InputDecoration(
            hintText: 'e.g. MH 12 AB 1234',
            hintStyle: AppTextStyles.bodyMd(isDark).copyWith(color: txtMut),
            filled: true,
            fillColor: bgInput,
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Icon(Icons.pin_outlined, size: 18, color: txtMut),
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
              borderSide: BorderSide(color: border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: border),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _fLabel(String t, bool isDark) => Text(
    t,
    style: AppTextStyles.labelSm(
      isDark,
    ).copyWith(fontSize: 12, letterSpacing: 0.2),
  );
}

// ═════════════════════════════════════════════════════════════
// Step progress bar
// ═════════════════════════════════════════════════════════════

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
