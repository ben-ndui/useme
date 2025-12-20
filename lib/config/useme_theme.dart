import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Use Me Theme Configuration
/// Primary: Blue (Viba-inspired)
/// Secondary: Light Blue
/// Tertiary: Turquoise
class UseMeTheme {
  // Brand Colors (Viba-inspired)
  static const Color primaryColor = Color(0xFF0B38BF);      // Viba Blue
  static const Color secondaryColor = Color(0xFF031473);    // Dark Blue
  static const Color tertiaryColor = Color(0xFF00CEC9);     // Turquoise
  static const Color accentColor = Color(0xFF3B5FC7);       // Light Blue

  // Semantic Colors
  static const Color successColor = Color(0xFF00B894);
  static const Color warningColor = Color(0xFFFDCB6E);
  static const Color errorColor = Color(0xFFE17055);
  static const Color infoColor = Color(0xFF74B9FF);

  // Light Theme
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: tertiaryColor,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(colorScheme),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: primaryColor.withValues(alpha: 0.2),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }

  // Dark Theme Colors
  static const Color _darkSurface = Color(0xFF0D0D0F);
  static const Color _darkSurfaceContainer = Color(0xFF151518);
  static const Color _darkSurfaceContainerHigh = Color(0xFF1C1C20);
  static const Color _darkSurfaceContainerHighest = Color(0xFF252529);
  static const Color _darkPrimary = Color(0xFF5B7FE8);
  static const Color _darkOnPrimary = Color(0xFFFFFFFF);
  static const Color _darkPrimaryContainer = Color(0xFF1A2B5E);
  static const Color _darkOnPrimaryContainer = Color(0xFFB8C8FF);
  static const Color _darkSecondary = Color(0xFF7B8AB5);
  static const Color _darkTertiary = Color(0xFF4DD5D1);
  static const Color _darkOutline = Color(0xFF45454D);
  static const Color _darkOutlineVariant = Color(0xFF2E2E35);

  // Dark Theme
  static ThemeData get darkTheme {
    const colorScheme = ColorScheme.dark(
      brightness: Brightness.dark,
      primary: _darkPrimary,
      onPrimary: _darkOnPrimary,
      primaryContainer: _darkPrimaryContainer,
      onPrimaryContainer: _darkOnPrimaryContainer,
      secondary: _darkSecondary,
      onSecondary: Color(0xFF0D0D0F),
      secondaryContainer: Color(0xFF2A2F42),
      onSecondaryContainer: Color(0xFFD8DCE8),
      tertiary: _darkTertiary,
      onTertiary: Color(0xFF0D0D0F),
      tertiaryContainer: Color(0xFF0A3A38),
      onTertiaryContainer: Color(0xFFB8F5F2),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: _darkSurface,
      onSurface: Color(0xFFE8E8EC),
      onSurfaceVariant: Color(0xFFA8A8B3),
      outline: _darkOutline,
      outlineVariant: _darkOutlineVariant,
      inverseSurface: Color(0xFFE8E8EC),
      onInverseSurface: Color(0xFF1A1A1D),
      inversePrimary: primaryColor,
      surfaceContainerLowest: Color(0xFF080809),
      surfaceContainerLow: Color(0xFF121214),
      surfaceContainer: _darkSurfaceContainer,
      surfaceContainerHigh: _darkSurfaceContainerHigh,
      surfaceContainerHighest: _darkSurfaceContainerHighest,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _darkSurface,
      textTheme: _buildTextTheme(colorScheme),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: _darkSurface,
        foregroundColor: Color(0xFFE8E8EC),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: _darkSurfaceContainer,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _darkOutlineVariant, width: 0.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkOutlineVariant, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkPrimary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: Color(0xFF6E6E78)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _darkPrimary,
          foregroundColor: _darkOnPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _darkPrimary,
          side: const BorderSide(color: _darkPrimary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: _darkPrimary),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _darkSurfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: const BorderSide(color: _darkOutlineVariant, width: 0.5),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _darkPrimary,
        foregroundColor: _darkOnPrimary,
        elevation: 4,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _darkSurfaceContainer,
        surfaceTintColor: Colors.transparent,
        indicatorColor: _darkPrimary.withValues(alpha: 0.15),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _darkSurfaceContainerHighest,
        contentTextStyle: const TextStyle(color: Color(0xFFE8E8EC)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _darkSurfaceContainer,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: _darkSurfaceContainer,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dividerTheme: const DividerThemeData(color: _darkOutlineVariant, thickness: 0.5),
      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
        iconColor: Color(0xFFA8A8B3),
      ),
      iconTheme: const IconThemeData(color: Color(0xFFA8A8B3)),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _darkPrimary;
          return const Color(0xFF6E6E78);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _darkPrimary.withValues(alpha: 0.3);
          }
          return const Color(0xFF2E2E35);
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _darkPrimary,
        linearTrackColor: _darkOutlineVariant,
      ),
    );
  }

  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(fontWeight: FontWeight.bold),
      displayMedium: GoogleFonts.inter(fontWeight: FontWeight.bold),
      displaySmall: GoogleFonts.inter(fontWeight: FontWeight.bold),
      headlineLarge: GoogleFonts.inter(fontWeight: FontWeight.w600),
      headlineMedium: GoogleFonts.inter(fontWeight: FontWeight.w600),
      headlineSmall: GoogleFonts.inter(fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w500),
      titleSmall: GoogleFonts.inter(fontWeight: FontWeight.w500),
      bodyLarge: GoogleFonts.inter(),
      bodyMedium: GoogleFonts.inter(),
      bodySmall: GoogleFonts.inter(),
      labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w500),
      labelMedium: GoogleFonts.inter(fontWeight: FontWeight.w500),
      labelSmall: GoogleFonts.inter(fontWeight: FontWeight.w500),
    );
  }
}
