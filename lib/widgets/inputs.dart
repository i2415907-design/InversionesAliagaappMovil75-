import 'package:flutter/material.dart';
import 'package:rutasinversionesaliaga/utils/app_theme.dart';

/// Campo de texto con estilo unificado: bordes redondeados, focus con acento.
class GlassTextField extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller;

  const GlassTextField({
    super.key,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.controller,
  });

  @override
  State<GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends State<GlassTextField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (v) => setState(() => _focused = v),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: AppTheme.inputGlass(focused: _focused),
        child: TextField(
          controller: widget.controller,
          obscureText: widget.isPassword,
          style: AppTheme.body.copyWith(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: AppTheme.label.copyWith(
              color: _focused ? AppTheme.accent.withOpacity(0.95) : AppTheme.textMuted,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16, right: 12),
              child: Icon(
                widget.icon,
                color: _focused ? AppTheme.accent : AppTheme.textMuted,
                size: 22,
              ),
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          ),
        ),
      ),
    );
  }
}
