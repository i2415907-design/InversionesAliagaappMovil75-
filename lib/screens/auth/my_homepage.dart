import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:convert'; // <--- Añade esta línea
import 'package:go_router/go_router.dart';
import 'package:rutasinversionesaliaga/service/google_auth_service.dart';
import 'package:rutasinversionesaliaga/service/pusher_config_service.dart';// <-- librerias para notificacion
import 'package:rutasinversionesaliaga/utils/app_theme.dart';

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /*final PusherConfig _pusherConfig = PusherConfig();
  String _mensaje = "Esperando datos";
  // sintaxis json para coment >> {"mensaje" :"hola mundo"}
  @override
  void initState(){
    super.initState();
        // Llamada simple a la configuración
    _pusherConfig.initPusher(
      channelName: "mi-canal",
      eventName: "mi-evento",
      onEventTriggered: (event) {
        if (!mounted) return;
        dynamic data;
        // 1. Verificar si event.data ya es un Mapa o si es un String
        if (event.data is String) {
          // Si es String (como en Android/iOS a veces), lo decodificamos
          data = jsonDecode(event.data.toString());
        } else {
          // Si ya es un Map (común en Web), lo usamos directamente
          data = event.data;
        }
        // 2. Acceder al valor de forma segura
        String mensajeRecibido = data['mensaje'] ?? "Sin mensaje";
        setState(() {
          _mensaje = mensajeRecibido;
        });
        //_mostrarAlerta(mensajeRecibido);
      },
    );
  }

  @override
  void dispose(){
    _pusherConfig.disconnect();
    super.dispose();
  }*/

  @override
  Widget build(BuildContext context) {
    const margin = 24.0;
    return Scaffold(
      body: Stack(
        children: [
          // Fondo
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/tienda_fondo.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.5, 1.0],
                    colors: [
                      AppTheme.primary.withOpacity(0.7),
                      AppTheme.primary.withOpacity(0.92),
                      AppTheme.primary,
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Panel glass a pantalla completa con margen
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(margin),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                        width: 1,
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          //Text("Data: $_mensaje"),//<<------linea de prueba de notificacion.
                          Image.asset(
                            'assets/images/logo1.png', // Cambia el nombre aquí
                            height: 50, // Ajusta el tamaño
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 115),
                          Image.asset(
                            'assets/images/solologo.png',
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 115),
                          Text(
                            'Bienvenido',
                            style: AppTheme.body.copyWith(
                              color: Colors.white,
                              fontSize: 14,
                              letterSpacing: 0.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 40),
                          _MinimalPillButton(
                            label: 'Iniciar sesión',
                            onTap: () => context.go("/Inicio_sesion"),
                            fill: AppTheme.buttonPrimaryFill,
                          ),
                          const SizedBox(height: 12),
                          _MinimalPillButton(
                            label: 'Crear cuenta',
                            onTap: () => context.go("/Registrarse"),
                            fill: AppTheme.buttonSecondaryFill,
                          ),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Colors.white.withOpacity(0.08),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'o continúa con',
                                  style: AppTheme.caption.copyWith(
                                    fontSize: 12,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Colors.white.withOpacity(0.08),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _MinimalPillButton(
                            label: 'Continuar con Google',
                            onTap: () async {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                  child: CircularProgressIndicator(color: AppTheme.textSecondary),
                                ),
                              );
                              final googleService = GoogleAuthService();
                              bool success = await googleService.signInWithGoogle();
                              if (mounted) Navigator.pop(context);
                              if (success && mounted) {
                                context.go("/Pedidos");
                              } else if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Error al conectar con Google")),
                                );
                              }
                            },
                            fill: Colors.transparent,
                            isOutlined: true,
                            leading: Image.network(
                              'https://gdm-catalog-fmapi-prod.imgix.net/ProductLogo/5179d6b3-aa3f-403b-8cb4-718850815472.png?w=80&h=80&fit=max&dpr=3&auto=format&q=50',
                              height: 18,
                              width: 18,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Icon(Icons.login_rounded, color: AppTheme.textSecondary, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


/// Botón pill minimalista: sin gradiente, sin sombra, color armónico.
class _MinimalPillButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color fill;
  final bool isOutlined;
  final Widget? leading;

  const _MinimalPillButton({
    required this.label,
    required this.onTap,
    required this.fill,
    this.isOutlined = false,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            color: isOutlined ? Colors.transparent : fill,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(isOutlined ? 0.12 : 0.08),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 10),
              ],
              Text(
                label,
                style: AppTheme.body.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

