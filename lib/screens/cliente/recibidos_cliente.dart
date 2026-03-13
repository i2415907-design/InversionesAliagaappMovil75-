import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rutasinversionesaliaga/service/pedido_service.dart';
import 'package:rutasinversionesaliaga/models/pedido_model.dart';
import 'package:rutasinversionesaliaga/utils/app_theme.dart';
import 'package:rutasinversionesaliaga/widgets/app_page_header.dart';

class RecibidosPedidoPage extends StatefulWidget {
  const RecibidosPedidoPage({super.key});

  @override
  State<RecibidosPedidoPage> createState() => _RecibidosPedidoPageState();
}

class _RecibidosPedidoPageState extends State<RecibidosPedidoPage> {
  final PedidoService _pedidoService = PedidoService();
  final TextEditingController _searchController = TextEditingController();
  
  Future<List<PedidoModel>>? _pedidosRecibidos;
  List<PedidoModel> _allRecibidos = [];      // Lista maestra de entregados
  List<PedidoModel> _filteredRecibidos = []; // Lista para mostrar en pantalla

  @override
  void initState() {
    super.initState();
    _loadRecibidos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecibidos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    if (token != null) {
      // 1. Obtenemos todos los pedidos
      final list = await _pedidoService.getMisPedidos(token);
      
      // 2. Filtramos solo los entregados para esta vista
      final entregados = list.where((p) => p.estado.toLowerCase() == 'entregado').toList();
      
      setState(() {
        _allRecibidos = entregados;
        _filteredRecibidos = entregados;
        _pedidosRecibidos = Future.value(entregados);
      });
    }
  }

  // Lógica de búsqueda
  void _filterRecibidos(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredRecibidos = _allRecibidos;
      } else {
        final lowercaseQuery = query.toLowerCase();
        _filteredRecibidos = _allRecibidos.where((p) {
          final matchId = p.idPedido.toString().contains(lowercaseQuery);
          final matchDireccion = (p.tempDireccion ?? "").toLowerCase().contains(lowercaseQuery);
          final matchProducto = p.detalles.any((det) => 
            det.nombre.toLowerCase().contains(lowercaseQuery)
          );
          
          return matchId || matchDireccion || matchProducto;
        }).toList();
      }
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
              title: "Recibidos",
              subtitle: "Historial de pedidos finalizados",
            ),

            // --- BARRA DE BÚSQUEDA ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: TextField(
                controller: _searchController,
                onChanged: _filterRecibidos,
                style: const TextStyle(color: Colors.white),
                decoration: _inputStyle("Buscar por N°, producto o dirección...", Icons.history_rounded).copyWith(
                  suffixIcon: _searchController.text.isNotEmpty 
                    ? IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          _filterRecibidos("");
                        },
                      )
                    : null,
                ),
              ),
            ),

            Expanded(
              child: FutureBuilder<List<PedidoModel>>(
                future: _pedidosRecibidos,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
                  }
                  
                  // Usamos la lista filtrada localmente
                  final pedidos = _filteredRecibidos;

                  if (pedidos.isEmpty) {
                    return _searchController.text.isEmpty 
                        ? _buildEmptyState() 
                        : Center(child: Text("Sin coincidencias", style: AppTheme.caption));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    itemCount: pedidos.length + 1,
                    itemBuilder: (context, index) {
                      if (index == pedidos.length) {
                        return _buildEndMessage();
                      }
                      return _buildReceivedCard(pedidos[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reutilizamos el estilo de input para mantener coherencia visual
  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppTheme.textMuted, fontSize: 14),
      prefixIcon: Icon(icon, color: AppTheme.accent, size: 22),
      filled: true,
      fillColor: AppTheme.cardOverlay(0.06),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  // --- TUS WIDGETS DE UI SE MANTIENEN IGUAL ---
  Widget _buildReceivedCard(PedidoModel pedido) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.pedidoCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("PEDIDO N°${pedido.idPedido} • ${pedido.detalles.length} Prods.", style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: AppTheme.cardOverlay(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.inventory_2_outlined, color: AppTheme.textMuted, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  pedido.detalles.map((e) => e.nombre).join(", "),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.cardOverlay(0.06),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Entregado en:", style: AppTheme.caption),
                const SizedBox(height: 4),
                Text("${pedido.tempDireccion}\nRef: ${pedido.tempReferencia}", style: AppTheme.bodySmall.copyWith(height: 1.4)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.accent.withOpacity(0.5)),
                ),
                child: Text("ENTREGADO", style: TextStyle(color: AppTheme.accent, fontSize: 10, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text("Finalizado el: ${pedido.fecha}", style: AppTheme.caption, textAlign: TextAlign.end),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text("AÚN NO TIENES\nPEDIDOS RECIBIDOS", textAlign: TextAlign.center, style: AppTheme.subtitle.copyWith(color: AppTheme.textHint, fontSize: 15)),
    );
  }

  Widget _buildEndMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Center(child: Text("HISTORIAL COMPLETO", style: AppTheme.caption.copyWith(fontWeight: FontWeight.w600))),
    );
  }
}