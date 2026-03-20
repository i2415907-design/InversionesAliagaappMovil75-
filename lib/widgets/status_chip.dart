import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rutasinversionesaliaga/utils/app_theme.dart';

/// Chip de estado unificado para pedidos (pendiente, enviado, entregado, etc.).
/// Mismo estilo en cliente, admin y vendedor.
class StatusChip extends StatelessWidget {
  final String estado;

  const StatusChip({super.key, required this.estado});

  static Color _colorForEstado(String estado) {
    final e = estado.toLowerCase();
    if (e == 'pendiente') return AppTheme.accentAmber;
    if (e == 'enviado' || e == 'en camino') return AppTheme.accentBlue;
    if (e == 'entregado') return AppTheme.accentGreen;
    return AppTheme.textMuted;
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForEstado(estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.35), width: 1),
      ),
      child: Text(
        estado.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
