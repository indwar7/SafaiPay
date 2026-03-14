import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class WalletCard extends StatelessWidget {
  final int points;
  final double balance;
  final VoidCallback? onRedeem;

  const WalletCard({
    super.key,
    required this.points,
    required this.balance,
    this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(28),
        border: const Border(
          top: BorderSide(color: AppColors.neonLime, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonLime.withValues(alpha: 0.08),
            blurRadius: 32,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Corner grid pattern decoration
          Positioned(
            top: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(28),
              ),
              child: CustomPaint(
                size: const Size(120, 120),
                painter: _GridPatternPainter(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Points label
                Text(
                  'POINTS',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 14,
                    color: AppColors.textTertiary,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 4),
                // Points value
                Text(
                  points.toString(),
                  style: GoogleFonts.bebasNeue(
                    fontSize: 72,
                    color: AppColors.neonLime,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 16),
                // Divider
                Container(
                  width: double.infinity,
                  height: 1,
                  color: AppColors.borderDefault,
                ),
                const SizedBox(height: 16),
                // Balance row + redeem button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BALANCE',
                          style: GoogleFonts.bebasNeue(
                            fontSize: 14,
                            color: AppColors.textTertiary,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\u20B9${balance.toStringAsFixed(2)}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 24,
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: onRedeem,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.neonLime,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'REDEEM',
                          style: GoogleFonts.bebasNeue(
                            fontSize: 14,
                            color: AppColors.textOnLime,
                            letterSpacing: 1.5,
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
    );
  }
}

class _GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const step = 12.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
