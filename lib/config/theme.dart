import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color accent;
  final Color accentSoft;
  final Color accentGradientStart;
  final Color accentGradientEnd;
  final Color surfaceElevated;
  final Color border;
  final Color muted;

  const AppColors({
    required this.accent,
    required this.accentSoft,
    required this.accentGradientStart,
    required this.accentGradientEnd,
    required this.surfaceElevated,
    required this.border,
    required this.muted,
  });

  static const dark = AppColors(
    accent: Color(0xFF7C5CFC),
    accentSoft: Color(0xFF7C5CFC),
    accentGradientStart: Color(0xFF7C5CFC),
    accentGradientEnd: Color(0xFFB454F8),
    surfaceElevated: Color(0xFF1E1E24),
    border: Color(0xFF2A2A32),
    muted: Color(0xFF6B6B76),
  );

  static const light = AppColors(
    accent: Color(0xFF6B4FE6),
    accentSoft: Color(0xFF6B4FE6),
    accentGradientStart: Color(0xFF6B4FE6),
    accentGradientEnd: Color(0xFF9333EA),
    surfaceElevated: Color(0xFFFFFFFF),
    border: Color(0xFFE5E5EA),
    muted: Color(0xFF8E8E93),
  );

  @override
  AppColors copyWith({
    Color? accent,
    Color? accentSoft,
    Color? accentGradientStart,
    Color? accentGradientEnd,
    Color? surfaceElevated,
    Color? border,
    Color? muted,
  }) =>
      AppColors(
        accent: accent ?? this.accent,
        accentSoft: accentSoft ?? this.accentSoft,
        accentGradientStart: accentGradientStart ?? this.accentGradientStart,
        accentGradientEnd: accentGradientEnd ?? this.accentGradientEnd,
        surfaceElevated: surfaceElevated ?? this.surfaceElevated,
        border: border ?? this.border,
        muted: muted ?? this.muted,
      );

  @override
  AppColors lerp(AppColors? other, double t) => AppColors(
        accent: Color.lerp(accent, other?.accent, t)!,
        accentSoft: Color.lerp(accentSoft, other?.accentSoft, t)!,
        accentGradientStart: Color.lerp(accentGradientStart, other?.accentGradientStart, t)!,
        accentGradientEnd: Color.lerp(accentGradientEnd, other?.accentGradientEnd, t)!,
        surfaceElevated: Color.lerp(surfaceElevated, other?.surfaceElevated, t)!,
        border: Color.lerp(border, other?.border, t)!,
        muted: Color.lerp(muted, other?.muted, t)!,
      );
}

class AppTheme {
  AppTheme._();

  static const Color _darkBg = Color(0xFF0D0D11);
  static const Color _darkSurface = Color(0xFF16161C);
  static const Color _darkPrimary = Color(0xFFF4F4F6);
  static const Color _darkError = Color(0xFFFF453A);

  static const Color _lightBg = Color(0xFFF6F6F8);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightPrimary = Color(0xFF1A1A1F);
  static const Color _lightError = Color(0xFFFF3B30);

  static ThemeData get darkTheme => _buildTheme(Brightness.dark);
  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final bg = isDark ? _darkBg : _lightBg;
    final surface = isDark ? _darkSurface : _lightSurface;
    final primary = isDark ? _darkPrimary : _lightPrimary;
    final error = isDark ? _darkError : _lightError;
    final ext = isDark ? AppColors.dark : AppColors.light;

    final displayFont = GoogleFonts.spaceGrotesk();
    final bodyFont = GoogleFonts.inter();

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme(
        primary: ext.accent,
        onPrimary: Colors.white,
        secondary: ext.accent,
        onSecondary: Colors.white,
        tertiary: ext.accentGradientEnd,
        onTertiary: Colors.white,
        error: error,
        onError: Colors.white,
        surface: surface,
        onSurface: primary,
        surfaceContainerHighest: isDark ? const Color(0xFF1E1E24) : const Color(0xFFF0F0F4),
        outline: ext.border,
        shadow: isDark ? Colors.black.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.08),
        brightness: brightness,
      ),
      scaffoldBackgroundColor: bg,
      extensions: [ext],
      textTheme: _buildTextTheme(displayFont, bodyFont, primary, ext.muted),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
          side: BorderSide(color: ext.border, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: primary,
        ),
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1A1A20) : const Color(0xFFF2F2F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
          borderSide: BorderSide(color: ext.border, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
          borderSide: BorderSide(color: ext.border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
          borderSide: BorderSide(color: ext.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
          borderSide: BorderSide(color: error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        hintStyle: GoogleFonts.inter(color: ext.muted, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: ext.muted, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ext.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ext.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: ext.border),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
          ),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ext.accent,
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: ext.accent,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? const Color(0xFF1E1E24) : const Color(0xFFF0F0F4),
        selectedColor: ext.accent.withValues(alpha: 0.15),
        labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
        side: BorderSide(color: ext.border, width: 0.5),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: ext.border,
        thickness: 0.5,
        space: 1,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: ext.accent,
        inactiveTrackColor: ext.border,
        thumbColor: ext.accent,
        overlayColor: ext.accent.withValues(alpha: 0.15),
        trackHeight: 4,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? Colors.white : ext.muted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? ext.accent : ext.border;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: ext.accent.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: ext.muted),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? ext.accent : ext.muted, size: 22);
        }),
        height: 62,
        surfaceTintColor: Colors.transparent,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: bg,
        selectedIconTheme: IconThemeData(color: ext.accent, size: 22),
        unselectedIconTheme: IconThemeData(color: ext.muted, size: 22),
        selectedLabelTextStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: ext.accent,
        ),
        unselectedLabelTextStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: ext.muted,
        ),
        indicatorColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
          side: BorderSide(color: ext.border, width: 0.5),
        ),
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: primary,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: ext.accent,
        linearTrackColor: ext.border,
      ),
      iconTheme: IconThemeData(color: primary, size: 22),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? const Color(0xFF1E1E24) : const Color(0xFF2A2A32),
        contentTextStyle: GoogleFonts.inter(color: Colors.white, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: ext.accent,
        unselectedLabelColor: ext.muted,
        indicatorColor: ext.accent,
        labelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(
    TextStyle displayFont,
    TextStyle bodyFont,
    Color color,
    Color muted,
  ) {
    return TextTheme(
      displayLarge: displayFont.copyWith(fontSize: 36, fontWeight: FontWeight.w700, letterSpacing: -1.2, color: color),
      displayMedium: displayFont.copyWith(fontSize: 30, fontWeight: FontWeight.w700, letterSpacing: -1, color: color),
      displaySmall: displayFont.copyWith(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.6, color: color),
      headlineLarge: displayFont.copyWith(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.4, color: color),
      headlineMedium: displayFont.copyWith(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.3, color: color),
      headlineSmall: displayFont.copyWith(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.2, color: color),
      titleLarge: displayFont.copyWith(fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -0.2, color: color),
      titleMedium: bodyFont.copyWith(fontSize: 15, fontWeight: FontWeight.w600, color: color),
      titleSmall: bodyFont.copyWith(fontSize: 14, fontWeight: FontWeight.w600, color: color),
      bodyLarge: bodyFont.copyWith(fontSize: 15, fontWeight: FontWeight.w400, color: color, height: 1.5),
      bodyMedium: bodyFont.copyWith(fontSize: 14, fontWeight: FontWeight.w400, color: muted, height: 1.4),
      bodySmall: bodyFont.copyWith(fontSize: 12, fontWeight: FontWeight.w400, color: muted, height: 1.3),
      labelLarge: bodyFont.copyWith(fontSize: 13, fontWeight: FontWeight.w600, color: color),
      labelMedium: bodyFont.copyWith(fontSize: 12, fontWeight: FontWeight.w500, color: muted),
      labelSmall: bodyFont.copyWith(fontSize: 11, fontWeight: FontWeight.w500, color: muted, letterSpacing: 0.2),
    );
  }
}
