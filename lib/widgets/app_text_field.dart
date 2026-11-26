import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Campo de texto con el estilo de Aftershock.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.suffixIcon,
    this.prefixIcon,
    this.onSubmitted,
    this.maxLines = 1,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? suffixIcon;
  final IconData? prefixIcon;
  final void Function(String)? onSubmitted;
  final int maxLines;
  final void Function(String)? onChanged;

  OutlineInputBorder _borde(Color color, [double ancho = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: ancho),
      );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
      keyboardType: maxLines > 1 ? TextInputType.multiline : keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: maxLines > 1,
        filled: true,
        fillColor: AppColors.surface,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, color: AppColors.muted),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: _borde(AppColors.border),
        focusedBorder: _borde(AppColors.primary, 2),
        errorBorder: _borde(AppColors.error),
        focusedErrorBorder: _borde(AppColors.error, 2),
      ),
    );
  }
}
