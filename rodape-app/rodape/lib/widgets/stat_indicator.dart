import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Card de estatística curta (Indicador), usado em grade de 3 colunas no
/// Perfil: ícone, valor grande e rótulo.
class StatIndicator extends StatelessWidget {
  const StatIndicator({
    super.key,
    required this.icon,
    required this.valor,
    required this.rotulo,
  });

  final IconData icon;
  final String valor;
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.borderHairline),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.spineTeal),
          const SizedBox(height: 10),
          Text(
            valor,
            style: AppTextStyles.mono(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.ink900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            rotulo,
            style: AppTextStyles.mono(
              fontSize: 9.5,
              color: AppColors.textFaint,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
