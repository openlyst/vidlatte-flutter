import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'constants.dart';

class AppTheme {
  AppTheme._();

  static const Color _lightBackground = Color(0xFFF5F5F7);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightPrimary = Color(0xFF1A1A1A);
  static const Color _lightSecondary = Color(0xFF6E6E73);
  static const Color _lightAccent = Color(0xFF007AFF);
  static const Color _lightBorder = Color(0xFFE5E5EA);
  static const Color _lightError = Color(0xFFFF3B30);
  static const Color _lightMuted = Color(0xFF8E8E93);

  static const Color _darkBackground = Color(0xFF1C1C1E);
  static const Color _darkSurface = Color(0xFF2C2C2E);
  static const Color _darkPrimary = Color(0xFFFFFFFF);
  static const Color _darkSecondary = Color(0xFF8E8E93);
  static const Color _darkAccent = Color(0xFF0A84FF);
  static const Color _darkBorder = Color(0xFF3A3A3C);
  static const Color _darkError = Color(0xFFFF453A);
  static const Color _darkMuted = Color(0xFF636366);

  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData getTheme(Brightness brightness) {
    return brightness == Brightness.light ? lightTheme : darkTheme;
  }

  static ThemeData _buildTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final bg = isLight ? _lightBackground : _darkBackground;
    final surface = isLight ? _lightSurface : _darkSurface;
    final primary = isLight ? _lightPrimary : _darkPrimary;
    final accent = isLight ? _lightAccent : _darkAccent;
    final border = isLight ? _lightBorder : _darkBorder;
    final error = isLight ? _lightError : _darkError;
    final secondary = isLight ? _lightSecondary : _darkSecondary;
    final muted = isLight ? _lightMuted : _darkMuted;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme(
        primary: primary,
        onPrimary: isLight ? Colors.white : Colors.black,
        secondary: accent,
        onSecondary: Colors.white,
        tertiary: accent,
        onTertiary: Colors.white,
        error: error,
        onError: Colors.white,
        surface: surface,
        onSurface: primary,
        surfaceContainerHighest: bg,
        outline: border,
        shadow: isLight ? Colors.black12 : Colors.black54,
        brightness: brightness,
      ),
      scaffoldBackgroundColor: bg,
      cardTheme: CardThemeData(
        color: surface,
        elevation: ThemeConstants.elevationSmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: primary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: isLight ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: primary,
          letterSpacing: -0.5,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
          borderSide: BorderSide(color: accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
          borderSide: BorderSide(color: error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.spacingMedium,
          vertical: ThemeConstants.spacingMedium,
        ),
        hintStyle: TextStyle(color: muted, fontSize: 15),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: isLight ? Colors.white : Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.spacingLarge,
            vertical: ThemeConstants.spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: border),
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.spacingLarge,
            vertical: ThemeConstants.spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.spacingMedium,
            vertical: ThemeConstants.spacingSmall,
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: ThemeConstants.elevationMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusLarge),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: bg,
        selectedColor: accent.withValues(alpha: 0.15),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.spacingMedium,
          vertical: ThemeConstants.spacingSmall,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: border,
        thickness: 1,
        space: ThemeConstants.spacingMedium,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: accent.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.all(TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: secondary,
        )),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? accent : secondary,
            size: ThemeConstants.iconMedium,
          );
        }),
        height: 64,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surface,
        selectedIconTheme: IconThemeData(color: accent, size: ThemeConstants.iconMedium),
        unselectedIconTheme: IconThemeData(color: secondary, size: ThemeConstants.iconMedium),
        selectedLabelTextStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: accent,
        ),
        unselectedLabelTextStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: secondary,
        ),
        indicatorColor: accent.withValues(alpha: 0.15),
      ),
      textTheme: _buildTextTheme(brightness),
    );
  }

  static TextTheme _buildTextTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final color = isLight ? _lightPrimary : _darkPrimary;
    final secondaryColor = isLight ? _lightSecondary : _darkSecondary;
    final mutedColor = isLight ? _lightMuted : _darkMuted;

    return TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -1, color: color),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.8, color: color),
      displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: color),
      headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.4, color: color),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.3, color: color),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.2, color: color),
      titleLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -0.2, color: color),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: -0.1, color: color),
      titleSmall: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: color),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: -0.1, color: color, height: 1.5),
      bodyMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: secondaryColor, height: 1.4),
      bodySmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: mutedColor, height: 1.3),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: mutedColor),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: mutedColor, letterSpacing: 0.1),
    );
  }
}
