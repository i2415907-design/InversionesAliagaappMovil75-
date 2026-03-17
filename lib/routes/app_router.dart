import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rutasinversionesaliaga/utils/app_theme.dart';
import 'package:rutasinversionesaliaga/models/pedido_model.dart';

// Auth
import 'package:rutasinversionesaliaga/screens/auth/my_homepage.dart';
import 'package:rutasinversionesaliaga/screens/auth/inicio_sesion.dart';
import 'package:rutasinversionesaliaga/screens/auth/registro_sesion.dart';

// Cliente
import 'package:rutasinversionesaliaga/screens/cliente/mis_pedidos_cliente.dart';
import 'package:rutasinversionesaliaga/screens/cliente/recibidos_cliente.dart';
import 'package:rutasinversionesaliaga/screens/cliente/perfil_cliente.dart';
import 'package:rutasinversionesaliaga/screens/cliente/notificaciones_cliente.dart';
import 'package:rutasinversionesaliaga/screens/cliente/seguimiento_cliente.dart';
import 'package:rutasinversionesaliaga/screens/cliente/seguimiento_cliente_map.dart';

// Admin
import 'package:rutasinversionesaliaga/screens/admin/pedidos_pendientes_admin.dart';
import 'package:rutasinversionesaliaga/screens/admin/pedidos_camino_admin.dart';
import 'package:rutasinversionesaliaga/screens/admin/pedidos_finalizados_admin.dart';
import 'package:rutasinversionesaliaga/screens/admin/perfil_admin.dart';
import 'package:rutasinversionesaliaga/screens/admin/notificaciones_admin.dart';

// Vendedor
import 'package:rutasinversionesaliaga/screens/vendedor/pedidos_vendedor.dart';
import 'package:rutasinversionesaliaga/screens/vendedor/entregados_vendedor.dart';
import 'package:rutasinversionesaliaga/screens/vendedor/perfil_vendedor.dart';
import 'package:rutasinversionesaliaga/screens/vendedor/notificaciones_vendedor.dart';
import 'package:rutasinversionesaliaga/screens/vendedor/mapa_entrega_vendedor.dart';
import 'package:rutasinversionesaliaga/screens/vendedor/evidencia_entrega_vendedor.dart';

/// Layout principal con AppBar y menú según rol.
class MainLayout extends StatefulWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedRole = prefs.getString('user_role');
    if (mounted) setState(() => _userRole = storedRole);
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = (_userRole == 'admin' || _userRole == 'admin_general');
    bool isWorker = (_userRole == 'trabajador' || _userRole == 'vendedor');

    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.white.withOpacity(0.06), height: 1.0),
        ),
        leading: PopupMenuButton<String>(
          icon: Icon(Icons.menu_rounded, color: AppTheme.textSecondary, size: 26),
          offset: const Offset(0, 55),
          color: AppTheme.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            side: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          onSelected: (route) => context.go(route),
          itemBuilder: (context) {
            if (isAdmin) {
              return [
                _buildPopupItem('/Admin_Pendientes', Icons.pending_actions_rounded, 'Pendientes'),
                _buildPopupItem('/Admin_Camino', Icons.local_shipping_rounded, 'En Camino'),
                _buildPopupItem('/Admin_Finalizados', Icons.check_circle_outline_rounded, 'Finalizados'),
              ];
            } else if (isWorker) {
              return [
                _buildPopupItem('/Vendedor_Lista', Icons.list_alt_rounded, 'Lista de Pedidos'),
                _buildPopupItem('/Vendedor_Entregados', Icons.task_alt_rounded, 'Entregados'),
              ];
            } else {
              return [
                _buildPopupItem('/Pedidos', Icons.inventory_2_outlined, 'Mis Pedidos'),
                _buildPopupItem('/Pedido_cliente', Icons.near_me_outlined, 'Seguimiento'),
                _buildPopupItem('/Recibidos', Icons.archive_outlined, 'Recibidos'),
              ];
            }
          },
        ),
        title: GestureDetector(
          onTap: () {
            if (isAdmin) context.go('/Admin_Pendientes');
            else if (isWorker) context.go('/Vendedor_Lista');
            else context.go('/Pedidos');
          },
          child: Image.asset('assets/images/solologo.png', height: 35),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.account_circle_outlined, color: AppTheme.textSecondary, size: 26),
            offset: const Offset(0, 55),
            color: AppTheme.surfaceCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            onSelected: (route) async {
              if (route == '/salir') {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (mounted) context.go('/Homepage');
              } else {
                context.go(route);
              }
            },
            itemBuilder: (context) {
              String perfilRoute = '/Perfil';
              String notiRoute = '/Notificaciones';
              if (isAdmin) {
                perfilRoute = '/Admin_Perfil';
                notiRoute = '/Admin_Notificaciones';
              } else if (isWorker) {
                perfilRoute = '/Vendedor_Perfil';
                notiRoute = '/Vendedor_Notificaciones';
              }
              return [
                _buildPopupItem(perfilRoute, Icons.person_outline_rounded, 'Mi Perfil'),
                _buildPopupItem(notiRoute, Icons.notifications_none_outlined, 'Notificaciones'),
                const PopupMenuDivider(height: 1),
                _buildPopupItem('/salir', Icons.logout_rounded, 'Cerrar Sesión', isDestructive: true),
              ];
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: widget.child,
    );
  }

  PopupMenuItem<String> _buildPopupItem(String value, IconData icon, String text, {bool isDestructive = false}) {
    final color = isDestructive ? Colors.redAccent : AppTheme.textSecondary;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(width: 16),
          Text(text, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

/// Configuración de rutas de la aplicación.
final GoRouter appRouter = GoRouter(
  initialLocation: '/Homepage',
  routes: [
    GoRoute(path: '/Homepage', builder: (context, state) => const MyHomePage(title: 'Inversiones Aliaga')),
    GoRoute(path: '/Inicio_sesion', builder: (context, state) => const InicioSesionPage()),
    GoRoute(path: '/Registrarse', builder: (context, state) => const RegistroSesionPage()),
    ShellRoute(
      builder: (context, state, child) => MainLayout(child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const MyHomePage(title: 'Inversiones Aliaga')),
        GoRoute(path: '/Pedidos', builder: (context, state) => const Pedidos_clientePage()),
        GoRoute(path: '/Pedido_cliente', builder: (context, state) => const SeguimientoPedidoPage(pedido_id: 7)),
        GoRoute(path: '/Recibidos', builder: (context, state) => const RecibidosPedidoPage()),
        GoRoute(path: '/Perfil', builder: (context, state) => const PerfilClientePage()),
        GoRoute(path: '/Notificaciones', builder: (context, state) => const NotificacionesClientePage()),
        GoRoute(path: '/Seguimiento_mapa', builder: (context, state) => const SeguimientoPedidoMapaPage()),
        GoRoute(path: '/Admin_Pendientes', builder: (context, state) => const AdminPendientesPage()),
        GoRoute(path: '/Admin_Camino', builder: (context, state) => const AdminEnCaminoPage()),
        GoRoute(path: '/Admin_Finalizados', builder: (context, state) => const AdminFinalizadosPage()),
        GoRoute(path: '/Admin_Perfil', builder: (context, state) => const PerfilAdminPage()),
        GoRoute(path: '/Admin_Notificaciones', builder: (context, state) => const NotificacionesAdminPage()),
        GoRoute(path: '/Vendedor_Lista', builder: (context, state) => const ListaPedidosVendedorPage()),
        GoRoute(path: '/Vendedor_Mapa', builder: (context, state) => MapaEnvioVendedorPage(pedido: state.extra as PedidoModel)),
        GoRoute(path: '/Vendedor_Fotografia', builder: (context, state) => FotografiaPedidoVendedorPage(pedido: state.extra as PedidoModel)),
        GoRoute(path: '/Vendedor_Entregados', builder: (context, state) => const PedidosEntregadosVendedorPage()),
        GoRoute(path: '/Vendedor_Perfil', builder: (context, state) => const PerfilVendedorPage()),
        GoRoute(path: '/Vendedor_Notificaciones', builder: (context, state) => const NotificacionesVendedorPage()),
      ],
    ),
  ],
);
