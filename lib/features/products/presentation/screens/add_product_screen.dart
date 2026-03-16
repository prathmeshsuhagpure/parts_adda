import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../category/domain/models/category_model.dart';
import '../../../category/presentation/providers/catalog_provider.dart';
import '../../../dealer/domain/models/inventory_model.dart';
import '../../../dealer/presentation/providers/inventory_provider.dart';

// ─── Static reference data ────────────────────────────────────
// NOTE: _kCategories removed — now dynamic from API via CategoryProvider

const _kBrands = [
  'Bosch',
  'Exide',
  'Mahle',
  'Minda',
  'Monroe',
  'Lumax',
  'NGK',
  'Valeo',
  'Denso',
  'ACDelco',
  'Mann',
  'Brembo',
  'KYB',
  'Bilstein',
  'Continental',
  'Other',
];

const _kMakes = [
  'All Makes',
  'Maruti',
  'Hyundai',
  'Honda',
  'Tata',
  'Toyota',
  'Kia',
  'MG',
  'Ford',
  'Volkswagen',
  'Skoda',
  'Renault',
  'Nissan',
  'Jeep',
  'BMW',
  'Mercedes',
];

const _kModelsByMake = <String, List<String>>{
  'Maruti': [
    'Swift',
    'Baleno',
    'Vitara',
    'Alto',
    'Wagon R',
    'Ertiga',
    'Brezza',
  ],
  'Hyundai': ['i20', 'Creta', 'Verna', 'Venue', 'Tucson', 'Alcazar'],
  'Honda': ['City', 'Amaze', 'Jazz', 'WR-V', 'CR-V'],
  'Tata': ['Nexon', 'Punch', 'Tiago', 'Harrier', 'Safari', 'Altroz'],
  'Toyota': ['Innova', 'Fortuner', 'Urban Cruiser', 'Camry', 'Glanza'],
  'Kia': ['Seltos', 'Sonet', 'Carnival', 'Carens'],
  'MG': ['Hector', 'Astor', 'ZS EV', 'Gloster'],
  'Ford': ['Figo', 'EcoSport', 'Endeavour'],
  'Volkswagen': ['Polo', 'Vento', 'Taigun', 'Tiguan'],
  'Skoda': ['Slavia', 'Kushaq', 'Octavia', 'Kodiaq'],
  'Renault': ['Kwid', 'Triber', 'Kiger', 'Duster'],
  'Nissan': ['Magnite', 'Kicks'],
  'Jeep': ['Compass', 'Meridian', 'Wrangler'],
};

// ═════════════════════════════════════════════════════════════
// AddProductScreen
// ═════════════════════════════════════════════════════════════

class AddProductScreen extends StatefulWidget {
  final InventoryItem? existing;

  const AddProductScreen({super.key, this.existing});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen>
    with SingleTickerProviderStateMixin {
  // ── Page controller ───────────────────────────────────────
  late final PageController _pageCtrl;
  final _scrollCtrl = ScrollController();
  int _currentStep = 0;
  static const _totalSteps = 4;

  // ── Form keys per step ────────────────────────────────────
  final _keys = List.generate(_totalSteps, (_) => GlobalKey<FormState>());

  // ── Step 0: Basic info ────────────────────────────────────
  final _nameCtrl = TextEditingController();
  final _skuCtrl = TextEditingController();
  final _oemCtrl = TextEditingController();

  // category is now managed entirely through CategoryProvider
  String _brand = _kBrands[0];
  String _partType = 'aftermarket';

  // ── Step 1: Images ────────────────────────────────────────
  final List<String?> _imageSlots = [null, null, null, null, null];
  int _primaryImageIdx = 0;

  // ── Step 2: Pricing & Stock ───────────────────────────────
  final _priceCtrl = TextEditingController();
  final _mrpCtrl = TextEditingController();
  final _b2bCtrl = TextEditingController();
  final _stockCtrl = TextEditingController(text: '0');
  final _minOrderCtrl = TextEditingController(text: '1');
  bool _freeDelivery = false;

  // ── Step 3: Details ───────────────────────────────────────
  final _descCtrl = TextEditingController();
  List<_SpecEntry> _specs = [];

  // Vehicle compatibility
  final List<_VehicleCompat> _compatList = [];
  String? _compatMake;
  List<String> _compatModels = [];
  String? _compatModel;
  String? _compatYearFrom;
  String? _compatYearTo;

  // ── Theme helpers ─────────────────────────────────────────
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _bg => _isDark ? AppColorsDark.bg : AppColorsLight.bg;

  Color get _bgCard => _isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;

  Color get _textPri =>
      _isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    _initFromExisting();
    Future.microtask(() {
      context.read<CategoryProvider>().loadCategories();
    });
  }

  void _initFromExisting() {
    final e = widget.existing;
    if (e == null) return;
    _nameCtrl.text = e.name;
    _skuCtrl.text = e.sku;
    _oemCtrl.text = e.oemNumber ?? '';
    _brand = e.brand.isNotEmpty ? e.brand : _kBrands[0];
    _partType = e.partType ?? 'aftermarket';
    _priceCtrl.text = e.price.toStringAsFixed(0);
    _mrpCtrl.text = e.mrp?.toStringAsFixed(0) ?? '';
    _b2bCtrl.text = e.b2bPrice?.toStringAsFixed(0) ?? '';
    _stockCtrl.text = e.stock.toString();
    _descCtrl.text = e.description ?? '';
    _specs = e.specifications.entries
        .map(
          (en) => _SpecEntry(
            TextEditingController(text: en.key),
            TextEditingController(text: en.value),
          ),
        )
        .toList();
    // Pre-select the existing category after categories load.
    // If the API returns the category id we can call selectCategory() in a
    // post-frame callback once loadCategories() completes.
    if (e.category.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<CategoryProvider>().selectCategory(e.category);
      });
    }
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _scrollCtrl.dispose();
    for (final c in [
      _nameCtrl,
      _skuCtrl,
      _oemCtrl,
      _priceCtrl,
      _mrpCtrl,
      _b2bCtrl,
      _stockCtrl,
      _minOrderCtrl,
      _descCtrl,
    ]) {
      c.dispose();
    }
    for (final s in _specs) {
      s.dispose();
    }
    super.dispose();
  }

  // ── Navigation ────────────────────────────────────────────
  void _next() {
    // Extra validation on step 0: a category must be selected
    if (_currentStep == 0) {
      final leafId = context.read<CategoryProvider>().leafCategoryId;
      if (leafId == null || leafId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select a category'),
            backgroundColor: AppColorsDark.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }
    }
    if (!_keys[_currentStep].currentState!.validate()) return;
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageCtrl.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _scrollCtrl.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    } else {
      _submit();
    }
  }

  void _back() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageCtrl.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.pop();
    }
  }

  Future<void> _submit() async {
    final specs = <String, String>{};
    for (final s in _specs) {
      final k = s.keyCtrl.text.trim();
      final v = s.valCtrl.text.trim();
      if (k.isNotEmpty && v.isNotEmpty) specs[k] = v;
    }

    final data = {
      'name': _nameCtrl.text.trim(),
      'sku': _skuCtrl.text.trim(),
      'brand': _brand,
      'category': context.read<CategoryProvider>().leafCategoryId ?? '',
      'oemNumber': _oemCtrl.text.trim().isNotEmpty
          ? _oemCtrl.text.trim()
          : null,
      'partType': _partType,
      'price': double.tryParse(_priceCtrl.text) ?? 0,
      'mrp': _mrpCtrl.text.isNotEmpty ? double.tryParse(_mrpCtrl.text) : null,
      'b2bPrice': _b2bCtrl.text.isNotEmpty
          ? double.tryParse(_b2bCtrl.text)
          : null,
      'stock': int.tryParse(_stockCtrl.text) ?? 0,
      'minOrder': int.tryParse(_minOrderCtrl.text) ?? 1,
      'freeDelivery': _freeDelivery,
      'description': _descCtrl.text.trim().isNotEmpty
          ? _descCtrl.text.trim()
          : null,
      'specifications': specs,
      'compatibleMakes': _compatList.map((c) => c.make).toSet().toList(),
      'compatibility': _compatList.map((c) => c.toJson()).toList(),
    };

    final provider = context.read<InventoryProvider>();
    bool ok;
    if (widget.existing != null) {
      ok = await provider.updateListing(widget.existing!.id, data);
    } else {
      ok = await provider.addListing(data);
    }

    if (ok && mounted) {
      _showSuccessSheet();
    }
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _bgCard,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _SuccessSheet(
        isDark: _isDark,
        isEdit: widget.existing != null,
        onDone: () {
          Navigator.pop(context);
          context.pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<InventoryProvider>().isSaving;
    final isEdit = widget.existing != null;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: GestureDetector(
          onTap: _back,
          child: Icon(
            _currentStep == 0 ? Icons.close : Icons.arrow_back_ios_new,
            size: 18,
            color: _textPri,
          ),
        ),
        title: Text(
          isEdit ? 'Edit Product' : 'Add New Product',
          style: AppTextStyles.headingSm(_isDark),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentStep + 1} / $_totalSteps',
                style: AppTextStyles.labelSm(
                  _isDark,
                ).copyWith(color: AppColors.primary),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: _StepProgressBar(
            current: _currentStep,
            total: _totalSteps,
            isDark: _isDark,
          ),
        ),
      ),

      body: Column(
        children: [
          _StepHeader(step: _currentStep, isDark: _isDark),

          Expanded(
            child: PageView(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _Step0BasicInfo(
                  formKey: _keys[0],
                  nameCtrl: _nameCtrl,
                  skuCtrl: _skuCtrl,
                  oemCtrl: _oemCtrl,
                  brand: _brand,
                  partType: _partType,
                  isDark: _isDark,
                  scrollCtrl: _scrollCtrl,
                  onBrandChanged: (v) => setState(() => _brand = v),
                  onPartTypeChanged: (v) => setState(() => _partType = v),
                ),
                _Step1Images(
                  formKey: _keys[1],
                  slots: _imageSlots,
                  primaryIdx: _primaryImageIdx,
                  isDark: _isDark,
                  scrollCtrl: _scrollCtrl,
                  onSetPrimary: (i) => setState(() => _primaryImageIdx = i),
                  onPickImage: (i) {
                    // TODO: wire image_picker
                    setState(() => _imageSlots[i] = 'picked_$i');
                  },
                  onRemoveImage: (i) => setState(() {
                    _imageSlots[i] = null;
                    if (_primaryImageIdx == i) _primaryImageIdx = 0;
                  }),
                ),
                _Step2Pricing(
                  formKey: _keys[2],
                  priceCtrl: _priceCtrl,
                  mrpCtrl: _mrpCtrl,
                  b2bCtrl: _b2bCtrl,
                  stockCtrl: _stockCtrl,
                  minOrderCtrl: _minOrderCtrl,
                  freeDelivery: _freeDelivery,
                  isDark: _isDark,
                  scrollCtrl: _scrollCtrl,
                  onFreeDeliveryChanged: (v) =>
                      setState(() => _freeDelivery = v),
                ),
                _Step3Details(
                  formKey: _keys[3],
                  descCtrl: _descCtrl,
                  specs: _specs,
                  compatList: _compatList,
                  compatMake: _compatMake,
                  compatModels: _compatModels,
                  compatModel: _compatModel,
                  compatYearFrom: _compatYearFrom,
                  compatYearTo: _compatYearTo,
                  isDark: _isDark,
                  scrollCtrl: _scrollCtrl,
                  onAddSpec: () => setState(
                    () => _specs.add(
                      _SpecEntry(
                        TextEditingController(),
                        TextEditingController(),
                      ),
                    ),
                  ),
                  onRemoveSpec: (i) => setState(() {
                    _specs[i].dispose();
                    _specs.removeAt(i);
                  }),
                  onCompatMakeChanged: (v) => setState(() {
                    _compatMake = v;
                    _compatModel = null;
                    _compatModels = v == 'All Makes'
                        ? []
                        : (_kModelsByMake[v] ?? []);
                  }),
                  onCompatModelChanged: (v) => setState(() => _compatModel = v),
                  onCompatYearFromChanged: (v) =>
                      setState(() => _compatYearFrom = v),
                  onCompatYearToChanged: (v) =>
                      setState(() => _compatYearTo = v),
                  onAddCompat: () {
                    if (_compatMake == null) return;
                    setState(() {
                      _compatList.add(
                        _VehicleCompat(
                          make: _compatMake!,
                          model: _compatModel,
                          yearFrom: _compatYearFrom,
                          yearTo: _compatYearTo,
                        ),
                      );
                      _compatMake = null;
                      _compatModel = null;
                      _compatYearFrom = null;
                      _compatYearTo = null;
                      _compatModels = [];
                    });
                  },
                  onRemoveCompat: (i) =>
                      setState(() => _compatList.removeAt(i)),
                ),
              ],
            ),
          ),

          _BottomNav(
            step: _currentStep,
            total: _totalSteps,
            isSaving: isSaving,
            isEdit: isEdit,
            isDark: _isDark,
            onBack: _back,
            onNext: _next,
          ),
        ],
      ),
    );
  }
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
      children: List.generate(
        total,
        (i) => Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 3,
            margin: EdgeInsets.only(right: i < total - 1 ? 2 : 0),
            color: i <= current ? AppColors.primary : bg,
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// Step header label
// ═════════════════════════════════════════════════════════════

const _kStepMeta = [
  (
    icon: Icons.info_outline,
    title: 'Basic Information',
    sub: 'Name, SKU, category & part type',
  ),
  (
    icon: Icons.photo_library_outlined,
    title: 'Product Images',
    sub: 'Add up to 5 photos',
  ),
  (
    icon: Icons.currency_rupee,
    title: 'Pricing & Stock',
    sub: 'Set price, MRP and inventory',
  ),
  (
    icon: Icons.description_outlined,
    title: 'Details',
    sub: 'Specs, compatibility & description',
  ),
];

class _StepHeader extends StatelessWidget {
  final int step;
  final bool isDark;

  const _StepHeader({required this.step, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final meta = _kStepMeta[step];
    final bgCard = isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgCard,
        border: Border(bottom: BorderSide(color: border)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(meta.icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(meta.title, style: AppTextStyles.labelMd(isDark)),
              Text(meta.sub, style: AppTextStyles.bodyXs(isDark)),
            ],
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// Bottom Navigation bar
// ═════════════════════════════════════════════════════════════

class _BottomNav extends StatelessWidget {
  final int step, total;
  final bool isSaving, isEdit, isDark;
  final VoidCallback onBack, onNext;

  const _BottomNav({
    required this.step,
    required this.total,
    required this.isSaving,
    required this.isEdit,
    required this.isDark,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final bgCard = isDark ? AppColorsDark.bgCard2 : AppColorsLight.bgCard2;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;
    final isLast = step == total - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: bgCard,
        border: Border(top: BorderSide(color: border)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onBack,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: border),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  step == 0 ? 'Cancel' : 'Back',
                  style: AppTextStyles.buttonSm.copyWith(
                    color: isDark
                        ? AppColorsDark.textPrimary
                        : AppColorsLight.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: isSaving ? null : onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isSaving && isLast
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLast
                                ? (isEdit ? 'Update Product' : 'Submit Listing')
                                : 'Continue',
                            style: AppTextStyles.buttonSm,
                          ),
                          if (!isLast) ...[
                            const SizedBox(width: 5),
                            const Icon(
                              Icons.arrow_forward,
                              size: 15,
                              color: Colors.white,
                            ),
                          ],
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
// STEP 0 — Basic Information
// ═════════════════════════════════════════════════════════════

class _Step0BasicInfo extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl, skuCtrl, oemCtrl;
  final String brand, partType;
  final bool isDark;
  final ScrollController scrollCtrl;
  final ValueChanged<String> onBrandChanged, onPartTypeChanged;

  const _Step0BasicInfo({
    required this.formKey,
    required this.nameCtrl,
    required this.skuCtrl,
    required this.oemCtrl,
    required this.brand,
    required this.partType,
    required this.isDark,
    required this.scrollCtrl,
    required this.onBrandChanged,
    required this.onPartTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<CategoryProvider>();

    return Form(
      key: formKey,
      child: ListView(
        controller: scrollCtrl,
        padding: const EdgeInsets.all(16),
        children: [
          // Part name
          _FieldLabel('Part Name *'),
          _TextField(
            ctrl: nameCtrl,
            hint: 'e.g. Bosch Wiper Blade 18"',
            isDark: isDark,
            validator: (v) =>
                v!.trim().isEmpty ? 'Part name is required' : null,
          ),
          const SizedBox(height: 16),

          // SKU + OEM row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel('SKU / Part No. *'),
                    _TextField(
                      ctrl: skuCtrl,
                      hint: 'BSH-WB18',
                      isDark: isDark,
                      textCapitalization: TextCapitalization.characters,
                      validator: (v) =>
                          v!.trim().isEmpty ? 'SKU required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel('OEM Number'),
                    _TextField(
                      ctrl: oemCtrl,
                      hint: '15400-PH1-014',
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Dynamic Category Cascade ──────────────────────────
          _FieldLabel('Category *'),
          if (cp.isCategoryLoading)
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? AppColorsDark.border : AppColorsLight.border,
                ),
              ),
              child: const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            )
          else
            _CategoryCascade(isDark: isDark),
          const SizedBox(height: 16),

          // Brand
          _FieldLabel('Brand *'),
          _DropdownTile<String>(
            value: brand,
            items: _kBrands,
            isDark: isDark,
            labelOf: (s) => s,
            onChanged: (v) => onBrandChanged(v!),
          ),
          const SizedBox(height: 20),

          // Part type selector
          _FieldLabel('Part Type'),
          _SegmentedToggle(
            options: const ['OEM / Genuine', 'Aftermarket'],
            values: const ['OEM', 'aftermarket'],
            selected: partType,
            isDark: isDark,
            onChanged: onPartTypeChanged,
          ),
          const SizedBox(height: 12),
          _InfoTip(
            text: partType == 'OEM'
                ? 'OEM parts require a valid OEM number for verification.'
                : 'Aftermarket parts should mention brand and compatibility clearly.',
            isDark: isDark,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// Category Cascade — 3-level dynamic dropdown
// ═════════════════════════════════════════════════════════════

class _CategoryCascade extends StatelessWidget {
  final bool isDark;

  const _CategoryCascade({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cp = context.watch<CategoryProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Level 1 — root categories
        _CascadeDropdown(
          hint: 'Select category',
          value: cp.selectedCategoryId,
          items: cp.categories,
          isDark: isDark,
          onChanged: (id) =>
              context.read<CategoryProvider>().selectCategory(id),
        ),

        // Level 2 — subcategories (shown after root is selected)
        if (cp.selectedCategoryId != null) ...[
          const SizedBox(height: 10),
          if (cp.isSubcategoryLoading)
            _CascadeShimmer(isDark: isDark)
          else if (cp.subcategories.isNotEmpty)
            _CascadeDropdown(
              hint: 'Select subcategory (optional)',
              value: cp.selectedSubcategoryId,
              items: cp.subcategories,
              isDark: isDark,
              onChanged: (id) =>
                  context.read<CategoryProvider>().selectSubcategory(id),
            )
          else
            // API returned no subcategories for this root — that's fine
            const SizedBox.shrink(),
        ],

        // Level 3 — sub-subcategories (shown after subcategory is selected)
        if (cp.selectedSubcategoryId != null) ...[
          const SizedBox(height: 10),
          if (cp.isSubSubcategoryLoading)
            _CascadeShimmer(isDark: isDark)
          else if (cp.subSubcategories.isNotEmpty)
            _CascadeDropdown(
              hint: 'Select type (optional)',
              value: cp.selectedSubSubcategoryId,
              items: cp.subSubcategories,
              isDark: isDark,
              onChanged: (id) =>
                  context.read<CategoryProvider>().selectSubSubcategory(id),
            )
          else
            const SizedBox.shrink(),
        ],
      ],
    );
  }
}

/// A single cascade level dropdown that takes a [CategoryModel] list.
class _CascadeDropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final List<CategoryModel> items;
  final bool isDark;
  final ValueChanged<String> onChanged;

  const _CascadeDropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bgCard = isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;
    final textSec = isDark
        ? AppColorsDark.textSecondary
        : AppColorsLight.textSecondary;
    final textPri = isDark
        ? AppColorsDark.textPrimary
        : AppColorsLight.textPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: value != null
              ? AppColors.primary.withValues(alpha: 0.5)
              : border,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(
            hint,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 13,
              color: textSec,
            ),
          ),
          dropdownColor: bgCard,
          icon: Icon(Icons.keyboard_arrow_down, color: textSec, size: 18),
          style: TextStyle(fontFamily: 'DMSans', fontSize: 13, color: textPri),
          items: items
              .map(
                (cat) => DropdownMenuItem(value: cat.id, child: Text(cat.name)),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

/// Small loading placeholder shown while a cascade level is fetching.
class _CascadeShimmer extends StatelessWidget {
  final bool isDark;

  const _CascadeShimmer({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bgCard = isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: const Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// STEP 1 — Images
// ═════════════════════════════════════════════════════════════

class _Step1Images extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final List<String?> slots;
  final int primaryIdx;
  final bool isDark;
  final ScrollController scrollCtrl;
  final ValueChanged<int> onSetPrimary, onPickImage, onRemoveImage;

  const _Step1Images({
    required this.formKey,
    required this.slots,
    required this.primaryIdx,
    required this.isDark,
    required this.scrollCtrl,
    required this.onSetPrimary,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    final bgCard = isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;
    final bgInput = isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;
    final textMuted = isDark
        ? AppColorsDark.textMuted
        : AppColorsLight.textMuted;

    return Form(
      key: formKey,
      child: ListView(
        controller: scrollCtrl,
        padding: const EdgeInsets.all(16),
        children: [
          _InfoTip(
            text:
                'Add up to 5 clear images. The first/starred image is shown as the thumbnail. '
                'Use white or neutral backgrounds for best results.',
            isDark: isDark,
          ),
          const SizedBox(height: 20),

          // Primary image (large)
          GestureDetector(
            onTap: () => onPickImage(0),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: bgInput,
                borderRadius: AppRadius.cardRadius,
                border: Border.all(
                  color: slots[0] != null
                      ? AppColors.primary.withValues(alpha: 0.4)
                      : border,
                ),
              ),
              child: slots[0] != null
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: AppRadius.cardRadius,
                          child: Container(
                            color: bgInput,
                            child: Center(
                              child: Icon(
                                Icons.image,
                                size: 60,
                                color: textMuted,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => onRemoveImage(0),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Primary',
                              style: TextStyle(
                                fontFamily: 'Syne',
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 44,
                          color: textMuted,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Tap to add primary image',
                          style: AppTextStyles.bodyMd(
                            isDark,
                          ).copyWith(color: textMuted),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'JPG or PNG, max 5MB',
                          style: AppTextStyles.bodyXs(isDark),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),

          // Additional images row
          Row(
            children: List.generate(4, (i) {
              final slotIdx = i + 1;
              final filled = slots[slotIdx] != null;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onPickImage(slotIdx),
                  child: Container(
                    height: 75,
                    margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
                    decoration: BoxDecoration(
                      color: bgInput,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: filled
                            ? AppColors.primary.withValues(alpha: 0.3)
                            : border,
                      ),
                    ),
                    child: filled
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  color: bgInput,
                                  child: Center(
                                    child: Icon(
                                      Icons.image,
                                      size: 28,
                                      color: textMuted,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 3,
                                right: 3,
                                child: GestureDetector(
                                  onTap: () => onRemoveImage(slotIdx),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Icon(Icons.add, size: 22, color: textMuted),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),

          // Tips card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: bgCard,
              borderRadius: AppRadius.cardRadius,
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📸 Photo Tips', style: AppTextStyles.labelMd(isDark)),
                const SizedBox(height: 8),
                ...[
                  'Use bright, even lighting — avoid shadows',
                  'Show the part from multiple angles',
                  'Include packaging and any labels',
                  'Avoid blurry or heavily compressed images',
                ].map(
                  (tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check,
                          size: 13,
                          color: AppColorsDark.success,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(tip, style: AppTextStyles.bodySm(isDark)),
                        ),
                      ],
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
}

// ═════════════════════════════════════════════════════════════
// STEP 2 — Pricing & Stock
// ═════════════════════════════════════════════════════════════

class _Step2Pricing extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController priceCtrl,
      mrpCtrl,
      b2bCtrl,
      stockCtrl,
      minOrderCtrl;
  final bool freeDelivery, isDark;
  final ScrollController scrollCtrl;
  final ValueChanged<bool> onFreeDeliveryChanged;

  const _Step2Pricing({
    required this.formKey,
    required this.priceCtrl,
    required this.mrpCtrl,
    required this.b2bCtrl,
    required this.stockCtrl,
    required this.minOrderCtrl,
    required this.freeDelivery,
    required this.isDark,
    required this.scrollCtrl,
    required this.onFreeDeliveryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        controller: scrollCtrl,
        padding: const EdgeInsets.all(16),
        children: [
          _FieldLabel('Selling Price (₹) *'),
          _TextField(
            ctrl: priceCtrl,
            hint: '349',
            isDark: isDark,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
            ],
            prefixText: '₹ ',
            validator: (v) {
              if (v!.isEmpty) return 'Price is required';
              if ((double.tryParse(v) ?? 0) <= 0) return 'Enter a valid price';
              return null;
            },
          ),
          const SizedBox(height: 16),

          _FieldLabel('MRP / List Price (₹)'),
          _TextField(
            ctrl: mrpCtrl,
            hint: '499 (optional)',
            isDark: isDark,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
            ],
            prefixText: '₹ ',
          ),
          const SizedBox(height: 8),
          _LiveMarginPreview(
            priceCtrl: priceCtrl,
            mrpCtrl: mrpCtrl,
            isDark: isDark,
          ),
          const SizedBox(height: 16),

          _FieldLabel('B2B / Wholesale Price (₹)'),
          _TextField(
            ctrl: b2bCtrl,
            hint: 'Visible only to verified dealers',
            isDark: isDark,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
            ],
            prefixText: '₹ ',
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel('Stock Quantity *'),
                    _TextField(
                      ctrl: stockCtrl,
                      hint: '0',
                      isDark: isDark,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel('Min Order Qty'),
                    _TextField(
                      ctrl: minOrderCtrl,
                      hint: '1',
                      isDark: isDark,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _ToggleRow(
            label: 'Offer Free Delivery',
            subtitle: 'Show free delivery badge on your listing',
            value: freeDelivery,
            isDark: isDark,
            onChanged: onFreeDeliveryChanged,
          ),
          const SizedBox(height: 20),

          _InfoTip(
            text:
                'Setting a higher MRP shows a discount % to buyers, '
                'increasing click-through rate. B2B pricing is never visible to retail buyers.',
            isDark: isDark,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// STEP 3 — Details
// ═════════════════════════════════════════════════════════════

class _Step3Details extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController descCtrl;
  final List<_SpecEntry> specs;
  final List<_VehicleCompat> compatList;
  final String? compatMake, compatModel, compatYearFrom, compatYearTo;
  final List<String> compatModels;
  final bool isDark;
  final ScrollController scrollCtrl;
  final VoidCallback onAddSpec, onAddCompat;
  final ValueChanged<int> onRemoveSpec, onRemoveCompat;
  final ValueChanged<String?> onCompatMakeChanged,
      onCompatModelChanged,
      onCompatYearFromChanged,
      onCompatYearToChanged;

  const _Step3Details({
    required this.formKey,
    required this.descCtrl,
    required this.specs,
    required this.compatList,
    required this.compatMake,
    required this.compatModel,
    required this.compatYearFrom,
    required this.compatYearTo,
    required this.compatModels,
    required this.isDark,
    required this.scrollCtrl,
    required this.onAddSpec,
    required this.onAddCompat,
    required this.onRemoveSpec,
    required this.onRemoveCompat,
    required this.onCompatMakeChanged,
    required this.onCompatModelChanged,
    required this.onCompatYearFromChanged,
    required this.onCompatYearToChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bgCard = isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;
    final textMuted = isDark
        ? AppColorsDark.textMuted
        : AppColorsLight.textMuted;

    final years = List.generate(30, (i) => '${DateTime.now().year - i}');

    return Form(
      key: formKey,
      child: ListView(
        controller: scrollCtrl,
        padding: const EdgeInsets.all(16),
        children: [
          // ── Description ─────────────────────────────────────
          _FieldLabel('Description'),
          TextFormField(
            controller: descCtrl,
            maxLines: 4,
            style: AppTextStyles.bodyMd(isDark),
            decoration: InputDecoration(
              hintText: 'Describe the part, condition, fit, special notes…',
              hintStyle: AppTextStyles.bodyMd(
                isDark,
              ).copyWith(color: textMuted),
              filled: true,
              fillColor: isDark
                  ? AppColorsDark.bgInput
                  : AppColorsLight.bgInput,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Specifications ──────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Text(
                  'Specifications',
                  style: AppTextStyles.labelMd(isDark),
                ),
              ),
              GestureDetector(
                onTap: onAddSpec,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add, size: 13, color: AppColors.primary),
                      const SizedBox(width: 3),
                      Text(
                        'Add Row',
                        style: AppTextStyles.labelXs(isDark).copyWith(
                          color: AppColors.primary,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ...List.generate(
            specs.length,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _TextField(
                      ctrl: specs[i].keyCtrl,
                      hint: 'e.g. Material',
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: _TextField(
                      ctrl: specs[i].valCtrl,
                      hint: 'e.g. Galvanised Steel',
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => onRemoveSpec(i),
                    child: Icon(
                      Icons.remove_circle_outline,
                      size: 18,
                      color: textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (specs.isEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: border),
              ),
              child: Center(
                child: Text(
                  'No specs added yet — tap + Add Row',
                  style: AppTextStyles.bodySm(isDark),
                ),
              ),
            ),
          const SizedBox(height: 24),

          // ── Vehicle Compatibility ────────────────────────────
          Text('Vehicle Compatibility', style: AppTextStyles.labelMd(isDark)),
          const SizedBox(height: 6),
          Text(
            'Specify which cars this part fits to improve search visibility.',
            style: AppTextStyles.bodySm(isDark),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: bgCard,
              borderRadius: AppRadius.cardRadius,
              border: Border.all(color: border),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _DropdownTile<String?>(
                        value: compatMake,
                        items: [null, ..._kMakes],
                        isDark: isDark,
                        labelOf: (v) => v ?? 'Select Make',
                        onChanged: onCompatMakeChanged,
                        hintText: 'Make',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _DropdownTile<String?>(
                        value: compatModel,
                        items: [null, ...compatModels],
                        isDark: isDark,
                        labelOf: (v) => v ?? 'All Models',
                        onChanged: onCompatModelChanged,
                        hintText: 'Model',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _DropdownTile<String?>(
                        value: compatYearFrom,
                        items: [null, ...years],
                        isDark: isDark,
                        labelOf: (v) => v ?? 'From Year',
                        onChanged: onCompatYearFromChanged,
                        hintText: 'From',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _DropdownTile<String?>(
                        value: compatYearTo,
                        items: [null, ...years],
                        isDark: isDark,
                        labelOf: (v) => v ?? 'To Year',
                        onChanged: onCompatYearToChanged,
                        hintText: 'To',
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: compatMake != null ? onAddCompat : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: isDark
                            ? AppColorsDark.bgInput
                            : AppColorsLight.bgInput,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                        elevation: 0,
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          ...List.generate(compatList.length, (i) {
            final c = compatList[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.directions_car_outlined,
                    size: 15,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      c.displayLabel,
                      style: AppTextStyles.labelSm(
                        isDark,
                      ).copyWith(color: AppColors.primary, fontSize: 12),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => onRemoveCompat(i),
                    child: Icon(Icons.close, size: 15, color: textMuted),
                  ),
                ],
              ),
            );
          }),

          if (compatList.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No compatibility added yet',
                  style: AppTextStyles.bodySm(isDark),
                ),
              ),
            ),
          const SizedBox(height: 24),

          _InfoTip(
            text:
                'Your listing will be submitted for review. '
                'It will go live within 24 hours once verified by our team.',
            isDark: isDark,
            color: AppColorsDark.success,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// Success Sheet
// ═════════════════════════════════════════════════════════════

class _SuccessSheet extends StatelessWidget {
  final bool isDark, isEdit;
  final VoidCallback onDone;

  const _SuccessSheet({
    required this.isDark,
    required this.isEdit,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final textSec = isDark
        ? AppColorsDark.textSecondary
        : AppColorsLight.textSecondary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColorsDark.success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColorsDark.success.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: Icon(
                isEdit ? Icons.edit_note : Icons.inventory_2_outlined,
                size: 36,
                color: AppColorsDark.success,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isEdit ? 'Listing Updated!' : 'Product Submitted!',
            style: AppTextStyles.displaySm(isDark),
          ),
          const SizedBox(height: 10),
          Text(
            isEdit
                ? 'Your listing has been updated successfully.'
                : 'Your product is now under review and will go live within 24 hours.',
            style: AppTextStyles.bodyMd(isDark).copyWith(color: textSec),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Back to Inventory',
                style: AppTextStyles.button,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════
// Local data models
// ═════════════════════════════════════════════════════════════

class _SpecEntry {
  final TextEditingController keyCtrl, valCtrl;

  _SpecEntry(this.keyCtrl, this.valCtrl);

  void dispose() {
    keyCtrl.dispose();
    valCtrl.dispose();
  }
}

class _VehicleCompat {
  final String make;
  final String? model, yearFrom, yearTo;

  const _VehicleCompat({
    required this.make,
    this.model,
    this.yearFrom,
    this.yearTo,
  });

  String get displayLabel {
    final parts = [
      make,
      model ?? 'All Models',
      if (yearFrom != null) '$yearFrom–${yearTo ?? 'present'}',
    ];
    return parts.join(' · ');
  }

  Map<String, dynamic> toJson() => {
    'make': make,
    if (model != null) 'model': model,
    if (yearFrom != null) 'yearFrom': int.tryParse(yearFrom!),
    if (yearTo != null) 'yearTo': int.tryParse(yearTo!),
  };
}

// ═════════════════════════════════════════════════════════════
// Reusable small widgets
// ═════════════════════════════════════════════════════════════

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: AppTextStyles.labelSm(isDark).copyWith(
          fontSize: 12,
          color: isDark
              ? AppColorsDark.textSecondary
              : AppColorsLight.textSecondary,
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final bool isDark;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final String? prefixText;

  const _TextField({
    required this.ctrl,
    required this.hint,
    required this.isDark,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.prefixText,
    this.textCapitalization = TextCapitalization.sentences,
  });

  @override
  Widget build(BuildContext context) {
    final bgInput = isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;
    final textMuted = isDark
        ? AppColorsDark.textMuted
        : AppColorsLight.textMuted;

    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      validator: validator,
      style: AppTextStyles.bodyMd(isDark),
      decoration: InputDecoration(
        hintText: hint,
        prefixText: prefixText,
        prefixStyle: AppTextStyles.bodyMd(isDark).copyWith(color: textMuted),
        hintStyle: AppTextStyles.bodyMd(isDark).copyWith(color: textMuted),
        filled: true,
        fillColor: bgInput,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColorsDark.error),
        ),
      ),
    );
  }
}

class _DropdownTile<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final bool isDark;
  final String Function(T) labelOf;
  final ValueChanged<T?> onChanged;
  final String? hintText;

  const _DropdownTile({
    required this.value,
    required this.items,
    required this.isDark,
    required this.labelOf,
    required this.onChanged,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final bgInput = isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;
    final textMuted = isDark
        ? AppColorsDark.textMuted
        : AppColorsLight.textMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: bgInput,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: hintText != null
              ? Text(
                  hintText!,
                  style: AppTextStyles.bodyMd(
                    isDark,
                  ).copyWith(color: textMuted),
                )
              : null,
          isExpanded: true,
          dropdownColor: isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard,
          style: AppTextStyles.bodyMd(isDark),
          icon: Icon(Icons.keyboard_arrow_down, size: 18, color: textMuted),
          onChanged: onChanged,
          items: items
              .map(
                (i) => DropdownMenuItem<T>(
                  value: i,
                  child: Text(labelOf(i), style: AppTextStyles.bodyMd(isDark)),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _SegmentedToggle extends StatelessWidget {
  final List<String> options, values;
  final String selected;
  final bool isDark;
  final ValueChanged<String> onChanged;

  const _SegmentedToggle({
    required this.options,
    required this.values,
    required this.selected,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bgInput = isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgInput,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        children: List.generate(options.length, (i) {
          final active = values[i] == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(values[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  options[i],
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelSm(isDark).copyWith(
                    color: active
                        ? Colors.white
                        : (isDark
                              ? AppColorsDark.textSecondary
                              : AppColorsLight.textSecondary),
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label, subtitle;
  final bool value, isDark;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bgCard = isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: value ? AppColors.primary.withValues(alpha: 0.4) : border,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.labelMd(isDark)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.bodyXs(isDark)),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 24,
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
                    duration: const Duration(milliseconds: 200),
                    left: value ? 22 : 2,
                    top: 2,
                    child: Container(
                      width: 20,
                      height: 20,
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

class _LiveMarginPreview extends StatefulWidget {
  final TextEditingController priceCtrl, mrpCtrl;
  final bool isDark;

  const _LiveMarginPreview({
    required this.priceCtrl,
    required this.mrpCtrl,
    required this.isDark,
  });

  @override
  State<_LiveMarginPreview> createState() => _LiveMarginPreviewState();
}

class _LiveMarginPreviewState extends State<_LiveMarginPreview> {
  @override
  void initState() {
    super.initState();
    widget.priceCtrl.addListener(_update);
    widget.mrpCtrl.addListener(_update);
  }

  void _update() => setState(() {});

  @override
  void dispose() {
    widget.priceCtrl.removeListener(_update);
    widget.mrpCtrl.removeListener(_update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final price = double.tryParse(widget.priceCtrl.text);
    final mrp = double.tryParse(widget.mrpCtrl.text);
    if (price == null || mrp == null || mrp <= 0 || price >= mrp) {
      return const SizedBox.shrink();
    }

    final disc = (((mrp - price) / mrp) * 100).round();
    final saving = mrp - price;
    final bgCard = widget.isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppColorsDark.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 14,
            color: AppColorsDark.success,
          ),
          const SizedBox(width: 7),
          Text(
            'Buyer saves ₹${saving.toStringAsFixed(0)} — ',
            style: AppTextStyles.bodySm(
              widget.isDark,
            ).copyWith(color: AppColorsDark.success),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: AppColorsDark.success,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$disc% OFF',
              style: const TextStyle(
                fontFamily: 'Syne',
                fontWeight: FontWeight.w800,
                fontSize: 10,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTip extends StatelessWidget {
  final String text;
  final bool isDark;
  final Color? color;

  const _InfoTip({required this.text, required this.isDark, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColorsDark.info;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 15, color: c),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySm(isDark).copyWith(color: c),
            ),
          ),
        ],
      ),
    );
  }
}
