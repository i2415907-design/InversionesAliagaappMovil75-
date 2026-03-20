import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rutasinversionesaliaga/models/pedido_model.dart';
import 'package:rutasinversionesaliaga/service/vendedor_service.dart';
import 'package:rutasinversionesaliaga/utils/app_theme.dart';

class MapaEnvioVendedorPage extends StatefulWidget {
  final PedidoModel pedido;
  const MapaEnvioVendedorPage({super.key, required this.pedido});

  @override
  State<MapaEnvioVendedorPage> createState() => _MapaEnvioVendedorPageState();
}

class _MapaEnvioVendedorPageState extends State<MapaEnvioVendedorPage> {
  final TextEditingController _cancelReasonController = TextEditingController();
  final VendedorService _vendedorService = VendedorService();
  bool _isProcessing = false;

  // MODAL 1: Pedir explicación (Texto)
  void _mostrarModalExplicacion() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text("MOTIVO DE CANCELACIÓN", 
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: _cancelReasonController,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Escribe aquí por qué se cancela...",
            hintStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: Colors.black26,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("VOLVER", style: TextStyle(color: Colors.white38))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
            onPressed: () {
              if (_cancelReasonController.text.trim().isEmpty) return;
              Navigator.pop(context); 
              _confirmarCancelacionFinal(); // Salta al segundo modal
            }, 
            child: const Text("CONTINUAR"),
          ),
        ],
      ),
    );
  }

  // MODAL 2: Confirmación Final y Llamada al API
  void _confirmarCancelacionFinal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text("¿ESTÁS SEGURO?", style: TextStyle(color: Colors.redAccent)),
        content: const Text("El pedido volverá a estar PENDIENTE y dejará de estar a tu nombre.",
          style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("NO, REGRESAR")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: _isProcessing ? null : _ejecutarCancelacionServer, 
            child: const Text("SÍ, CANCELAR ENTREGA"),
          ),
        ],
      ),
    );
  }

  Future<void> _ejecutarCancelacionServer() async {
    setState(() => _isProcessing = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    final success = await _vendedorService.cancelarEntrega(
      token, 
      widget.pedido.idPedido, 
      _cancelReasonController.text
    );

    if (mounted) {
      Navigator.pop(context); // Cierra el modal
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pedido devuelto a PENDIENTE"), backgroundColor: Colors.orange)
        );
        context.go('/Vendedor_Lista'); // Regresa a la lista
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al cancelar"), backgroundColor: Colors.red)
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.pedido;
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Stack(
        children: [
          const Center(child: Icon(Icons.map_rounded, size: 100, color: Colors.white10)),
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: AppTheme.cardDecoration(radius: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.cliente?.nombreCliente ?? "Cliente", style: AppTheme.body.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(p.tempDireccion ?? "Sin dirección", style: AppTheme.bodySmall),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _mostrarModalExplicacion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text("CANCELAR", style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.push('/Vendedor_Fotografia', extra: p),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text("ENTREGADO", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
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
}