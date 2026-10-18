import 'package:flutter/material.dart';
import 'package:rodape/models/desejo.dart';
import 'package:rodape/models/livro.dart';
import 'package:rodape/services/auth_service.dart';
import 'package:rodape/services/desejo_service.dart';
import 'package:rodape/services/livro_service.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/book_row.dart';
import '../widgets/rodape_button.dart';
import '../widgets/rodape_header.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});
  @override
  State<WishlistScreen> createState() => _WishlistScreenStare();
}

class _WishlistScreenStare extends State<WishlistScreen> {
  late Future<List<Desejo>> _fetchDesejos;

  Future<List<Desejo>> _obterListaDesejos() async {
    final desejos = await DesejoService.obterDesejos(AuthService.loggedUser!);
    for (final desejo in desejos) {
      desejo.livro = await LivroService.obterById(desejo.livroId);
    }

    return desejos;
  }

  @override
  void initState() {
    super.initState();
    _fetchDesejos = _obterListaDesejos();
  }

  @override
  Widget build(BuildContext context) {
    final saldo = AuthService.loggedUser?.saldoCredito ?? 0;

    return Scaffold(
      backgroundColor: AppColors.paper100,
      body: SafeArea(
        bottom: false,
        child: FutureBuilder(
          future: _fetchDesejos,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              final data = snapshot.data;

              if (data == null) {
                return Column();
              }

              return Column(
                children: [
                  RodapeHeader(
                    title: 'Lista de desejos',
                    eyebrow: '${data.length} títulos · arraste para reordenar',
                  ),
                  Container(
                    width: double.infinity,
                    color: AppColors.spineTeal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'SALDO',
                          style: AppTextStyles.mono(
                            fontSize: 10,
                            color: const Color(0xFFBCD8D6),
                            letterSpacing: 1.6,
                          ),
                        ),
                        Text(
                          '$saldo CRÉDITOS',
                          style: AppTextStyles.mono(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.paper050,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      itemCount: data.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => _WishlistTile(
                        index: index + 1,
                        book: data[index].livro,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceCard,
                      border: Border(
                        top: BorderSide(color: AppColors.borderHairline),
                      ),
                    ),
                    child: RodapeButton(
                      label: 'Adicionar título',
                      icon: Icons.add,
                      onPressed: () {},
                    ),
                  ),
                ],
              );
            }

            return Text("Loading...");
          },
        ),
      ),
    );
  }
}

class _WishlistTile extends StatelessWidget {
  const _WishlistTile({required this.index, required this.book});

  final int index;
  final Livro? book;

  bool get _semExemplar => (book?.exemplares ?? 0) == 0;

  @override
  Widget build(BuildContext context) {
    if (book == null) {
      return Column();
    }

    final leading = Column(
      children: [
        const Icon(
          Icons.drag_indicator,
          size: 15,
          color: AppColors.paperGray400,
        ),
        const SizedBox(height: 4),
        Text(
          index.toString().padLeft(2, '0'),
          style: AppTextStyles.mono(fontSize: 11, color: AppColors.textFaint),
        ),
      ],
    );

    final tile = BookRow(
      book: book!,
      coverWidth: _semExemplar ? 44 : 72,
      leading: leading,
      metaLine: _semExemplar
          ? 'NENHUM EXEMPLAR — AVISAMOS QUANDO APARECER'
          : '${book?.exemplares} EXEMPLARES · ${book?.distancia} · 1 CRÉDITO + ${book?.frete}',
      footer: _semExemplar
          ? null
          : RodapeButton(
              label: 'Resgatar com crédito',
              size: RodapeButtonSize.sm,
              variant: index == 1
                  ? RodapeButtonVariant.accent
                  : RodapeButtonVariant.quiet,
              onPressed: () {},
            ),
    );

    if (!_semExemplar) {
      return index == 1
          ? Container(
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
              child: tile,
            )
          : tile;
    }

    return Opacity(
      opacity: 0.55,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Divider(height: 1, color: AppColors.borderData),
          ),
          tile,
        ],
      ),
    );
  }
}
