import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tema: color base 0xFF1A1A2E. Paleta derivada + Glassmorphism + Bento.
class AppTheme {
  AppTheme._();

  // --- COLOR BASE (único fijo) ---
  static const Color primary = Color(0xFF1A1A2E);

  // Paleta derivada del base (tonos azul oscuro / índigo)
  static const Color surfaceDark = Color(0xFF1E1E36);
  static const Color surface = Color(0xFF252542);
  static const Color surfaceCard = Color(0xFF2A2A48);
  static const Color surfaceElevated = Color(0xFF32325A);
  static const Color primaryLight = Color(0xFF2E2E4A);

  // Acentos armónicos al base (muted, no brillantes)
  static const Color accent = Color(0xFF4A5568);
  static const Color accentLight = Color(0x1AFFFFFF);
  static const Color accentDim = Color(0xFF3D4654);
  static const Color accentCyan = Color(0xFF4A5F5C);
  static const Color accentCyanDim = Color(0xFF3D514E);
  static const Color accentOlive = Color(0xFFFFB347);
  static const Color accentOliveLight = Color(0xFF5C6450);
  static const Color accentGreen = Color(0xFF4A5F5C);
  static const Color accentGreenDark = Color(0xFF3D514E);
  static const Color accentBlue = Color(0xFFFFB347);
  static const Color accentBlueLight = Color(0xFF4A5568);
  static const Color accentAmber = Color(0xFF6B5C3D);
  static const Color accentCoral = Color(0xFF6B4A4A);

  // Botones minimalistas (fill suave, armónico con base)
  static const Color buttonPrimaryFill = Colors.transparent;
  static const Color buttonSecondaryFill = Color(0x1AFFFFFF);
  static const Color buttonBorder = Colors.white;

  // Texto
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFFB8B8C8);
  static const Color textMuted = Colors.white;
  static const Color textHint = Color(0xFF5C5C70);

  // Utilidades
  static Color get border => Colors.white.withOpacity(0.08);
  static Color get borderFocus => accentLight.withOpacity(0.6);
  static Color cardOverlay(double opacity) => Colors.white.withOpacity(opacity.clamp(0.0, 1.0));

  // Gradientes (derivados del base)
  static LinearGradient get gradientPrimary => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF252542), Color(0xFF1A1A2E)],
      );

  static final LinearGradient gradientGlass = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withOpacity(0.12),
      Colors.white.withOpacity(0.04),
    ],
  );

  static const LinearGradient gradientButtonGreen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3D514E), Color(0xFF2E3D3A)],
  );

  static const LinearGradient gradientButtonOlive = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3D4236), Color(0xFF2E3328)],
  );

  static const LinearGradient gradientButtonBlue = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF363D4E), Color(0xFF2A3040)],
  );

  static LinearGradient gradientOverlay(double opacity) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, primary.withOpacity(opacity)],
      );

  // --- GLASSMORPHISM ---
  static const double glassBlurSigma = 12;
  static ImageFilter get glassBlur => ImageFilter.blur(sigmaX: glassBlurSigma, sigmaY: glassBlurSigma);

  static BoxDecoration glassDecoration({
    double? radius,
    Color? borderColor,
    double borderOpacity = 0.15,
  }) {
    final r = radius ?? radiusCard;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(r),
      border: Border.all(
        color: borderColor ?? Colors.white.withOpacity(borderOpacity),
        width: 1.2,
      ),
      gradient: gradientGlass,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 24,
          offset: const Offset(0, 8),
          spreadRadius: -4,
        ),
      ],
    );
  }

  // --- TIPOGRAFÍA ---
  static TextStyle get displayLarge => GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: textPrimary,
        letterSpacing: -0.6,
        height: 1.15,
      );

  static TextStyle get titleLarge => GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.3,
      );

  static TextStyle get titleMedium => GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      );

  static TextStyle get titleSection => GoogleFonts.plusJakartaSans(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: 0.2,
      );

  static TextStyle get body => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        height: 1.4,
      );

  static TextStyle get caption => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.white,
        letterSpacing: 0.2,
      );

  static TextStyle get label => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: textMuted,
        letterSpacing: 0.3,
      );

  static TextStyle get subtitle => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textMuted,
        letterSpacing: 0.2,
      );

  // --- SOMBRAS ---
  static final List<BoxShadow> shadowCard = [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 6),
      spreadRadius: -2,
    ),
  ];

  static List<BoxShadow> shadowButton(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.35),
          blurRadius: 14,
          offset: const Offset(0, 4),
          spreadRadius: -2,
        ),
      ];

  // --- RADIOS (Bento / Glass) ---
  static const double radiusCard = 20;
  static const double radiusBento = 16;
  static const double radiusButton = 14;
  static const double radiusInput = 14;

  // Compatibilidad
  static BoxDecoration cardGlass({double? radius, Color? borderColor}) {
    final r = radius ?? radiusCard;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(r),
      border: Border.all(color: borderColor ?? Colors.white.withOpacity(0.1), width: 1),
      color: surfaceCard,
      boxShadow: shadowCard,
    );
  }

  static BoxDecoration cardDecoration({double? radius, Color? borderColor}) =>
      glassDecoration(radius: radius ?? radiusCard, borderColor: borderColor);

  static const double pedidoCardRadius = 18;
  static BoxDecoration get pedidoCardDecoration => cardGlass(radius: pedidoCardRadius);

  static BoxDecoration cardElevated({double? radius}) {
    return BoxDecoration(
      color: surfaceElevated,
      borderRadius: BorderRadius.circular(radius ?? radiusCard),
      border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
      boxShadow: shadowCard,
    );
  }

  static BoxDecoration inputGlass({bool focused = false}) {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.06),
      borderRadius: BorderRadius.circular(radiusInput),
      border: Border.all(
        color: focused ? accentLight.withOpacity(0.6) : Colors.white.withOpacity(0.1),
        width: focused ? 2 : 1,
      ),
    );
  }

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primary,
      primaryColor: primary,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      colorScheme: ColorScheme.dark(
        primary: accent,
        secondary: accentCyan,
        surface: surface,
        error: accentCoral,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textSecondary, size: 24),
        titleTextStyle: titleMedium,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusButton)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.06),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusInput)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: BorderSide(color: accentLight.withOpacity(0.5), width: 2),
        ),
        labelStyle: caption,
        hintStyle: caption.copyWith(color: textHint),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceElevated,
        contentTextStyle: body,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
