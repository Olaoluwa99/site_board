import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_palette.dart';

class AppTheme {
  static _border([Color color = AppPalette.borderColor]) => OutlineInputBorder(
    borderSide: BorderSide(color: color, width: 3),
    borderRadius: BorderRadius.circular(12),
  );

  static _lightBorder([Color color = AppPalette.lightBorderColor]) =>
      OutlineInputBorder(
        borderSide: BorderSide(color: color, width: 3),
        borderRadius: BorderRadius.circular(12),
      );

  static final darkThemeMode = _baseTheme(
    base: ThemeData.dark(),
    bgColor: AppPalette.backgroundColor,
    borderColor: AppPalette.borderColor,
    isDark: true,
  );

  static final lightThemeMode = _baseTheme(
    base: ThemeData.light(),
    bgColor: AppPalette.lightBackgroundColor,
    borderColor: AppPalette.lightBorderColor,
    isDark: false,
  );

  static ThemeData _baseTheme({
    required ThemeData base,
    required Color bgColor,
    required Color borderColor,
    required bool isDark,
  }) {
    return base.copyWith(
      scaffoldBackgroundColor: bgColor,
      appBarTheme: AppBarTheme(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          color: isDark ? AppPalette.whiteColor : AppPalette.lightTextPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(
          color: isDark ? AppPalette.whiteColor : AppPalette.lightTextPrimary,
        ),
      ),
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme).apply(
        bodyColor: isDark ? AppPalette.whiteColor : AppPalette.lightTextPrimary,
        displayColor:
            isDark ? AppPalette.whiteColor : AppPalette.lightTextPrimary,
      ),
      chipTheme: ChipThemeData(
        color: WidgetStatePropertyAll(
          isDark ? AppPalette.backgroundColor : AppPalette.lightSurfaceColor,
        ),
        side:
            isDark
                ? BorderSide.none
                : BorderSide(color: AppPalette.lightBorderColor),
        labelStyle: TextStyle(
          color: isDark ? AppPalette.whiteColor : AppPalette.lightTextPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color:
            isDark
                ? const Color.fromRGBO(30, 30, 40, 1)
                : AppPalette.lightSurfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color:
                isDark
                    ? Colors.transparent
                    : AppPalette.lightBorderColor.withValues(alpha: 0.5),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.all(18),
        filled: true,
        fillColor: isDark ? Colors.transparent : AppPalette.lightSurfaceColor,
        border: isDark ? _border() : _lightBorder(),
        enabledBorder: isDark ? _border() : _lightBorder(),
        focusedBorder:
            isDark
                ? _border(AppPalette.gradient2)
                : _lightBorder(AppPalette.gradient2),
        errorBorder:
            isDark
                ? _border(AppPalette.errorColor)
                : _lightBorder(AppPalette.errorColor),
      ),
    );
  }
}
