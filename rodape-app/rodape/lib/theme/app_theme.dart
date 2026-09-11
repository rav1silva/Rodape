import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.paper100,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.spineTeal,
        brightness: Brightness.light,
        primary: AppColors.spineTeal,
        secondary: AppColors.spineMustard,
        error: AppColors.stampRed600,
        surface: AppColors.paper100,
      ),
      fontFamily: GoogleFonts.ibmPlexSans().fontFamily,
    );

    return base.copyWith(
      textTheme: GoogleFonts.ibmPlexSansTextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.wood800,
        foregroundColor: AppColors.paper050,
        elevation: 0,
        centerTitle: false,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderHairline,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(color: AppColors.ink700),
    );
  }
}
