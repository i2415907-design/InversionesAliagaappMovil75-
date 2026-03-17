import 'package:flutter/material.dart';
import 'package:rutasinversionesaliaga/utils/app_theme.dart';

class SeguimientoPedidoMapaPage extends StatefulWidget {
  const SeguimientoPedidoMapaPage({super.key});

  @override
  State<SeguimientoPedidoMapaPage> createState() => _SeguimientoPedidoMapaPageState();
}

class _SeguimientoPedidoMapaPageState extends State<SeguimientoPedidoMapaPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Text("SEGUIMIENTO", style: AppTheme.titleSection.copyWith(letterSpacing: 2)),
              const SizedBox(height: 20),
              _buildCompactOrderInfo(),
              const SizedBox(height: 16),
              Container(
                height: 280,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppTheme.cardOverlay(0.06),
                  border: Border.all(color: AppTheme.border),
                  image: const DecorationImage(
                    image: NetworkImage('https://miro.medium.com/v2/resize:fit:1400/1*q3Z99C7p0l7W_6xInF4GqA.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                  child: Icon(Icons.location_on_rounded, color: Colors.redAccent, size: 48),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accentAmber.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.accentAmber.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_shipping_rounded, color: AppTheme.accentAmber, size: 28),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        "SERÁ ENTREGADO POR:\nJOSE CARLO MARIATEGUI",
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // SECCIÓN DE CALIFICACIÓN (Glass)
              _buildRatingSection(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactOrderInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: AppTheme.cardDecoration(radius: 16),
      child: Row(
        children: [
          Text("MI PEDIDO N°2", style: AppTheme.caption.copyWith(fontWeight: FontWeight.w600)),
          const Spacer(),
          Icon(Icons.inventory_2_outlined, color: AppTheme.textMuted, size: 20),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Solo podrás calificar cuando hayas recibido el pedido.", style: AppTheme.caption),
          const SizedBox(height: 14),
          Text("Califica la entrega:", style: AppTheme.body.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(
            children: List.generate(5, (_) => Icon(Icons.star_border_rounded, color: AppTheme.textMuted, size: 28)),
          ),
          const SizedBox(height: 14),
          Text("Comenta:", style: AppTheme.body.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          TextField(
            maxLines: 3,
            style: AppTheme.body,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.cardOverlay(0.06),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }
}