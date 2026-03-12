import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class B2bRegisterScreen extends StatefulWidget {
  const B2bRegisterScreen({super.key});

  @override
  State<B2bRegisterScreen> createState() => _B2bRegisterScreenState();
}

class _B2bRegisterScreenState extends State<B2bRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _businessNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _gstCtrl = TextEditingController();
  final _contactNameCtrl = TextEditingController();
  final _businessAddressCtrl = TextEditingController();
  final _panNumberCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  Future<void> _createDealerAccount() async {
    if (!_formKey.currentState!.validate()) return;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final auth = context.read<AuthProvider>();

    if (auth.isLoading) return;
    auth.clearError();
    await auth.applyForDealer(
      businessName: _businessNameCtrl.text.trim(),
      gstNumber: _gstCtrl.text.trim(),
      contactName: _contactNameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      address: _businessAddressCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      panNumber: _panNumberCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      state: _stateCtrl.text.trim(),
      pincode: _pincodeCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
    );
    if (!mounted) return;
    if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error!),
          backgroundColor: isDarkMode
              ? AppColorsDark.error
              : AppColorsLight.error,
        ),
      );
      auth.clearError();
      return;
    }
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isLoading = context.select<AuthProvider, bool>((a) => a.isLoading);

    return Scaffold(
      backgroundColor: isDarkMode ? AppColorsDark.bg : AppColorsLight.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Dealer Application',
          style: AppTextStyles.headingSm(isDarkMode),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'B2B Dealer Account',
                style: AppTextStyles.displayMd(isDarkMode),
              ),
              const SizedBox(height: 8),
              Text(
                'Get trade pricing, credit terms & GST invoices',
                style: AppTextStyles.bodyMd(isDarkMode).copyWith(
                  color: isDarkMode
                      ? AppColorsDark.textSecondary
                      : AppColorsLight.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppColorsDark.warning.withValues(alpha: 0.08)
                      : AppColorsLight.warning.withValues(alpha: 0.08),
                  border: Border.all(
                    color: isDarkMode
                        ? AppColorsDark.warning.withValues(alpha: 0.2)
                        : AppColorsLight.warning.withValues(alpha: 0.2),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.bolt,
                      color: isDarkMode
                          ? AppColorsDark.warning
                          : AppColorsLight.warning,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Trade prices · Net-30 credit · Bulk orders up to 500 items · Dedicated support',
                        style: AppTextStyles.bodySm(isDarkMode).copyWith(
                          color: isDarkMode
                              ? AppColorsDark.warning
                              : AppColorsLight.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AppTextField(
                controller: _businessNameCtrl,
                label: 'Business Name',
                hint: 'Rajesh Auto Works Pvt Ltd',
                prefixIcon: Icons.business_outlined,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _gstCtrl,
                label: 'GST Number',
                hint: '22AAAAA0000A1Z5',
                prefixIcon: Icons.receipt_outlined,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _panNumberCtrl,
                label: 'Pan Card Number',
                hint: 'ABCDE1234F',
                prefixIcon: Icons.receipt_outlined,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _contactNameCtrl,
                label: 'Contact Person',
                hint: 'Rajesh Kumar',
                prefixIcon: Icons.person_outlined,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _phoneCtrl,
                label: 'Phone Number',
                hint: '+91 98765 43210',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _emailCtrl,
                label: 'Email',
                hint: 'rajesh@gmail.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _businessAddressCtrl,
                label: 'Business Address',
                hint: 'Shop 12, Auto Market, Pune',
                prefixIcon: Icons.location_on_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _cityCtrl,
                label: 'City',
                hint: 'Pune',
                prefixIcon: Icons.location_city_outlined,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _stateCtrl,
                label: 'State',
                hint: 'Maharashtra',
                prefixIcon: Icons.map_outlined,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _pincodeCtrl,
                label: 'Pincode',
                hint: '411001',
                prefixIcon: Icons.pin_drop_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _passwordCtrl,
                label: 'Password',
                hint: '••••••••',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 28),
              AppButton(
                label: 'Apply for Dealer Account',
                backgroundColor: isDarkMode
                    ? AppColorsDark.warning
                    : AppColorsLight.warning,
                textColor: Colors.black,
                onTap: () => _createDealerAccount(),
                isLoading: isLoading,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
