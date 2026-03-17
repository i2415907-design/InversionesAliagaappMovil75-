import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rutasinversionesaliaga/service/admin_service.dart';
import 'package:rutasinversionesaliaga/models/pedido_model.dart';
import 'package:rutasinversionesaliaga/utils/app_theme.dart';
import 'package:rutasinversionesaliaga/widgets/status_chip.dart';
import 'package:rutasinversionesaliaga/widgets/app_page_header.dart';

class AdminEnCaminoPage extends StatefulWidget {
  const AdminEnCaminoPage({super.key});

  @override
  State<AdminEnCaminoPage> createState() => _AdminEnCaminoPageState();
}

class _AdminEnCaminoPageState extends State<AdminEnCaminoPage> {
  final AdminService _adminService = AdminService();
  Future<List<PedidoModel>>? _pedidosFuture;

  @override
  void initState() {
    super.initState();
    _fetchPedidos();
  }

  void _fetchPedidos() {
    setState(() {
      _pedidosFuture = _adminService.getPedidosPorEstado('enviado').then((dynamic lista) {
        return (lista as List).map((e) => PedidoModel.fromJson(e)).toList();
      });
    });
  }

  Future<void> _finalizarPedido(int idPedido) async {
    bool success = await _adminService.actualizarEstadoPedido(idPedido, 'entregado');
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("¡Pedido marcado como ENTREGADO!"), backgroundColor: Colors.blue),
        );
        _fetchPedidos(); 
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            const AppPageHeader(
              title: "Pedidos en ruta",
              subtitle: "Seguimiento de entregas",
            ),
            Expanded(
              child: FutureBuilder<List<PedidoModel>>(
                future: _pedidosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("No hay pedidos en ruta actualmente", style: AppTheme.body.copyWith(color: AppTheme.textMuted)));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) => _buildEnCaminoCard(snapshot.data![index]),
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

  Widget _buildEnCaminoCard(PedidoModel pedido) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppTheme.pedidoCardDecoration,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Icon(Icons.local_shipping_rounded, color: AppTheme.accentBlue, size: 24),
        title: Text("Pedido N° ${pedido.idPedido}", style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              StatusChip(estado: pedido.estado),
              const SizedBox(width: 8),
              Expanded(child: Text("Cliente: ${pedido.cliente?.nombreCliente ?? 'N/A'}", style: AppTheme.bodySmall, overflow: TextOverflow.ellipsis)),
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
                _rowInfo(Icons.location_on_rounded, "Distrito: ${pedido.distrito?.nombre ?? 'N/A'}"),
                _rowInfo(Icons.home_rounded, "Dirección: ${pedido.tempDireccion}"),
                _rowInfo(Icons.explore_rounded, "Ref: ${pedido.tempReferencia}"),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.cardOverlay(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(backgroundColor: AppTheme.accentOlive.withOpacity(0.3), child: Icon(Icons.delivery_dining_rounded, color: AppTheme.accentOlive, size: 22)),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("VENDEDOR / ENCARGADO:", style: AppTheme.caption.copyWith(fontWeight: FontWeight.w600)),
                          Text(pedido.nombreEncargado, style: AppTheme.bodySmall.copyWith(color: AppTheme.accentOlive, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => _finalizarPedido(pedido.idPedido),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("CONFIRMAR ENTREGA FINAL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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