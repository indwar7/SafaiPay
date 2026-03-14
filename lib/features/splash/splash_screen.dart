import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Individual icon controllers for spring bounce
  late AnimationController _icon1Controller;
  late AnimationController _icon2Controller;
  late AnimationController _icon3Controller;

  // Background glow pulse
  late AnimationController _glowController;

  // Particle float
  late AnimationController _particleController;

  // Text and UI state
  bool _showName = false;
  bool _showTagline = false;
  bool _showLoader = false;
  bool _iconsVisible1 = false;
  bool _iconsVisible2 = false;
  bool _iconsVisible3 = false;

  @override
  void initState() {
    super.initState();

    _icon1Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _icon2Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _icon3Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat();

    _startAnimationSequence();
  }

  Future<void> _startAnimationSequence() async {
    // Phase 1: Eco leaf icon bounces in
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => _iconsVisible1 = true);
    _icon1Controller.forward();

    // Phase 2: Broom icon bounces in
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _iconsVisible2 = true);
    _icon2Controller.forward();

    // Phase 3: Phone payment icon bounces in
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _iconsVisible3 = true);
    _icon3Controller.forward();

    // Phase 4: Show app name
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _showName = true);

    // Phase 5: Show tagline
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() => _showTagline = true);

    // Phase 6: Show loader
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _showLoader = true);

    // Navigate
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.mainApp);
    }
  }

  @override
  void dispose() {
    _icon1Controller.dispose();
    _icon2Controller.dispose();
    _icon3Controller.dispose();
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Animated background glow
          _buildAnimatedBackground(),

          // Floating particles
          _buildParticles(),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),

                // Three animated icons in a row
                _buildIconRow(),

                const SizedBox(height: 40),

                // App name
                SizedBox(
                  height: 56,
                  child: _showName
                      ? AnimatedTextKit(
                          isRepeatingAnimation: false,
                          animatedTexts: [
                            TypewriterAnimatedText(
                              'SafaiPay',
                              textStyle: GoogleFonts.bebasNeue(
                                fontSize: 52,
                                color: AppColors.textWhite,
                                letterSpacing: 3,
                              ),
                              speed: const Duration(milliseconds: 80),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),

                const SizedBox(height: 8),

                // Tagline
                SizedBox(
                  height: 30,
                  child: _showTagline
                      ? AnimatedTextKit(
                          isRepeatingAnimation: false,
                          animatedTexts: [
                            TypewriterAnimatedText(
                              'Clean Actions. Real Rewards.',
                              textStyle: GoogleFonts.dmSans(
                                fontSize: 18,
                                color: AppColors.neonLime,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              speed: const Duration(milliseconds: 30),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),

                const Spacer(flex: 2),

                // Loading indicator
                AnimatedOpacity(
                  opacity: _showLoader ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 400),
                  child: const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.neonLime,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glowValue = _glowController.value;
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.3, -0.4),
              radius: 1.2 + (glowValue * 0.3),
              colors: [
                Color.lerp(
                  const Color(0xFF1E3010),
                  const Color(0xFF2A4A18),
                  glowValue,
                )!,
                const Color(0xFF0F1808),
                const Color(0xFF0A0A0A),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _ParticlePainter(_particleController.value),
        );
      },
    );
  }

  Widget _buildIconRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon 1: Eco leaf
        _buildAnimatedIcon(
          controller: _icon1Controller,
          visible: _iconsVisible1,
          icon: Icons.eco_rounded,
          size: 72,
          iconSize: 36,
        ),
        const SizedBox(width: 20),

        // Icon 2: Broom / cleaning
        _buildAnimatedIcon(
          controller: _icon2Controller,
          visible: _iconsVisible2,
          icon: Icons.cleaning_services_rounded,
          size: 72,
          iconSize: 36,
        ),
        const SizedBox(width: 20),

        // Icon 3: Mobile payment
        _buildAnimatedIcon(
          controller: _icon3Controller,
          visible: _iconsVisible3,
          icon: Icons.smartphone_rounded,
          size: 72,
          iconSize: 36,
          overlay: Icons.currency_rupee_rounded,
        ),
      ],
    );
  }

  Widget _buildAnimatedIcon({
    required AnimationController controller,
    required bool visible,
    required IconData icon,
    required double size,
    required double iconSize,
    IconData? overlay,
  }) {
    if (!visible) {
      return SizedBox(width: size, height: size);
    }

    final scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(controller);

    final fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.scale(
          scale: scaleAnim.value,
          child: Opacity(
            opacity: fadeAnim.value,
            child: child,
          ),
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF1A3008),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.neonLime.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonLime.withValues(alpha: 0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: iconSize, color: AppColors.neonLime),
            if (overlay != null)
              Positioned(
                right: 10,
                bottom: 10,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.neonLime,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    overlay,
                    size: 14,
                    color: AppColors.textOnLime,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Floating green particles for ambient effect
class _ParticlePainter extends CustomPainter {
  final double progress;
  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42);
    const count = 15;

    for (int i = 0; i < count; i++) {
      final baseX = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final speed = 0.3 + rng.nextDouble() * 0.7;
      final radius = 1.5 + rng.nextDouble() * 2.5;
      final phase = rng.nextDouble() * 2 * pi;

      final x = baseX + sin((progress * speed * 2 * pi) + phase) * 20;
      final y = baseY - (progress * speed * 60) % size.height;
      final adjustedY = y < 0 ? y + size.height : y;

      final alpha = 0.15 + sin((progress * 2 * pi) + phase).abs() * 0.2;

      final paint = Paint()
        ..color = const Color(0xFFC6F135).withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(Offset(x, adjustedY), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
