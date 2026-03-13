import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rutasinversionesaliaga/service/perfil_service.dart';
import 'package:rutasinversionesaliaga/utils/app_theme.dart';
import 'package:rutasinversionesaliaga/widgets/app_page_header.dart';

class PerfilAdminPage extends StatefulWidget {
  const PerfilAdminPage({super.key});

  @override
  State<PerfilAdminPage> createState() => _PerfilAdminPageState();
}

class _PerfilAdminPageState extends State<PerfilAdminPage> {
  final PerfilService _perfilService = PerfilService();
  final TextEditingController _actualController = TextEditingController();
  final TextEditingController _nuevaController = TextEditingController();
  
  String _emailUser = "Cargando...";
  String _rolUser = "Administrador";
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    // CAMBIO AQUÍ: Usamos 'auth_token' igual que en tu PerfilCliente
    final token = prefs.getString('auth_token') ?? ''; 
    
    final datos = await _perfilService.obtenerPerfil(token);
    if (datos != null) {
      setState(() {
        _emailUser = datos['email'] ?? 'Sin correo';
        _rolUser = datos['rol']?.toUpperCase() ?? 'ADMIN';
      });
    }
  }

  Future<void> _actualizar() async {
    if (_actualController.text.isEmpty || _nuevaController.text.isEmpty) {
      _showMsg("Completa los campos de seguridad", Colors.orange);
      return;
    }

    setState(() => _isUpdating = true);
    final prefs = await SharedPreferences.getInstance();
    // CAMBIO AQUÍ TAMBIÉN: 'auth_token'
    final token = prefs.getString('auth_token') ?? '';

    final res = await _perfilService.cambiarPassword(
      token, _actualController.text, _nuevaController.text
    );

    _showMsg(res['mensaje'], res['success'] ? Colors.green : Colors.redAccent);
    
    if (res['success']) {
      _actualController.clear();
      _nuevaController.clear();
    }
    setState(() => _isUpdating = false);
  }

  void _showMsg(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: color));
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token'); // Eliminamos el token específico
    if (mounted) context.go("/");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              AppPageHeader(title: "Perfil $_rolUser", subtitle: "Administra tu cuenta"),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.admin_panel_settings_rounded, color: AppTheme.accent, size: 56),
              ),
              const SizedBox(height: 24),
              _inputField("CORREO DE ACCESO", _emailUser, isReadOnly: true),
              const SizedBox(height: 18),
              _inputField("CONTRASEÑA ACTUAL", "********", controller: _actualController, isPass: true),
              const SizedBox(height: 18),
              _inputField("NUEVA CONTRASEÑA", "Mínimo 6 caracteres", controller: _nuevaController, isPass: true),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isUpdating ? null : _actualizar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isUpdating
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("ACTUALIZAR CREDENCIALES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _logout,
                child: const Text("CERRAR SESIÓN ADMINISTRATIVA", style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(String label, String hint, {bool isReadOnly = false, bool isPass = false, TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.caption.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: isReadOnly,
          obscureText: isPass,
          style: AppTheme.body,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppTheme.textHint),
            filled: true,
            fillColor: AppTheme.cardOverlay(0.06),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppTheme.accentBlue, width: 1.2)),
          ),
        ),
      ],
    );
  }
}