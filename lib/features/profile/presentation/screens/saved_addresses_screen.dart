import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/models/address_model.dart';
import '../providers/profile_provider.dart';

const _kIndianStates = [
  'Andhra Pradesh',
  'Arunachal Pradesh',
  'Assam',
  'Bihar',
  'Chhattisgarh',
  'Goa',
  'Gujarat',
  'Haryana',
  'Himachal Pradesh',
  'Jharkhand',
  'Karnataka',
  'Kerala',
  'Madhya Pradesh',
  'Maharashtra',
  'Manipur',
  'Meghalaya',
  'Mizoram',
  'Nagaland',
  'Odisha',
  'Punjab',
  'Rajasthan',
  'Sikkim',
  'Tamil Nadu',
  'Telangana',
  'Tripura',
  'Uttar Pradesh',
  'Uttarakhand',
  'West Bengal',
  'Delhi',
  'Jammu & Kashmir',
  'Ladakh',
  'Chandigarh',
  'Puducherry',
];

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  bool get _d => Theme.of(context).brightness == Brightness.dark;

  Color get _bg => _d ? AppColorsDark.bg : AppColorsLight.bg;

  Color get _bgCard => _d ? AppColorsDark.bgCard : AppColorsLight.bgCard;

  Color get _border => _d ? AppColorsDark.border : AppColorsLight.border;

  Color get _txtPri =>
      _d ? AppColorsDark.textPrimary : AppColorsLight.textPrimary;

  Color get _txtSec =>
      _d ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;

  Color get _txtMut => _d ? AppColorsDark.textMuted : AppColorsLight.textMuted;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ProfileProvider>().loadAddresses(),
    );
  }

  void _openForm({AddressModel? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<ProfileProvider>(),
        child: _AddressFormSheet(existing: existing, isDark: _d),
      ),
    );
  }

  void _confirmDelete(AddressModel a) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete address?', style: AppTextStyles.headingSm(_d)),
        content: Text(
          'Remove the ${a.label.toLowerCase()} address at ${a.city} from your account?',
          style: AppTextStyles.bodyMd(_d).copyWith(color: _txtSec),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelMd(_d).copyWith(color: _txtSec),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<ProfileProvider>().deleteAddress(a.id);
            },
            child: Text(
              'Delete',
              style: AppTextStyles.labelMd(
                _d,
              ).copyWith(color: AppColorsDark.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: _txtPri,
          ),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Saved Addresses', style: AppTextStyles.heading(_d)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => _openForm(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.add_rounded, size: 15, color: Colors.white),
                  const SizedBox(width: 4),
                  const Text('Add New', style: AppTextStyles.buttonSm),
                ]),
              ),
            ),
          ),
        ],
      ),
      body: provider.isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            )
          : provider.addresses.isEmpty
          ? _emptyState()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              physics: const BouncingScrollPhysics(),
              itemCount: provider.addresses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final addr = provider.addresses[i];
                return _AddressCard(
                  address: addr,
                  isDark: _d,
                  onEdit: () => _openForm(existing: addr),
                  onDelete: () => _confirmDelete(addr),
                  onSetDefault: () => context
                      .read<ProfileProvider>()
                      .setDefaultAddress(addr.id),
                );
              },
            ),
    );
  }

  Widget _emptyState() => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: _bgCard,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _border),
            ),
            child: Icon(Icons.location_off_outlined, size: 44, color: _txtMut),
          ),
          const SizedBox(height: 20),
          Text('No addresses saved', style: AppTextStyles.heading(_d)),
          const SizedBox(height: 8),
          Text(
            'Add a delivery address to speed up checkout.',
            style: AppTextStyles.bodyMd(_d).copyWith(color: _txtSec),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => _openForm(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text('Add Address', style: AppTextStyles.button),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ─── Address Card ─────────────────────────────────────────────

class _AddressCard extends StatelessWidget {
  final AddressModel address;
  final bool isDark;
  final VoidCallback onEdit, onDelete, onSetDefault;

  const _AddressCard({
    required this.address,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  Color get _bgCard => isDark ? AppColorsDark.bgCard : AppColorsLight.bgCard;


  Color get _border => isDark ? AppColorsDark.border : AppColorsLight.border;

  Color get _txtSec =>
      isDark ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;

  Color get _txtMut =>
      isDark ? AppColorsDark.textMuted : AppColorsLight.textMuted;

  Color _accent(String lbl) {
    switch (lbl.toLowerCase()) {
      case 'home':
        return AppColorsDark.success;
      case 'work':
        return AppColorsDark.info;
      default:
        return AppColorsDark.warning;
    }
  }

  IconData _icon(String lbl) {
    switch (lbl.toLowerCase()) {
      case 'home':
        return Icons.home_outlined;
      case 'work':
        return Icons.business_outlined;
      default:
        return Icons.location_on_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accent(address.label);
    final isDefault = address.isDefault;

    return Container(
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDefault ? AppColors.primary.withValues(alpha: 0.45) : _border,
          width: isDefault ? 1.5 : 1,
        ),
        boxShadow: isDefault
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.07),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: accent.withValues(alpha: 0.28)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_icon(address.label), size: 12, color: accent),
                      const SizedBox(width: 5),
                      Text(
                        address.label,
                        style: TextStyle(
                          fontFamily: 'Syne',
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'DEFAULT',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w800,
                        fontSize: 9,
                        color: AppColors.primary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                const Spacer(),
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  color: _bgCard,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: _border),
                  ),
                  icon: Icon(Icons.more_vert_rounded, size: 20, color: _txtSec),
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'delete') onDelete();
                    if (v == 'default') onSetDefault();
                  },
                  itemBuilder: (_) => [
                    if (!isDefault)
                      _mi(
                        isDark,
                        'default',
                        Icons.check_circle_outline,
                        'Set as Default',
                        AppColors.primary,
                      ),
                    _mi(isDark, 'edit', Icons.edit_outlined, 'Edit', _txtSec),
                    _mi(
                      isDark,
                      'delete',
                      Icons.delete_outline_rounded,
                      'Delete',
                      AppColorsDark.error,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Name + phone
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Row(
              children: [
                Text(
                  address.fullName,
                  style: AppTextStyles.headingSm(isDark).copyWith(fontSize: 14),
                ),
                const SizedBox(width: 10),
                Text(
                  address.phone,
                  style: AppTextStyles.mono(
                    isDark,
                  ).copyWith(fontSize: 11, color: _txtSec),
                ),
              ],
            ),
          ),
          // Address
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 7, 14, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.location_on_outlined,
                    size: 13,
                    color: _txtMut,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    [
                      address.line1,
                      if (address.line2 != null && address.line2!.isNotEmpty)
                        address.line2!,
                      '${address.city}, ${address.state} – ${address.pincode}',
                    ].join(', '),
                    style: AppTextStyles.bodyMd(
                      isDark,
                    ).copyWith(color: _txtSec, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          // Bottom strip
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: _border)),
            ),
            child: Row(
              children: [
                _stripBtn('Edit', Icons.edit_outlined, _txtSec, onEdit),
                Container(width: 1, height: 36, color: _border),
                isDefault
                    ? Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Default',
                              style: AppTextStyles.labelSm(
                                isDark,
                              ).copyWith(color: AppColors.primary),
                            ),
                          ],
                        ),
                      )
                    : _stripBtn(
                        'Set Default',
                        Icons.check_circle_outline,
                        AppColors.primary,
                        onSetDefault,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stripBtn(String label, IconData icon, Color c, VoidCallback onTap) =>
      Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14, color: c),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: AppTextStyles.labelSm(isDark).copyWith(color: c),
                ),
              ],
            ),
          ),
        ),
      );

  PopupMenuItem<String> _mi(
    bool isDark,
    String value,
    IconData icon,
    String label,
    Color color,
  ) => PopupMenuItem(
    value: value,
    child: Row(
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 10),
        Text(
          label,
          style: AppTextStyles.bodyMd(isDark).copyWith(
            color: isDark
                ? AppColorsDark.textPrimary
                : AppColorsLight.textPrimary,
          ),
        ),
      ],
    ),
  );
}

// ─── Address Form Sheet ───────────────────────────────────────

class _AddressFormSheet extends StatefulWidget {
  final AddressModel? existing;
  final bool isDark;

  const _AddressFormSheet({this.existing, required this.isDark});

  @override
  State<_AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<_AddressFormSheet> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _name, _phone, _l1, _l2, _city, _pin;
  late String _label, _state;
  late bool _isDefault;

  bool get _isEdit => widget.existing != null;

  bool get _d => widget.isDark;

  Color get _bgCard => _d ? AppColorsDark.bgCard : AppColorsLight.bgCard;

  Color get _bgInput => _d ? AppColorsDark.bgInput : AppColorsLight.bgInput;

  Color get _border => _d ? AppColorsDark.border : AppColorsLight.border;

  Color get _txtPri =>
      _d ? AppColorsDark.textPrimary : AppColorsLight.textPrimary;

  Color get _txtSec =>
      _d ? AppColorsDark.textSecondary : AppColorsLight.textSecondary;

  Color get _txtMut => _d ? AppColorsDark.textMuted : AppColorsLight.textMuted;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.fullName ?? '');
    _phone = TextEditingController(text: e?.phone ?? '');
    _l1 = TextEditingController(text: e?.line1 ?? '');
    _l2 = TextEditingController(text: e?.line2 ?? '');
    _city = TextEditingController(text: e?.city ?? '');
    _pin = TextEditingController(text: e?.pincode ?? '');
    _label = e?.label ?? 'Home';
    _state = e?.state ?? 'Maharashtra';
    _isDefault = e?.isDefault ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _l1.dispose();
    _l2.dispose();
    _city.dispose();
    _pin.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_key.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final ok = await context.read<ProfileProvider>().addAddress({
      'label': _label,
      'fullName': _name.text.trim(),
      'phone': _phone.text.trim(),
      'line1': _l1.text.trim(),
      'line2': _l2.text.trim(),
      'city': _city.text.trim(),
      'state': _state,
      'pincode': _pin.text.trim(),
      'isDefault': _isDefault,
    });
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
                _isEdit ? 'Address updated' : 'Address added',
                style: AppTextStyles.bodyMd(_d),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
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
        initialChildSize: 0.93,
        maxChildSize: 0.97,
        builder: (_, sc) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle + title
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
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isEdit ? 'Edit Address' : 'Add New Address',
                              style: AppTextStyles.heading(_d),
                            ),
                            Text(
                              _isEdit
                                  ? 'Update your delivery address'
                                  : 'Fill in the address details',
                              style: AppTextStyles.bodyXs(
                                _d,
                              ).copyWith(color: _txtSec),
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
                ],
              ),
            ),
            // Form
            Expanded(
              child: Form(
                key: _key,
                child: ListView(
                  controller: sc,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    _lbl('Address Type'),
                    const SizedBox(height: 8),
                    _typeRow(),
                    const SizedBox(height: 18),
                    _lbl('Full Name'),
                    const SizedBox(height: 7),
                    _tf(
                      _name,
                      'Recipient\'s full name',
                      Icons.person_outline_rounded,
                      cap: TextCapitalization.words,
                      val: (v) => v!.trim().isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 14),
                    _lbl('Mobile Number'),
                    const SizedBox(height: 7),
                    _tf(
                      _phone,
                      '10-digit mobile number',
                      Icons.phone_outlined,
                      kb: TextInputType.phone,
                      fmt: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      val: (v) {
                        if (v!.trim().isEmpty) return 'Required';
                        if (v.trim().length != 10) {
                          return 'Enter 10-digit number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _lbl('Address Line 1'),
                    const SizedBox(height: 7),
                    _tf(
                      _l1,
                      'Flat / House No., Building, Street',
                      Icons.home_outlined,
                      cap: TextCapitalization.words,
                      val: (v) => v!.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    _lbl('Address Line 2  (optional)'),
                    const SizedBox(height: 7),
                    _tf(
                      _l2,
                      'Landmark, Colony, Area',
                      Icons.place_outlined,
                      cap: TextCapitalization.words,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _lbl('City'),
                              const SizedBox(height: 7),
                              _tf(
                                _city,
                                'City',
                                Icons.location_city_outlined,
                                cap: TextCapitalization.words,
                                val: (v) =>
                                    v!.trim().isEmpty ? 'Required' : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _lbl('Pincode'),
                              const SizedBox(height: 7),
                              _tf(
                                _pin,
                                '6 digits',
                                Icons.pin_drop_outlined,
                                kb: TextInputType.number,
                                fmt: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(6),
                                ],
                                val: (v) {
                                  if (v!.trim().isEmpty) return 'Required';
                                  if (v.trim().length != 6) {
                                    return '6 digits only';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _lbl('State'),
                    const SizedBox(height: 7),
                    _dropdown(),
                    const SizedBox(height: 16),
                    _defaultToggle(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Save
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
                    onPressed: saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
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
                        : Text(
                            _isEdit ? 'Save Changes' : 'Add Address',
                            style: AppTextStyles.button,
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

  Widget _typeRow() {
    const types = [
      ('Home', Icons.home_rounded),
      ('Work', Icons.business_rounded),
      ('Other', Icons.location_on_rounded),
    ];
    return Row(
      children: types.map((t) {
        final (label, icon) = t;
        final sel = _label == label;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: label != 'Other' ? 10 : 0),
            child: GestureDetector(
              onTap: () => setState(() => _label = label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: sel ? AppColors.primary.withValues(alpha: 0.1) : _bgInput,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: sel ? AppColors.primary.withValues(alpha: 0.5) : _border,
                    width: sel ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      icon,
                      size: 22,
                      color: sel ? AppColors.primary : _txtSec,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: sel ? AppColors.primary : _txtSec,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _dropdown() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
    decoration: BoxDecoration(
      color: _bgInput,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _border),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _state,
        isExpanded: true,
        dropdownColor: _d ? AppColorsDark.bgCard : AppColorsLight.bgCard,
        style: AppTextStyles.bodyMd(_d),
        icon: Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: _txtSec),
        onChanged: (v) => setState(() => _state = v!),
        items: _kIndianStates
            .map(
              (s) => DropdownMenuItem(
                value: s,
                child: Text(s, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
      ),
    ),
  );

  Widget _defaultToggle() => GestureDetector(
    onTap: () => setState(() => _isDefault = !_isDefault),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _isDefault ? AppColors.primary.withValues(alpha: 0.07) : _bgInput,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isDefault ? AppColors.primary.withValues(alpha: 0.35) : _border,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Use as default address',
                  style: AppTextStyles.labelMd(
                    _d,
                  ).copyWith(color: _isDefault ? AppColors.primary : _txtPri),
                ),
                const SizedBox(height: 2),
                Text(
                  'Auto-selected at checkout',
                  style: AppTextStyles.bodyXs(_d).copyWith(color: _txtSec),
                ),
              ],
            ),
          ),
          _ToggleSwitch(
            value: _isDefault,
            isDark: _d,
            onChange: (v) => setState(() => _isDefault = v),
          ),
        ],
      ),
    ),
  );

  Widget _lbl(String t) => Text(
    t,
    style: AppTextStyles.labelSm(_d).copyWith(fontSize: 12, letterSpacing: 0.2),
  );

  Widget _tf(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    TextInputType? kb,
    TextCapitalization cap = TextCapitalization.none,
    List<TextInputFormatter>? fmt,
    String? Function(String?)? val,
    int lines = 1,
  }) => TextFormField(
    controller: ctrl,
    keyboardType: kb,
    textCapitalization: cap,
    inputFormatters: fmt,
    validator: val,
    maxLines: lines,
    style: AppTextStyles.bodyMd(_d),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyMd(_d).copyWith(color: _txtMut),
      filled: true,
      fillColor: _bgInput,
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 14, right: 10),
        child: Icon(icon, size: 18, color: _txtMut),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColorsDark.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColorsDark.error, width: 1.5),
      ),
      errorStyle: const TextStyle(
        fontFamily: 'DMSans',
        fontSize: 11,
        color: AppColorsDark.error,
      ),
    ),
  );
}

// ─── Toggle Switch ────────────────────────────────────────────

class _ToggleSwitch extends StatelessWidget {
  final bool value, isDark;
  final ValueChanged<bool> onChange;

  const _ToggleSwitch({
    required this.value,
    required this.isDark,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput;
    final bd = isDark ? AppColorsDark.border : AppColorsLight.border;
    return GestureDetector(
      onTap: () => onChange(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 46,
        height: 26,
        decoration: BoxDecoration(
          color: value ? AppColors.primary : bg,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: value ? AppColors.primary : bd),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              top: 3,
              left: value ? 23 : 3,
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
    );
  }
}
