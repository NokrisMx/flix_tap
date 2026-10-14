import 'package:flutter/material.dart';

class AppTheme {
  static const _background = Color(0xFF081A2F);
  static const _surface = Color(0xFF10243A);
  static const _surfaceRaised = Color(0xFF18324D);
  static const _primary = Color(0xFF69BDEB);
  static const _secondary = Color(0xFFF2937A);
  static const _text = Color(0xFFF4F7FB);
  static const _mutedText = Color(0xFFB3C1D1);
  static const _outline = Color(0xFF29445F);

  ThemeData getTheme() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: _background,
          brightness: Brightness.dark,
        ).copyWith(
          primary: _primary,
          onPrimary: _background,
          primaryContainer: _surfaceRaised,
          onPrimaryContainer: _text,
          secondary: _secondary,
          onSecondary: _background,
          secondaryContainer: const Color(0xFF49313C),
          onSecondaryContainer: _text,
          surface: _surface,
          onSurface: _text,
          onSurfaceVariant: _mutedText,
          outline: _outline,
          outlineVariant: const Color(0xFF203952),
        );
    final baseTextTheme = ThemeData.dark().textTheme;
    final textTheme = baseTextTheme
        .apply(bodyColor: _text, displayColor: _text)
        .copyWith(
          titleLarge: baseTextTheme.titleLarge?.copyWith(
            color: _text,
            fontWeight: FontWeight.w700,
          ),
          titleMedium: baseTextTheme.titleMedium?.copyWith(
            color: _text,
            fontWeight: FontWeight.w700,
          ),
          titleSmall: baseTextTheme.titleSmall?.copyWith(
            color: _text,
            fontWeight: FontWeight.w600,
          ),
          bodySmall: baseTextTheme.bodySmall?.copyWith(color: _mutedText),
          labelSmall: baseTextTheme.labelSmall?.copyWith(color: _mutedText),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _background,
      canvasColor: _background,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: _background,
        foregroundColor: _text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _surface,
        selectedItemColor: _primary,
        unselectedItemColor: _mutedText,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: _surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: _outline),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _surfaceRaised,
        selectedColor: _primary,
        secondarySelectedColor: _surfaceRaised,
        disabledColor: _surface,
        side: const BorderSide(color: _outline),
        shape: const StadiumBorder(),
        labelStyle: const TextStyle(color: _text, fontWeight: FontWeight.w600),
        secondaryLabelStyle: const TextStyle(color: _text),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceRaised,
        hintStyle: const TextStyle(color: _mutedText),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: _background,
          backgroundColor: _primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _text,
          side: const BorderSide(color: _outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(color: _outline, thickness: 1),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: _surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}
