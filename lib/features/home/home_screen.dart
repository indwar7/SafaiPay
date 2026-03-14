import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/user_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../routes/app_routes.dart';

class HomeScreenProfessional extends StatefulWidget {
  const HomeScreenProfessional({super.key});

  @override
  State<HomeScreenProfessional> createState() => _HomeScreenProfessionalState();
}

class _HomeScreenProfessionalState extends State<HomeScreenProfessional>
    with TickerProviderStateMixin {
  late final List<AnimationController> _sectionControllers;
  late final List<Animation<double>> _fadeAnimations;
  late final List<Animation<Offset>> _slideAnimations;

  static const int _sectionCount = 6;

  @override
  void initState() {
    super.initState();

    _sectionControllers = List.generate(
      _sectionCount,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );

    _fadeAnimations = _sectionControllers
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut)
            .drive(Tween<double>(begin: 0.0, end: 1.0)))
        .toList();

    _slideAnimations = _sectionControllers
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOutCubic)
            .drive(Tween<Offset>(
                begin: const Offset(0, 40), end: Offset.zero)))
        .toList();

    _startStaggeredAnimation();
  }

  Future<void> _startStaggeredAnimation() async {
    for (int i = 0; i < _sectionCount; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) _sectionControllers[i].forward();
    }
  }

  @override
  void dispose() {
    for (final c in _sectionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _animatedSection(int index, Widget child) {
    return AnimatedBuilder(
      animation: _sectionControllers[index],
      builder: (context, ch) {
        return Transform.translate(
          offset: _slideAnimations[index].value,
          child: Opacity(
            opacity: _fadeAnimations[index].value,
            child: ch,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;
    final userName = user?.name ?? 'Citizen';
    final userPoints = user?.points ?? 2450;
    final walletBalance = user?.walletBalance ?? 245;
    final streak = user?.streak ?? 7;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // HEADER
            SliverToBoxAdapter(
              child: _animatedSection(0, _buildHeader(userName, streak)),
            ),
            // WALLET HERO CARD
            SliverToBoxAdapter(
              child: _animatedSection(
                  1, _buildWalletHeroCard(userPoints, walletBalance)),
            ),
            // QUICK ACTIONS
            SliverToBoxAdapter(
              child: _animatedSection(2, _buildQuickActions()),
            ),
            // IMPACT TRACKER
            SliverToBoxAdapter(
              child: _animatedSection(3, _buildImpactTracker()),
            ),
            // COMMUNITY RANK
            SliverToBoxAdapter(
              child: _animatedSection(4, _buildCommunityRankCard()),
            ),
            // RECENT ACTIVITY
            SliverToBoxAdapter(
              child: _animatedSection(5, _buildRecentActivity()),
            ),
            // Bottom padding for nav bar
            const SliverToBoxAdapter(
              child: SizedBox(height: 120),
            ),
          ],
        ),
      ),
    );
  }

  // --- HEADER -----------------------------------------------------------
  Widget _buildHeader(String userName, int streak) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.neonLime, width: 2),
              color: AppColors.elevatedCard,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: const Icon(Icons.person_rounded,
                  color: AppColors.textTertiary, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          // Greeting stack
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Namaste',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
                Text(
                  userName,
                  style: GoogleFonts.barlowSemiCondensed(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textWhite,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Notification bell
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface3,
                ),
                child: const Icon(Icons.notifications_outlined,
                    color: AppColors.textSecondary, size: 20),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.neonLime,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Streak fire
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_fire_department_rounded,
                  color: AppColors.neonLime, size: 20),
              const SizedBox(width: 4),
              Text(
                '$streak',
                style: GoogleFonts.barlowSemiCondensed(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neonLime,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- WALLET HERO CARD (finance-app style gradient) ----------------------
  Widget _buildWalletHeroCard(int points, int walletBalance) {
    final balanceStr = '\u20B9${walletBalance.toStringAsFixed(2)}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.walletCard,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppColors.neonLime.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonLime.withValues(alpha: 0.15),
              blurRadius: 30,
              spreadRadius: -4,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles (like reference finance card)
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.neonLime.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              right: 20,
              top: 20,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.neonLime.withValues(alpha: 0.06),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.neonLime.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'SafaiPay Wallet',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.neonLime,
                          ),
                        ),
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.neonLime.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.trending_up_rounded,
                            color: AppColors.neonLime, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Animated points count-up
                  TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: points),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutExpo,
                    builder: (context, value, child) {
                      final formatted = value.toString().replaceAllMapped(
                          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                          (m) => '${m[1]},');
                      return Text(
                        formatted,
                        style: GoogleFonts.bebasNeue(
                          fontSize: 72,
                          color: AppColors.textWhite,
                          height: 1.0,
                        ),
                      );
                    },
                  ),
                  Text(
                    'POINTS',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 14,
                      color: AppColors.neonLime,
                      letterSpacing: 4.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Divider
                  Container(
                    height: 1,
                    color: AppColors.neonLime.withValues(alpha: 0.15),
                  ),
                  const SizedBox(height: 16),
                  // Bottom row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            balanceStr,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 26,
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Available Balance',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: AppColors.neonLime.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.rewards),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.neonLime,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            'Redeem \u2192',
                            style: GoogleFonts.barlowSemiCondensed(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textOnLime,
                            ),
                          ),
                        ),
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

  // --- QUICK ACTIONS ----------------------------------------------------
  Widget _buildQuickActions() {
    final actions = [
      _QuickAction('Report Issue', Icons.report_problem_rounded, '+5 pts',
          () => Navigator.pushNamed(context, AppRoutes.reportIssue)),
      _QuickAction('Book Pickup', Icons.local_shipping_rounded, '+5 pts',
          () => Navigator.pushNamed(context, AppRoutes.bookPickup)),
      _QuickAction('Check In', Icons.check_circle_rounded, '+2 pts', () {
        final userProvider =
            Provider.of<UserProvider>(context, listen: false);
        userProvider.dailyCheckIn();
      }),
      _QuickAction('Leaderboard', Icons.leaderboard_rounded, '+5 pts',
          () => Navigator.pushNamed(context, AppRoutes.rewards)),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: actions
            .map((a) => Expanded(child: _buildQuickActionItem(a)))
            .toList(),
      ),
    );
  }

  Widget _buildQuickActionItem(_QuickAction action) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: _ScaleTapWidget(
        onTap: action.onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.neonLime,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(action.icon, color: AppColors.textOnLime, size: 24),
              ),
              const SizedBox(height: 10),
              Text(
                action.label,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: AppColors.textWhite,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                action.sub,
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- IMPACT STATISTICS CHART -------------------------------------------
  Widget _buildImpactTracker() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderDefault, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Weekly Activity',
                  style: GoogleFonts.barlowSemiCondensed(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textWhite,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.neonLime.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+18% \u2191',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neonLime,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Bar chart with line overlay
            SizedBox(
              height: 140,
              child: CustomPaint(
                size: const Size(double.infinity, 140),
                painter: _WeeklyChartPainter(),
              ),
            ),
            const SizedBox(height: 16),
            // Legend row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendDot(AppColors.neonLime, 'Reports'),
                const SizedBox(width: 24),
                _buildLegendDot(
                    AppColors.neonLime.withValues(alpha: 0.35), 'Pickups'),
              ],
            ),
            const SizedBox(height: 16),
            // Stats row
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface3,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _buildChartStat('12', 'Reports', Icons.flag_rounded),
                  _buildChartStatDivider(),
                  _buildChartStat(
                      '3', 'Pickups', Icons.local_shipping_rounded),
                  _buildChartStatDivider(),
                  _buildChartStat('7', 'Streak', Icons.local_fire_department),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildChartStat(String value, String label, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.neonLime, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.bebasNeue(
              fontSize: 24,
              color: AppColors.textWhite,
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

  Widget _buildChartStatDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.borderDefault,
    );
  }

  // --- COMMUNITY RANK CARD ----------------------------------------------
  Widget _buildCommunityRankCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Rank
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#3',
                      style: GoogleFonts.bebasNeue(
                        fontSize: 48,
                        color: AppColors.neonLime,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      'in Ward 5',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Sparkline placeholder
                SizedBox(
                  width: 80,
                  height: 40,
                  child: CustomPaint(
                    painter: _SparklinePainter(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.rewards),
                child: Text(
                  'See all \u2192',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: AppColors.neonLime,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- RECENT ACTIVITY --------------------------------------------------
  Widget _buildRecentActivity() {
    final activities = [
      _ActivityItem('Report Submitted', '2h ago', '+5 pts',
          Icons.report_problem_rounded),
      _ActivityItem('Pickup Booked', '5h ago', '+5 pts',
          Icons.local_shipping_rounded),
      _ActivityItem('Daily Check-in', '1d ago', '+2 pts',
          Icons.check_circle_rounded),
      _ActivityItem('Report Resolved', '2d ago', '+10 pts',
          Icons.verified_rounded),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Actions',
            style: GoogleFonts.barlowSemiCondensed(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textWhite,
            ),
          ),
          const SizedBox(height: 12),
          ...activities.map((a) => _buildActivityItem(a)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(_ActivityItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.neonLime,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: AppColors.textOnLime, size: 18),
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
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    item.timeAgo,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              item.points,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.neonLime,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- HELPER DATA CLASSES ------------------------------------------------

class _QuickAction {
  final String label;
  final IconData icon;
  final String sub;
  final VoidCallback onTap;

  _QuickAction(this.label, this.icon, this.sub, this.onTap);
}

// --- WEEKLY CHART PAINTER (bar chart + line overlay) --------------------

class _WeeklyChartPainter extends CustomPainter {
  // Reports per day (Mon-Sun)
  static const reportData = [2, 3, 1, 4, 2, 3, 1];
  // Pickups per day
  static const pickupData = [1, 0, 1, 1, 0, 2, 0];
  static const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void paint(Canvas canvas, Size size) {
    final chartTop = 10.0;
    final chartBottom = size.height - 24;
    final chartHeight = chartBottom - chartTop;
    final barAreaWidth = size.width;
    final barGroupWidth = barAreaWidth / 7;
    final barWidth = barGroupWidth * 0.3;
    final maxVal = 5.0;

    // Y-axis grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFF2A2A2A)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 4; i++) {
      final y = chartTop + (chartHeight / 4) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw bars
    final reportBarPaint = Paint()..color = const Color(0xFFC6F135);
    final pickupBarPaint = Paint()
      ..color = const Color(0xFFC6F135).withValues(alpha: 0.35);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < 7; i++) {
      final cx = barGroupWidth * i + barGroupWidth / 2;

      // Report bar
      final rh = (reportData[i] / maxVal) * chartHeight;
      final rRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - barWidth - 1, chartBottom - rh, barWidth, rh),
        const Radius.circular(3),
      );
      canvas.drawRRect(rRect, reportBarPaint);

      // Pickup bar
      final ph = (pickupData[i] / maxVal) * chartHeight;
      final pRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + 1, chartBottom - ph, barWidth, ph),
        const Radius.circular(3),
      );
      canvas.drawRRect(pRect, pickupBarPaint);

      // Day label
      textPainter.text = TextSpan(
        text: dayLabels[i],
        style: const TextStyle(
          color: Color(0xFF5A5A5A),
          fontSize: 10,
          fontFamily: 'sans-serif',
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(cx - textPainter.width / 2, chartBottom + 6),
      );
    }

    // Line overlay (trend line connecting report data)
    final linePaint = Paint()
      ..color = const Color(0xFFC6F135)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (int i = 0; i < 7; i++) {
      final cx = barGroupWidth * i + barGroupWidth / 2;
      final y = chartBottom - (reportData[i] / maxVal) * chartHeight;
      if (i == 0) {
        path.moveTo(cx, y);
      } else {
        // Smooth curve
        final prevCx = barGroupWidth * (i - 1) + barGroupWidth / 2;
        final prevY =
            chartBottom - (reportData[i - 1] / maxVal) * chartHeight;
        final midX = (prevCx + cx) / 2;
        path.cubicTo(midX, prevY, midX, y, cx, y);
      }
    }
    canvas.drawPath(path, linePaint);

    // Glow on line
    final glowPaint = Paint()
      ..color = const Color(0xFFC6F135).withValues(alpha: 0.15)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(path, glowPaint);

    // Dots on line
    final dotPaint = Paint()..color = const Color(0xFFC6F135);
    for (int i = 0; i < 7; i++) {
      final cx = barGroupWidth * i + barGroupWidth / 2;
      final y = chartBottom - (reportData[i] / maxVal) * chartHeight;
      canvas.drawCircle(Offset(cx, y), 3.5, dotPaint);
      canvas.drawCircle(
        Offset(cx, y),
        2,
        Paint()..color = const Color(0xFF181818),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ActivityItem {
  final String title;
  final String timeAgo;
  final String points;
  final IconData icon;

  _ActivityItem(this.title, this.timeAgo, this.points, this.icon);
}

// --- SCALE TAP WIDGET ---------------------------------------------------

class _ScaleTapWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _ScaleTapWidget({required this.child, required this.onTap});

  @override
  State<_ScaleTapWidget> createState() => _ScaleTapWidgetState();
}

class _ScaleTapWidgetState extends State<_ScaleTapWidget> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: widget.child,
      ),
    );
  }
}

// --- SPARKLINE PAINTER --------------------------------------------------

class _SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.neonLime
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final points = [0.6, 0.4, 0.7, 0.3, 0.5, 0.8, 0.6, 0.9];
    final path = Path();

    for (int i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * size.width;
      final y = size.height - (points[i] * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Glow effect
    final glowPaint = Paint()
      ..color = AppColors.neonLime.withValues(alpha: 0.2)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
