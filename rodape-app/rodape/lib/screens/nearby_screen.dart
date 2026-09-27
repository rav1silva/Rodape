import 'package:flutter/material.dart';

import '../helpers/mocks/mock_books.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/book_row.dart';
import '../widgets/filter_chip_pill.dart';
import '../widgets/rodape_button.dart';

class NearbyScreen extends StatelessWidget {
  const NearbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final livros = MockBooks.perto;

    return Scaffold(
      backgroundColor: AppColors.paper100,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.wood800,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '28 EXEMPLARES EM 3 KM',
                          style: AppTextStyles.mono(
                            fontSize: 10,
                            color: AppColors.textOnWoodMuted,
                            letterSpacing: 1.6,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Perto de você',
                          style: AppTextStyles.display(
                            fontSize: 26,
                            color: AppColors.paper050,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.map_outlined,
                      color: AppColors.paper100,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: SizedBox(
                height: 30,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    FilterChipPill(label: 'Só minha lista', active: true),
                    SizedBox(width: 6),
                    FilterChipPill(label: 'Até 3 km'),
                    SizedBox(width: 6),
                    FilterChipPill(label: 'Bom ou melhor'),
                    SizedBox(width: 6),
                    FilterChipPill(label: 'Frete até R\$ 25'),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.borderHairline),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      border: Border.all(color: AppColors.wood800),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadowStamped,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: BookRow(
                      book: livros[0],
                      coverWidth: 112,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      subtitle:
                          '${livros[0].autor}\nestado: ${livros[0].estadoConservacao}',
                      metaLine:
                          '${livros[0].distanciaLabel}\n1 CRÉDITO + ${livros[0].freteLabel}',
                      footer: RodapeButton(
                        label: 'Resgatar crédito',
                        icon: Icons.paid_outlined,
                        size: RodapeButtonSize.sm,
                        variant: RodapeButtonVariant.accent,
                        onPressed: () {},
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  BookRow(
                    book: livros[1],
                    coverWidth: 96,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    metaLine:
                        '${livros[1].distanciaLabel} · 1 CRÉDITO + ${livros[1].freteLabel}',
                    footer: RodapeButton(
                      label: 'Resgatar crédito',
                      size: RodapeButtonSize.sm,
                      block: false,
                      variant: RodapeButtonVariant.quiet,
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.spineMustard,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mais 34 livros entre R\$ 25 e R\$ 60 de frete',
                          style: AppTextStyles.display(
                            fontSize: 17,
                            color: AppColors.wood800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Estão acima do seu limite de R\$ 25.',
                          style: AppTextStyles.sans(
                            fontSize: 13,
                            color: AppColors.wood700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        RodapeButton(
                          label: 'Ver mesmo assim',
                          size: RodapeButtonSize.sm,
                          onPressed: () {},
                        ),
                      ],
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
