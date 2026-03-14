import 'package:flutter/material.dart';

class AppGradients {
  static const LinearGradient mainBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A0A0A), Color(0xFF0A0A0A)],
  );

  /// Screen background — rich forest-green to black like the reference finance app
  static const LinearGradient screenBg = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.45, 1.0],
    colors: [
      Color(0xFF1E3010), // rich forest green
      Color(0xFF0F1808), // dark olive transition
      Color(0xFF0A0A0A), // pure black
    ],
  );

  /// Wallet / hero card gradient — bright lime to dark green
  static const LinearGradient walletCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF3A6B10), // rich green
      Color(0xFF1E3A08), // medium forest
      Color(0xFF0F1A05), // very dark green
    ],
  );

  static const RadialGradient limeRadial = RadialGradient(
    center: Alignment.topRight,
    radius: 1.2,
    colors: [Color(0x0DC6F135), Color(0xFF0A0A0A)],
  );

  static const RadialGradient limeGlow = RadialGradient(
    center: Alignment.center,
    radius: 0.8,
    colors: [Color(0x26C6F135), Color(0x00C6F135)],
  );

  static const LinearGradient shimmerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF181818), Color(0x33C6F135), Color(0xFF181818)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A1A), Color(0xFF181818)],
  );

  static const LinearGradient limeOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x00C6F135), Color(0x1AC6F135)],
  );

  // Legacy aliases
  static const LinearGradient greenGradient = cardGradient;
  static const LinearGradient walletGradient = walletCard;
}
