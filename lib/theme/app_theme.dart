// lib/theme/app_theme.dart
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  final double radius;
  final double gap;
  final double cardPadding;
  final Duration fast;
  final Duration normal;
  const AppTokens({
    required this.radius,
    required this.gap,
    required this.cardPadding,
    required this.fast,
    required this.normal,
  });
  @override
  AppTokens copyWith({
    double? radius,
    double? gap,
    double? cardPadding,
    Duration? fast,
    Duration? normal,
  }) => AppTokens(
    radius: radius ?? this.radius,
    gap: gap ?? this.gap,
    cardPadding: cardPadding ?? this.cardPadding,
    fast: fast ?? this.fast,
    normal: normal ?? this.normal,
  );
  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    double lerp(double a, double b) => a + (b - a) * t;
    return AppTokens(
      radius: lerp(radius, other.radius),
      gap: lerp(gap, other.gap),
      cardPadding: lerp(cardPadding, other.cardPadding),
      fast: Duration(
        milliseconds:
            (fast.inMilliseconds +
                    (other.fast.inMilliseconds - fast.inMilliseconds) * t)
                .round(),
      ),
      normal: Duration(
        milliseconds:
            (normal.inMilliseconds +
                    (other.normal.inMilliseconds - normal.inMilliseconds) * t)
                .round(),
      ),
    );
  }
}

class AppTheme {
  static const Color _brand = Color(0xFF2A6CF6);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _brand,
      brightness: Brightness.light,
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
    );
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFFF7F7F8),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      inputDecorationTheme: _input(base),
      elevatedButtonTheme: _elevated(base),
      filledButtonTheme: _filled(base),
      outlinedButtonTheme: _outlined(base),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      extensions: const [
        AppTokens(
          radius: 16,
          gap: 12,
          cardPadding: 16,
          fast: Duration(milliseconds: 120),
          normal: Duration(milliseconds: 220),
        ),
      ],
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _brand,
      brightness: Brightness.dark,
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
    );
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF0F1115),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      inputDecorationTheme: _input(base),
      elevatedButtonTheme: _elevated(base),
      filledButtonTheme: _filled(base),
      outlinedButtonTheme: _outlined(base),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      extensions: const [
        AppTokens(
          radius: 16,
          gap: 12,
          cardPadding: 16,
          fast: Duration(milliseconds: 120),
          normal: Duration(milliseconds: 220),
        ),
      ],
    );
  }

  static InputDecorationTheme _input(ThemeData base) {
    final cs = base.colorScheme;
    final r = (base.extension<AppTokens>()?.radius ?? 16).toDouble();
    OutlineInputBorder o(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(r),
      borderSide: BorderSide(color: c, width: 1),
    );
    return InputDecorationTheme(
      filled: true,
      fillColor: cs.surface,
      hintStyle: TextStyle(color: cs.onSurfaceVariant),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: o(cs.outlineVariant),
      enabledBorder: o(cs.outlineVariant),
      focusedBorder: o(cs.primary),
      errorBorder: o(cs.error),
      focusedErrorBorder: o(cs.error),
    );
  }

  static ElevatedButtonThemeData _elevated(ThemeData base) {
    final r = (base.extension<AppTokens>()?.radius ?? 16).toDouble();
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  static FilledButtonThemeData _filled(ThemeData base) {
    final r = (base.extension<AppTokens>()?.radius ?? 16).toDouble();
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  static OutlinedButtonThemeData _outlined(ThemeData base) {
    final r = (base.extension<AppTokens>()?.radius ?? 16).toDouble();
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: base.colorScheme.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
