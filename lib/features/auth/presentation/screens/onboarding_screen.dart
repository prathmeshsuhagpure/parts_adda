import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../providers/auth_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageCtrl = PageController();
  int _page = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'emoji': '🔍',
      'title': 'Find Any Part\nFor Any Car',
      'sub':
          'Search millions of auto parts by make, model, year, or OEM number.',
      'color': 0xFF1a0808,
    },
    {
      'emoji': '🚚',
      'title': 'Fast Delivery\nAcross India',
      'sub':
          'Track shipments in real time and get parts delivered in 2-4 days.',
      'color': 0xFF0a1a10,
    },
    {
      'emoji': '🏢',
      'title': 'Dealer & Workshop\nPricing',
      'sub':
          'Special trade pricing, GST invoices, and bulk ordering for garages.',
      'color': 0xFF0a0a1a,
    },
  ];

  Future<void> _finishOnboarding() async {
    final auth = context.read<AuthProvider>();

    await auth.setOnboardingSeen(true);

    if (!context.mounted) return;

    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? AppColorsDark.bg : AppColorsLight.bg,
      body: SafeArea(
        child: Column(
          children: [
            /// Skip Button
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16, top: 8),
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: const Text("Skip"),
                ),
              ),
            ),

            /// Pages
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: _pages.length,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) {
                  final p = _pages[i];

                  return Column(
                    children: [
                      Expanded(
                        child: Container(
                          color: Color(p['color']),
                          child: Center(
                            child: Text(
                              p['emoji'],
                              style: const TextStyle(fontSize: 90),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '0${i + 1} / 03',
                              style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 2,
                                color: isDarkMode
                                    ? AppColorsDark.textMuted
                                    : AppColorsLight.textMuted,
                              ),
                            ),

                            const SizedBox(height: 12),

                            Text(
                              p['title'],
                              style: TextStyle(
                                fontFamily: 'Syne',
                                fontWeight: FontWeight.w800,
                                fontSize: 26,
                                color: isDarkMode
                                    ? AppColorsDark.textPrimary
                                    : AppColorsLight.textPrimary,
                                height: 1.2,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              p['sub'],
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode
                                    ? AppColorsDark.textSecondary
                                    : AppColorsLight.textSecondary,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            /// Bottom Controls
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  /// Page Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(
                          _pages.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 6),
                            width: _page == i ? 22 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _page == i
                                  ? (isDarkMode
                                        ? AppColors.primary
                                        : Colors.green)
                                  : (isDarkMode
                                        ? AppColorsDark.border
                                        : AppColorsLight.border),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),

                      /// Next / Get Started
                      _page < _pages.length - 1
                          ? AppButton(
                              label: "Next",
                              width: 120,
                              onTap: () {
                                _pageCtrl.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                            )
                          : AppButton(
                              label: "Get Started",
                              width: 160,
                              onTap: _finishOnboarding,
                            ),
                    ],
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
