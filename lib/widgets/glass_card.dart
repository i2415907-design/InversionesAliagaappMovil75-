import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:rutasinversionesaliaga/utils/app_theme.dart';

/// Card con efecto glassmorphism: blur de fondo + borde + gradiente sutil.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? radius;
  final VoidCallback? onTap;
  final double blurSigma;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.radius,
    this.onTap,
    this.blurSigma = AppTheme.glassBlurSigma,
  });

  @override
  Widget build(BuildContext context) {
    final r = radius ?? AppTheme.radiusCard;
    return ClipRRect(
      borderRadius: BorderRadius.circular(r),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(r),
                border: Border.all(
                  color: Colors.white.withOpacity(0.18),
                  width: 1.2,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.12),
                    Colors.white.withOpacity(0.04),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                    spreadRadius: -4,
                  ),
                ],
              ),
              padding: padding ?? const EdgeInsets.all(20),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
