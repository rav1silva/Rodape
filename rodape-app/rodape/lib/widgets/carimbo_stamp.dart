import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// O "carimbo de circulação": mostra por quantas mãos (leitores) um
/// exemplar já passou. Azul até a 4ª mão, vermelho da 5ª em diante — o
/// selo visual de que um livro girou bastante na rede.
class CarimboStamp extends StatelessWidget {
  const CarimboStamp({super.key, required this.maos, this.compact = false});

  final int maos;
  final bool compact;

  bool get _alerta => maos >= 5;

  @override
  Widget build(BuildContext context) {
    final color = _alerta ? AppColors.stampRed600 : AppColors.stampBlue600;
    final label = maos <= 0 ? 'NOVO' : '$maosª MÃO';

    return Transform.rotate(
      angle: -0.06,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 8,
          vertical: compact ? 2 : 3,
        ),
        decoration: BoxDecoration(
          color: AppColors.paper050,
          border: Border.all(color: color, width: 1.4),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(
          label,
          style: AppTextStyles.mono(
            fontSize: compact ? 8.5 : 9.5,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}
