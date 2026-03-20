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
    _adminService.getPedidosPorEstado('enviado').then((dynamic lista) {
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
        return p.idPedido.toString().contains(searchLower) || 
               (p.cliente?.nombreCliente.toLowerCase().contains(searchLower) ?? false) ||
               p.nombreEncargado.toLowerCase().contains(searchLower);
      }).toList();
    });
  }

  Future<void> _finalizarPedido(int idPedido) async {
    bool success = await _adminService.actualizarEstadoPedido(idPedido, 'entregado');
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("¡Pedido marcado como ENTREGADO!"), backgroundColor: Colors.blue),
      );
      _fetchPedidos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            const AppPageHeader(title: "Pedidos en ruta", subtitle: "Seguimiento de entregas"),
            _buildSearchBar(),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppTheme.accentBlue))
                : _filteredPedidos.isEmpty
                  ? Center(child: Text("Sin resultados en ruta", style: AppTheme.bodySmall.copyWith(color: AppTheme.textMuted)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      itemCount: _filteredPedidos.length,
                      itemBuilder: (context, index) => _buildEnCaminoCard(_filteredPedidos[index]),
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
          hintText: "Buscar pedido, cliente o vendedor...",
          hintStyle: AppTheme.caption,
          prefixIcon: Icon(Icons.search, color: AppTheme.accentBlue),
          filled: true,
          fillColor: AppTheme.cardOverlay(0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }

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
                  decoration: BoxDecoration(color: AppTheme.cardOverlay(0.08), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      CircleAvatar(backgroundColor: AppTheme.accentBlue.withOpacity(0.2), child: Icon(Icons.delivery_dining_rounded, color: AppTheme.accentBlue, size: 22)),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("ENCARGADO ACTUAL:", style: AppTheme.caption.copyWith(fontWeight: FontWeight.w600)),
                          Text(pedido.nombreEncargado, style: AppTheme.bodySmall.copyWith(color: AppTheme.accentBlue, fontWeight: FontWeight.w600)),
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
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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