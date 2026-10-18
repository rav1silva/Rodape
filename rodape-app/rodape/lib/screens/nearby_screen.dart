import 'package:flutter/material.dart';
import 'package:rodape/models/exemplar.dart';
import 'package:rodape/services/exemplar_service.dart';
import 'package:rodape/services/livro_service.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/book_row.dart';
import '../widgets/filter_chip_pill.dart';
import '../widgets/rodape_button.dart';

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key});
  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  late Future<List<Exemplar>> _obterExemplaresFuture;

  Future<List<Exemplar>> _obterExemplares() async {
    final exemplares = await ExemplarService.obterFiltrado();
    for (final exemplar in exemplares) {
      exemplar.livro = await LivroService.obterById(exemplar.livroId);
    }
    return exemplares;
  }

  @override
  void initState() {
    super.initState();
    _obterExemplaresFuture = _obterExemplares();
  }

  @override
  Widget build(BuildContext context) {
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
            FutureBuilder(
              future: _obterExemplaresFuture,
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  final data = snapshot.data;
                  if (data == null) {
                    return Column();
                  }

                  return Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                      children: [
                        for (final exemplar in data) ...[
                          if (exemplar.livro != null)
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
                                book: exemplar.livro!,
                                coverWidth: 112,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                subtitle:
                                    '${exemplar.livro!.autor}\nestado: ${exemplar.estadoDeConservacao}',
                                metaLine:
                                    '${exemplar.distancia}\n1 CRÉDITO + ${exemplar.frete}',
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
                        ],
                      ],
                    ),
                  );
                }

                return Text("Loading...");
              },
            ),
          ],
        ),
      ),
    );
  }
}
