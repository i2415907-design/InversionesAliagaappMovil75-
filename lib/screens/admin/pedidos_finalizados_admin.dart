import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rutasinversionesaliaga/service/admin_service.dart';
import 'package:rutasinversionesaliaga/models/pedido_model.dart';
import 'package:rutasinversionesaliaga/utils/app_theme.dart';
import 'package:rutasinversionesaliaga/widgets/status_chip.dart';
import 'package:rutasinversionesaliaga/widgets/app_page_header.dart';

class AdminFinalizadosPage extends StatefulWidget {
  const AdminFinalizadosPage({super.key});

  @override
  State<AdminFinalizadosPage> createState() => _AdminFinalizadosPageState();
}

class _AdminFinalizadosPageState extends State<AdminFinalizadosPage> {
  final AdminService _adminService = AdminService();
  Future<List<PedidoModel>>? _pedidosFuture;

  @override
  void initState() {
    super.initState();
    _fetchPedidos();
  }

  void _fetchPedidos() {
    setState(() {
      _pedidosFuture = _adminService.getPedidosPorEstado('entregado').then((dynamic lista) {
        return (lista as List).map((e) => PedidoModel.fromJson(e)).toList();
      });
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
              subtitle: "Pedidos finalizados",
            ),
            Expanded(
              child: FutureBuilder<List<PedidoModel>>(
                future: _pedidosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("No hay pedidos finalizados", style: AppTheme.body.copyWith(color: AppTheme.textMuted)));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) => _buildFinalizadoCard(snapshot.data![index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

// ... (imports y lógica de fetch iguales)

  Widget _buildFinalizadoCard(PedidoModel pedido) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppTheme.pedidoCardDecoration,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Icon(Icons.check_circle_rounded, color: AppTheme.accent, size: 24),
        title: Text("Pedido N° ${pedido.idPedido}", style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              StatusChip(estado: pedido.estado),
              const SizedBox(width: 8),
              Expanded(child: Text("Entregado por: ${pedido.nombreEncargado}", style: AppTheme.bodySmall, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
        iconColor: AppTheme.textSecondary,
        collapsedIconColor: AppTheme.textSecondary,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _rowInfo(Icons.person_rounded, "Cliente: ${pedido.cliente?.nombreCliente ?? 'N/A'}"),
                _rowInfo(Icons.home_rounded, "Dirección: ${pedido.tempDireccion}"),
                Divider(color: AppTheme.border, height: 24),
                Text("DETALLES DE LA EXPERIENCIA:", style: AppTheme.caption.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                pedido.total == "0" ? _buildSinResenaWidget() : _buildDetalleResena(pedido),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSinResenaWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardOverlay(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 20, color: AppTheme.textMuted),
          const SizedBox(width: 12),
          Expanded(child: Text("El cliente aún no ha calificado este pedido.", style: AppTheme.bodySmall.copyWith(fontStyle: FontStyle.italic, color: AppTheme.textMuted))),
        ],
      ),
    );
  }

  Widget _buildDetalleResena(PedidoModel pedido) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: List.generate(5, (index) => Icon(Icons.star_rounded, color: AppTheme.accentAmber, size: 20))),
        const SizedBox(height: 8),
        Text("Excelente servicio, llegó muy rápido y el producto está en perfecto estado.", style: AppTheme.bodySmall),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            'https://via.placeholder.com/400x200',
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 150,
              decoration: BoxDecoration(color: AppTheme.cardOverlay(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.broken_image_rounded, color: AppTheme.textMuted, size: 48),
            ),
          ),
        ),
      ],
    );
  }

  Widget _rowInfo(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textMuted),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppTheme.bodySmall)),
        ],
      ),
    );
  }
}