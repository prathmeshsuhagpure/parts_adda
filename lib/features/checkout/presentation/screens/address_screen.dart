import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../features/profile/presentation/providers/profile_provider.dart';

class AddressScreen extends StatefulWidget {
  final bool selectMode;

  const AddressScreen({super.key, this.selectMode = false});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProfileProvider>();
      provider.loadAddresses();
      _selectedId = provider.defaultAddress?.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final addresses = provider.addresses;
    final isLoading = provider.isLoading;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColorsDark.bg : AppColorsLight.bg,
      appBar: AppBar(
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
        title: Text(
          widget.selectMode ? 'Select Delivery Address' : 'Saved Addresses',
          style: AppTextStyles.headingSm(isDarkMode),
        ),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              physics: const BouncingScrollPhysics(),
              children: [
                // ── Address list ─────────────────────────────
                if (addresses.isEmpty) ...[
                  const SizedBox(height: 60),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
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
                          child: Icon(
                            Icons.location_off_outlined,
                            size: 36,
                            color: isDarkMode
                                ? AppColorsDark.textMuted
                                : AppColorsLight.textMuted,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No saved addresses',
                          style: AppTextStyles.heading(isDarkMode),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Add a delivery address to get started.',
                          style: AppTextStyles.bodyMd(isDarkMode).copyWith(
                            color: isDarkMode
                                ? AppColorsDark.textSecondary
                                : AppColorsLight.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  ...addresses.map((addr) {
                    final isSelected = _selectedId == addr.id;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedId = addr.id);
                        if (widget.selectMode) Navigator.pop(context, addr);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? AppColorsDark.bgCard
                              : AppColorsLight.bgCard,
                          borderRadius: AppRadius.cardRadius,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.6)
                                : (isDarkMode
                                      ? AppColorsDark.border
                                      : AppColorsLight.border),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Radio indicator
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 20,
                              height: 20,
                              margin: const EdgeInsets.only(top: 2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : (isDarkMode
                                            ? AppColorsDark.border
                                            : AppColorsLight.border),
                                  width: 2,
                                ),
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      size: 12,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),

                            // Address details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      _LabelBadge(label: addr.label),
                                      if (addr.isDefault) ...[
                                        const SizedBox(width: 8),
                                        _LabelBadge(
                                          label: 'Default',
                                          color: isDarkMode
                                              ? AppColorsDark.success
                                              : AppColorsLight.success,
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    addr.fullName,
                                    style: AppTextStyles.labelMd(isDarkMode),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    addr.phone,
                                    style: AppTextStyles.bodySm(isDarkMode),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    [
                                          addr.line1,
                                          addr.line2,
                                          addr.city,
                                          addr.state,
                                          addr.pincode,
                                        ]
                                        .where((s) => s != null && s.isNotEmpty)
                                        .join(', '),
                                    style: AppTextStyles.bodyMd(isDarkMode)
                                        .copyWith(
                                          color: isDarkMode
                                              ? AppColorsDark.textSecondary
                                              : AppColorsLight.textSecondary,
                                        ),
                                  ),
                                ],
                              ),
                            ),

                            // Edit / Delete actions
                            PopupMenuButton<String>(
                              color: isDarkMode
                                  ? AppColorsDark.bgCard
                                  : AppColorsLight.bgCard,
                              icon: Icon(
                                Icons.more_vert,
                                color: isDarkMode
                                    ? AppColorsDark.textMuted
                                    : AppColorsLight.textMuted,
                                size: 18,
                              ),
                              onSelected: (v) async {
                                if (v == 'edit') {
                                  _showAddressForm(context, existing: addr);
                                } else if (v == 'default') {
                                  await context
                                      .read<ProfileProvider>()
                                      .setDefaultAddress(addr.id);
                                } else if (v == 'delete') {
                                  final confirmed = await _confirmDelete(
                                    context,
                                  );
                                  if (confirmed == true && context.mounted) {
                                    await context
                                        .read<ProfileProvider>()
                                        .deleteAddress(addr.id);
                                  }
                                }
                              },
                              itemBuilder: (_) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text(
                                    'Edit',
                                    style: AppTextStyles.bodyMd(isDarkMode),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'default',
                                  child: Text(
                                    'Set as default',
                                    style: AppTextStyles.bodyMd(isDarkMode),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text(
                                    'Delete',
                                    style: AppTextStyles.bodyMd(isDarkMode)
                                        .copyWith(
                                          color: isDarkMode
                                              ? AppColorsDark.error
                                              : AppColorsLight.error,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],

                const SizedBox(height: 16),

                // ── Add new address button ─────────────────────
                GestureDetector(
                  onTap: () => _showAddressForm(context),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppColorsDark.bgCard
                          : AppColorsLight.bgCard,
                      borderRadius: AppRadius.cardRadius,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: AppColors.primary,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Add New Address',
                          style: AppTextStyles.labelMd(
                            isDarkMode,
                          ).copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

      // ── Select button (select mode only) ──────────────────
      bottomNavigationBar: widget.selectMode && _selectedId != null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: ElevatedButton(
                  onPressed: () {
                    final addr = context
                        .read<ProfileProvider>()
                        .addresses
                        .firstWhere((a) => a.id == _selectedId);
                    Navigator.pop(context, addr);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Deliver to This Address',
                    style: AppTextStyles.button,
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDarkMode
            ? AppColorsDark.bgCard
            : AppColorsLight.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete address?',
          style: AppTextStyles.displaySm(isDarkMode),
        ),
        content: Text(
          'This address will be permanently removed.',
          style: AppTextStyles.bodyMd(isDarkMode).copyWith(
            color: isDarkMode
                ? AppColorsDark.textSecondary
                : AppColorsLight.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelMd(isDarkMode).copyWith(
                color: isDarkMode
                    ? AppColorsDark.textMuted
                    : AppColorsLight.textMuted,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Delete',
              style: AppTextStyles.labelMd(isDarkMode).copyWith(
                color: isDarkMode ? AppColorsDark.error : AppColorsLight.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddressForm(BuildContext context, {dynamic existing}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkMode
          ? AppColorsDark.bgCard
          : AppColorsLight.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddressForm(
        existing: existing,
        onSave: (data) async {
          final provider = context.read<ProfileProvider>();
          bool ok;
          if (existing != null) {
            ok = await provider.updateAddress(existing.id, data);
          } else {
            ok = await provider.addAddress(data);
          }
          if (ok && context.mounted) Navigator.pop(context);
        },
      ),
    );
  }
}

// ─── Address Form Sheet ───────────────────────────────────────

class _AddressForm extends StatefulWidget {
  final dynamic existing;
  final Future<void> Function(Map<String, dynamic>) onSave;

  const _AddressForm({this.existing, required this.onSave});

  @override
  State<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<_AddressForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name,
      _phone,
      _line1,
      _line2,
      _city,
      _state,
      _pin;
  String _label = 'Home';
  bool _isDefault = false;
  bool _saving = false;

  static const _labels = ['Home', 'Work', 'Other'];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.fullName ?? '');
    _phone = TextEditingController(text: e?.phone ?? '');
    _line1 = TextEditingController(text: e?.line1 ?? '');
    _line2 = TextEditingController(text: e?.line2 ?? '');
    _city = TextEditingController(text: e?.city ?? '');
    _state = TextEditingController(text: e?.state ?? '');
    _pin = TextEditingController(text: e?.pincode ?? '');
    _label = e?.label ?? 'Home';
    _isDefault = e?.isDefault ?? false;
  }

  @override
  void dispose() {
    for (final c in [_name, _phone, _line1, _line2, _city, _state, _pin]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await widget.onSave({
      'label': _label,
      'fullName': _name.text.trim(),
      'phone': _phone.text.trim(),
      'line1': _line1.text.trim(),
      'line2': _line2.text.trim(),
      'city': _city.text.trim(),
      'state': _state.text.trim(),
      'pincode': _pin.text.trim(),
      'isDefault': _isDefault,
    });
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottom + 24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppColorsDark.border
                        : AppColorsLight.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                widget.existing == null ? 'Add New Address' : 'Edit Address',
                style: AppTextStyles.heading(isDarkMode),
              ),
              const SizedBox(height: 18),

              // Label chips
              Row(
                children: _labels.map((l) {
                  final active = _label == l;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _label = l),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : (isDarkMode
                                    ? AppColorsDark.bgInput
                                    : AppColorsLight.bgInput),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: active
                                ? AppColors.primary.withValues(alpha: 0.5)
                                : (isDarkMode
                                      ? AppColorsDark.border
                                      : AppColorsLight.border),
                          ),
                        ),
                        child: Text(
                          l,
                          style: AppTextStyles.labelSm(isDarkMode).copyWith(
                            color: active
                                ? AppColors.primary
                                : (isDarkMode
                                      ? AppColorsDark.textSecondary
                                      : AppColorsLight.textSecondary),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Full name + phone
              Row(
                children: [
                  Expanded(
                    child: _Field(
                      ctrl: _name,
                      label: 'Full Name',
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Field(
                      ctrl: _phone,
                      label: 'Phone',
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) => v!.length < 10 ? 'Invalid phone' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _Field(
                ctrl: _line1,
                label: 'Address Line 1',
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _Field(ctrl: _line2, label: 'Address Line 2 (optional)'),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _Field(
                      ctrl: _city,
                      label: 'City',
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Field(
                      ctrl: _state,
                      label: 'State',
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _Field(
                ctrl: _pin,
                label: 'Pincode',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                validator: (v) =>
                    v!.length != 6 ? 'Enter 6-digit pincode' : null,
              ),
              const SizedBox(height: 16),

              // Set as default
              GestureDetector(
                onTap: () => setState(() => _isDefault = !_isDefault),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _isDefault
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: _isDefault
                              ? AppColors.primary
                              : (isDarkMode
                                    ? AppColorsDark.border
                                    : AppColorsLight.border),
                          width: 1.5,
                        ),
                      ),
                      child: _isDefault
                          ? const Icon(
                              Icons.check,
                              size: 13,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Set as default address',
                      style: AppTextStyles.bodyMd(isDarkMode),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          widget.existing == null
                              ? 'Save Address'
                              : 'Update Address',
                          style: AppTextStyles.button,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Reusable form field ──────────────────────────────────────

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _Field({
    required this.ctrl,
    required this.label,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: AppTextStyles.bodyMd(isDarkMode),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodySm(isDarkMode).copyWith(
          color: isDarkMode
              ? AppColorsDark.textMuted
              : AppColorsLight.textMuted,
        ),
        filled: true,
        fillColor: isDarkMode ? AppColorsDark.bgInput : AppColorsLight.bgInput,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDarkMode ? AppColorsDark.border : AppColorsLight.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDarkMode ? AppColorsDark.border : AppColorsLight.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDarkMode ? AppColorsDark.error : AppColorsLight.error,
          ),
        ),
      ),
    );
  }
}

// ─── Label badge ──────────────────────────────────────────────

class _LabelBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _LabelBadge({required this.label, this.color = AppColors.primary});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelXs(
          isDarkMode,
        ).copyWith(color: color, letterSpacing: 0.5),
      ),
    );
  }
}
