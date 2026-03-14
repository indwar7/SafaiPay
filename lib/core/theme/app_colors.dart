import 'package:flutter/material.dart';

class AppColors {
  // Primary Backgrounds
  static const Color primaryBg = Color(0xFF0A0A0A);
  static const Color surface1 = Color(0xFF111111);
  static const Color surface2 = Color(0xFF161616);
  static const Color surface3 = Color(0xFF1E1E1E);
  static const Color cardBg = Color(0xFF181818);
  static const Color elevatedCard = Color(0xFF202020);

  // Borders
  static const Color borderDefault = Color(0xFF2A2A2A);
  static const Color borderActive = Color(0xFF3A3A3A);

  // Neon Lime — HERO
  static const Color neonLime = Color(0xFFC6F135);
  static const Color limeDim = Color(0xFFA8D020);
  static const Color limeGlow = Color(0x1FC6F135);
  static const Color limeUltraDim = Color(0x0FC6F135);

  // Text
  static const Color textWhite = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFF9A9A9A);
  static const Color textTertiary = Color(0xFF5A5A5A);
  static const Color textOnLime = Color(0xFF0A0A0A);

  // Status
  static const Color success = Color(0xFFC6F135);
  static const Color warning = Color(0xFFFFB830);
  static const Color error = Color(0xFFFF4D4D);
  static const Color info = Color(0xFF4DA6FF);

  // Navigation
  static const Color navBg = Color(0xFF0D0D0D);
  static const Color navBorder = Color(0xFF1E1E1E);

  // Special
  static const Color limePointsBanner = Color(0xFF0F1A00);
  static const Color errorBg = Color(0xFF1A0000);

  // Legacy aliases
  static const Color primaryLime = neonLime;
  static const Color primaryGreen = neonLime;
  static const Color accentGreen = limeDim;
  static const Color black = primaryBg;
  static const Color white = textWhite;
  static const Color scaffoldBg = primaryBg;
  static const Color cardDark = cardBg;
  static const Color greyText = textSecondary;
  static const Color greyLight = borderDefault;
  static const Color greyBorder = borderDefault;
  static const Color offWhite = primaryBg;
  static const Color paleLime = limeUltraDim;
  static const Color red = error;
  static const Color blue = info;
  static const Color orange = warning;
  static const Color gold = Color(0xFFFFD700);
  static const Color teal = Color(0xFF26A69A);
}
