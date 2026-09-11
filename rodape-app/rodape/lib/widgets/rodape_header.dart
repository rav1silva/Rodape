import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Cabeçalho de madeira escura reutilizado em (quase) toda tela: um
/// eyebrow mono em caixa alta e um título grande em Saira Condensed.
///
/// Use [onBack] para o formato "CabecalhoTela" (com seta de voltar) das
/// telas secundárias, ou [trailing] para o ícone de ação das abas
/// principais (sino de notificações, mapa, ajustes...).
class RodapeHeader extends StatelessWidget {
  const RodapeHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.trailing,
    this.onBack,
  });

  final String title;
  final String? eyebrow;
  final Widget? trailing;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      color: AppColors.wood800,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (onBack != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back, color: AppColors.paper100),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (eyebrow != null)
                  Text(
                    eyebrow!.toUpperCase(),
                    style: AppTextStyles.mono(
                      fontSize: 10,
                      color: AppColors.textOnWoodMuted,
                      letterSpacing: 1.6,
                    ),
                  ),
                if (eyebrow != null) const SizedBox(height: 4),
                Text(
                  title,
                  style: AppTextStyles.display(
                    fontSize: 26,
                    color: AppColors.paper050,
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
