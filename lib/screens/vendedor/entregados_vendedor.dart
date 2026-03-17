import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rutasinversionesaliaga/models/pedido_model.dart';
import 'package:rutasinversionesaliaga/service/vendedor_service.dart';
import 'package:rutasinversionesaliaga/utils/app_theme.dart';
import 'package:rutasinversionesaliaga/widgets/status_chip.dart';
import 'package:rutasinversionesaliaga/widgets/app_page_header.dart';

class PedidosEntregadosVendedorPage extends StatefulWidget {
  const PedidosEntregadosVendedorPage({super.key});

  @override
  State<PedidosEntregadosVendedorPage> createState() => _PedidosEntregadosVendedorPageState();
}

class _PedidosEntregadosVendedorPageState extends State<PedidosEntregadosVendedorPage> {
  final VendedorService _vendedorService = VendedorService();
  List<PedidoModel> _entregados = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    final lista = await _vendedorService.getPedidosEntregados(token);
    setState(() {
      _entregados = lista;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            const AppPageHeader(
              title: "Historial de entregas",
              subtitle: "Entregas completadas",
            ),
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
                : _entregados.isEmpty
                  ? Center(child: Text("Aún no tienes entregas registradas", style: AppTheme.body.copyWith(color: AppTheme.textMuted)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      itemCount: _entregados.length,
                      itemBuilder: (context, index) => _CardEntregaExito(pedido: _entregados[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardEntregaExito extends StatefulWidget {
  final PedidoModel pedido;
  const _CardEntregaExito({required this.pedido});

  @override
  State<_CardEntregaExito> createState() => _CardEntregaExitoState();
}

class _CardEntregaExitoState extends State<_CardEntregaExito> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.pedido;
    // Asumimos que los datos de reseña vienen en el JSON (puedes ajustar los nombres según tu API)
final double calificacion = double.tryParse(p.calificacion ?? '0') ?? 0;
    final String comentario = p.comentario ?? "Sin comentarios del cliente";
    final String urlFotoEvidencia = p.fotoEvidencia ?? "";

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardOverlay(0.06),
        borderRadius: BorderRadius.circular(AppTheme.pedidoCardRadius),
        border: Border.all(color: AppTheme.accent.withOpacity(0.25)),
        boxShadow: AppTheme.shadowCard,
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            leading: Icon(Icons.check_circle_rounded, color: AppTheme.accent, size: 28),
            title: Text("Pedido #${p.idPedido}", style: AppTheme.body.copyWith(fontWeight: FontWeight.w500)),
            subtitle: Text(p.cliente?.nombreCliente ?? "Cliente", style: AppTheme.caption),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star_rounded, color: AppTheme.accentAmber, size: 18),
                const SizedBox(width: 4),
                Text(calificacion.toString(), style: TextStyle(color: AppTheme.accentAmber, fontWeight: FontWeight.w600)),
                const SizedBox(width: 10),
                Icon(_isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: AppTheme.textMuted),
              ],
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: AppTheme.border, height: 1),
                  const SizedBox(height: 12),
                  if (urlFotoEvidencia.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(urlFotoEvidencia, height: 150, width: double.infinity, fit: BoxFit.cover),
                    ),
                  const SizedBox(height: 14),
                  Text("RESEÑA DEL CLIENTE:", style: AppTheme.caption.copyWith(color: AppTheme.accentAmber, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(comentario, style: AppTheme.bodySmall.copyWith(fontStyle: FontStyle.italic)),
                  const SizedBox(height: 14),
                  Text("DETALLES:", style: AppTheme.caption.copyWith(fontWeight: FontWeight.w600)),
                  Text("Fecha entrega: ${p.fecha}", style: AppTheme.bodySmall),
                  Text("Total pagado: S/ ${p.total}", style: AppTheme.bodySmall),
                ],
              ),
            ),
        ],
      ),
    );
  }
}