import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';
import '../../core/theme/app_colors.dart';
import 'package:confetti/confetti.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<UserModel> _leaderboard = [];
  bool _isLoading = false;
  late ConfettiController _confettiController;

  final List<Badge> _badges = [
    Badge('Eco Warrior', 'Complete 10 reports', Icons.eco, 10,
        AppColors.primaryGreen),
    Badge('Clean Streak', '7 day check-in streak', Icons.local_fire_department,
        7, AppColors.red),
    Badge('Point Master', 'Earn 100 points', Icons.star, 100, AppColors.gold),
    Badge('Booking Pro', 'Book 5 pickups', Icons.calendar_today, 5,
        AppColors.blue),
    Badge('Community Hero', 'Top 10 in ward', Icons.emoji_events, 1,
        AppColors.orange),
  ];

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);
    try {
      _leaderboard = await _firestoreService.getLeaderboard(limit: 20);
    } catch (e) {
      debugPrint('Error loading leaderboard: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _isBadgeUnlocked(Badge badge, UserModel? user) {
    if (user == null) return false;
    switch (badge.title) {
      case 'Eco Warrior':
        return user.totalReports >= 10;
      case 'Clean Streak':
        return user.streak >= 7;
      case 'Point Master':
        return user.points >= 100;
      case 'Booking Pro':
        return user.totalBookings >= 5;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rewards & Leaderboard',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Earn badges and compete with your community',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.greyText,
                      ),
                    ),
                  ],
                ),
              ),
              // Tabs
              const TabBar(
                labelColor: AppColors.primaryGreen,
                unselectedLabelColor: AppColors.greyText,
                indicatorColor: AppColors.primaryGreen,
                tabs: [
                  Tab(text: 'Badges'),
                  Tab(text: 'Leaderboard'),
                ],
              ),
              // Content
              Expanded(
                child: TabBarView(
                  children: [
                    _buildBadgesTab(),
                    _buildLeaderboardTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgesTab() {
    return Consumer<UserProvider>(builder: (context, userProvider, child) {
      final user = userProvider.currentUser;
      return GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.9,
        ),
        itemCount: _badges.length,
        itemBuilder: (context, index) {
          final badge = _badges[index];
          final isUnlocked = _isBadgeUnlocked(badge, user);
          return _buildBadgeCard(badge, isUnlocked);
        },
      );
    });
  }

  Widget _buildBadgeCard(Badge badge, bool isUnlocked) {
    return Container(
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? badge.color.withOpacity(0.1)
                  : AppColors.greyLight.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              badge.icon,
              size: 35,
              color: isUnlocked ? badge.color : AppColors.greyText,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            badge.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isUnlocked ? AppColors.black : AppColors.greyText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            badge.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.greyText,
            ),
          ),
          const SizedBox(height: 8),
          if (isUnlocked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: badge.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'UNLOCKED',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: badge.color,
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.greyLight.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'LOCKED',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.greyText,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_leaderboard.isEmpty) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(color: AppColors.greyText),
        ),
      );
    }

    return Consumer<UserProvider>(builder: (context, userProvider, child) {
      final currentUser = userProvider.currentUser;
      return ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: _leaderboard.length,
        itemBuilder: (context, index) {
          final user = _leaderboard[index];
          final isCurrentUser = user.uid == currentUser?.uid;
          final rank = index + 1;
          return _buildLeaderboardItem(user, rank, isCurrentUser);
        },
      );
    });
  }

  Widget _buildLeaderboardItem(UserModel user, int rank, bool isCurrentUser) {
    Color getRankColor() {
      if (rank == 1) return AppColors.gold;
      if (rank == 2) return Colors.grey.shade400;
      if (rank == 3) return Colors.brown.shade300;
      return AppColors.greyText;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.primaryGreen.withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isCurrentUser
            ? Border.all(color: AppColors.primaryGreen, width: 2)
            : null,
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: getRankColor().withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: rank <= 3
                  ? Icon(Icons.emoji_events, color: getRankColor(), size: 24)
                  : Text(
                      '#$rank',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: getRankColor(),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user.name ?? 'User',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'YOU',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${user.totalReports} reports • ${user.totalBookings} bookings',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.greyText,
                  ),
                ),
              ],
            ),
          ),
          // Points
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${user.points}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
              const Text(
                'points',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.greyText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }
}

class Badge {
  final String title;
  final String description;
  final IconData icon;
  final int requirement;
  final Color color;

  Badge(this.title, this.description, this.icon, this.requirement, this.color);
}
