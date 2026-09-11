import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Linha simples label/valor (FieldRow) — usada no extrato de crédito do
/// Perfil. Valor verde quando positivo, vermelho quando negativo.
class FieldRow extends StatelessWidget {
  const FieldRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  bool get _negativo => value.trim().startsWith('−') || value.trim().startsWith('-');

  @override
  Widget build(BuildContext context) {
    final valueColor = _negativo ? AppColors.stampRed600 : AppColors.stampGreen600;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.sans(fontSize: 13, color: AppColors.ink700),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.mono(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
