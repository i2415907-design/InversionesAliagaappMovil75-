import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rutasinversionesaliaga/utils/app_theme.dart';

/// Botón principal: estilo minimalista, fill suave, sin brillo, armónico con base.
class ButtonPrimary extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final bool useGradient;

  const ButtonPrimary({
    super.key,
    required this.text,
    required this.onPressed,
    required this.color,
    this.useGradient = false,
  });

  Color _fillForColor(Color c) {
    if (c.value == AppTheme.accentGreen.value) return AppTheme.gradientButtonGreen.colors.first;
    if (c.value == AppTheme.accentOlive.value) return AppTheme.gradientButtonOlive.colors.first;
    if (c.value == AppTheme.accentBlue.value) return AppTheme.gradientButtonBlue.colors.first;
    return c;
  }

  @override
  Widget build(BuildContext context) {
    final fill = _fillForColor(color);
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusButton),
        color: fill,
        border: Border.all(color: AppTheme.buttonBorder.withOpacity(0.6), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppTheme.radiusButton),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón secundario: contorno sutil, fondo muy suave.
class ButtonSecondary extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;

  const ButtonSecondary({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusButton),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
        color: Colors.white.withOpacity(0.04),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppTheme.radiusButton),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppTheme.textSecondary, size: 22),
                const SizedBox(width: 10),
              ],
              Text(
                text,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botón social (Google): minimalista, sin brillo.
class ButtonSocial extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final String imageUrl;

  const ButtonSocial({
    super.key,
    required this.text,
    required this.onPressed,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusButton),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        color: Colors.white.withOpacity(0.04),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppTheme.radiusButton),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                imageUrl,
                height: 20,
                width: 20,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(Icons.login_rounded, color: AppTheme.textSecondary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                text,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
