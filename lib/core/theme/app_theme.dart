import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.cream,
      primaryColor: AppColors.mint,
      colorScheme: const ColorScheme.light(
        primary: AppColors.mint,
        onPrimary: AppColors.ink,
        surface: AppColors.cream,
        onSurface: AppColors.textPrimary,
        error: AppColors.rejected,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: AppColors.ink,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
          letterSpacing: -0.3,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.normal,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.textPrimary,
        ),
        bodySmall: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColors.textSecondary,
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.fieldGrey,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.mintPressed, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mint,
          foregroundColor: AppColors.ink,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          elevation: 0,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
    );
  }
}
