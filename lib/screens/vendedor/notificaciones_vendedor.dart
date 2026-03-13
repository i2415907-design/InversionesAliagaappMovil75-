import 'package:flutter/material.dart';
import 'package:rutasinversionesaliaga/utils/app_theme.dart';
import 'package:rutasinversionesaliaga/widgets/app_page_header.dart';
import 'package:rutasinversionesaliaga/service/pusher_config_service.dart';
import 'package:rutasinversionesaliaga/service/notificacion_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:overlay_support/overlay_support.dart';

class NotificacionesVendedorPage extends StatefulWidget {
  const NotificacionesVendedorPage({super.key});

  @override
  State<NotificacionesVendedorPage> createState() => _NotificacionesVendedorPageState();
}

class _NotificacionesVendedorPageState extends State<NotificacionesVendedorPage> {
  final PusherConfig _pusherConfig = PusherConfig();
  final NotificacionService _notificacionService = NotificacionService();
  List<dynamic> _notificaciones = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initVendedorData();
  }

Future<void> _initVendedorData() async {
  final prefs = await SharedPreferences.getInstance();
  final String token = prefs.getString('auth_token') ?? '';
  final int userId = prefs.getInt('user_id') ?? 0; // Obtener ID del vendedor

  final datos = await _notificacionService.getNotificaciones(token);
  setState(() {
    _notificaciones = datos;
    _isLoading = false;
  });

  if (userId != 0) {
_pusherConfig.initPusher(
  channelName: "private-usuario.$userId", 
  eventName: "notificacion.pedido", 
  onEventTriggered: (event) {
    // FILTRO DE SEGURIDAD: Solo mostrar si el rol destino es 'vendedor'
    if (event.data['rol'] == 'vendedor') {
       showSimpleNotification(
         Text("ACTUALIZACIÓN"),
         subtitle: Text(event.data['mensaje']),
         background: AppTheme.accent,
       );
       _initVendedorData();
    }
    // Si el rol es 'admin', el vendedor lo ignora por completo.
  },
);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            const AppPageHeader(title: "Centro de avisos", subtitle: "Notificaciones y actualizaciones"),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
                : RefreshIndicator(
                    onRefresh: _initVendedorData,
                    child: _notificaciones.isEmpty 
                      ? _buildEmpty() 
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          itemCount: _notificaciones.length,
                          itemBuilder: (context, index) {
                            final n = _notificaciones[index];
                            // Lógica de color según tipo (urgente o nuevo)
                            bool isUrgente = n['tipo'] == 'urgente';
                            final color = isUrgente ? Colors.redAccent : AppTheme.accent;
                            
                            return _buildItem(n, color, isUrgente);
                          },
                        ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(dynamic n, Color color, bool isUrgente) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUrgente ? Colors.redAccent.withOpacity(0.08) : AppTheme.cardOverlay(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Icon(isUrgente ? Icons.warning_amber_rounded : Icons.notifications_active_rounded, color: color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(n['titulo'], style: AppTheme.body.copyWith(fontWeight: FontWeight.w600)),
                Text(n['mensaje'], style: AppTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() => Center(child: Text("SIN AVISOS PENDIENTES", style: AppTheme.subtitle.copyWith(color: AppTheme.textHint)));
}