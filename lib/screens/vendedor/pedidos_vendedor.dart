import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rutasinversionesaliaga/models/pedido_model.dart';
import 'package:rutasinversionesaliaga/service/vendedor_service.dart';
import 'package:rutasinversionesaliaga/utils/app_theme.dart';
import 'package:rutasinversionesaliaga/widgets/status_chip.dart';
import 'package:rutasinversionesaliaga/widgets/app_page_header.dart';

class ListaPedidosVendedorPage extends StatefulWidget {
  const ListaPedidosVendedorPage({super.key});

  @override
  State<ListaPedidosVendedorPage> createState() => _ListaPedidosVendedorPageState();
}

class _ListaPedidosVendedorPageState extends State<ListaPedidosVendedorPage> {
  final VendedorService _vendedorService = VendedorService();
  List<PedidoModel> _pedidos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarPedidos();
  }

  Future<void> _cargarPedidos() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    
    final lista = await _vendedorService.getPedidosAsignados(token);
    setState(() {
      _pedidos = lista;
      _isLoading = false;
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
              title: "Mis entregas pendientes",
              subtitle: "Pedidos asignados para entregar",
            ),
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
                : _pedidos.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _cargarPedidos,
                      color: AppTheme.accent,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        itemCount: _pedidos.length,
                        itemBuilder: (context, index) => _PedidoCardVendedor(pedido: _pedidos[index]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        "NO TIENES PEDIDOS\nASIGNADOS POR AHORA",
        textAlign: TextAlign.center,
        style: AppTheme.subtitle.copyWith(color: AppTheme.textMuted, fontSize: 15),
      ),
    );
  }
}

class _PedidoCardVendedor extends StatefulWidget {
  final PedidoModel pedido;
  const _PedidoCardVendedor({required this.pedido});

  @override
  State<_PedidoCardVendedor> createState() => _PedidoCardVendedorState();
}

class _PedidoCardVendedorState extends State<_PedidoCardVendedor> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.pedido;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppTheme.pedidoCardDecoration,
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: AppTheme.accentOlive.withOpacity(0.3),
              child: Icon(Icons.local_shipping_rounded, color: AppTheme.accentOlive, size: 22),
            ),
            title: Text("Pedido #${p.idPedido}", style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  StatusChip(estado: p.estado),
                  const SizedBox(width: 8),
                  Expanded(child: Text("${p.cliente?.nombreCliente} ${p.cliente?.apellidoCliente}", style: AppTheme.bodySmall, overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
            trailing: Icon(
              _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
              color: AppTheme.textSecondary,
            ),
          ),

          // CUERPO DETALLADO (Visible al expandir)
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: AppTheme.border, height: 1),
                  _infoRow(Icons.person_rounded, "CLIENTE", "${p.cliente?.nombreCliente} ${p.cliente?.apellidoCliente}"),
                  _infoRow(Icons.phone_rounded, "TELÉFONO", p.cliente?.telefonoCliente ?? "Sin teléfono"),
                  _infoRow(Icons.location_on_rounded, "DIRECCIÓN", p.tempDireccion ?? "Sin dirección"),
                  _infoRow(Icons.explore_rounded, "REFERENCIA", p.tempReferencia ?? "Sin referencia"),
                  _infoRow(Icons.calendar_today_rounded, "FECHA", p.fecha),
                  const SizedBox(height: 14),
                  Text("PRODUCTOS:", style: AppTheme.caption.copyWith(color: AppTheme.accentOlive, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ...p.detalles.map((d) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text("• ${d.cantidad}x ${d.nombre}", style: AppTheme.bodySmall),
                  )),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _isExpanded = false),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppTheme.borderFocus),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text("VOLVER", style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => context.push('/Vendedor_Mapa', extra: p),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("INICIAR ENTREGA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTheme.caption),
                Text(value, style: AppTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}