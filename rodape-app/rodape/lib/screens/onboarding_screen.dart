import 'package:flutter/material.dart';

import '../helpers/mocks/mock_books.dart';
import '../helpers/models/book.dart';
import '../helpers/models/onboarding_args.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/book_cover.dart';
import '../widgets/rodape_button.dart';

/// C1 · Abertura — primeira tela do app: "Troca em roda, não em dupla".
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper100,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Hero(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  Container(
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
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              'FECHOU AGORA',
                              style: AppTextStyles.mono(
                                fontSize: 10,
                                color: AppColors.spineTeal,
                                letterSpacing: 1.6,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'HÁ 4 MIN',
                              style: AppTextStyles.mono(fontSize: 10, color: AppColors.textFaint),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Uma roda de três fechou',
                          style: AppTextStyles.display(fontSize: 20),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _RondaBook(book: MockBooks.vidasSecas, rota: 'AL → BM'),
                            const SizedBox(width: 10),
                            _RondaBook(book: MockBooks.horaDaEstrela, rota: 'BM → CT'),
                            const SizedBox(width: 10),
                            _RondaBook(book: MockBooks.tortoArado, rota: 'CT → AL'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.spineTeal,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '312 RODAS NESTE MÊS',
                          style: AppTextStyles.mono(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppColors.paper050,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Cada pessoa entrega uma vez e recebe uma vez. Quem entrega ganha crédito na hora.',
                          style: AppTextStyles.sans(fontSize: 12, color: const Color(0xFFDDEBEA)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: const BoxDecoration(
                color: AppColors.surfaceCard,
                border: Border(top: BorderSide(color: AppColors.borderHairline)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RodapeButton(
                    label: 'Começar',
                    onPressed: () => Navigator.of(context).pushNamed('/cep'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushNamed(
                      '/phone',
                      arguments: const PhoneStepArgs(isLogin: true),
                    ),
                    child: Text(
                      'Já tenho conta',
                      style: AppTextStyles.mono(
                        fontSize: 12,
                        color: AppColors.ink900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.wood800,
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'RODAPÉ',
                style: AppTextStyles.display(
                  fontSize: 22,
                  color: AppColors.paper100,
                ).copyWith(letterSpacing: 1.5),
              ),
              const Spacer(),
              Row(
                children: [
                  for (final c in AppColors.spines) ...[
                    Container(width: 7, height: 20, color: c),
                    if (c != AppColors.spines.last) const SizedBox(width: 3),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Troca em roda,\nnão em dupla',
            style: AppTextStyles.display(fontSize: 38, color: AppColors.paper050),
          ),
          const SizedBox(height: 10),
          Text(
            'Você diz o que tem e o que quer. O sistema fecha o circuito: cada um '
            'entrega para a próxima pessoa e recebe de outra.',
            style: AppTextStyles.sans(fontSize: 15, color: AppColors.textOnWoodMuted),
          ),
        ],
      ),
    );
  }
}

class _RondaBook extends StatelessWidget {
  const _RondaBook({required this.book, required this.rota});

  final Book book;
  final String rota;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          BookCover(book: book, width: 56, stampCompact: true),
          const SizedBox(height: 10),
          Text(
            rota,
            style: AppTextStyles.mono(
              fontSize: 10,
              color: AppColors.textMuted,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
