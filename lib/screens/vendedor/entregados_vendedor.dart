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
  List<PedidoModel> _allEntregados = [];
  List<PedidoModel> _filteredEntregados = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

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
      _allEntregados = lista;
      _filteredEntregados = lista;
      _isLoading = false;
    });
  }

  void _filterPedidos(String query) {
    setState(() {
      _filteredEntregados = _allEntregados.where((p) {
        final searchLower = query.toLowerCase();
        // Corrección de sintaxis: p.cliente?.nombreCliente es String no nulo
        final nombreCliente = p.cliente?.nombreCliente.toLowerCase() ?? "";
        final idPedido = p.idPedido.toString();
        
        return idPedido.contains(searchLower) || nombreCliente.contains(searchLower);
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
            const AppPageHeader(
              title: "Historial de entregas",
              subtitle: "Entregas completadas",
            ),
            _buildSearchBar(),
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
                : _filteredEntregados.isEmpty
                  ? Center(
                      child: Text(
                        _searchController.text.isEmpty 
                            ? "Aún no tienes entregas registradas" 
                            : "No se encontraron coincidencias", 
                        style: AppTheme.body.copyWith(color: AppTheme.textMuted)
                      )
                    )
                  : RefreshIndicator(
                      onRefresh: _cargarHistorial,
                      color: AppTheme.accent,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        itemCount: _filteredEntregados.length,
                        itemBuilder: (context, index) => _CardEntregaExito(pedido: _filteredEntregados[index]),
                      ),
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
          suffixIcon: _searchController.text.isNotEmpty 
            ? IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () {
                  _searchController.clear();
                  _filterPedidos("");
                },
              ) 
            : null,
          filled: true,
          fillColor: AppTheme.cardOverlay(0.05),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15), 
            borderSide: BorderSide.none
          ),
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
            title: Text("Pedido #${p.idPedido}", style: AppTheme.body.copyWith(fontWeight: FontWeight.w700)),
            // Corrección aquí también para evitar la advertencia
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
                      child: Image.network(
                        urlFotoEvidencia, 
                        height: 150, 
                        width: double.infinity, 
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 100,
                          color: Colors.black12,
                          child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                        ),
                      ),
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