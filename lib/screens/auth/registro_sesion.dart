import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rutasinversionesaliaga/service/auth_service.dart';
import 'package:rutasinversionesaliaga/widgets/buttons.dart';
import 'package:rutasinversionesaliaga/widgets/inputs.dart';
import 'package:rutasinversionesaliaga/widgets/glass_card.dart';
import 'package:rutasinversionesaliaga/service/google_auth_service.dart';
import 'package:rutasinversionesaliaga/utils/app_theme.dart';

class RegistroSesionPage extends StatefulWidget {
  const RegistroSesionPage({super.key});

  @override
  State<RegistroSesionPage> createState() => _RegistroSesionPageState();
}

class _RegistroSesionPageState extends State<RegistroSesionPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  void _handleRegister() async {
    if (_passController.text != _confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Las contraseñas no coinciden")),
      );
      return;
    }
    if (_nameController.text.isEmpty || _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor complete todos los campos")),
      );
      return;
    }

    setState(() => _isLoading = true);

    bool success = await _authService.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passController.text,
      passwordConfirmation: _confirmPassController.text,
    );

    if (mounted) setState(() => _isLoading = false);

    if (success) {
      if (mounted) context.go("/Pedidos");
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Error: Revisa que la clave tenga Mayúscula, Número y Carácter especial.",
            ),
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
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
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                    child: GlassCard(
                      radius: 28,
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentCyan.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(Icons.person_add_rounded, color: AppTheme.accentCyan, size: 24),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Crear cuenta", style: AppTheme.displayLarge.copyWith(fontSize: 22)),
                                    Text(
                                      "Completa tus datos",
                                      style: AppTheme.bodySmall.copyWith(color: AppTheme.textMuted, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          GlassTextField(
                            controller: _nameController,
                            label: "Nombre completo",
                            icon: Icons.person_outline_rounded,
                          ),
                          GlassTextField(
                            controller: _emailController,
                            label: "Correo electrónico",
                            icon: Icons.email_outlined,
                          ),
                          GlassTextField(
                            controller: _passController,
                            label: "Contraseña",
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                          ),
                          GlassTextField(
                            controller: _confirmPassController,
                            label: "Confirmar contraseña",
                            icon: Icons.lock_reset_rounded,
                            isPassword: true,
                          ),
                          const SizedBox(height: 22),
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
                              text: "Registrarme",
                              color: Colors.transparent,
                              onPressed: _handleRegister,
                            ),
                          const SizedBox(height: 18),
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
                          const SizedBox(height: 18),
                          Center(
                            child: TextButton(
                              onPressed: () => context.go("/Inicio_sesion"),
                              child: Text(
                                "¿Ya tienes cuenta? Inicia sesión",
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
