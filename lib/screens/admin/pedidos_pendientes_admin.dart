import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rutasinversionesaliaga/service/admin_service.dart';
import 'package:rutasinversionesaliaga/models/pedido_model.dart';
import 'package:rutasinversionesaliaga/utils/app_theme.dart';
import 'package:rutasinversionesaliaga/widgets/status_chip.dart';
import 'package:rutasinversionesaliaga/widgets/app_page_header.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminPendientesPage extends StatefulWidget {
  const AdminPendientesPage({super.key});

  @override
  State<AdminPendientesPage> createState() => _AdminPendientesPageState();
}

class _AdminPendientesPageState extends State<AdminPendientesPage> {
  final AdminService _adminService = AdminService();
  Future<List<PedidoModel>>? _pedidosFuture;

  @override
  void initState() {
    super.initState();
    _fetchPedidos();
  }

  void _fetchPedidos() {
    setState(() {
      // Usamos el servicio de admin para traer solo pendientes
      _pedidosFuture = _adminService.getPedidosPorEstado('pendiente').then((dynamic lista) {
        // Mapeamos el dynamic a tu PedidoModel para reusar tu lógica
        return (lista as List).map((e) => PedidoModel.fromJson(e)).toList();
      });
    });
  }

  Future<void> _cambiarEstado(int idPedido) async {
    // Cambiamos a 'enviado' para que aparezca en la siguiente pestaña
    bool success = await _adminService.actualizarEstadoPedido(idPedido, 'enviado');
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pedido enviado a ruta"), backgroundColor: Colors.green),
        );
        _fetchPedidos(); // Refrescar lista
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
              title: "Pedidos pendientes",
              subtitle: "Despacha los pedidos a ruta",
            ),
            Expanded(
              child: FutureBuilder<List<PedidoModel>>(
                future: _pedidosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("No hay pedidos pendientes", style: AppTheme.body.copyWith(color: AppTheme.textMuted)));
                  }
                  final pedidos = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    itemCount: pedidos.length,
                    itemBuilder: (context, index) => _buildPedidoAdminCard(pedidos[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

// ... (imports iguales)

  Widget _buildPedidoAdminCard(PedidoModel pedido) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppTheme.pedidoCardDecoration,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        iconColor: AppTheme.textSecondary,
        collapsedIconColor: AppTheme.textSecondary,
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
        children: [
          Divider(color: AppTheme.border, indent: 18, endIndent: 18),
          ...pedido.detalles.map((prod) => ListTile(
            dense: true,
            leading: Icon(Icons.shopping_basket_outlined, color: AppTheme.accentOlive, size: 20),
            title: Text(prod.nombre, style: AppTheme.bodySmall),
            subtitle: Text("Cantidad: ${prod.cantidad}", style: AppTheme.caption),
          )).toList(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.cardOverlay(0.06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _rowInfo(Icons.location_on_rounded, "Distrito: ${pedido.distrito?.nombre ?? 'N/A'}"),
                  _rowInfo(Icons.home_rounded, "Dirección: ${pedido.tempDireccion}"),
                  _rowInfo(Icons.explore_rounded, "Ref: ${pedido.tempReferencia}"),
                  _rowInfo(Icons.assignment_ind_rounded, "Registrado por: ${pedido.nombreEncargado}"),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: () => _cambiarEstado(pedido.idPedido),
                      icon: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 20),
                      label: const Text("DESPACHAR PEDIDO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
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