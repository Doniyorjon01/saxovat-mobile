import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.n1,
      colorScheme: base.colorScheme.copyWith(
        brightness: Brightness.dark,
        primary: AppColors.b1,
        secondary: AppColors.g0,
        surface: AppColors.n3,
        error: AppColors.r1,
      ),
      // Sora everywhere for UI/body text.
      textTheme: GoogleFonts.soraTextTheme(base.textTheme).apply(
        bodyColor: AppColors.white,
        displayColor: AppColors.white,
      ).copyWith(
        titleLarge: GoogleFonts.sora(
          fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.white,
        ),
        titleMedium: GoogleFonts.sora(
          fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.white,
        ),
        bodyMedium: GoogleFonts.sora(
          fontSize: 13, color: AppColors.white,
        ),
        bodySmall: GoogleFonts.sora(
          fontSize: 11, color: AppColors.muted,
        ),
      ),
    );
  }

  /// Noto Serif — used only for Arabic / Quran verses and the "Assalomu
  /// alaykum" serif headings, matching the mockup.
  static TextStyle serif({
    double size = 20,
    FontWeight weight = FontWeight.w600,
    Color color = AppColors.white,
  }) {
    return GoogleFonts.notoSerif(
      fontSize: size, fontWeight: weight, color: color,
    );
  }
}