import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/user_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../home/home_screen.dart';
import '../report/report_issue_screen.dart';
import '../map/map_screen.dart';
import '../wallet/wallet_screen.dart';
import '../profile/profile_screen.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with TickerProviderStateMixin {
  int _currentIndex = 0;

  late final List<AnimationController> _scaleControllers;
  late final List<Animation<double>> _scaleAnimations;

  final List<Widget> _screens = const [
    HomeScreenProfessional(),
    ReportIssueScreen(),
    MapScreen(),
    WalletScreen(),
    ProfileScreen(),
  ];

  final List<IconData> _icons = const [
    Icons.home_rounded,
    Icons.campaign_rounded,
    Icons.map_rounded,
    Icons.account_balance_wallet_rounded,
    Icons.person_rounded,
  ];

  final List<String> _labels = const [
    'Home',
    'Report',
    'Map',
    'Wallet',
    'Profile',
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();

    _scaleControllers = List.generate(5, (index) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      );
    });

    _scaleAnimations = _scaleControllers.map((controller) {
      return TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.15)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: Tween(begin: 1.15, end: 1.0)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 50,
        ),
      ]).animate(controller);
    }).toList();
  }

  void _loadUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<UserProvider>().loadUser(user.uid);
      });
    }
  }

  void _onTabSelected(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.lightImpact();
    setState(() {
      _currentIndex = index;
    });
    _scaleControllers[index].forward(from: 0.0);
  }

  @override
  void dispose() {
    for (final controller in _scaleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.primaryBg,
        body: Container(
          decoration: const BoxDecoration(gradient: AppGradients.screenBg),
          child: Stack(
          children: [
            // Screen content area above the nav bar
            Positioned.fill(
              bottom: 80 + bottomPadding,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeOutCubic,
                transitionBuilder: (child, animation) {
                  final isIncoming = child.key == ValueKey(_currentIndex);

                  if (isIncoming) {
                    // Incoming: slide from right + fade in
                    final slideIn = Tween<Offset>(
                      begin: const Offset(0.15, 0.0),
                      end: Offset.zero,
                    ).animate(animation);

                    return SlideTransition(
                      position: slideIn,
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  } else {
                    // Outgoing: scale down to 0.96 + fade out
                    final scaleOut = Tween<double>(
                      begin: 0.96,
                      end: 1.0,
                    ).animate(animation);

                    return ScaleTransition(
                      scale: scaleOut,
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  }
                },
                child: KeyedSubtree(
                  key: ValueKey(_currentIndex),
                  child: _screens[_currentIndex],
                ),
              ),
            ),

            // Bottom navigation bar — NOT inside SafeArea
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomNavBar(bottomPadding),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(double bottomPadding) {
    return Container(
      height: 80 + bottomPadding,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF111111),
            Color(0xFF0A0A0A),
          ],
        ),
        border: const Border(
          top: BorderSide(
            color: Color(0xFF1A1A1A),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tabWidth = constraints.maxWidth / 5;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Animated glow behind active tab
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutBack,
                  left: tabWidth * _currentIndex + (tabWidth - 48) / 2,
                  top: 4,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFC6F135).withValues(alpha: 0.18),
                          const Color(0xFFC6F135).withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),

                // Tab items row
                Row(
                  children: List.generate(5, (index) {
                    final isActive = _currentIndex == index;

                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _onTabSelected(index),
                        child: SizedBox(
                          height: 80,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Icon with highlight pill + spring animation
                              AnimatedBuilder(
                                animation: _scaleAnimations[index],
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _scaleAnimations[index].value,
                                    child: child,
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutCubic,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isActive ? 16 : 0,
                                    vertical: isActive ? 6 : 0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? const Color(0xFFC6F135)
                                            .withValues(alpha: 0.15)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    _icons[index],
                                    size: isActive ? 26 : 24,
                                    color: isActive
                                        ? const Color(0xFFC6F135)
                                        : const Color(0xFF5A5A5A),
                                  ),
                                ),
                              ),
                              // Active label
                              AnimatedSize(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOutCubic,
                                child: isActive
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          _labels[index],
                                          style: GoogleFonts.dmSans(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFFC6F135),
                                            height: 1,
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
