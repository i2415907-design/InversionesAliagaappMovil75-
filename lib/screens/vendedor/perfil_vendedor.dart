import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rutasinversionesaliaga/service/perfil_service.dart';
import 'package:rutasinversionesaliaga/utils/app_theme.dart';
import 'package:rutasinversionesaliaga/widgets/app_page_header.dart';

class PerfilVendedorPage extends StatefulWidget {
  const PerfilVendedorPage({super.key});

  @override
  State<PerfilVendedorPage> createState() => _PerfilVendedorPageState();
}

class _PerfilVendedorPageState extends State<PerfilVendedorPage> {
  //String _nombre = "Cargando...";
  String _rol = "Trabajador";
  String _email = "...";

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

Future<void> _cargarDatos() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token') ?? ''; 
  
  // Usamos el servicio en lugar de solo leer el disco local
  final perfilService = PerfilService(); 
  final datos = await perfilService.obtenerPerfil(token);

  if (datos != null) {
    setState(() {
      //_nombre = datos['nombre_usuario'] ?? "Usuario";
      _rol = datos['rol']?.toUpperCase() ?? "VENDEDOR";
      _email = datos['email'] ?? "Sin correo";
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const AppPageHeader(title: "Mi perfil", subtitle: "Datos de tu cuenta"),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.accent.withOpacity(0.5), width: 2),
                ),
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: AppTheme.accent.withOpacity(0.2),
                  child: Icon(Icons.person_rounded, size: 48, color: AppTheme.accent),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.accent.withOpacity(0.4)),
                ),
                child: Text(_rol, style: TextStyle(color: AppTheme.accent, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 24),
              _buildDataCard(Icons.badge_outlined, "Rol en la empresa", _rol),
              _buildDataCard(Icons.email_outlined, "Correo Electrónico", _email),
              _buildDataCard(Icons.verified_user_rounded, "Estado de cuenta", "Activo / Verificado"),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.cardDecoration(radius: 14),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: AppTheme.accent, size: 24),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        "Para modificar tus datos personales, por favor contacta con el Administrador General.",
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataCard(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(radius: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.accentOlive.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.accentOlive, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTheme.caption),
              const SizedBox(height: 2),
              Text(value, style: AppTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}