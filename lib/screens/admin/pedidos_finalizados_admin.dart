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
    _adminService.getPedidosPorEstado('entregado').then((dynamic lista) {
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
               p.nombreEncargado.toLowerCase().contains(searchLower) ||
               (p.cliente?.nombreCliente.toLowerCase().contains(searchLower) ?? false);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            const AppPageHeader(title: "Historial de entregas", subtitle: "Pedidos finalizados"),
            _buildSearchBar(),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
                : _filteredPedidos.isEmpty
                  ? Center(child: Text("Sin registros encontrados", style: AppTheme.bodySmall.copyWith(color: AppTheme.textMuted)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      itemCount: _filteredPedidos.length,
                      itemBuilder: (context, index) => _buildFinalizadoCard(_filteredPedidos[index]),
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
          hintText: "Buscar por pedido, cliente o quien entregó...",
          hintStyle: AppTheme.caption,
          prefixIcon: Icon(Icons.history_rounded, color: AppTheme.accentAmber),
          filled: true,
          fillColor: AppTheme.cardOverlay(0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }

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
      decoration: BoxDecoration(color: AppTheme.cardOverlay(0.06), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.border)),
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
        Text("Excelente servicio, llegó muy rápido.", style: AppTheme.bodySmall),
      ],
    );
  }

  Widget _rowInfo(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [Icon(icon, size: 18, color: AppTheme.textMuted), const SizedBox(width: 10), Expanded(child: Text(text, style: AppTheme.bodySmall))]),
    );
  }
}