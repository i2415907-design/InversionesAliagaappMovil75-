import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rutasinversionesaliaga/models/pedido_model.dart';
import 'package:rutasinversionesaliaga/service/vendedor_service.dart';
import 'package:rutasinversionesaliaga/utils/app_theme.dart';
import 'package:go_router/go_router.dart';

class FotografiaPedidoVendedorPage extends StatefulWidget {
  final PedidoModel pedido;
  const FotografiaPedidoVendedorPage({super.key, required this.pedido});

  @override
  State<FotografiaPedidoVendedorPage> createState() => _FotografiaPedidoVendedorPageState();
}

class _FotografiaPedidoVendedorPageState extends State<FotografiaPedidoVendedorPage> {
  final VendedorService _vendedorService = VendedorService();
  bool _isFinalizing = false;

  Future<void> _finalizarEntrega() async {
    setState(() => _isFinalizing = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    // Como es "en plano", enviamos una cadena vacía o un path ficticio 
    // Asegúrate de que tu vendedor_service maneje el caso de path vacío si es necesario
    final success = await _vendedorService.finalizarEntrega(
      token, 
      widget.pedido.idPedido, 
      "" // Enviamos vacío ya que no hay foto real
    );

    if (success) {
      _mostrarPantallaExito();
    } else {
      _showError("No se pudo completar el registro. Intenta de nuevo.");
      setState(() => _isFinalizing = false);
    }
  }

void _mostrarPantallaExito() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Scaffold(
        backgroundColor: AppTheme.primary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline_rounded, color: AppTheme.accent, size: 88),
              const SizedBox(height: 20),
              Text("ENTREGA COMPLETADA", style: AppTheme.titleLarge.copyWith(letterSpacing: 1.5)),
              const SizedBox(height: 10),
              Text("Pedido #${widget.pedido.idPedido}", style: AppTheme.bodySmall),
              Text("Cliente: ${widget.pedido.cliente?.nombreCliente}", style: AppTheme.bodySmall),
              const SizedBox(height: 36),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.go('/Vendedor_Entregados');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text("VOLVER AL MENÚ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.redAccent));
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.pedido;

    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        title: Text("CONFIRMACIÓN DE ENTREGA", style: AppTheme.bodySmall.copyWith(color: AppTheme.textMuted)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary), onPressed: () => context.pop()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            // Resumen del pedido
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  const Icon(Icons.inventory, color: Colors.orangeAccent, size: 30),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Pedido #${p.idPedido}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text(p.cliente?.nombreCliente ?? "Cliente", style: const TextStyle(color: Colors.white60, fontSize: 12)),
                    ],
                  )
                ],
              ),
            ),
            
            const Spacer(),

            // Área visual "en plano" (Simulacro de evidencia)
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white10, width: 1),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_user_outlined, color: Colors.greenAccent, size: 80),
                  SizedBox(height: 20),
                  Text("EVIDENCIA DIGITAL GENERADA", style: TextStyle(color: Colors.white38, fontSize: 14, fontWeight: FontWeight.bold)),
                  Text("No se requiere fotografía física", style: TextStyle(color: Colors.white10, fontSize: 11)),
                ],
              ),
            ),

            const Spacer(),

            // Botón de acción
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isFinalizing ? null : _finalizarEntrega,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                ),
                child: _isFinalizing 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("CONFIRMAR Y FINALIZAR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () => context.pop(), 
              child: const Text("CANCELAR", style: TextStyle(color: Colors.white24))
            ),
          ],
        ),
      ),
    );
  }
}