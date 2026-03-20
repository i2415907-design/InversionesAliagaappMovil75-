import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rutasinversionesaliaga/service/auth_service.dart';
import 'package:rutasinversionesaliaga/widgets/buttons.dart';
import 'package:rutasinversionesaliaga/widgets/inputs.dart';
import 'package:rutasinversionesaliaga/widgets/glass_card.dart';
import 'package:rutasinversionesaliaga/service/google_auth_service.dart';
import 'package:rutasinversionesaliaga/utils/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InicioSesionPage extends StatefulWidget {
  const InicioSesionPage({super.key});

  @override
  State<InicioSesionPage> createState() => _InicioSesionPageState();
}

class _InicioSesionPageState extends State<InicioSesionPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, completa todos los campos")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await _authService.login(email, password);

      if (success) {
        if (mounted) {
          final prefs = await SharedPreferences.getInstance();
          final String? rol = prefs.getString('user_role');
          if (rol == 'admin' || rol == 'admin_general') {
            context.go("/Admin_Pendientes");
          } else if (rol == 'vendedor') {
            context.go("/Vendedor_Lista");
          } else {
            context.go("/Pedidos");
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Credenciales incorrectas")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error de conexión: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: const [0.0, 0.4, 0.85, 1.0],
                    colors: [
                      AppTheme.primary.withOpacity(0.75),
                      AppTheme.surfaceDark.withOpacity(0.88),
                      AppTheme.primary.withOpacity(0.92),
                      AppTheme.primary,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, right: 4, top: 50, bottom: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: IconButton(
                            onPressed: () => context.go('/Homepage'),
                            icon: const Icon(Icons.arrow_back_rounded),
                            color: AppTheme.textPrimary,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 50),
                      Image.asset('assets/images/logo1.png', fit: BoxFit.contain, height: 34),
                      const SizedBox(width: 100),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                    child: GlassCard(
                      radius: 28,
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.accent.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(Icons.login_rounded, color: AppTheme.accentLight, size: 24),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Iniciar sesión", style: AppTheme.displayLarge.copyWith(fontSize: 22)),
                                    Text(
                                      "Ingresa tus datos",
                                      style: AppTheme.bodySmall.copyWith(color: AppTheme.textMuted, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 26),
                          GlassTextField(
                            controller: _emailController,
                            label: "Correo electrónico",
                            icon: Icons.email_outlined,
                          ),
                          GlassTextField(
                            controller: _passwordController,
                            label: "Contraseña",
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                          ),
                          const SizedBox(height: 24),
                          if (_isLoading)
                            const Center(
                              child: SizedBox(
                                height: 48,
                                width: 48,
                                child: CircularProgressIndicator(color: AppTheme.accentLight, strokeWidth: 2.5),
                              ),
                            )
                          else
                            ButtonPrimary(
                              text: "Entrar",
                              color: Colors.transparent,
                              onPressed: _handleLogin,
                            ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(child: Divider(color: Colors.white.withOpacity(0.12), thickness: 1)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text("o continúa con", style: AppTheme.caption.copyWith(fontSize: 11)),
                              ),
                              Expanded(child: Divider(color: Colors.white.withOpacity(0.12), thickness: 1)),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ButtonSocial(
                            text: "Google",
                            imageUrl:
                                'https://gdm-catalog-fmapi-prod.imgix.net/ProductLogo/5179d6b3-aa3f-403b-8cb4-718850815472.png?w=80&h=80&fit=max&dpr=3&auto=format&q=50',
                            onPressed: () async {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                  child: CircularProgressIndicator(color: AppTheme.accent),
                                ),
                              );
                              final googleService = GoogleAuthService();
                              bool success = await googleService.signInWithGoogle();
                              if (mounted) Navigator.pop(context);
                              if (success && mounted) {
                                context.go("/Pedidos");
                              } else if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("No se pudo iniciar sesión con Google. Intenta de nuevo."),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: TextButton(
                              onPressed: () => context.go("/Registrarse"),
                              child: Text(
                                "¿No tienes cuenta? Regístrate",
                                style: AppTheme.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
