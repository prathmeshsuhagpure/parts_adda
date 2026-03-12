import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _identifierCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(bool isDarkMode) async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    if (auth.isLoading) return;
    auth.clearError();
    await auth.login(
      phoneOrEmail: _identifierCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
    if (!mounted) return;
    if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error!),
          backgroundColor:
          isDarkMode ? AppColorsDark.error : AppColorsLight.error,
        ),
      );
      auth.clearError();
      return;
    }
    if (auth.status == AuthStatus.authenticated) {
      final role = auth.user?.role.name;
      if (role == "dealer") {
        context.go(AppRoutes.dealerHome);
      } else {
        context.go(AppRoutes.home);
      }
    }
  }

  void _skipLogin() => context.go(AppRoutes.home);

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<AuthProvider, bool>((a) => a.isLoading);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bg = isDarkMode ? AppColorsDark.bg : AppColorsLight.bg;
    final textMuted =
    isDarkMode ? AppColorsDark.textMuted : AppColorsLight.textMuted;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Column(
              children: [
                // ── Top bar: logo + skip
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Center(
                              child: Text(
                                'PA',
                                style: TextStyle(
                                  fontFamily: 'Syne',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          RichText(
                            text: TextSpan(
                              text: 'Parts',
                              style: AppTextStyles.heading(isDarkMode)
                                  .copyWith(fontSize: 18),
                              children: [
                                TextSpan(
                                  text: 'Adda',
                                  style:
                                  TextStyle(color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Scrollable form
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),

                          // Headline
                          Text(
                            'Welcome\nBack 👋',
                            style: AppTextStyles.displayMd(isDarkMode),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign in to access 5M+ parts\nwith guaranteed compatibility',
                            style: AppTextStyles.bodyMd(isDarkMode).copyWith(
                              color: isDarkMode
                                  ? AppColorsDark.textSecondary
                                  : AppColorsLight.textSecondary,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Fields
                          AppTextField(
                            controller: _identifierCtrl,
                            label: 'Phone or Email',
                            hint: '+91 98765 43210',
                            prefixIcon: Icons.phone_android_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _passwordCtrl,
                            label: 'Password',
                            hint: '••••••••',
                            prefixIcon: Icons.lock_outline,
                            obscureText: _obscure,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: textMuted,
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                            validator: (v) =>
                            (v == null || v.length < 6)
                                ? 'Min 6 characters'
                                : null,
                          ),
                          const SizedBox(height: 8),

                          // Forgot password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => context.push(
                                AppRoutes.otp,
                                extra: _identifierCtrl.text.trim(),
                              ),
                              child: Text(
                                'Forgot Password?',
                                style: AppTextStyles.labelSm(isDarkMode)
                                    .copyWith(color: AppColors.primary),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Sign In button
                          AppButton(
                            label: 'Login',
                            onTap: () => _submit(isDarkMode),
                            isLoading: isLoading,
                            width: double.infinity,
                          ),
                          const SizedBox(height: 20),

                          // Divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: isDarkMode
                                      ? AppColorsDark.border
                                      : AppColorsLight.border,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12),
                                child: Text(
                                  'or continue with',
                                  style: AppTextStyles.bodyXs(isDarkMode),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: isDarkMode
                                      ? AppColorsDark.border
                                      : AppColorsLight.border,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Google button
                          _SocialButton(
                            icon: Icons.g_mobiledata_rounded,
                            label: 'Continue with Google',
                            onTap: () {},
                          ),
                          const SizedBox(height: 16),

                          // Browse as guest — prominent secondary CTA
                          _GuestButton(
                            isDarkMode: isDarkMode,
                            onTap: _skipLogin,
                          ),
                          const SizedBox(height: 28),

                          // Sign up link
                          Center(
                            child: GestureDetector(
                              onTap: () => context.push(AppRoutes.register),
                              child: RichText(
                                text: TextSpan(
                                  text: "Don't have an account? ",
                                  style: AppTextStyles.bodyMd(isDarkMode)
                                      .copyWith(color: textMuted),
                                  children: [
                                    TextSpan(
                                      text: 'Sign Up',
                                      style:
                                      AppTextStyles.labelMd(isDarkMode)
                                          .copyWith(
                                          color: AppColors.primary),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Guest / Browse button ────────────────────────────────────────────────────

class _GuestButton extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onTap;

  const _GuestButton({required this.isDarkMode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.buttonRadius,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDarkMode
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.primary.withValues(alpha: 0.06),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.25),
          ),
          borderRadius: AppRadius.buttonRadius,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront_outlined,
                color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Text(
              'Browse as Guest',
              style: AppTextStyles.labelMd(isDarkMode)
                  .copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Social button ────────────────────────────────────────────────────────────

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.buttonRadius,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColorsDark.bgCard : AppColorsLight.bgCard,
          border: Border.all(
            color: isDarkMode ? AppColorsDark.border : AppColorsLight.border,
          ),
          borderRadius: AppRadius.buttonRadius,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isDarkMode
                  ? AppColorsDark.textSecondary
                  : AppColorsLight.textSecondary,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(label, style: AppTextStyles.labelMd(isDarkMode)),
          ],
        ),
      ),
    );
  }
}