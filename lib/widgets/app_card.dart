import 'package:flutter/material.dart';
import 'package:rutasinversionesaliaga/utils/app_theme.dart';

/// Card reutilizable con estilo unificado (bordes redondeados, sombra, padding).
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? radius;
  final Color? backgroundColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.radius,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final r = radius ?? AppTheme.radiusCard;
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(r),
        border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
        boxShadow: AppTheme.shadowCard,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(20),
        child: child,
      ),
    );
  }
}
