import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Neo-Mint Transit Palette (from Stitch Design System)
  static const Color mintAccent = Color(0xFF2FE5A6); // Electric Neo-Mint (Primary Container)
  static const Color forestMint = Color(0xFF006C4B); // Deep Forest Mint (Primary Brand)
  static const Color mintDark = Color(0xFF005138); // Dark Forest Green
  static const Color mintSoft = Color(0xFFE5F0EC); // Surface Container
  static const Color mintCanvas = Color(0xFFF1FCF8); // App Background Canvas
  static const Color mintSurfaceLow = Color(0xFFEBF6F2); // Subtle Surface
  static const Color mintSurfaceHigh = Color(0xFFE0EBE7);
  static const Color mintSurfaceHighest = Color(0xFFDAE5E1);

  // Dark Ink & Inverse Surfaces
  static const Color darkCharcoal = Color(0xFF121417); // Inverse Surface / Dark Hero Ink
  static const Color darkCard = Color(0xFF283230); // Inverse Surface Elevated
  static const Color darkBorder = Color(0xFF3B4A42);

  // Status & Cohesion Accents
  static const Color emerald = Color(0xFF006C4B); // High Cohesion / Success
  static const Color emeraldLight = Color(0xFFE5F0EC);
  static const Color emeraldBorder = Color(0xFF2FE5A6);

  static const Color teal = Color(0xFF0D9488);
  static const Color tealLight = Color(0xFFF0FDFA);

  static const Color indigo = Color(0xFF505F76); // Tertiary Slate
  static const Color indigoLight = Color(0xFFEEF2FF);
  static const Color indigoBorder = Color(0xFFC7D2FE);

  static const Color amber = Color(0xFFD97706); // Warning / Medium Cohesion
  static const Color amberLight = Color(0xFFFFFBEB);
  static const Color amberBorder = Color(0xFFFDE68A);

  static const Color rose = Color(0xFFBA1A1A); // Attention Needed / Error
  static const Color roseLight = Color(0xFFFFDAD6);
  static const Color roseBorder = Color(0xFFFFB4AB);

  // Surface & Canvas
  static const Color scaffoldBg = Color(0xFFF1FCF8); // Neo-Mint soft tint canvas
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEBF6F2);
  static const Color surfaceSubtle = Color(0xFFF1FCF8);
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color cardBorderSubtle = Color(0xFFE0EBE7);
  static const Color dividerColor = Color(0xFFE5F0EC);

  // Typography Palette
  static const Color textDark = Color(0xFF141D1B); // Ink On Surface
  static const Color textBody = Color(0xFF283230); // Deep Slate
  static const Color textMuted = Color(0xFF5D5E62); // Secondary Slate
  static const Color textLight = Color(0xFF6B7B71); // Outline text

  // Seat Status Map Colors
  static const Color seatSameBay = Color(0xFF006C4B); // Deep Forest Mint
  static const Color seatSameCoach = Color(0xFFD97706); // Amber
  static const Color seatOtherCoach = Color(0xFFBA1A1A); // Rose
  static const Color seatOpenToSwap = Color(0xFF2FE5A6); // Neo-Mint
  static const Color seatOccupied = Color(0xFF94A3B8); // Muted Slate
  static const Color seatYourGroup = Color(0xFF006C4B); // Primary Group Green

  // Backwards compatibility aliases
  static const Color brandPrimary = forestMint;
  static const Color brandNavy = darkCharcoal;
  static const Color brandAccent = mintAccent;
  static const Color brandLight = mintSoft;
  static const Color brandGradientStart = darkCharcoal;
  static const Color brandGradientEnd = darkCard;
  static const Color primary = forestMint;
  static const Color primaryDark = darkCharcoal;
  static const Color primaryDeep = darkCharcoal;
  static const Color primaryLight = mintSoft;
  static const Color primaryBlue = mintAccent;
  static const Color danger = rose;
  static const Color dangerLight = roseLight;
  static const Color success = emerald;
  static const Color successLight = emeraldLight;
}

class AppTheme {
  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.scaffoldBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brandAccent,
        primary: AppColors.brandPrimary,
        secondary: AppColors.emerald,
        surface: AppColors.surfaceWhite,
      ),
      textTheme: textTheme.copyWith(
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: AppColors.textDark,
          letterSpacing: -0.6,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.textDark,
          letterSpacing: -0.4,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
          letterSpacing: -0.2,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        titleSmall: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textBody,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.textMuted,
        ),
        bodySmall: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: AppColors.textLight,
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  // Modern Card Decoration with 24px radius, subtle border, and soft elevation
  static BoxDecoration cardDecoration({
    Color? color,
    BorderRadius? borderRadius,
    Border? border,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      color: color ?? AppColors.surfaceWhite,
      borderRadius: borderRadius ?? BorderRadius.circular(24),
      border: border ?? Border.all(color: AppColors.cardBorderSubtle, width: 1),
      boxShadow: shadows ??
          [
            BoxShadow(
              color: const Color(0xFF141D1B).withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: const Color(0xFF141D1B).withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
    );
  }

  // Elevated Accent Card Decoration
  static BoxDecoration gradientCardDecoration({
    required List<Color> colors,
    BorderRadius? borderRadius,
    Border? border,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: borderRadius ?? BorderRadius.circular(24),
      border: border,
      boxShadow: [
        BoxShadow(
          color: colors.first.withValues(alpha: 0.22),
          blurRadius: 22,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}
