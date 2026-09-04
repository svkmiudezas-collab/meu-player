import 'package:flutter/material.dart';

/// Paleta: fundo índigo profundo, lilás como única cor de destaque,
/// texto em branco-marfim. Um só acento, usado só onde há ação.
class Palette {
  static const bg = Color(0xFF14121E);
  static const surface = Color(0xFF1F1C2C);
  static const surfaceHigh = Color(0xFF2A2639);
  static const accent = Color(0xFFC39BF5);
  static const text = Color(0xFFF4EFE4);
  static const muted = Color(0xFF9A93AB);
}

ThemeData buildTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: Palette.bg,
    colorScheme: const ColorScheme.dark(
      primary: Palette.accent,
      onPrimary: Palette.bg,
      surface: Palette.surface,
      onSurface: Palette.text,
      secondary: Palette.accent,
      onSecondary: Palette.bg,
      surfaceContainerHighest: Palette.surfaceHigh,
      outline: Palette.muted,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: Palette.text,
      displayColor: Palette.text,
    ).copyWith(
      headlineLarge: const TextStyle(
        fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.8, height: 1.1),
      titleLarge: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      bodyMedium: const TextStyle(fontSize: 14, color: Palette.muted),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Palette.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Palette.text, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.6),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Palette.surface,
      indicatorColor: Palette.accent.withOpacity(0.18),
      surfaceTintColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
            fontSize: 12,
            fontWeight: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
            color: s.contains(WidgetState.selected) ? Palette.text : Palette.muted,
          )),
      iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
            color: s.contains(WidgetState.selected) ? Palette.accent : Palette.muted,
          )),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: Palette.muted,
      textColor: Palette.text,
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: Palette.accent,
      inactiveTrackColor: Palette.surfaceHigh,
      thumbColor: Palette.accent,
      trackHeight: 3,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
      overlayShape: RoundSliderOverlayShape(overlayRadius: 14),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Palette.surface,
      surfaceTintColor: Colors.transparent,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Palette.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Palette.accent,
        foregroundColor: Palette.bg,
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Palette.surfaceHigh,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    ),
    dividerColor: Palette.surfaceHigh,
  );
}
