import 'package:flutter/material.dart';
import 'package:rutasinversionesaliaga/utils/app_theme.dart';
import 'package:rutasinversionesaliaga/service/pusher_config_service.dart';
import 'package:rutasinversionesaliaga/service/notificacion_service.dart'; // Importa el service
import 'package:shared_preferences/shared_preferences.dart';
import 'package:overlay_support/overlay_support.dart'; // Para el banner visual

class NotificacionesClientePage extends StatefulWidget {
  const NotificacionesClientePage({super.key});

  @override
  State<NotificacionesClientePage> createState() => _NotificacionesClientePageState();
}

class _NotificacionesClientePageState extends State<NotificacionesClientePage> {
  final PusherConfig _pusherConfig = PusherConfig();
  final NotificacionService _notificacionService = NotificacionService();
  
  List<dynamic> _notificaciones = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarHistorialYConectarPusher();
  }

@override
  void dispose() {
    _pusherConfig.disconnect(); // Corta la conexión con Pusher
    super.dispose();
  }


Future<void> _cargarHistorialYConectarPusher() async {
  final prefs = await SharedPreferences.getInstance();
  final String token = prefs.getString('auth_token') ?? '';
  final int userId = prefs.getInt('user_id') ?? 0;

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
        // El cliente solo reacciona si el rol en el JSON es 'cliente'
        if (event.data['rol'] == 'cliente') {
          _gestionarNuevoEvento(event.data);
        }
      },
    );
  }
}

  void _gestionarNuevoEvento(dynamic data) {
    // Mostrar Banner Visual (Alerta Push)
    showSimpleNotification(
      Text("Actualización de Pedido", style: TextStyle(color: Colors.white)),
      subtitle: Text(data['mensaje'] ?? "Tienes una nueva actualización"),
      background: AppTheme.accent,
      duration: Duration(seconds: 4),
    );

    // Recargar la lista para que aparezca la nueva notificación arriba
    _cargarHistorialYConectarPusher(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 26),
            Text("NOTIFICACIONES", style: AppTheme.titleSection.copyWith(letterSpacing: 2)),
            const SizedBox(height: 24),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
                : RefreshIndicator(
                    onRefresh: _cargarHistorialYConectarPusher,
                    child: _notificaciones.isEmpty 
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _notificaciones.length,
                          itemBuilder: (context, index) {
                            final n = _notificaciones[index];
                            return _buildNotificationItem(
                              n['titulo'], 
                              n['mensaje'], 
                              n['leido'] == 1
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

  Widget _buildNotificationItem(String title, String message, bool leido) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.cardDecoration(radius: AppTheme.radiusCard).copyWith(
        // Si no está leído, le ponemos un borde sutil de color acento
        border: !leido ? Border.all(color: AppTheme.accent.withOpacity(0.5)) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            leido ? Icons.notifications_none_outlined : Icons.notifications_active, 
            color: leido ? AppTheme.textMuted : AppTheme.accent, 
            size: 24
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.body.copyWith(fontWeight: FontWeight.bold, color: leido ? AppTheme.textMuted : Colors.white)),
                const SizedBox(height: 4),
                Text(message, style: AppTheme.bodySmall.copyWith(color: leido ? AppTheme.textMuted : Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text("NO TIENES NOTIFICACIONES", style: AppTheme.subtitle.copyWith(color: AppTheme.textHint, fontSize: 14)),
    );
  }
}