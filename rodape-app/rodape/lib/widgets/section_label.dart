import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Eyebrow mono em caixa alta usado para rotular seções de conteúdo,
/// com um valor opcional alinhado à direita (ex.: "5 TÍTULOS").
class SectionLabel extends StatelessWidget {
  const SectionLabel({
    super.key,
    required this.label,
    this.trailing,
    this.color = AppColors.textFaint,
  });

  final String label;
  final String? trailing;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label.toUpperCase(),
      style: AppTextStyles.mono(fontSize: 10, color: color, letterSpacing: 1.6),
    );

    if (trailing == null) return text;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(child: text),
        Text(
          trailing!.toUpperCase(),
          style: AppTextStyles.mono(
            fontSize: 10,
            color: AppColors.textFaint,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
