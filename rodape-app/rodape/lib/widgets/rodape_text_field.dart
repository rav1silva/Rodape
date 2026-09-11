import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Campo de texto do design system Rodapé ("Input"): label pequeno mono
/// acima, caixa com borda que reage a foco/erro.
class RodapeTextField extends StatelessWidget {
  const RodapeTextField({
    super.key,
    required this.label,
    this.controller,
    this.mono = false,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.errorText,
    this.enabled = true,
    this.textCapitalization = TextCapitalization.none,
    this.autofocus = false,
  });

  final String label;
  final TextEditingController? controller;
  final bool mono;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final bool enabled;
  final TextCapitalization textCapitalization;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.mono(
            fontSize: 10,
            color: hasError ? AppColors.stampRed600 : AppColors.textFaint,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          enabled: enabled,
          autofocus: autofocus,
          textCapitalization: textCapitalization,
          style: mono
              ? AppTextStyles.mono(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink900,
                  letterSpacing: 0.4,
                )
              : AppTextStyles.sans(fontSize: 16, fontWeight: FontWeight.w600),
          cursorColor: AppColors.wood800,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: enabled ? AppColors.surfaceCard : AppColors.surfaceSunken,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: _border(AppColors.borderHairline),
            enabledBorder: _border(hasError ? AppColors.stampRed600 : AppColors.borderHairline),
            focusedBorder: _border(hasError ? AppColors.stampRed600 : AppColors.wood800, width: 1.6),
            disabledBorder: _border(AppColors.borderHairline),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          Text(
            errorText!,
            style: AppTextStyles.sans(fontSize: 12, color: AppColors.stampRed600),
          ),
        ],
      ],
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
