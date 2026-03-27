import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rutasinversionesaliaga/models/pedido_model.dart';
import 'package:rutasinversionesaliaga/models/detalle_producto_model.dart';
import 'package:rutasinversionesaliaga/utils/app_theme.dart';

class SeguimientoPedidoPage extends StatefulWidget {
  final int pedido_id; // Se mantiene el nombre original
  const SeguimientoPedidoPage({super.key, required this.pedido_id});

  @override
  State<SeguimientoPedidoPage> createState() => _SeguimientoPedidoPageState();
}

class _SeguimientoPedidoPageState extends State<SeguimientoPedidoPage> {
  List<PedidoModel> pedidosEnCurso = []; // Cambiado a Lista
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _cargarPedidosEnCamino();
  }

  Future<void> _cargarPedidosEnCamino() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final response = await Dio().get(
        'https://inversionesaliaga.com/v1/pedido-activo',
        queryParameters: {'token': token},
      );

      if (!mounted) return;

if (response.statusCode == 200) {
  setState(() {
    if (response.data is List) {
      // Si recibimos la lista directamente
      pedidosEnCurso = (response.data as List)
          .map((json) => PedidoModel.fromJson(json))
          .toList();
    } else if (response.data is Map && response.data.containsKey('id_pedido')) {
      // Por si el servidor solo manda un objeto (compatibilidad)
      pedidosEnCurso = [PedidoModel.fromJson(response.data)];
    }
    _isLoading = false;
  });
}
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.response?.data['mensaje'] ?? "No hay pedidos en ruta actualmente.";
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Error de conexión";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        title: const Text("SEGUIMIENTO", style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
    }

    if (_errorMessage != null || pedidosEnCurso.isEmpty) {
      return _buildErrorState();
    }

    // Ahora usamos un ListView para mostrar todos los pedidos que vengan en la lista
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 20),
      itemCount: pedidosEnCurso.length,
      itemBuilder: (context, index) {
        final pedido = pedidosEnCurso[index];
        return _buildPedidoCard(pedido);
      },
    );
  }

  Widget _buildPedidoCard(PedidoModel pedido) {
    final primerProducto = pedido.detalles.isNotEmpty 
        ? pedido.detalles.first 
        : DetalleProducto(nombre: "Pedido General", imagen: "", cantidad: 1, precio: "0");

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        decoration: AppTheme.cardDecoration(radius: 24),
        child: Column(
          children: [
            Text(
              "ORDEN #00${pedido.idPedido}",
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 25),
            _buildProductPreview(primerProducto.imagen),
            const SizedBox(height: 20),
            Text(
              primerProducto.nombre.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            if (pedido.detalles.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  "y ${pedido.detalles.length - 1} producto(s) más",
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                ),
              ),
            const SizedBox(height: 25),
            _buildStatusBadge(pedido.estado),
            const SizedBox(height: 30),
            _buildMapButton(pedido.idPedido),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS DE SOPORTE ---

  Widget _buildStatusBadge(String estado) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.accentAmber,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentAmber.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        estado.toUpperCase(),
        style: const TextStyle(color: Color(0xFF1A1A2E), fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1),
      ),
    );
  }

  Widget _buildMapButton(int idPedido) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => context.push("/Seguimiento_mapa", extra: idPedido),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accent,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_rounded, color: Colors.white),
            SizedBox(width: 10),
            Text(
              "RASTREAR EN MAPA",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductPreview(String imageUrl) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 2),
      ),
      child: CircleAvatar(
        radius: 60,
        backgroundColor: Colors.white.withOpacity(0.05),
        backgroundImage: imageUrl.isNotEmpty 
            ? NetworkImage(imageUrl) 
            : const AssetImage('assets/no_image.png') as ImageProvider,
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 72, color: AppTheme.textHint),
          const SizedBox(height: 20),
          Text(_errorMessage ?? "NO HAY PEDIDOS ACTIVOS", 
               style: const TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () => context.go('/Pedidos'),
            icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.accent),
            label: const Text("VOLVER", style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
