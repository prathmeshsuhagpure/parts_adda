import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _role = 'customer';

  Future<void> _createAccount() async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    if (auth.isLoading) return;
    auth.clearError();
    await auth.register(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      role: _role,
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
        title: const Text('Create Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Join AutoParts',
                style: AppTextStyles.displayMd(isDarkMode),
              ),
              const SizedBox(height: 8),
              Text(
                'Millions of customers & workshops trust us',
                style: AppTextStyles.bodyMd(isDarkMode).copyWith(
                  color: isDarkMode
                      ? AppColorsDark.textSecondary
                      : AppColorsLight.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              AppTextField(
                controller: _nameCtrl,
                label: 'Full Name',
                hint: 'Rahul Sharma',
                prefixIcon: Icons.person_outline,
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
                label: 'Email (optional)',
                hint: 'rahul@email.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _passCtrl,
                label: 'Password',
                hint: '••••••••',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 20),
              Text('Account Type', style: AppTextStyles.labelSm(isDarkMode)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _role = 'customer'),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _role == 'customer'
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : (isDarkMode
                                    ? AppColorsDark.bgCard
                                    : AppColorsLight.bgCard),
                          border: Border.all(
                            color: _role == 'customer'
                                ? AppColors.primary
                                : AppColorsDark.border,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            const Text('👤', style: TextStyle(fontSize: 24)),
                            const SizedBox(height: 4),
                            Text(
                              'Customer',
                              style: AppTextStyles.labelMd(isDarkMode),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.push(AppRoutes.b2bRegister),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? AppColorsDark.bgCard
                              : AppColorsLight.bgCard,
                          border: Border.all(
                            color: isDarkMode
                                ? AppColorsDark.border
                                : AppColorsLight.border,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            const Text('🏢', style: TextStyle(fontSize: 24)),
                            const SizedBox(height: 4),
                            Text(
                              'Dealer / B2B',
                              style: AppTextStyles.labelMd(isDarkMode),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              AppButton(
                label: 'Create Account',
                onTap: () => _createAccount(),
                width: double.infinity,
                isLoading: isLoading,
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: AppTextStyles.bodyMd(isDarkMode).copyWith(
                        color: isDarkMode
                            ? AppColorsDark.textMuted
                            : AppColorsLight.textMuted,
                      ),
                      children: [
                        TextSpan(
                          text: 'Sign In',
                          style: AppTextStyles.labelMd(
                            isDarkMode,
                          ).copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
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
