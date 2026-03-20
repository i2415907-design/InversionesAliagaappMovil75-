import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rutasinversionesaliaga/service/admin_service.dart';
import 'package:rutasinversionesaliaga/models/pedido_model.dart';
import 'package:rutasinversionesaliaga/utils/app_theme.dart';
import 'package:rutasinversionesaliaga/widgets/status_chip.dart';
import 'package:rutasinversionesaliaga/widgets/app_page_header.dart';

class AdminPendientesPage extends StatefulWidget {
  const AdminPendientesPage({super.key});

  @override
  State<AdminPendientesPage> createState() => _AdminPendientesPageState();
}

class _AdminPendientesPageState extends State<AdminPendientesPage> {
  final AdminService _adminService = AdminService();
  List<PedidoModel> _allPedidos = [];
  List<PedidoModel> _filteredPedidos = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPedidos();
  }

  void _fetchPedidos() {
    setState(() => _isLoading = true);
    _adminService.getPedidosPorEstado('pendiente').then((dynamic lista) {
      if (mounted) {
        setState(() {
          _allPedidos = (lista as List).map((e) => PedidoModel.fromJson(e)).toList();
          _filteredPedidos = _allPedidos;
          _isLoading = false;
        });
      }
    });
  }

  void _filterPedidos(String query) {
    setState(() {
      _filteredPedidos = _allPedidos.where((p) {
        final searchLower = query.toLowerCase();
        final id = p.idPedido.toString();
        final cliente = p.cliente?.nombreCliente.toLowerCase() ?? "";
        return id.contains(searchLower) || cliente.contains(searchLower);
      }).toList();
    });
  }

  Future<void> _cambiarEstado(int idPedido) async {
    bool success = await _adminService.actualizarEstadoPedido(idPedido, 'enviado');
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pedido enviado a ruta"), backgroundColor: Colors.green),
      );
      _fetchPedidos();
      _searchController.clear();
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
            _buildSearchBar(),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
                : _filteredPedidos.isEmpty
                  ? Center(child: Text("No se encontraron pedidos", style: AppTheme.bodySmall.copyWith(color: AppTheme.textMuted)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      itemCount: _filteredPedidos.length,
                      itemBuilder: (context, index) => _buildPedidoAdminCard(_filteredPedidos[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: TextField(
        controller: _searchController,
        onChanged: _filterPedidos,
        style: AppTheme.bodySmall,
        decoration: InputDecoration(
          hintText: "Buscar por N° pedido o cliente...",
          hintStyle: AppTheme.caption,
          prefixIcon: Icon(Icons.search, color: AppTheme.accent, size: 20),
          filled: true,
          fillColor: AppTheme.cardOverlay(0.05),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }

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
              decoration: BoxDecoration(color: AppTheme.cardOverlay(0.06), borderRadius: BorderRadius.circular(14)),
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