import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import '../../providers/user_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/wallet_card.dart';
import '../../core/widgets/quick_action_card.dart';
import '../../routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _greetingController;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _greetingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _greetingController,
      curve: Curves.easeOutCubic,
    ));
    
    _greetingController.forward();
  }

  @override
  void dispose() {
    _greetingController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    final userProvider = context.read<UserProvider>();
    final user = userProvider.currentUser;
    if (user != null) {
      await userProvider.loadUser(user.uid);
    }
    await Future.delayed(const Duration(milliseconds: 500));
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            final user = userProvider.currentUser;
            final isLoading = userProvider.isLoading;

            return LiquidPullToRefresh(
              onRefresh: _handleRefresh,
              color: AppColors.primaryGreen,
              backgroundColor: Colors.white,
              animSpeedFactor: 2,
              showChildOpacityTransition: false,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 100),
                child: AnimationLimiter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 600),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: widget,
                        ),
                      ),
                      children: [
                        // Header with Greeting
                        Container(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: SlideTransition(
                                      position: _slideAnimation,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${_getGreeting()} 👋',
                                            style: AppTextStyles.subHeading,
                                          ),
                                          const SizedBox(height: 4),
                                          Hero(
                                            tag: 'userName',
                                            child: Material(
                                              color: Colors.transparent,
                                              child: Text(
                                                user?.name ?? 'User',
                                                style: AppTextStyles.heading,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Animated notification bell
                                  TweenAnimationBuilder<double>(
                                    duration: const Duration(milliseconds: 800),
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    builder: (context, value, child) {
                                      return Transform.scale(
                                        scale: value,
                                        child: Transform.rotate(
                                          angle: value * 0.2,
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.05),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.notifications_outlined,
                                              color: AppColors.black,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "You're making your city cleaner today",
                                style: AppTextStyles.body,
                              ),
                            ],
                          ),
                        ),

                        // Wallet Card with Hero animation
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Hero(
                            tag: 'walletCard',
                            child: Material(
                              color: Colors.transparent,
                              child: WalletCard(
                                points: user?.points ?? 0,
                                walletBalance: user?.walletBalance ?? 0,
                                showShimmer: isLoading,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Quick Actions
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Quick Actions',
                            style: AppTextStyles.subHeading,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: AnimationLimiter(
                            child: GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 1.1,
                              children: AnimationConfiguration.toStaggeredList(
                                duration: const Duration(milliseconds: 500),
                                childAnimationBuilder: (widget) => ScaleAnimation(
                                  scale: 0.5,
                                  child: FadeInAnimation(
                                    child: widget,
                                  ),
                                ),
                                children: [
                                  QuickActionCard(
                                    icon: Icons.report_problem,
                                    label: 'Report\nGarbage',
                                    onTap: () {
                                      Navigator.pushNamed(context, AppRoutes.reportIssue);
                                    },
                                    iconColor: AppColors.orange,
                                  ),
                                  QuickActionCard(
                                    icon: Icons.calendar_today,
                                    label: 'Book\nPickup',
                                    onTap: () {
                                      Navigator.pushNamed(context, AppRoutes.bookPickup);
                                    },
                                    iconColor: AppColors.blue,
                                  ),
                                  QuickActionCard(
                                    icon: Icons.check_circle,
                                    label: 'Daily\nCheck-in',
                                    onTap: () async {
                                      await userProvider.dailyCheckIn();
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Row(
                                              children: [
                                                Icon(Icons.check_circle, color: Colors.white),
                                                SizedBox(width: 12),
                                                Text('Check-in successful! +2 points'),
                                              ],
                                            ),
                                            backgroundColor: AppColors.primaryGreen,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    iconColor: AppColors.primaryGreen,
                                  ),
                                  QuickActionCard(
                                    icon: Icons.emoji_events,
                                    label: 'Rewards &\nLeaderboard',
                                    onTap: () {
                                      Navigator.pushNamed(context, AppRoutes.rewards);
                                    },
                                    iconColor: AppColors.gold,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Impact Tracker
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Impact',
                                style: AppTextStyles.subHeading,
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    _buildImpactItem(
                                      'Reports Submitted',
                                      user?.totalReports ?? 0,
                                      Icons.report,
                                      AppColors.orange,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildImpactItem(
                                      'Pickups Booked',
                                      user?.totalBookings ?? 0,
                                      Icons.delete_outline,
                                      AppColors.blue,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildImpactItem(
                                      'Day Streak',
                                      user?.streak ?? 0,
                                      Icons.local_fire_department,
                                      AppColors.red,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Community Rank Card with shimmer
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 1000),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Opacity(
                                  opacity: value,
                                  child: child,
                                ),
                              );
                            },
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, AppRoutes.rewards);
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFFFFD700),
                                      Color(0xFFFFA500),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.gold.withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    TweenAnimationBuilder<double>(
                                      duration: const Duration(milliseconds: 1500),
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      builder: (context, value, child) {
                                        return Transform.rotate(
                                          angle: value * 6.28, // 2π radians
                                          child: child,
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.3),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.emoji_events,
                                          size: 32,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Community Rank',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Top ${((user?.points ?? 0) / 10).ceil()}%',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
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
          },
        ),
      ),
    );
  }

  Widget _buildImpactItem(
      String label, int value, IconData icon, Color color) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, animValue, child) {
        return Row(
          children: [
            Transform.scale(
              scale: animValue,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.greyText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value.toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
            ),
            // Animated progress bar
            SizedBox(
              width: 60,
              height: 60,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 1500),
                      tween: Tween(begin: 0.0, end: (value / 100).clamp(0.0, 1.0)),
                      curve: Curves.easeOut,
                      builder: (context, progressValue, child) {
                        return CircularProgressIndicator(
                          value: progressValue,
                          backgroundColor: color.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          strokeWidth: 4,
                        );
                      },
                    ),
                  ),
                  Text(
                    value.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
