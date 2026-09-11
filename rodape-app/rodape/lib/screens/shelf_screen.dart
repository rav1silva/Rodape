import 'package:flutter/material.dart';

import '../helpers/mocks/mock_books.dart';
import '../helpers/models/book.dart';
import '../helpers/models/book_status.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/book_cover.dart';
import '../widgets/filter_chip_pill.dart';
import '../widgets/rodape_button.dart';
import '../widgets/rodape_header.dart';
import '../widgets/status_badge.dart';

class ShelfScreen extends StatefulWidget {
  const ShelfScreen({super.key});

  @override
  State<ShelfScreen> createState() => _ShelfScreenState();
}

class _ShelfScreenState extends State<ShelfScreen> {
  BookStatus? _filtro;

  @override
  Widget build(BuildContext context) {
    final estante = MockBooks.minhaEstante;
    final pedidos = estante
        .where((b) => b.status == BookStatus.reservado || b.status == BookStatus.caminho)
        .length;
    final visiveis = _filtro == null
        ? estante
        : estante.where((b) => b.status == _filtro).toList();

    return Scaffold(
      backgroundColor: AppColors.paper100,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            RodapeHeader(
              title: 'Minha estante',
              eyebrow: '${estante.length} exemplares · $pedidos pedidos',
            ),
            if (estante.isEmpty)
              const Expanded(child: _EmptyShelf())
            else ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: SizedBox(
                  height: 30,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      FilterChipPill(
                        label: 'Todos',
                        count: estante.length,
                        active: _filtro == null,
                        onTap: () => setState(() => _filtro = null),
                      ),
                      const SizedBox(width: 6),
                      for (final status in BookStatus.values) ...[
                        FilterChipPill(
                          label: status.label,
                          count: estante.where((b) => b.status == status).length,
                          active: _filtro == status,
                          onTap: () => setState(() => _filtro = status),
                        ),
                        const SizedBox(width: 6),
                      ],
                    ],
                  ),
                ),
              ),
              if (pedidos > 0)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  decoration: BoxDecoration(
                    color: AppColors.spineMustard,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.group_outlined, size: 17, color: AppColors.wood800),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '$pedidos exemplares seus foram pedidos. Entregar gera crédito.',
                          style: AppTextStyles.sans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.wood800,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward, size: 17, color: AppColors.wood800),
                    ],
                  ),
                ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 16,
                    childAspectRatio: 171 / 225,
                  ),
                  itemCount: visiveis.length,
                  itemBuilder: (context, index) => _ShelfTile(book: visiveis[index]),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceCard,
                  border: Border(top: BorderSide(color: AppColors.borderHairline)),
                ),
                child: RodapeButton(
                  label: 'Escanear livro',
                  icon: Icons.qr_code_scanner,
                  onPressed: () => _showComingSoon(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Escaneamento de código de barras — em breve.')),
    );
  }
}

class _ShelfTile extends StatelessWidget {
  const _ShelfTile({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: BookCover(book: book, width: 171, height: 180)),
        const SizedBox(height: 10),
        Text(
          book.titulo,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.sans(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 5),
        StatusBadge(status: book.status),
      ],
    );
  }
}

class _EmptyShelf extends StatelessWidget {
  const _EmptyShelf();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 26, 16, 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < AppColors.spines.length; i++)
                Container(
                  width: 26,
                  height: 82.0 + (i * 8 % 40),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: AppColors.spines[i],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Sua estante é a\nmoeda da roda',
            textAlign: TextAlign.center,
            style: AppTextStyles.display(fontSize: 28),
          ),
          const SizedBox(height: 14),
          Text(
            'Escaneie o código de barras de um livro que você já leu. Ele entra na '
            'rede na mesma hora e passa a valer crédito quando alguém pedir o título.',
            textAlign: TextAlign.center,
            style: AppTextStyles.sans(fontSize: 15, color: AppColors.ink700),
          ),
        ],
      ),
    );
  }
}
