import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'rodape_header.dart';

/// Cabeçalho de um passo do cadastro: reaproveita o [RodapeHeader]
/// ("PASSO N DE TOTAL" + título) e acrescenta a barra de progresso
/// segmentada logo abaixo.
class StepProgressHeader extends StatelessWidget {
  const StepProgressHeader({
    super.key,
    required this.step,
    required this.totalSteps,
    required this.title,
    this.eyebrowSuffix,
    this.onBack,
  });

  final int step;
  final int totalSteps;
  final String title;

  /// Texto extra concatenado ao eyebrow, ex.: `" · Vila Buarque"`.
  final String? eyebrowSuffix;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RodapeHeader(
          title: title,
          eyebrow: 'Passo $step de $totalSteps${eyebrowSuffix ?? ''}',
          onBack: onBack,
        ),
        Container(
          width: double.infinity,
          color: AppColors.wood800,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: Row(
            children: [
              for (var i = 0; i < totalSteps; i++) ...[
                if (i > 0) const SizedBox(width: 4),
                Expanded(
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: i < step ? AppColors.spineMustard : AppColors.borderOnWood,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
