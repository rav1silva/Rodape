import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Card "Como os outros vão te ver": avatar com iniciais + nome público
/// (nome + inicial do sobrenome) + contagem de trocas. Usado como preview
/// ao vivo no passo "Seu nome".
class PublicProfileBadge extends StatelessWidget {
  const PublicProfileBadge({
    super.key,
    required this.nome,
    required this.sobrenomeInicial,
    this.trocasConcluidas = 0,
  });

  final String nome;
  final String sobrenomeInicial;
  final int trocasConcluidas;

  String get _iniciais {
    final n = nome.trim().isEmpty ? '?' : nome.trim()[0];
    final s = sobrenomeInicial.trim().isEmpty ? '' : sobrenomeInicial.trim()[0];
    return (n + s).toUpperCase();
  }

  String get _nomePublico {
    final n = nome.trim().isEmpty ? 'Seu nome' : nome.trim();
    final s = sobrenomeInicial.trim().isEmpty ? '' : ' ${sobrenomeInicial.trim()[0].toUpperCase()}.';
    return '$n$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.wood800),
        borderRadius: BorderRadius.circular(5),
        boxShadow: const [
          BoxShadow(color: AppColors.shadowStamped, offset: Offset(2, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'COMO OS OUTROS VÃO TE VER',
            style: AppTextStyles.mono(
              fontSize: 10,
              color: AppColors.textFaint,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.spineTeal,
                child: Text(
                  _iniciais,
                  style: AppTextStyles.display(fontSize: 17, color: AppColors.paper050),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _nomePublico,
                      style: AppTextStyles.sans(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$trocasConcluidas TROCAS CONCLUÍDAS',
                      style: AppTextStyles.mono(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
