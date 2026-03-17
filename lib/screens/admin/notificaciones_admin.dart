import 'package:flutter/material.dart';
import 'package:rutasinversionesaliaga/utils/app_theme.dart';
import 'package:rutasinversionesaliaga/widgets/app_page_header.dart';
import 'package:rutasinversionesaliaga/service/pusher_config_service.dart';
import 'package:rutasinversionesaliaga/service/notificacion_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:overlay_support/overlay_support.dart';

class NotificacionesAdminPage extends StatefulWidget {
  const NotificacionesAdminPage({super.key});

  @override
  State<NotificacionesAdminPage> createState() => _NotificacionesAdminPageState();
}

class _NotificacionesAdminPageState extends State<NotificacionesAdminPage> {
  final PusherConfig _pusherConfig = PusherConfig();
  final NotificacionService _notificacionService = NotificacionService();
  List<dynamic> _alertas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdminAlerts();
  }


Future<void> _loadAdminAlerts() async {
  final prefs = await SharedPreferences.getInstance();
  final String token = prefs.getString('auth_token') ?? '';
  
  final datos = await _notificacionService.getNotificaciones(token);
  setState(() {
    _alertas = datos;
    _isLoading = false;
  });

  _pusherConfig.initPusher(
    channelName: "private-admins", // Coincide con PrivateChannel('admins') de Laravel
    eventName: "notificacion.pedido",
    onEventTriggered: (event) {
      // El admin solo reacciona si el rolf en el JSON es 'admin'
      if (event.data['rol'] == 'admin') {
        showSimpleNotification(
          Text("ALERTA DE SISTEMA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text(event.data['mensaje']),
          background: Colors.indigo,
        );
        _loadAdminAlerts();
      }
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            const AppPageHeader(title: "Centro de alertas", subtitle: "Alertas y notificaciones del sistema"),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
                : RefreshIndicator(
                    onRefresh: _loadAdminAlerts,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _alertas.length,
                      itemBuilder: (context, index) {
                        final a = _alertas[index];
                        // Definir color según prioridad o título
                        Color alertColor = a['titulo'].toString().contains('STOCK') 
                            ? AppTheme.accentAmber 
                            : AppTheme.accent;

                        return _buildAdminAlert(
                          a['titulo'].toString().toUpperCase(),
                          a['mensaje'],
                          a['titulo'].toString().contains('STOCK') ? Icons.warning_amber_rounded : Icons.shopping_cart_rounded,
                          alertColor
                        );
                      },
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminAlert(String title, String msg, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardOverlay(0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(msg, style: AppTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}