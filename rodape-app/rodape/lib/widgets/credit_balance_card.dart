
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CreditBalanceCard extends StatelessWidget {
  const CreditBalanceCard({
    super.key,
    required this.saldo,
    this.descricao = 'Um crédito paga um exemplar, sempre.',
  });

  final int saldo;
  final String descricao;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.spineTeal,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SALDO DE CRÉDITO',
            style: AppTextStyles.mono(
              fontSize: 10,
              color: const Color(0xFFBCD8D6),
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                child: Text(
                  descricao,
                  textAlign: TextAlign.left,
                  style: AppTextStyles.sans(
                    fontSize: 13,
                    color: const Color(0xFFDDEBEA),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
