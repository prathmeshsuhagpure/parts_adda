import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../dealer/domain/models/inventory_model.dart';
import '../../../dealer/presentation/providers/inventory_provider.dart';
import '../../../dealer/presentation/screens/inventory_screen.dart';

class ProductFormSheet extends StatefulWidget {
  final bool isDark;
  final InventoryItem? existing;

  const ProductFormSheet({super.key, required this.isDark, this.existing});

  @override
  State<ProductFormSheet> createState() => ProductFormSheetState();
}

class ProductFormSheetState extends State<ProductFormSheet> {
  final _formKey = GlobalKey<FormState>();
  int _step = 0; // 0=basic, 1=pricing, 2=details

  // Controllers
  late final TextEditingController _name,
      _sku,
      _brand,
      _oem,
      _price,
      _mrp,
      _b2bPrice,
      _stock,
      _desc;

  String _partType = 'aftermarket';
  String _category = 'Engine';
  final List<String> _selectedMakes = [];

  static const _categories = [
    'Engine',
    'Brakes',
    'Filters',
    'Electrical',
    'Suspension',
    'Body',
    'Tyres',
    'Wipers',
    'Batteries',
    'Other',
  ];
  static const _makes = [
    'Maruti',
    'Hyundai',
    'Honda',
    'Tata',
    'Toyota',
    'Kia',
    'MG',
    'Ford',
    'All Makes',
  ];
  static const _partTypes = ['OEM', 'aftermarket'];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _sku = TextEditingController(text: e?.sku ?? '');
    _brand = TextEditingController(text: e?.brand ?? '');
    _oem = TextEditingController(text: e?.oemNumber ?? '');
    _price = TextEditingController(text: e?.price.toStringAsFixed(0) ?? '');
    _mrp = TextEditingController(text: e?.mrp?.toStringAsFixed(0) ?? '');
    _b2bPrice = TextEditingController(
      text: e?.b2bPrice?.toStringAsFixed(0) ?? '',
    );
    _stock = TextEditingController(text: e?.stock.toString() ?? '0');
    _desc = TextEditingController(text: e?.description ?? '');
    _partType = e?.partType ?? 'aftermarket';
    _category = e?.category ?? 'Engine';
    if (e?.compatibleMakes != null) _selectedMakes.addAll(e!.compatibleMakes);
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _sku,
      _brand,
      _oem,
      _price,
      _mrp,
      _b2bPrice,
      _stock,
      _desc,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _isDark => widget.isDark;

  Color get _bgInput =>
      _isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput;

  Color get _border => _isDark ? AppColorsDark.border : AppColorsLight.border;

  Color get _textMuted =>
      _isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'name': _name.text.trim(),
      'sku': _sku.text.trim(),
      'brand': _brand.text.trim(),
      'category': _category,
      'price': double.tryParse(_price.text) ?? 0,
      'mrp': _mrp.text.isNotEmpty ? double.tryParse(_mrp.text) : null,
      'b2bPrice': _b2bPrice.text.isNotEmpty
          ? double.tryParse(_b2bPrice.text)
          : null,
      'stock': int.tryParse(_stock.text) ?? 0,
      'oemNumber': _oem.text.trim().isNotEmpty ? _oem.text.trim() : null,
      'partType': _partType,
      'description': _desc.text.trim().isNotEmpty ? _desc.text.trim() : null,
      'compatibleMakes': _selectedMakes,
    };

    final provider = context.read<InventoryProvider>();
    bool ok;
    if (widget.existing != null) {
      ok = await provider.updateListing(widget.existing!.id, data);
    } else {
      ok = await provider.addListing(data);
    }
    if (ok && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<InventoryProvider>().isSaving;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final isEdit = widget.existing != null;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.90,
      maxChildSize: 0.97,
      builder: (_, ctrl) => Form(
        key: _formKey,
        child: Column(
          children: [
            // ── Sheet handle + header ─────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
                      Expanded(
                        child: Text(
                          isEdit ? 'Edit Listing' : 'Add New Product',
                          style: AppTextStyles.heading(_isDark),
                        ),
                      ),
                      // Step indicator
                      Text(
                        'Step ${_step + 1}/3',
                        style: AppTextStyles.bodySm(
                          _isDark,
                        ).copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Step tabs
                  Row(
                    children: List.generate(3, (i) {
                      const labels = ['Basic Info', 'Pricing', 'Details'];
                      final active = i == _step;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _step = i),
                          child: Column(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: 3,
                                margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                                decoration: BoxDecoration(
                                  color: active ? AppColors.primary : _border,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                labels[i],
                                style: AppTextStyles.labelXs(_isDark).copyWith(
                                  color: active
                                      ? AppColors.primary
                                      : _textMuted,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // ── Form pages ─────────────────────────────────────
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: EdgeInsets.fromLTRB(16, 8, 16, bottom + 16),
                children: [
                  if (_step == 0) _buildBasicInfo(),
                  if (_step == 1) _buildPricing(),
                  if (_step == 2) _buildDetails(),
                ],
              ),
            ),

            // ── Navigation buttons ────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, bottom + 16),
              child: Row(
                children: [
                  if (_step > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _step--),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: _border),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Back',
                          style: AppTextStyles.buttonSm.copyWith(
                            color: _isDark
                                ? AppColorsDark.textPrimary
                                : AppColorsLight.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  if (_step > 0) const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () {
                        if (_step < 2) {
                          setState(() => _step++);
                        } else {
                          _submit();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: isSaving && _step == 2
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : Text(
                        _step < 2
                            ? 'Next'
                            : (isEdit
                            ? 'Update Listing'
                            : 'Add to Inventory'),
                        style: AppTextStyles.buttonSm,
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

  // ── Step 0: Basic info ──────────────────────────────────
  Widget _buildBasicInfo() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _Label('Part Name *'),
      _FormField(
        ctrl: _name,
        hint: 'e.g. Bosch Wiper Blade 18"',
        isDark: _isDark,
        validator: (v) => v!.isEmpty ? 'Required' : null,
      ),
      const SizedBox(height: 14),

      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Label('SKU *'),
                _FormField(
                  ctrl: _sku,
                  hint: 'BSH-WB18',
                  isDark: _isDark,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Label('Brand'),
                _FormField(ctrl: _brand, hint: 'Bosch', isDark: _isDark),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),

      _Label('Category'),
      _DropdownField<String>(
        value: _category,
        items: _categories,
        isDark: _isDark,
        labelOf: (s) => s,
        onChanged: (v) => setState(() => _category = v!),
      ),
      const SizedBox(height: 14),

      _Label('Part Type'),
      Row(
        children: _partTypes.map((t) {
          final active = _partType == t;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _partType = t),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : _bgInput,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: active
                        ? AppColors.primary.withValues(alpha: 0.5)
                        : _border,
                  ),
                ),
                child: Text(
                  t == 'OEM' ? 'OEM / Genuine' : 'Aftermarket',
                  style: AppTextStyles.labelSm(_isDark).copyWith(
                    color: active
                        ? AppColors.primary
                        : (_isDark
                        ? AppColorsDark.textSecondary
                        : AppColorsLight.textSecondary),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 14),

      _Label('OEM Number (optional)'),
      _FormField(ctrl: _oem, hint: '15400-PH1-014', isDark: _isDark),
    ],
  );

  // ── Step 1: Pricing ─────────────────────────────────────
  Widget _buildPricing() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _InfoBox(
        'Set your selling price. MRP helps show discount to buyers. B2B price is only visible to verified dealers.',
        isDark: _isDark,
      ),
      const SizedBox(height: 14),

      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Label('Selling Price (₹) *'),
                _FormField(
                  ctrl: _price,
                  hint: '349',
                  isDark: _isDark,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                  ],
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Label('MRP / List Price (₹)'),
                _FormField(
                  ctrl: _mrp,
                  hint: '499',
                  isDark: _isDark,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),

      _Label('B2B / Wholesale Price (₹)'),
      _FormField(
        ctrl: _b2bPrice,
        hint: 'Optional dealer price',
        isDark: _isDark,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
      ),
      const SizedBox(height: 14),

      _Label('Stock Quantity *'),
      _FormField(
        ctrl: _stock,
        hint: '0',
        isDark: _isDark,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (v) => v!.isEmpty ? 'Required' : null,
      ),

      const SizedBox(height: 16),
      // Live margin preview
      MarginPreview(priceCtrl: _price, mrpCtrl: _mrp, isDark: _isDark),
    ],
  );

  // ── Step 2: Details ─────────────────────────────────────
  Widget _buildDetails() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _Label('Compatible Makes'),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _makes.map((m) {
          final sel = _selectedMakes.contains(m);
          return GestureDetector(
            onTap: () => setState(() {
              if (m == 'All Makes') {
                _selectedMakes.clear();
                _selectedMakes.add('All Makes');
              } else {
                _selectedMakes.remove('All Makes');
                sel ? _selectedMakes.remove(m) : _selectedMakes.add(m);
              }
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
              decoration: BoxDecoration(
                color: sel
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : _bgInput,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: sel
                      ? AppColors.primary.withValues(alpha: 0.4)
                      : _border,
                ),
              ),
              child: Text(
                m,
                style: AppTextStyles.labelSm(_isDark).copyWith(
                  color: sel
                      ? AppColors.primary
                      : (_isDark
                      ? AppColorsDark.textSecondary
                      : AppColorsLight.textSecondary),
                ),
              ),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 18),

      _Label('Description'),
      TextFormField(
        controller: _desc,
        maxLines: 4,
        style: AppTextStyles.bodyMd(_isDark),
        decoration: InputDecoration(
          hintText: 'Describe the product, condition, packaging…',
          hintStyle: AppTextStyles.bodyMd(_isDark).copyWith(color: _textMuted),
          filled: true,
          fillColor: _bgInput,
          contentPadding: const EdgeInsets.all(14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: _border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
      const SizedBox(height: 16),

      _InfoBox(
        'Your listing will go into Pending review. It will be published within 24 hours after verification.',
        isDark: _isDark,
        color: AppColorsDark.info,
      ),
    ],
  );
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
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

class _FormField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final bool isDark;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _FormField({
    required this.ctrl,
    required this.hint,
    required this.isDark,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
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
      inputFormatters: inputFormatters,
      validator: validator,
      style: AppTextStyles.bodyMd(isDark),
      decoration: InputDecoration(
        hintText: hint,
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

class _DropdownField<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final bool isDark;
  final String Function(T) labelOf;
  final ValueChanged<T?> onChanged;

  const _DropdownField({
    required this.value,
    required this.items,
    required this.isDark,
    required this.labelOf,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bgInput = isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput;
    final border = isDark ? AppColorsDark.border : AppColorsLight.border;

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
          isExpanded: true,
          dropdownColor: isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard,
          style: AppTextStyles.bodyMd(isDark),
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted,
          ),
          onChanged: onChanged,
          items: items
              .map(
                (i) => DropdownMenuItem(
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

class _InfoBox extends StatelessWidget {
  final String text;
  final bool isDark;
  final Color? color;

  const _InfoBox(this.text, {required this.isDark, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColorsDark.info;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 15, color: c),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySm(
                isDark,
              ).copyWith(color: c.withValues(alpha: 0.9)),
            ),
          ),
        ],
      ),
    );
  }
}