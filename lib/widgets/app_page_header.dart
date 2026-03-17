import 'package:flutter/material.dart';
import 'package:rutasinversionesaliaga/utils/app_theme.dart';

/// Cabecera de pantalla reutilizable: título + subtítulo opcional.
class AppPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const AppPageHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.displayLarge.copyWith(fontSize: 26),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textMuted,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
