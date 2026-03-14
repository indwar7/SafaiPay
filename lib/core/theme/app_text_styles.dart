import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Display — Bebas Neue
  static TextStyle displayXL = GoogleFonts.bebasNeue(
    fontSize: 72,
    color: AppColors.neonLime,
    letterSpacing: 2.0,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle displayL = GoogleFonts.bebasNeue(
    fontSize: 48,
    color: AppColors.textWhite,
    letterSpacing: 1.5,
  );

  static TextStyle displayM = GoogleFonts.bebasNeue(
    fontSize: 36,
    color: AppColors.neonLime,
    letterSpacing: 1.0,
  );

  static TextStyle displayS = GoogleFonts.bebasNeue(
    fontSize: 28,
    color: AppColors.textWhite,
    letterSpacing: 1.0,
  );

  // Heading — Barlow Semi Condensed
  static TextStyle heading = GoogleFonts.barlowSemiCondensed(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textWhite,
  );

  static TextStyle subheading = GoogleFonts.barlowSemiCondensed(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textWhite,
  );

  static TextStyle headingLime = GoogleFonts.barlowSemiCondensed(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.neonLime,
  );

  // Body — DM Sans
  static TextStyle bodyL = GoogleFonts.dmSans(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textWhite,
    letterSpacing: -0.2,
  );

  static TextStyle bodyM = GoogleFonts.dmSans(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textWhite,
    letterSpacing: -0.2,
  );

  static TextStyle caption = GoogleFonts.dmSans(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );

  static TextStyle label = GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textWhite,
  );

  // Mono — JetBrains Mono
  static TextStyle monoNumber = GoogleFonts.jetBrainsMono(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textWhite,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle monoSmall = GoogleFonts.jetBrainsMono(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textWhite,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  // Button
  static TextStyle buttonText = GoogleFonts.bebasNeue(
    fontSize: 20,
    color: AppColors.textOnLime,
    letterSpacing: 1.5,
  );

  static TextStyle chipText = GoogleFonts.dmSans(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnLime,
  );

  // Points
  static TextStyle pointsBadge = GoogleFonts.bebasNeue(
    fontSize: 28,
    color: AppColors.neonLime,
    letterSpacing: 1.0,
  );

  static TextStyle pointsLabel = GoogleFonts.bebasNeue(
    fontSize: 14,
    color: AppColors.textTertiary,
    letterSpacing: 4.0,
  );

  // Legacy aliases
  static TextStyle get subHeading => heading;
  static TextStyle get cardTitle => heading;
  static TextStyle get body => bodyM;
  static TextStyle get bodyBold => bodyL;
  static TextStyle get points => displayXL;
}
