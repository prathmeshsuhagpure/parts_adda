import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../auth/domain/models/user_model.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;

  String _gender = 'Male';
  DateTime? _dob;
  bool _hasChanges = false;
  String _initName = '';
  String _initEmail = '';

  // ── Theme helpers ─────────────────────────────────────────
  bool get _d => Theme.of(context).brightness == Brightness.dark;

  Color get _bg => _d ? AppColorsDark.bg : AppColorsLight.bg;

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
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<ProfileProvider>();

      if (provider.user == null) {
        await provider.loadProfile();
      }
      _prefill();
    });
  }

  void _prefill() {
    final u = context.read<ProfileProvider>().user;
    if (u == null) return;
    _nameCtrl.text = u.name;
    _emailCtrl.text = u.email ?? '';
    _phoneCtrl.text = u.phone;
    _initName = u.name;
    _initEmail = u.email ?? '';
    if (u.gender != null) {
      switch (u.gender!) {
        case Gender.male:
          _gender = "Male";
          break;
        case Gender.female:
          _gender = "Female";
          break;
        case Gender.other:
          _gender = "Other";
          break;
      }
    }
    if (u.dateOfBirth != null) {
      _dob = u.dateOfBirth;
    }
    _nameCtrl.addListener(_checkChanges);
    _emailCtrl.addListener(_checkChanges);
    setState(() {});
  }

  void _checkChanges() {
    final u = context.read<ProfileProvider>().user;
    if (u == null) return;

    setState(() {
      _hasChanges =
          _nameCtrl.text.trim() != _initName ||
          _emailCtrl.text.trim() != _initEmail ||
          _gender != (u.gender ?? 'Male') ||
          (_dob?.toIso8601String() ?? '') != (u.dateOfBirth ?? '');
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final ok = await context.read<ProfileProvider>().updateProfile(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      gender: _gender,
      dateOfBirth: _dob != null ? _dob!.toIso8601String() : null,
      avatar: null,
    );
    if (!mounted) return;
    if (ok) {
      _showSnack('Profile updated successfully', success: true);
      context.pop();
    } else {
      _showSnack('Failed to update. Please try again.');
    }
  }

  void _showSnack(
    String msg, {
    bool success = false,
  }) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: _bgCard,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Row(
        children: [
          Icon(
            success ? Icons.check_circle_rounded : Icons.error_outline_rounded,
            color: success ? AppColorsDark.success : AppColorsDark.error,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(msg, style: AppTextStyles.bodyMd(_d))),
        ],
      ),
      duration: const Duration(seconds: 2),
    ),
  );

  void _onBack() {
    if (_hasChanges) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: _bgCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Discard changes?', style: AppTextStyles.headingSm(_d)),
          content: Text(
            'You have unsaved changes that will be lost.',
            style: AppTextStyles.bodyMd(_d).copyWith(color: _txtSec),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Keep editing',
                style: AppTextStyles.labelMd(_d).copyWith(color: _txtSec),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.pop();
              },
              child: Text(
                'Discard',
                style: AppTextStyles.labelMd(
                  _d,
                ).copyWith(color: AppColorsDark.error),
              ),
            ),
          ],
        ),
      );
    } else {
      context.pop();
    }
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(1995, 1, 1),
      firstDate: DateTime(1940),
      lastDate: DateTime(now.year - 16, now.month, now.day),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: _bgCard,
            onSurface: _txtPri,
          ),
          dialogTheme: DialogThemeData(backgroundColor: _bgCard),
        ),
        child: child!,
      ),
    );
    if (result != null) {
      setState(() {
        _dob = result;
        _hasChanges = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    return Scaffold(
      backgroundColor: _bg,
      appBar: _appBar(provider),
      body: provider.user == null
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            )
          : _body(provider),
    );
  }

  AppBar _appBar(ProfileProvider provider) => AppBar(
    backgroundColor: _bg,
    elevation: 0,
    scrolledUnderElevation: 0,
    leading: IconButton(
      icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _txtPri),
      onPressed: _onBack,
    ),
    title: Text('Edit Profile', style: AppTextStyles.heading(_d)),
    actions: [
      if (provider.isSaving)
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          ),
        )
      else
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: AnimatedOpacity(
            opacity: _hasChanges ? 1.0 : 0.35,
            duration: const Duration(milliseconds: 200),
            child: GestureDetector(
              onTap: _hasChanges ? _save : null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: _hasChanges
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Save', style: AppTextStyles.buttonSm),
              ),
            ),
          ),
        ),
    ],
  );

  Widget _body(ProfileProvider provider) {
    final user = provider.user!;
    final initials = user.name
        .trim()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    return Form(
      key: _formKey,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          // ── Avatar hero ────────────────────────────────────
          _buildAvatarSection(user, initials),

          // ── Form ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Personal info
                _sectionHeader('Personal Information'),
                const SizedBox(height: 14),

                _label('Full Name'),
                const SizedBox(height: 6),
                _textField(
                  ctrl: _nameCtrl,
                  focus: _nameFocus,
                  hint: 'Your full name',
                  icon: Icons.person_outline_rounded,
                  capitalization: TextCapitalization.words,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Name is required';
                    }
                    if (v.trim().length < 2) return 'Name is too short';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                _label('Email Address'),
                const SizedBox(height: 6),
                _textField(
                  ctrl: _emailCtrl,
                  focus: _emailFocus,
                  hint: 'your@email.com (optional)',
                  icon: Icons.mail_outline_rounded,
                  keyboard: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final ok = RegExp(
                      r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,}$',
                    ).hasMatch(v.trim());
                    return ok ? null : 'Enter a valid email address';
                  },
                ),
                const SizedBox(height: 14),

                _label('Mobile Number'),
                const SizedBox(height: 6),
                _readOnlyField(
                  value: user.phone,
                  icon: Icons.phone_outlined,
                  actionLabel: 'Change',
                  onAction: _showChangePhone,
                ),
                const SizedBox(height: 28),

                // Additional details
                _sectionHeader('Additional Details'),
                const SizedBox(height: 14),

                _label('Gender'),
                const SizedBox(height: 8),
                _genderRow(),
                const SizedBox(height: 14),

                _label('Date of Birth'),
                const SizedBox(height: 6),
                _dobField(),
                const SizedBox(height: 14),

                _label('Account Type'),
                const SizedBox(height: 6),
                _readOnlyField(
                  value: _roleLabel(user.role),
                  icon: Icons.badge_outlined,
                  trailing: user.isVerified ? _verifiedBadge() : null,
                ),
                const SizedBox(height: 32),

                // Save CTA
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: (provider.isSaving || !_hasChanges)
                        ? null
                        : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.primary.withValues(
                        alpha: 0.35,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: provider.isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _hasChanges ? 'Save Changes' : 'No Changes',
                            style: AppTextStyles.button,
                          ),
                  ),
                ),

                if (!_hasChanges) ...[
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Modify any field above to save',
                      style: AppTextStyles.bodyXs(_d).copyWith(color: _txtMut),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Avatar section ────────────────────────────────────────
  Widget _buildAvatarSection(user, String initials) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: _bgCard,
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Avatar circle
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.9),
                      AppColors.primaryDark,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.28),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: user.avatar != null
                    ? ClipOval(
                        child: Image.network(user.avatar!, fit: BoxFit.cover),
                      )
                    : Center(
                        child: Text(
                          initials,
                          style: const TextStyle(
                            fontFamily: 'Syne',
                            fontWeight: FontWeight.w800,
                            fontSize: 34,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
              // Camera button
              Positioned(
                bottom: 2,
                right: 2,
                child: GestureDetector(
                  onTap: _showAvatarPicker,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _bgCard,
                      shape: BoxShape.circle,
                      border: Border.all(color: _border, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(user.name, style: AppTextStyles.displaySm(_d)),
          const SizedBox(height: 4),
          Text(
            user.phone,
            style: AppTextStyles.bodyMd(_d).copyWith(color: _txtSec),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _showAvatarPicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Text(
                'Change Photo',
                style: AppTextStyles.labelSm(
                  _d,
                ).copyWith(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Gender row ────────────────────────────────────────────
  Widget _genderRow() {
    const options = [
      ('Male', Icons.male_rounded),
      ('Female', Icons.female_rounded),
      ('Other', Icons.transgender_rounded),
    ];
    return Row(
      children: options.map((opt) {
        final (label, icon) = opt;
        final sel = _gender == label;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: label != 'Other' ? 8 : 0),
            child: GestureDetector(
              onTap: () => setState(() {
                _gender = label;
                _hasChanges = true;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: sel
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : _bgInput,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: sel
                        ? AppColors.primary.withValues(alpha: 0.5)
                        : _border,
                    width: sel ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: sel ? AppColors.primary : _txtSec,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontWeight: FontWeight.w600,
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

  // ── DOB field ─────────────────────────────────────────────
  Widget _dobField() {
    final display = _dob != null
        ? '${_dob!.day.toString().padLeft(2, '0')} / '
              '${_dob!.month.toString().padLeft(2, '0')} / '
              '${_dob!.year}'
        : 'DD / MM / YYYY';
    return GestureDetector(
      onTap: _pickDob,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _bgInput,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Icon(Icons.cake_outlined, size: 18, color: _txtMut),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                display,
                style: AppTextStyles.bodyMd(
                  _d,
                ).copyWith(color: _dob != null ? _txtPri : _txtMut),
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: _txtMut),
          ],
        ),
      ),
    );
  }

  // ── Read-only field ───────────────────────────────────────
  Widget _readOnlyField({
    required String value,
    required IconData icon,
    String? actionLabel,
    VoidCallback? onAction,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: _bgInput,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _txtMut),
          const SizedBox(width: 10),
          Expanded(child: Text(value, style: AppTextStyles.bodyMd(_d))),
          if (trailing != null) trailing,
          if (actionLabel != null && onAction != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel,
                style: AppTextStyles.labelSm(
                  _d,
                ).copyWith(color: AppColors.primary, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  // ── Section header ────────────────────────────────────────
  Widget _sectionHeader(String title) => Row(
    children: [
      Container(
        width: 3,
        height: 16,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 8),
      Text(title, style: AppTextStyles.headingSm(_d)),
    ],
  );

  // ── Field label ───────────────────────────────────────────
  Widget _label(String text) => Text(
    text,
    style: AppTextStyles.labelSm(_d).copyWith(fontSize: 12, letterSpacing: 0.3),
  );

  // ── Text field ────────────────────────────────────────────
  Widget _textField({
    required TextEditingController ctrl,
    required FocusNode focus,
    required String hint,
    required IconData icon,
    TextInputType? keyboard,
    TextCapitalization capitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      focusNode: focus,
      keyboardType: keyboard,
      textCapitalization: capitalization,
      validator: validator,
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
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
        errorStyle: TextStyle(
          fontFamily: 'DMSans',
          fontSize: 11,
          color: AppColorsDark.error,
        ),
      ),
    );
  }

  // ── Verified badge ────────────────────────────────────────
  Widget _verifiedBadge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: AppColorsDark.success.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: AppColorsDark.success.withValues(alpha: 0.25)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.verified_rounded,
          size: 11,
          color: AppColorsDark.success,
        ),
        const SizedBox(width: 3),
        Text(
          'Verified',
          style: TextStyle(
            fontFamily: 'Syne',
            fontWeight: FontWeight.w700,
            fontSize: 10,
            color: AppColorsDark.success,
          ),
        ),
      ],
    ),
  );

  String _roleLabel(dynamic role) {
    switch (role.toString()) {
      case 'UserRole.dealer':
        return 'Dealer / Seller';
      case 'UserRole.vendor':
        return 'Vendor';
      case 'UserRole.admin':
        return 'Administrator';
      default:
        return 'Customer';
    }
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AvatarPickerSheet(isDark: _d),
    );
  }

  void _showChangePhone() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Change Mobile Number', style: AppTextStyles.headingSm(_d)),
        content: Text(
          'To change your mobile number, you\'ll receive an OTP '
          'to verify ownership of the new number.',
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
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Proceed',
              style: AppTextStyles.labelMd(
                _d,
              ).copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Avatar picker bottom sheet ──────────────────────────────

class _AvatarPickerSheet extends StatelessWidget {
  final bool isDark;

  const _AvatarPickerSheet({required this.isDark});

  Color get _bgInput => isDark ? AppColorsDark.bgInput : AppColorsLight.bgInput;

  Color get _border => isDark ? AppColorsDark.border : AppColorsLight.border;

  Color get _txtPri =>
      isDark ? AppColorsDark.textPrimary : AppColorsLight.textPrimary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
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
          Text('Update Profile Photo', style: AppTextStyles.heading(isDark)),
          const SizedBox(height: 20),
          _PickerOption(
            icon: Icons.camera_alt_outlined,
            label: 'Take a Photo',
            isDark: isDark,
            bgInput: _bgInput,
            border: _border,
            txtPri: _txtPri,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 10),
          _PickerOption(
            icon: Icons.photo_library_outlined,
            label: 'Choose from Gallery',
            isDark: isDark,
            bgInput: _bgInput,
            border: _border,
            txtPri: _txtPri,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 10),
          _PickerOption(
            icon: Icons.delete_outline_rounded,
            label: 'Remove Current Photo',
            isDark: isDark,
            bgInput: _bgInput,
            border: _border,
            txtPri: _txtPri,
            color: AppColorsDark.error,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _PickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final Color bgInput, border, txtPri;
  final Color? color;
  final VoidCallback onTap;

  const _PickerOption({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.bgInput,
    required this.border,
    required this.txtPri,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? txtPri;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgInput,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: c),
            const SizedBox(width: 14),
            Text(label, style: AppTextStyles.bodyMd(isDark).copyWith(color: c)),
          ],
        ),
      ),
    );
  }
}
