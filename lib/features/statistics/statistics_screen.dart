import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _selectedPeriod = 2; // Monthly by default
  final List<String> _periods = ['Today', 'Weekly', 'Monthly', 'Yearly'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(),
              _buildPeriodSelector(),
              _buildEarningSpendingCards(),
              _buildGoalProgress(),
              _buildOverview(),
              _buildBarChart(),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  // -- Header --

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  size: 18, color: AppColors.textWhite),
            ),
          ),
          Text(
            'Statistics',
            style: GoogleFonts.bebasNeue(
              color: AppColors.textWhite,
              fontSize: 32,
              fontWeight: FontWeight.w400,
              letterSpacing: 1.5,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderDefault),
            ),
            child: const Icon(Icons.more_horiz,
                size: 18, color: AppColors.textWhite),
          ),
        ],
      ),
    );
  }

  // -- Period Selector --

  Widget _buildPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: List.generate(_periods.length, (index) {
            final isActive = _selectedPeriod == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedPeriod = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color:
                        isActive ? AppColors.neonLime : Colors.transparent,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Center(
                    child: Text(
                      _periods[index],
                      style: GoogleFonts.dmSans(
                        color: isActive
                            ? AppColors.textOnLime
                            : AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight:
                            isActive ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // -- Earning & Spending Cards --

  Widget _buildEarningSpendingCards() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        children: [
          // Earning card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.trending_up_rounded,
                          color: AppColors.neonLime, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Earning',
                        style: GoogleFonts.dmSans(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.neonLime.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.more_horiz,
                            size: 14, color: AppColors.neonLime),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '24%',
                    style: GoogleFonts.bebasNeue(
                      color: AppColors.neonLime,
                      fontSize: 38,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your current month earning\nis increased by 24% compared\nto last month.',
                    style: GoogleFonts.dmSans(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Spending card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.trending_down_rounded,
                          color: AppColors.neonLime, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Spending',
                        style: GoogleFonts.dmSans(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.surface3,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.more_horiz,
                            size: 14, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$3,250',
                        style: GoogleFonts.bebasNeue(
                          color: AppColors.textWhite,
                          fontSize: 28,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(
                          '.80',
                          style: GoogleFonts.bebasNeue(
                            color: AppColors.textTertiary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Mini pie chart
                  Center(
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: CustomPaint(
                        painter: _MiniPieChartPainter(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _legendDot(AppColors.neonLime, 'Debit Card'),
                      const SizedBox(width: 12),
                      _legendDot(AppColors.borderDefault, 'Credit Card'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.dmSans(
            color: AppColors.textTertiary,
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // -- Goal Progress --

  Widget _buildGoalProgress() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Goal',
                  style: GoogleFonts.barlowSemiCondensed(
                    color: AppColors.textWhite,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '\$2567',
                        style: GoogleFonts.bebasNeue(
                          color: AppColors.textWhite,
                          fontSize: 16,
                        ),
                      ),
                      TextSpan(
                        text: '/\$5000',
                        style: GoogleFonts.bebasNeue(
                          color: AppColors.textTertiary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Progress bar segments
            Row(
              children: List.generate(10, (index) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 8,
                    decoration: BoxDecoration(
                      color: index < 5
                          ? AppColors.neonLime
                          : AppColors.borderDefault,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // -- Overview Section --

  Widget _buildOverview() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overview',
                style: GoogleFonts.barlowSemiCondensed(
                  color: AppColors.textWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderDefault),
                ),
                child: const Icon(Icons.tune,
                    size: 18, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Total balance + cards
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderDefault),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Balance',
                          style: GoogleFonts.dmSans(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$25,453.00',
                          style: GoogleFonts.bebasNeue(
                            color: AppColors.textWhite,
                            fontSize: 26,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _spendingLabel(
                            'Debit Card Spending', AppColors.neonLime),
                        const SizedBox(height: 6),
                        _spendingLabel(
                            'Credit Card Spending', AppColors.borderDefault),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Highlighted amount
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.neonLime,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '\$2,410.00',
                      style: GoogleFonts.dmSans(
                        color: AppColors.textOnLime,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
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

  Widget _spendingLabel(String text, Color dotColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: GoogleFonts.dmSans(
            color: AppColors.textTertiary,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: dotColor,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ],
    );
  }

  // -- Bar Chart --

  Widget _buildBarChart() {
    final months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN'];
    final debitValues = [0.6, 0.8, 0.5, 0.9, 0.7, 0.4];
    final creditValues = [0.4, 0.3, 0.7, 0.5, 0.6, 0.3];
    final maxY = [
      '\$3500', '\$3000', '\$2500', '\$2000', '\$1500', '\$1000', '\$500',
      '\$0'
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Y-axis labels
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: maxY
                        .map((label) => Text(
                              label,
                              style: GoogleFonts.dmSans(
                                color: AppColors.textTertiary,
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(width: 12),
                  // Bars
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children:
                          List.generate(months.length, (index) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Debit bar (lime)
                            Container(
                              width: 16,
                              height: 180 * debitValues[index],
                              decoration: BoxDecoration(
                                color: AppColors.neonLime,
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4)),
                              ),
                            ),
                            const SizedBox(height: 3),
                            // Credit bar (dark secondary)
                            Container(
                              width: 16,
                              height: 180 * creditValues[index] * 0.5,
                              decoration: BoxDecoration(
                                color: AppColors.borderDefault,
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4)),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // X-axis labels
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: months
                    .map((m) => Text(
                          m,
                          style: GoogleFonts.dmSans(
                            color: AppColors.textTertiary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -- Mini Pie Chart Painter --

class _MiniPieChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Debit portion (neon lime)
    final debitPaint = Paint()
      ..color = AppColors.neonLime
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    // Credit portion (dark border)
    final creditPaint = Paint()
      ..color = AppColors.borderDefault
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background arc
    canvas.drawArc(rect, 0, 2 * math.pi, false, creditPaint);

    // Debit arc (65%)
    canvas.drawArc(
        rect, -math.pi / 2, 2 * math.pi * 0.65, false, debitPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
