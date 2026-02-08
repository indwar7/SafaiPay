import 'package:flutter/material.dart';
import 'dart:math' as math;

// Premium Onboarding Screen with stunning animations
class OnboardingScreenPremium extends StatefulWidget {
  const OnboardingScreenPremium({super.key});

  @override
  State<OnboardingScreenPremium> createState() => _OnboardingScreenPremiumState();
}

class _OnboardingScreenPremiumState extends State<OnboardingScreenPremium>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _floatController;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    
    // Floating animation for illustrations
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Scale animation for page transitions
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: 'Your Clean Journey\nBegins Here',
      description: 'Join thousands making cities cleaner, one action at a time.',
      illustration: OnboardingIllustration.cleanJourney,
      primaryColor: const Color(0xFF2ECC71),
      secondaryColor: const Color(0xFF1A1A1A),
    ),
    OnboardingPageData(
      title: 'A Cleaner World\nStarts with You',
      description: 'Report issues, earn rewards, and make a real difference.',
      illustration: OnboardingIllustration.cleanWorld,
      primaryColor: const Color(0xFF27AE60),
      secondaryColor: const Color(0xFF1A1A1A),
    ),
    OnboardingPageData(
      title: 'A Clean Space is\nPeace of Mind',
      description: 'Let\'s keep it that way, together.',
      illustration: OnboardingIllustration.peaceOfMind,
      primaryColor: const Color(0xFF2ECC71),
      secondaryColor: const Color(0xFF1A1A1A),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Stack(
          children: [
            // Animated Background Gradient
            AnimatedBuilder(
              animation: _pageController,
              builder: (context, child) {
                double page = _pageController.hasClients
                    ? (_pageController.page ?? 0)
                    : 0;
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.lerp(
                          const Color(0xFF1A1A1A),
                          const Color(0xFF2C2C2C),
                          (page % 1),
                        )!,
                        const Color(0xFF1A1A1A),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Main Content
            Column(
              children: [
                // Skip Button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 60),
                      // Page Indicators (Top)
                      Row(
                        children: List.generate(
                          _pages.length,
                          (index) => _buildTopIndicator(index),
                        ),
                      ),
                      TextButton(
                        onPressed: _skipToEnd,
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                      _scaleController.forward(from: 0);
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _buildPage(_pages[index], index);
                    },
                  ),
                ),

                // Bottom Section
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      // Dot Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (index) => _buildDotIndicator(index),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Next/Get Started Button
                      _buildPremiumButton(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPageData data, int index) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double value = 1.0;
        if (_pageController.position.haveDimensions) {
          value = (_pageController.page ?? 0) - index;
          value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
        }

        return Transform.scale(
          scale: Curves.easeOut.transform(value),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Illustration
            AnimatedBuilder(
              animation: _floatController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    0,
                    math.sin(_floatController.value * 2 * math.pi) * 10,
                  ),
                  child: child,
                );
              },
              child: _buildIllustration(data.illustration),
            ),

            const SizedBox(height: 60),

            // Title with fade animation
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                data.title,
                key: ValueKey(_currentPage),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Description
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                data.description,
                key: ValueKey('desc_$_currentPage'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF888888),
                  height: 1.6,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration(OnboardingIllustration type) {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFF2ECC71).withOpacity(0.2),
            Colors.transparent,
          ],
        ),
      ),
      child: Center(
        child: _getIllustrationWidget(type),
      ),
    );
  }

  Widget _getIllustrationWidget(OnboardingIllustration type) {
    switch (type) {
      case OnboardingIllustration.cleanJourney:
        return _buildCleanJourneyIllustration();
      case OnboardingIllustration.cleanWorld:
        return _buildCleanWorldIllustration();
      case OnboardingIllustration.peaceOfMind:
        return _buildPeaceOfMindIllustration();
    }
  }

  // Illustration 1: Clean Journey
  Widget _buildCleanJourneyIllustration() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background circle
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF2ECC71).withOpacity(0.2),
          ),
        ),
        // Character with cleaning tools
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Head
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFDBB5),
              ),
              child: Stack(
                children: [
                  // Face
                  Positioned(
                    top: 20,
                    left: 15,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    right: 15,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  // Smile
                  Positioned(
                    bottom: 12,
                    left: 15,
                    child: Container(
                      width: 20,
                      height: 10,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: const Color(0xFF1A1A1A),
                            width: 2,
                          ),
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Body
            Container(
              width: 60,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF2ECC71),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            // Legs
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 20,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF27AE60),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 20,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF27AE60),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          ],
        ),
        // Broom (positioned to side)
        Positioned(
          right: 30,
          bottom: 50,
          child: Transform.rotate(
            angle: -0.3,
            child: Column(
              children: [
                Container(
                  width: 4,
                  height: 80,
                  color: const Color(0xFF8B4513),
                ),
                Container(
                  width: 30,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD700),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Trash bucket
        Positioned(
          left: 40,
          bottom: 60,
          child: Container(
            width: 35,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF3498DB),
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Center(
              child: Icon(
                Icons.delete_outline,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Illustration 2: Clean World
  Widget _buildCleanWorldIllustration() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF27AE60).withOpacity(0.2),
          ),
        ),
        // Character picking up trash
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Head
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFDBB5),
              ),
            ),
            // Bent body
            Transform.rotate(
              angle: 0.3,
              child: Container(
                width: 60,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFF2ECC71),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        // Trash bag
        Positioned(
          bottom: 40,
          right: 50,
          child: Container(
            width: 50,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(
                Icons.eco,
                color: Color(0xFF2ECC71),
                size: 30,
              ),
            ),
          ),
        ),
        // Sparkles
        Positioned(
          top: 30,
          right: 40,
          child: Icon(
            Icons.auto_awesome,
            color: const Color(0xFFFFD700).withOpacity(0.8),
            size: 24,
          ),
        ),
        Positioned(
          top: 50,
          left: 40,
          child: Icon(
            Icons.auto_awesome,
            color: const Color(0xFFFFD700).withOpacity(0.6),
            size: 18,
          ),
        ),
      ],
    );
  }

  // Illustration 3: Peace of Mind
  Widget _buildPeaceOfMindIllustration() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF2ECC71).withOpacity(0.2),
          ),
        ),
        // Character with thumbs up
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Head with smile
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFDBB5),
              ),
              child: Stack(
                children: [
                  // Happy eyes
                  Positioned(
                    top: 18,
                    left: 12,
                    child: Container(
                      width: 10,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 18,
                    right: 12,
                    child: Container(
                      width: 10,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Big smile
                  Positioned(
                    bottom: 10,
                    left: 12,
                    child: Container(
                      width: 26,
                      height: 15,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: const Color(0xFF1A1A1A),
                            width: 2,
                          ),
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Body
            Container(
              width: 60,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF2ECC71),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            // Legs
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 20,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF27AE60),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 20,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF27AE60),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          ],
        ),
        // Thumbs up
        Positioned(
          right: 40,
          top: 80,
          child: Transform.rotate(
            angle: -0.5,
            child: const Icon(
              Icons.thumb_up,
              color: Color(0xFFFFD700),
              size: 40,
            ),
          ),
        ),
        // Trash bag with star
        Positioned(
          left: 35,
          bottom: 50,
          child: Stack(
            children: [
              Container(
                width: 45,
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  Icons.star,
                  color: Color(0xFF2ECC71),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopIndicator(int index) {
    bool isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: isActive ? 24 : 8,
      height: 4,
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF2ECC71)
            : const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildDotIndicator(int index) {
    bool isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 32 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF2ECC71)
            : const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildPremiumButton() {
    bool isLastPage = _currentPage == _pages.length - 1;
    
    return GestureDetector(
      onTap: () {
        if (isLastPage) {
          _navigateToLogin();
        } else {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF2ECC71),
              Color(0xFF27AE60),
            ],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2ECC71).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isLastPage ? 'Get Started' : 'Next',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _skipToEnd() {
    _pageController.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _navigateToLogin() {
    // Replace with your navigation logic
    // Navigator.of(context).pushReplacementNamed(AppRoutes.mainApp);
    print('Navigate to login or main app');
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    _scaleController.dispose();
    super.dispose();
  }
}

// Data Models
enum OnboardingIllustration {
  cleanJourney,
  cleanWorld,
  peaceOfMind,
}

class OnboardingPageData {
  final String title;
  final String description;
  final OnboardingIllustration illustration;
  final Color primaryColor;
  final Color secondaryColor;

  OnboardingPageData({
    required this.title,
    required this.description,
    required this.illustration,
    required this.primaryColor,
    required this.secondaryColor,
  });
}