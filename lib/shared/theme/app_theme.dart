import 'package:flutter/material.dart';

class AppTheme {
  static const Color _steel = Color(0xFF27323D);
  static const Color _slate = Color(0xFF3E4A57);
  static const Color _fog = Color(0xFFF2F4F7);
  static const Color _signal = Color(0xFFE66100);
  static const Color _mint = Color(0xFF1E8A6A);

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _steel,
        brightness: Brightness.light,
        primary: _steel,
        secondary: _slate,
      ),
      scaffoldBackgroundColor: _fog,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: _fog,
        foregroundColor: _steel,
      ),
    );

    return base.copyWith(
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shadowColor: const Color(0x1A1C2B3A),
        margin: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: const Color(0xFFDCE5EE),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _steel,
        foregroundColor: Colors.white,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _steel,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD7DEE6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD7DEE6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _steel, width: 1.3),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: const Color(0xFFE9EEF3),
        selectedColor: _steel,
        secondarySelectedColor: _signal,
        labelStyle: const TextStyle(color: _steel, fontWeight: FontWeight.w600),
      ),
      extensions: const [InventoryPalette(signal: _signal, mint: _mint)],
    );
  }
}

@immutable
class InventoryPalette extends ThemeExtension<InventoryPalette> {
  const InventoryPalette({required this.signal, required this.mint});

  final Color signal;
  final Color mint;

  @override
  ThemeExtension<InventoryPalette> copyWith({Color? signal, Color? mint}) {
    return InventoryPalette(
      signal: signal ?? this.signal,
      mint: mint ?? this.mint,
    );
  }

  @override
  ThemeExtension<InventoryPalette> lerp(
    covariant ThemeExtension<InventoryPalette>? other,
    double t,
  ) {
    if (other is! InventoryPalette) {
      return this;
    }
    return InventoryPalette(
      signal: Color.lerp(signal, other.signal, t) ?? signal,
      mint: Color.lerp(mint, other.mint, t) ?? mint,
    );
  }
}
