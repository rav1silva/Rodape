import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'rodape_button.dart';

/// Card teal de saldo de crédito, usado na Home e na Lista de desejos.
/// "Um crédito paga um exemplar, sempre."
class CreditBalanceCard extends StatelessWidget {
  const CreditBalanceCard({
    super.key,
    required this.saldo,
    required this.validade,
    this.descricao =
        'Um crédito paga um exemplar, sempre. Resgate quando quiser, sem esperar roda.',
    this.onResgatar,
  });

  final int saldo;
  final String validade;
  final String descricao;
  final VoidCallback? onResgatar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.spineTeal,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'SALDO DE CRÉDITO',
                style: AppTextStyles.mono(
                  fontSize: 10,
                  color: const Color(0xFFBCD8D6),
                  letterSpacing: 1.6,
                ),
              ),
              const Spacer(),
              Text(
                'VALIDADE $validade',
                style: AppTextStyles.mono(
                  fontSize: 10,
                  color: const Color(0xFFBCD8D6),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$saldo',
                style: AppTextStyles.mono(
                  fontSize: 48,
                  fontWeight: FontWeight.w600,
                  color: AppColors.paper050,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    descricao,
                    style: AppTextStyles.sans(
                      fontSize: 13,
                      color: const Color(0xFFDDEBEA),
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RodapeButton(
            label: 'Resgatar crédito',
            icon: Icons.paid_outlined,
            variant: RodapeButtonVariant.accent,
            onPressed: onResgatar,
          ),
        ],
      ),
    );
  }
}
