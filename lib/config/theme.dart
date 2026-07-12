import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'constants.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color accent;
  final Color accentSoft;
  final Color accentGradientStart;
  final Color accentGradientEnd;
  final Color surfaceElevated;
  final Color border;
  final Color muted;

  final Color secondary;
  final Color crema;
  final Color espresso;

  const AppColors({
    required this.accent,
    required this.accentSoft,
    required this.accentGradientStart,
    required this.accentGradientEnd,
    required this.surfaceElevated,
    required this.border,
    required this.muted,
    required this.secondary,
    required this.crema,
    required this.espresso,
  });

  static const dark = AppColors(
    accent: Color(0xFFD4956A),
    accentSoft: Color(0xFFB07A52),
    accentGradientStart: Color(0xFFE0A86E),
    accentGradientEnd: Color(0xFFB5663D),
    surfaceElevated: Color(0xFF241D17),
    border: Color(0xFF332A22),
    muted: Color(0xFF8A7B6A),
    secondary: Color(0xFF6B4A2F),
    crema: Color(0xFFF2E9DC),
    espresso: Color(0xFF0F0B08),
  );

  static const light = AppColors(
    accent: Color(0xFFA86A3C),
    accentSoft: Color(0xFFC28A5C),
    accentGradientStart: Color(0xFFB97A45),
    accentGradientEnd: Color(0xFF8B4F2A),
    surfaceElevated: Color(0xFFFFFBF5),
    border: Color(0xFFE5DACB),
    muted: Color(0xFF8A7560),
    secondary: Color(0xFF6B4A2F),
    crema: Color(0xFF2A1F17),
    espresso: Color(0xFF1F160F),
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
    Color? secondary,
    Color? crema,
    Color? espresso,
  }) =>
      AppColors(
        accent: accent ?? this.accent,
        accentSoft: accentSoft ?? this.accentSoft,
        accentGradientStart: accentGradientStart ?? this.accentGradientStart,
        accentGradientEnd: accentGradientEnd ?? this.accentGradientEnd,
        surfaceElevated: surfaceElevated ?? this.surfaceElevated,
        border: border ?? this.border,
        muted: muted ?? this.muted,
        secondary: secondary ?? this.secondary,
        crema: crema ?? this.crema,
        espresso: espresso ?? this.espresso,
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
        secondary: Color.lerp(secondary, other?.secondary, t)!,
        crema: Color.lerp(crema, other?.crema, t)!,
        espresso: Color.lerp(espresso, other?.espresso, t)!,
      );
}

class AppTheme {
  AppTheme._();

  static const Color _darkBg = Color(0xFF14100C);
  static const Color _darkSurface = Color(0xFF1E1813);
  static const Color _darkPrimary = Color(0xFFF2E9DC);
  static const Color _darkError = Color(0xFFE07A5F);

  static const Color _lightBg = Color(0xFFF5EEE3);
  static const Color _lightSurface = Color(0xFFFFFBF5);
  static const Color _lightPrimary = Color(0xFF2A1F17);
  static const Color _lightError = Color(0xFFC4502A);

  static ThemeData get darkTheme => _buildTheme(Brightness.dark);
  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final bg = isDark ? _darkBg : _lightBg;
    final surface = isDark ? _darkSurface : _lightSurface;
    final primary = isDark ? _darkPrimary : _lightPrimary;
    final error = isDark ? _darkError : _lightError;
    final ext = isDark ? AppColors.dark : AppColors.light;

    const displayFont = TextStyle();
    const bodyFont = TextStyle();

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme(
        primary: ext.accent,
        onPrimary: isDark ? ext.espresso : Colors.white,
        secondary: ext.secondary,
        onSecondary: Colors.white,
        tertiary: ext.accentGradientEnd,
        onTertiary: Colors.white,
        error: error,
        onError: Colors.white,
        surface: surface,
        onSurface: primary,
        surfaceContainerHighest: ext.surfaceElevated,
        outline: ext.border,
        shadow: isDark ? Colors.black.withValues(alpha: 0.45) : Colors.black.withValues(alpha: 0.06),
        brightness: brightness,
      ),
      scaffoldBackgroundColor: bg,
      extensions: [ext],
      textTheme: _buildTextTheme(displayFont, bodyFont, primary, ext.muted),
      cardTheme: CardThemeData(
        color: ext.surfaceElevated,
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
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
          color: primary,
        ),
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1A140F) : const Color(0xFFEFE6D7),
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
        hintStyle: TextStyle(color: ext.muted, fontSize: 14),
        labelStyle: TextStyle(color: ext.muted, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ext.accent,
          foregroundColor: isDark ? ext.espresso : Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
          ),
          textStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ext.accent,
          foregroundColor: isDark ? ext.espresso : Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
          ),
          textStyle: TextStyle(
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
          textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ext.accent,
          textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: ext.accent,
        foregroundColor: isDark ? ext.espresso : Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.borderRadius),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? const Color(0xFF241D17) : const Color(0xFFEFE6D7),
        selectedColor: ext.accent.withValues(alpha: 0.18),
        labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        side: BorderSide(color: ext.border, width: 0.5),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusPill),
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
        indicatorColor: ext.accent.withValues(alpha: 0.14),
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: ext.muted),
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
        selectedLabelTextStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: ext.accent,
        ),
        unselectedLabelTextStyle: TextStyle(
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
          borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusLarge),
          side: BorderSide(color: ext.border, width: 0.5),
        ),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: ext.accent,
        linearTrackColor: ext.border,
      ),
      iconTheme: IconThemeData(color: primary, size: 22),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? const Color(0xFF241D17) : const Color(0xFF2A1F17),
        contentTextStyle: TextStyle(color: isDark ? const Color(0xFFF2E9DC) : Colors.white, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.borderRadiusSmall),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: ext.accent,
        unselectedLabelColor: ext.muted,
        indicatorColor: ext.accent,
        labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
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
      displayLarge: displayFont.copyWith(fontSize: 40, fontWeight: FontWeight.w600, letterSpacing: -1.2, color: color),
      displayMedium: displayFont.copyWith(fontSize: 32, fontWeight: FontWeight.w600, letterSpacing: -1, color: color),
      displaySmall: displayFont.copyWith(fontSize: 26, fontWeight: FontWeight.w600, letterSpacing: -0.6, color: color),
      headlineLarge: displayFont.copyWith(fontSize: 23, fontWeight: FontWeight.w600, letterSpacing: -0.4, color: color),
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
