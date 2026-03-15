import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/user_provider.dart';
import '../../services/api_service.dart';
import '../../models/user_model.dart';
import '../../core/theme/app_colors.dart';
import 'package:confetti/confetti.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  List<UserModel> _leaderboard = [];
  bool _isLoading = false;
  late ConfettiController _confettiController;
  late TabController _tabController;

  final List<Badge> _badges = [
    Badge('Eco Warrior', 'Complete 10 reports', Icons.eco, 10,
        AppColors.neonLime),
    Badge('Clean Streak', '7 day check-in streak', Icons.local_fire_department,
        7, AppColors.error),
    Badge('Point Master', 'Earn 100 points', Icons.star, 100, AppColors.gold),
    Badge('Booking Pro', 'Book 5 pickups', Icons.calendar_today, 5,
        AppColors.info),
    Badge('Community Hero', 'Top 10 in ward', Icons.emoji_events, 1,
        AppColors.warning),
  ];

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _tabController = TabController(length: 3, vsync: this);
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);
    try {
      _leaderboard = await _apiService.getLeaderboard(limit: 20);
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

  double _getBadgeProgress(Badge badge, UserModel? user) {
    if (user == null) return 0.0;
    switch (badge.title) {
      case 'Eco Warrior':
        return (user.totalReports / 10).clamp(0.0, 1.0);
      case 'Clean Streak':
        return (user.streak / 7).clamp(0.0, 1.0);
      case 'Point Master':
        return (user.points / 100).clamp(0.0, 1.0);
      case 'Booking Pro':
        return (user.totalBookings / 5).clamp(0.0, 1.0);
      default:
        return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 4),
              child: Text(
                'REWARDS',
                style: GoogleFonts.bebasNeue(
                  fontSize: 36,
                  color: AppColors.textWhite,
                  letterSpacing: 2,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Text(
                'Earn badges and compete with your community',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            // Tabs
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom:
                      BorderSide(color: AppColors.borderDefault, width: 1),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.neonLime,
                unselectedLabelColor: AppColors.textTertiary,
                indicatorColor: AppColors.neonLime,
                indicatorWeight: 2,
                labelStyle: GoogleFonts.barlowSemiCondensed(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: GoogleFonts.barlowSemiCondensed(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                tabs: const [
                  Tab(text: 'Badges'),
                  Tab(text: 'Leaderboard'),
                  Tab(text: 'Challenges'),
                ],
              ),
            ),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBadgesTab(),
                  _buildLeaderboardTab(),
                  _buildChallengesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── BADGES TAB ──
  Widget _buildBadgesTab() {
    return Consumer<UserProvider>(builder: (context, userProvider, child) {
      final user = userProvider.currentUser;
      return GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.78,
        ),
        itemCount: _badges.length,
        itemBuilder: (context, index) {
          final badge = _badges[index];
          final isUnlocked = _isBadgeUnlocked(badge, user);
          final progress = _getBadgeProgress(badge, user);
          return _buildBadgeCard(badge, isUnlocked, progress);
        },
      );
    });
  }

  Widget _buildBadgeCard(Badge badge, bool isUnlocked, double progress) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isUnlocked ? AppColors.cardBg : AppColors.surface1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked ? AppColors.borderActive : AppColors.borderDefault,
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? badge.color.withValues(alpha: 0.15)
                  : AppColors.surface3,
              shape: BoxShape.circle,
            ),
            child: Icon(
              badge.icon,
              size: 32,
              color: isUnlocked
                  ? badge.color
                  : AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 12),
          // Title
          Text(
            badge.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.barlowSemiCondensed(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isUnlocked ? AppColors.textWhite : AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            badge.description,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 10),
          // Earned chip or progress bar
          if (isUnlocked)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.neonLime.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'EARNED',
                style: GoogleFonts.barlowSemiCondensed(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neonLime,
                  letterSpacing: 1,
                ),
              ),
            )
          else
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: AppColors.surface3,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.limeDim),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ── LEADERBOARD TAB ──
  Widget _buildLeaderboardTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.neonLime),
      );
    }

    if (_leaderboard.isEmpty) {
      return Center(
        child: Text(
          'NO DATA AVAILABLE',
          style: GoogleFonts.bebasNeue(
            fontSize: 20,
            color: AppColors.textTertiary,
            letterSpacing: 1.5,
          ),
        ),
      );
    }

    return Consumer<UserProvider>(builder: (context, userProvider, child) {
      final currentUser = userProvider.currentUser;
      return CustomScrollView(
        slivers: [
          // Top 3 podium
          if (_leaderboard.length >= 3)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: _buildPodium(currentUser),
              ),
            ),

          // Rest of leaderboard
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final actualIndex = _leaderboard.length >= 3 ? index + 3 : index;
                  if (actualIndex >= _leaderboard.length) return null;
                  final user = _leaderboard[actualIndex];
                  final isCurrentUser = user.uid == currentUser?.uid;
                  final rank = actualIndex + 1;
                  return _buildLeaderboardItem(user, rank, isCurrentUser);
                },
                childCount: _leaderboard.length >= 3
                    ? _leaderboard.length - 3
                    : _leaderboard.length,
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      );
    });
  }

  Widget _buildPodium(UserModel? currentUser) {
    final first = _leaderboard[0];
    final second = _leaderboard[1];
    final third = _leaderboard[2];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // #2
        Expanded(
          child: _buildPodiumCard(
            user: second,
            rank: 2,
            height: 130,
            isCurrentUser: second.uid == currentUser?.uid,
            isFirst: false,
          ),
        ),
        const SizedBox(width: 8),
        // #1
        Expanded(
          flex: 1,
          child: _buildPodiumCard(
            user: first,
            rank: 1,
            height: 160,
            isCurrentUser: first.uid == currentUser?.uid,
            isFirst: true,
          ),
        ),
        const SizedBox(width: 8),
        // #3
        Expanded(
          child: _buildPodiumCard(
            user: third,
            rank: 3,
            height: 120,
            isCurrentUser: third.uid == currentUser?.uid,
            isFirst: false,
          ),
        ),
      ],
    );
  }

  Widget _buildPodiumCard({
    required UserModel user,
    required int rank,
    required double height,
    required bool isCurrentUser,
    required bool isFirst,
  }) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isFirst ? AppColors.neonLime.withValues(alpha: 0.12) : AppColors.surface3,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFirst ? AppColors.neonLime.withValues(alpha: 0.3) : AppColors.borderDefault,
          width: isFirst ? 1.5 : 0.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isFirst)
            Icon(Icons.workspace_premium, color: AppColors.neonLime, size: 24),
          Text(
            '#$rank',
            style: GoogleFonts.bebasNeue(
              fontSize: isFirst ? 28 : 22,
              color: isFirst ? AppColors.neonLime : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.name ?? 'User',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textWhite,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${user.points}',
            style: GoogleFonts.bebasNeue(
              fontSize: 20,
              color: AppColors.neonLime,
            ),
          ),
          Text(
            'pts',
            style: GoogleFonts.dmSans(
              fontSize: 10,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(UserModel user, int rank, bool isCurrentUser) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrentUser ? AppColors.surface2 : AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: isCurrentUser
            ? const Border(
                left: BorderSide(color: AppColors.neonLime, width: 2),
              )
            : Border.all(color: AppColors.borderDefault, width: 0.5),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 36,
            child: Text(
              '#$rank',
              style: GoogleFonts.bebasNeue(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.name ?? 'User',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textWhite,
                        ),
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.neonLime,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'YOU',
                          style: GoogleFonts.barlowSemiCondensed(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textOnLime,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${user.totalReports} reports \u2022 ${user.totalBookings} bookings',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.textTertiary,
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
                style: GoogleFonts.bebasNeue(
                  fontSize: 20,
                  color: AppColors.neonLime,
                ),
              ),
              Text(
                'points',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── CHALLENGES TAB ──
  Widget _buildChallengesTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flag_outlined,
            size: 64,
            color: AppColors.neonLime.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'COMING SOON',
            style: GoogleFonts.bebasNeue(
              fontSize: 24,
              color: AppColors.textTertiary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Weekly challenges will appear here',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _tabController.dispose();
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
