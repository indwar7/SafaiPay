import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeInOut),
      ),
    );

    _animationController.forward();

    Timer(const Duration(seconds: 3), () {
      _checkAuthStatus();
    });
  }

  void _checkAuthStatus() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.mainApp);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF4F7F5),
              Color(0xFFFFFFFF),
              Color(0xFFE8F8F5),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles
            ...List.generate(20, (index) {
              return AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Positioned(
                    left: (index % 5) * (MediaQuery.of(context).size.width / 5),
                    top: (index ~/ 5) *
                            (MediaQuery.of(context).size.height / 4) +
                        (50 * _animationController.value),
                    child: Opacity(
                      opacity: 0.1 * (1 - _animationController.value),
                      child: Icon(
                        index % 2 == 0 ? Icons.eco : Icons.recycling,
                        size: 30,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  );
                },
              );
            }),

            // Main content
            Center(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated logo
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: RotationTransition(
                            turns: Tween<double>(begin: 0.0, end: 0.1)
                                .animate(_rotateAnimation),
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF2ECC71),
                                    Color(0xFF27AE60),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(35),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppColors.primaryGreen.withOpacity(0.4),
                                    blurRadius: 40,
                                    offset: const Offset(0, 20),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.eco,
                                size: 70,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Animated app name
                        AnimatedTextKit(
                          animatedTexts: [
                            TypewriterAnimatedText(
                              'SafaiPay',
                              textStyle: const TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                                letterSpacing: 2,
                              ),
                              speed: const Duration(milliseconds: 150),
                            ),
                          ],
                          totalRepeatCount: 1,
                          pause: const Duration(milliseconds: 1000),
                          displayFullTextOnTap: true,
                          stopPauseOnTap: true,
                        ),

                        const SizedBox(height: 16),

                        // Animated tagline
                        FadeTransition(
                          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(0.6, 1.0,
                                  curve: Curves.easeIn),
                            ),
                          ),
                          child: AnimatedTextKit(
                            animatedTexts: [
                              FadeAnimatedText(
                                'Clean Actions. Real Rewards.',
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.greyText,
                                  letterSpacing: 0.8,
                                ),
                                duration: const Duration(milliseconds: 1000),
                              ),
                            ],
                            totalRepeatCount: 1,
                          ),
                        ),

                        const SizedBox(height: 50),

                        // Loading indicator
                        FadeTransition(
                          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(0.7, 1.0,
                                  curve: Curves.easeIn),
                            ),
                          ),
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryGreen,
                              ),
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
