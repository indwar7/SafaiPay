import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/user_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';
import 'edit_profile_sheet.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _openEditProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const EditProfileSheet(),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Logout',
          style: GoogleFonts.bebasNeue(
            fontSize: 28,
            color: AppColors.textWhite,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.dmSans(
            fontSize: 15,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.dmSans(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<UserProvider>().logout();
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.login,
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Logout',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Consumer<UserProvider>(builder: (context, userProvider, child) {
          final user = userProvider.currentUser;

          // Fake enriched data
          final name = user?.name ?? 'Arjun Mehta';
          final ward = user?.ward ?? 'Ward 5, Indiranagar';
          final phone = user?.phoneNumber ?? '+91 98765 43210';
          final points = user?.points ?? 2450;
          final reports = user?.totalReports ?? 24;
          final bookings = user?.totalBookings ?? 12;
          final streak = user?.streak ?? 7;
          final walletBalance = user?.walletBalance ?? 1245;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: [
                // ── HEADER ──
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.surface3,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.neonLime,
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(
                              Icons.person,
                              size: 40,
                              color: AppColors.neonLime,
                            ),
                            // Level badge
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.neonLime,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'LV.5',
                                  style: GoogleFonts.bebasNeue(
                                    fontSize: 10,
                                    color: AppColors.textOnLime,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: GoogleFonts.barlowSemiCondensed(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textWhite,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$ward \u2022 $phone',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Member since
                          Row(
                            children: [
                              Icon(Icons.calendar_today_rounded,
                                  size: 12,
                                  color: AppColors.textTertiary),
                              const SizedBox(width: 4),
                              Text(
                                'Member since Jan 2025',
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () => _openEditProfile(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 7),
                              decoration: BoxDecoration(
                                color: AppColors.surface3,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.borderDefault,
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                'Edit Profile',
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.neonLime,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── ECO LEVEL PROGRESS ──
                _buildEcoLevelCard(points),
                const SizedBox(height: 20),

                // ── STATS GRID (2x2) ──
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        number: reports.toString(),
                        label: 'Reports',
                        icon: Icons.flag_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatCard(
                        number: bookings.toString(),
                        label: 'Pickups',
                        icon: Icons.local_shipping_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        number: points.toString(),
                        label: 'Points Earned',
                        icon: Icons.star_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatCard(
                        number: '\u20B9$walletBalance',
                        label: 'Wallet Balance',
                        icon: Icons.account_balance_wallet_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── STREAK CARD ──
                _buildStreakCard(streak),
                const SizedBox(height: 20),

                // ── MONTHLY IMPACT SUMMARY ──
                _buildMonthlyImpact(),
                const SizedBox(height: 20),

                // ── ACHIEVEMENTS ──
                _buildAchievementsSection(),
                const SizedBox(height: 20),

                // ── RECENT ACTIVITY TIMELINE ──
                _buildRecentActivityTimeline(),
                const SizedBox(height: 20),

                // ── ENVIRONMENTAL IMPACT ──
                _buildEnvironmentalImpact(),
                const SizedBox(height: 20),

                // ── SETTINGS LIST ──
                _buildSettingsSection(
                  title: 'ACCOUNT',
                  items: [
                    _SettingItem(
                      icon: Icons.person_outline,
                      label: 'Edit Profile',
                      subtitle: 'Name, ward, address',
                      onTap: () => _openEditProfile(context),
                    ),
                    _SettingItem(
                      icon: Icons.history,
                      label: 'My Bookings',
                      subtitle: '$bookings completed',
                      onTap: () {},
                    ),
                    _SettingItem(
                      icon: Icons.report_outlined,
                      label: 'My Reports',
                      subtitle: '$reports submitted',
                      onTap: () {},
                    ),
                    _SettingItem(
                      icon: Icons.payment_rounded,
                      label: 'Payment Methods',
                      subtitle: 'UPI, Bank account',
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                _buildSettingsSection(
                  title: 'PREFERENCES',
                  items: [
                    _SettingItem(
                      icon: Icons.notifications_outlined,
                      label: 'Push Notifications',
                      subtitle: 'Reports, pickups, rewards',
                      onTap: () {},
                      hasToggle: true,
                      toggleValue: true,
                    ),
                    _SettingItem(
                      icon: Icons.language_rounded,
                      label: 'Language',
                      subtitle: 'English',
                      onTap: () {},
                    ),
                    _SettingItem(
                      icon: Icons.location_on_outlined,
                      label: 'Location Services',
                      subtitle: 'Always on',
                      onTap: () {},
                      hasToggle: true,
                      toggleValue: true,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                _buildSettingsSection(
                  title: 'SUPPORT & LEGAL',
                  items: [
                    _SettingItem(
                      icon: Icons.help_outline,
                      label: 'Help & Support',
                      subtitle: 'FAQs, contact us',
                      onTap: () {},
                    ),
                    _SettingItem(
                      icon: Icons.lock_outline,
                      label: 'Privacy Policy',
                      onTap: () {},
                    ),
                    _SettingItem(
                      icon: Icons.description_outlined,
                      label: 'Terms of Service',
                      onTap: () {},
                    ),
                    _SettingItem(
                      icon: Icons.info_outline,
                      label: 'About SafaiPay',
                      subtitle: 'v1.0.0',
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── INVITE FRIENDS ──
                _buildInviteCard(),
                const SizedBox(height: 12),

                // Logout (separate, red)
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.borderDefault,
                      width: 0.5,
                    ),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.logout,
                        color: AppColors.error,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'Logout',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.error,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.borderActive,
                      size: 20,
                    ),
                    onTap: () => _logout(context),
                  ),
                ),
                const SizedBox(height: 28),

                // Version + love
                Text(
                  'Made with \u2764 for cleaner cities',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── Eco Level Card ──
  Widget _buildEcoLevelCard(int points) {
    final level = (points / 500).floor().clamp(1, 10);
    final nextLevel = level + 1;
    final progressInLevel = (points % 500) / 500;
    final pointsToNext = 500 - (points % 500);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F1A00),
            AppColors.cardBg,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.neonLime.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.neonLime,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    '$level',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 28,
                      color: AppColors.textOnLime,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getEcoTitle(level),
                      style: GoogleFonts.barlowSemiCondensed(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neonLime,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$pointsToNext pts to Level $nextLevel',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.trending_up_rounded,
                color: AppColors.neonLime,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface3,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progressInLevel,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.neonLime,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level $level',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
              Text(
                'Level $nextLevel',
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

  String _getEcoTitle(int level) {
    const titles = [
      'Eco Beginner',
      'Green Starter',
      'Clean Advocate',
      'Eco Champion',
      'Green Warrior',
      'Eco Hero',
      'City Guardian',
      'Planet Protector',
      'Eco Legend',
      'SafaiPay Master',
    ];
    return titles[(level - 1).clamp(0, 9)];
  }

  // ── Stat Card ──
  Widget _buildStatCard({
    required String number,
    required String label,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDefault, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.neonLime, size: 18),
            const SizedBox(height: 8),
          ],
          Text(
            number,
            style: GoogleFonts.bebasNeue(
              fontSize: 36,
              color: AppColors.neonLime,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Streak Card ──
  Widget _buildStreakCard(int streak) {
    final cappedStreak = streak.clamp(0, 7);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1A00),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.neonLime.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_fire_department,
                color: AppColors.neonLime,
                size: 28,
              ),
              const SizedBox(width: 10),
              Text(
                '$streak DAY STREAK',
                style: GoogleFonts.bebasNeue(
                  fontSize: 32,
                  color: AppColors.neonLime,
                  letterSpacing: 1.5,
                  height: 1.0,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.neonLime.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'BEST: 14',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 14,
                    color: AppColors.neonLime,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final isCompleted = index < cappedStreak;
              return Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.neonLime
                          : AppColors.borderDefault,
                      shape: BoxShape.circle,
                    ),
                    child: isCompleted
                        ? const Icon(
                            Icons.check,
                            color: AppColors.textOnLime,
                            size: 18,
                          )
                        : Center(
                            child: Text(
                              '+2',
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                color: AppColors.textTertiary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _dayLabel(index),
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      color: isCompleted
                          ? AppColors.neonLime
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  String _dayLabel(int index) {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return labels[index];
  }

  // ── Monthly Impact Summary ──
  Widget _buildMonthlyImpact() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'March 2025',
                style: GoogleFonts.barlowSemiCondensed(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textWhite,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.neonLime.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+24% vs Feb',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neonLime,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Mini bar chart for the month
          SizedBox(
            height: 60,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(12, (index) {
                final heights = [
                  0.3, 0.5, 0.7, 0.4, 0.8, 0.6, 0.9, 0.5, 0.7, 0.85, 0.6, 0.95
                ];
                final h = heights[index];
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Container(
                      height: 60 * h,
                      decoration: BoxDecoration(
                        color: index == 11
                            ? AppColors.neonLime
                            : AppColors.neonLime.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.borderDefault, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMiniStat('8', 'Reports'),
              _buildMiniStat('4', 'Pickups'),
              _buildMiniStat('340', 'Points'),
              _buildMiniStat('7', 'Streak'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.bebasNeue(
              fontSize: 24,
              color: AppColors.neonLime,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Achievements Section ──
  Widget _buildAchievementsSection() {
    final achievements = [
      _Achievement('Eco Warrior', Icons.eco, true, 'Complete 10 reports'),
      _Achievement(
          'Clean Streak', Icons.local_fire_department, true, '7 day streak'),
      _Achievement('Point Master', Icons.star, false, 'Earn 5000 pts'),
      _Achievement(
          'First Pickup', Icons.local_shipping, true, 'Book 1 pickup'),
      _Achievement(
          'Night Owl', Icons.nightlight_round, false, 'Report after 10 PM'),
      _Achievement(
          'Community Hero', Icons.emoji_events, false, 'Top 3 in ward'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Achievements',
              style: GoogleFonts.barlowSemiCondensed(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textWhite,
              ),
            ),
            Text(
              '3/6 Unlocked',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.neonLime,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: achievements.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final a = achievements[index];
              return Container(
                width: 120,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: a.unlocked ? AppColors.cardBg : AppColors.surface1,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: a.unlocked
                        ? AppColors.neonLime.withValues(alpha: 0.3)
                        : AppColors.borderDefault,
                    width: a.unlocked ? 1.0 : 0.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon in a container
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: a.unlocked
                            ? AppColors.neonLime.withValues(alpha: 0.15)
                            : AppColors.surface3,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        a.icon,
                        size: 24,
                        color: a.unlocked
                            ? AppColors.neonLime
                            : AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Title
                    Text(
                      a.title,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: a.unlocked
                            ? AppColors.textWhite
                            : AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Description
                    Text(
                      a.description,
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        color: a.unlocked
                            ? AppColors.textSecondary
                            : AppColors.textTertiary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (a.unlocked) ...[
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle,
                              size: 12, color: AppColors.neonLime),
                          const SizedBox(width: 4),
                          Text(
                            'Unlocked',
                            style: GoogleFonts.dmSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: AppColors.neonLime,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Recent Activity Timeline ──
  Widget _buildRecentActivityTimeline() {
    final activities = [
      _TimelineItem('Report Submitted', 'Overflowing bin at MG Road',
          '2h ago', '+5 pts', Icons.report_problem_rounded),
      _TimelineItem('Pickup Completed', 'Dry waste \u2022 15kg', '5h ago',
          '+10 pts', Icons.local_shipping_rounded),
      _TimelineItem('Daily Check-in', 'Day 7 streak!', '1d ago', '+2 pts',
          Icons.check_circle_rounded),
      _TimelineItem('Report Resolved', 'Sewage issue at 12th Cross',
          '2d ago', '+15 pts', Icons.verified_rounded),
      _TimelineItem('Points Redeemed', 'Converted 500 pts to \u20B9500',
          '3d ago', '', Icons.currency_rupee_rounded),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: GoogleFonts.barlowSemiCondensed(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textWhite,
          ),
        ),
        const SizedBox(height: 12),
        ...activities.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == activities.length - 1;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline dot and line
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: index == 0
                            ? AppColors.neonLime
                            : AppColors.surface3,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: index == 0
                              ? AppColors.neonLime
                              : AppColors.borderActive,
                          width: 2,
                        ),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 1,
                          color: AppColors.borderDefault,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                // Content card
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.borderDefault,
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.neonLime.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(item.icon,
                              color: AppColors.neonLime, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textWhite,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.subtitle,
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (item.points.isNotEmpty)
                              Text(
                                item.points,
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.neonLime,
                                ),
                              ),
                            Text(
                              item.timeAgo,
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ── Environmental Impact ──
  Widget _buildEnvironmentalImpact() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.eco, color: AppColors.neonLime, size: 22),
              const SizedBox(width: 10),
              Text(
                'Your Environmental Impact',
                style: GoogleFonts.barlowSemiCondensed(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _buildImpactStat(
                  '48 kg', 'Waste\nDiverted', Icons.delete_sweep_rounded),
              const SizedBox(width: 12),
              _buildImpactStat(
                  '12', 'Trees\nSaved', Icons.park_rounded),
              const SizedBox(width: 12),
              _buildImpactStat(
                  '36 kg', 'CO\u2082\nReduced', Icons.cloud_outlined),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.neonLime.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    color: AppColors.neonLime, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You\'re in the top 15% of eco-warriors in Bangalore!',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.neonLime,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactStat(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface3,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.neonLime, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.bebasNeue(
                fontSize: 22,
                color: AppColors.textWhite,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Invite Friends Card ──
  Widget _buildInviteCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.neonLime.withValues(alpha: 0.12),
            AppColors.cardBg,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.neonLime.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.neonLime,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.people_rounded,
                color: AppColors.textOnLime, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invite Friends',
                  style: GoogleFonts.barlowSemiCondensed(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textWhite,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Earn 50 pts for each friend who joins!',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right,
              color: AppColors.neonLime, size: 24),
        ],
      ),
    );
  }

  // ── Settings Section ──
  Widget _buildSettingsSection({
    required String title,
    required List<_SettingItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: GoogleFonts.barlowSemiCondensed(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderDefault, width: 0.5),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  if (index > 0)
                    const Divider(
                      height: 1,
                      color: AppColors.borderDefault,
                      indent: 58,
                    ),
                  ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.neonLime.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        item.icon,
                        color: AppColors.textOnLime,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      item.label,
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textWhite,
                      ),
                    ),
                    subtitle: item.subtitle != null
                        ? Text(
                            item.subtitle!,
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              color: AppColors.textTertiary,
                            ),
                          )
                        : null,
                    trailing: item.hasToggle
                        ? Switch(
                            value: item.toggleValue,
                            onChanged: (_) {},
                            activeColor: AppColors.neonLime,
                            activeTrackColor:
                                AppColors.neonLime.withValues(alpha: 0.3),
                            inactiveTrackColor: AppColors.surface3,
                            inactiveThumbColor: AppColors.textTertiary,
                          )
                        : const Icon(
                            Icons.chevron_right,
                            color: AppColors.borderActive,
                            size: 20,
                          ),
                    onTap: item.onTap,
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingItem {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final bool hasToggle;
  final bool toggleValue;

  const _SettingItem({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
    this.hasToggle = false,
    this.toggleValue = false,
  });
}

class _Achievement {
  final String title;
  final IconData icon;
  final bool unlocked;
  final String description;

  const _Achievement(this.title, this.icon, this.unlocked, this.description);
}

class _TimelineItem {
  final String title;
  final String subtitle;
  final String timeAgo;
  final String points;
  final IconData icon;

  const _TimelineItem(
      this.title, this.subtitle, this.timeAgo, this.points, this.icon);
}
