import 'dart:async'; // Necesario para el dispose del controller
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rutasinversionesaliaga/service/pedido_service.dart';
import 'package:rutasinversionesaliaga/models/pedido_model.dart';
import 'package:rutasinversionesaliaga/models/distrito_model.dart';
import 'package:rutasinversionesaliaga/utils/app_theme.dart';
import 'package:rutasinversionesaliaga/widgets/app_page_header.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class Pedidos_clientePage extends StatefulWidget {
  const Pedidos_clientePage({super.key});

  @override
  State<Pedidos_clientePage> createState() => _Pedidos_clientePageState();
}

class _Pedidos_clientePageState extends State<Pedidos_clientePage> {
  final PedidoService _pedidoService = PedidoService();
  final TextEditingController _searchController = TextEditingController(); // Controlador para el buscador
  
  Future<List<PedidoModel>>? _pedidosList;
  List<PedidoModel> _allPedidos = [];       // Lista maestra original
  List<PedidoModel> _filteredPedidos = [];  // Lista que cambia con la búsqueda
  List<DistritoModel> _listaDistritos = [];

  @override
  void initState() {
    super.initState();
    _initData();
    _loadDistritos();
  }

  @override
  void dispose() {
    _searchController.dispose(); // Limpieza de memoria
    super.dispose();
  }

  Future<void> _initData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    if (token != null) {
      // Obtenemos los datos y los guardamos localmente para filtrar sin re-llamar a la API
      final pedidos = await _pedidoService.getMisPedidos(token);
      setState(() {
        _allPedidos = pedidos;
        _filteredPedidos = pedidos;
        _pedidosList = Future.value(pedidos);
      });
    } else {
      context.go('/Inicio_sesion');
    }
  }

  // Lógica de filtrado local
void _filterPedidos(String query) {
  setState(() {
    if (query.isEmpty) {
      _filteredPedidos = _allPedidos;
    } else {
      final lowercaseQuery = query.toLowerCase();
      
      _filteredPedidos = _allPedidos.where((p) {
        // 1. Buscar por ID de pedido
        final matchId = p.idPedido.toString().contains(lowercaseQuery);
        
        // 2. Buscar por Estado del pedido
        final matchEstado = p.estado.toLowerCase().contains(lowercaseQuery);
        
        // 3. NUEVO: Buscar por nombre de producto dentro de los detalles
        final matchProducto = p.detalles.any((prod) => 
          prod.nombre.toLowerCase().contains(lowercaseQuery)
        );

        // Retorna verdadero si cualquiera de las condiciones se cumple
        return matchId || matchEstado || matchProducto;
      }).toList();
    }
  });
}

  Future<void> _loadDistritos() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    if (token.isNotEmpty) {
      final dists = await _pedidoService.getDistritos(token);
      setState(() { _listaDistritos = dists; });
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
              title: "Mis pedidos",
              subtitle: "Gestiona y da seguimiento a tus órdenes",
            ),
            
            // --- BLOQUE DEL BUSCADOR ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: _filterPedidos,
                style: const TextStyle(color: Colors.white),
                decoration: _inputStyle("Buscar por N° o nombre de producto...", Icons.search).copyWith(
                  suffixIcon: _searchController.text.isNotEmpty 
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white60, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          _filterPedidos("");
                        },
                      )
                    : null,
                ),
              ),
            ),
            // ---------------------------

            Expanded(
              child: _pedidosList == null
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
                  : FutureBuilder<List<PedidoModel>>(
                      future: _pedidosList,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
                        }
                        if (snapshot.hasError || snapshot.data == null) {
                          return Center(child: Text('Error al conectar', style: AppTheme.body.copyWith(color: AppTheme.textMuted)));
                        }
                        
                        // Usamos la lista filtrada para el ListView
                        final pedidos = _filteredPedidos;

                        if (pedidos.isEmpty) {
                          return Center(child: Text('No hay resultados', style: AppTheme.body.copyWith(color: AppTheme.textMuted)));
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          itemCount: pedidos.length,
                          itemBuilder: (context, index) => _buildPedidoExpandible(pedidos[index]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPedidoExpandible(PedidoModel pedido) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: AppTheme.pedidoCardDecoration,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        title: Text(
          "Pedido N° ${pedido.idPedido}",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            "Estado: ${pedido.estado.toUpperCase()} • S/ ${pedido.total}",
            style: AppTheme.bodySmall.copyWith(color: AppTheme.accent, fontWeight: FontWeight.w600),
          ),
        ),
        children: [
          Divider(color: AppTheme.border, height: 1),
          ...pedido.detalles.map((prod) => ListTile(
            title: Text(prod.nombre, style: AppTheme.bodySmall),
            subtitle: Text("Cant: ${prod.cantidad} • S/ ${prod.precio}", style: AppTheme.caption),
          )).toList(),
          
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                DropdownButtonFormField<int>(
                  dropdownColor: AppTheme.surface,
                  value: _listaDistritos.any((d) => d.id == pedido.tempIdDistrito) ? pedido.tempIdDistrito : null,
                  style: AppTheme.body,
                  decoration: _inputStyle("Distrito", Icons.location_city),
                  items: _listaDistritos.map((dist) => DropdownMenuItem(value: dist.id, child: Text(dist.nombre))).toList(),
                  onChanged: (val) => setState(() => pedido.tempIdDistrito = val),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: TextEditingController(text: pedido.tempDireccion)..selection = TextSelection.collapsed(offset: (pedido.tempDireccion ?? "").length),
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputStyle("Dirección", Icons.home),
                  onChanged: (val) => pedido.tempDireccion = val,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: TextEditingController(text: pedido.tempCodigoPostal)..selection = TextSelection.collapsed(offset: (pedido.tempCodigoPostal ?? "").length),
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputStyle("Código Postal", Icons.mark_as_unread),
                  onChanged: (val) => pedido.tempCodigoPostal = val,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: TextEditingController(text: pedido.tempReferencia)..selection = TextSelection.collapsed(offset: (pedido.tempReferencia ?? "").length),
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputStyle("Referencia", Icons.explore),
                  onChanged: (val) => pedido.tempReferencia = val,
                ),
                const SizedBox(height: 15),
                _buildBotonGuardar(pedido),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonGuardar(PedidoModel pedido) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () => _updatePedido(pedido),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusButton)),
        ),
        child: const Text("ACTUALIZAR DATOS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppTheme.textMuted),
      prefixIcon: Icon(icon, color: AppTheme.accent, size: 22),
      filled: true,
      fillColor: AppTheme.cardOverlay(0.06),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusInput), borderSide: BorderSide.none),
    );
  }

  Future<void> _updatePedido(PedidoModel pedido) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    bool success = await _pedidoService.updateUbicacion(
      token: token,
      idPedido: pedido.idPedido,
      idDistrito: pedido.tempIdDistrito ?? 1,
      direccionCliente: pedido.tempDireccion ?? "",
      referencia: pedido.tempReferencia ?? "",
      codigoPostal: pedido.tempCodigoPostal ?? "",
    );

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success ? "Actualizado" : "Error"),
      backgroundColor: success ? Colors.green : Colors.red,
    ));
  }
}