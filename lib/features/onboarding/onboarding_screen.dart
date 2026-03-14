import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';

class _SlideData {
  final IconData icon;
  final String headline;
  final String body;

  const _SlideData({
    required this.icon,
    required this.headline,
    required this.body,
  });
}

const _slides = [
  _SlideData(
    icon: Icons.eco_rounded,
    headline: 'Clean Actions\nReal Rewards',
    body: 'Report waste, schedule pickups,\nand earn points for every action',
  ),
  _SlideData(
    icon: Icons.stars_rounded,
    headline: 'Earn Points\nRedeem Rewards',
    body: 'Convert your clean actions into\nreal monetary rewards',
  ),
  _SlideData(
    icon: Icons.public_rounded,
    headline: 'Track Your\nImpact',
    body: 'See your contribution to a\ncleaner world',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  double _pageOffset = 0.0;

  // Sine-wave float animation for icons
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();

    _pageController.addListener(() {
      setState(() {
        _pageOffset = _pageController.page ?? 0.0;
      });
    });

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(); // continuous cycle for sine wave
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  void _onSkip() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // --- PageView with parallax ---
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];

                  // Parallax: content moves at 0.7x page speed
                  final parallax = (_pageOffset - index) * size.width * 0.3;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Transform.translate(
                      offset: Offset(parallax, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // --- Floating icon in circle ---
                          AnimatedBuilder(
                            animation: _floatController,
                            builder: (context, child) {
                              // Sine wave: 8px amplitude
                              final dy = math.sin(
                                      _floatController.value * 2 * math.pi) *
                                  8.0;
                              return Transform.translate(
                                offset: Offset(0, dy),
                                child: child,
                              );
                            },
                            child: Container(
                              width: 260,
                              height: 260,
                              decoration: const BoxDecoration(
                                color: AppColors.surface3,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  slide.icon,
                                  size: 100,
                                  color: AppColors.neonLime,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 48),

                          // --- Headline (Bebas Neue 48sp) ---
                          Text(
                            slide.headline,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.bebasNeue(
                              fontSize: 48,
                              color: AppColors.textWhite,
                              height: 1.05,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // --- Body (DM Sans 15sp) ---
                          Text(
                            slide.body,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // --- Bottom nav: Skip | Dots | Next/Let's Begin ---
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip button (#5A5A5A)
                  GestureDetector(
                    onTap: _onSkip,
                    child: SizedBox(
                      width: 72,
                      child: Text(
                        'Skip',
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  // Pill indicators
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(_slides.length, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.neonLime
                              : AppColors.borderDefault,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),

                  // Next / Let's Begin CTA pill button
                  GestureDetector(
                    onTap: _onNext,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.neonLime,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isLastPage ? "Let's Begin" : 'Next',
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              color: AppColors.textOnLime,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (isLastPage) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.arrow_forward,
                              size: 18,
                              color: AppColors.textOnLime,
                            ),
                          ],
                        ],
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
