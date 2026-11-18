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
import '../widgets/rodape_text_field.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});
  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<Desejo>? _itens;

  @override
  void initState() {
    super.initState();
    DesejoService.versao.addListener(_carregar);
    _carregar(); // mostra o que está no aparelho na hora
    DesejoService.sync(); // e atualiza em segundo plano (se houver internet)
  }

  @override
  void dispose() {
    DesejoService.versao.removeListener(_carregar);
    super.dispose();
  }

  Future<void> _carregar() async {
    final user = AuthService.loggedUser;
    final desejos = user == null ? <Desejo>[] : await DesejoService.obterDesejos(user);
    for (final d in desejos) {
      d.livro = await LivroService.obterById(d.livroId);
    }
    if (mounted) setState(() => _itens = desejos);
  }

  void _reordenar(int de, int para) {
    final user = AuthService.loggedUser;
    if (user == null || _itens == null) return;
    if (para > de) para--;
    final nova = [..._itens!];
    nova.insert(para, nova.removeAt(de));
    setState(() => _itens = nova);
    DesejoService.reordenar(user, nova);
  }

  void _remover(Desejo d) {
    final user = AuthService.loggedUser;
    if (user != null) DesejoService.remover(user, d);
  }

  Future<void> _adicionar() async {
    final user = AuthService.loggedUser;
    if (user == null) return;
    final livro = await showModalBottomSheet<Livro>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.paper100,
      builder: (_) => const _BuscaLivroSheet(),
    );
    if (livro != null) await DesejoService.adicionar(user, livro);
  }

  @override
  Widget build(BuildContext context) {
    final saldo = AuthService.loggedUser?.saldoCredito ?? 0;
    final itens = _itens;

    return Scaffold(
      backgroundColor: AppColors.paper100,
      body: SafeArea(
        bottom: false,
        child: itens == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  RodapeHeader(
                    title: 'Lista de desejos',
                    eyebrow: '${itens.length} títulos · arraste para reordenar',
                  ),
                  Container(
                    width: double.infinity,
                    color: AppColors.spineTeal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                    child: ReorderableListView.builder(
                      buildDefaultDragHandles: false,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      itemCount: itens.length,
                      onReorder: _reordenar,
                      itemBuilder: (context, i) {
                        final d = itens[i];
                        return Padding(
                          key: ValueKey(d.id),
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: _WishlistTile(index: i + 1, book: d.livro),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: AppColors.paperGray500,
                                ),
                                tooltip: 'Remover',
                                onPressed: () => _remover(d),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceCard,
                      border: Border(top: BorderSide(color: AppColors.borderHairline)),
                    ),
                    child: RodapeButton(
                      label: 'Adicionar título',
                      icon: Icons.add,
                      onPressed: _adicionar,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Busca no catálogo local (funciona sem internet).
class _BuscaLivroSheet extends StatefulWidget {
  const _BuscaLivroSheet();
  @override
  State<_BuscaLivroSheet> createState() => _BuscaLivroSheetState();
}

class _BuscaLivroSheetState extends State<_BuscaLivroSheet> {
  final _controller = TextEditingController();
  late Future<List<Livro>> _resultados = LivroService.obterLivros();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: 420,
        child: Column(
          children: [
            RodapeTextField(
              label: 'Adicionar título',
              controller: _controller,
              onChanged: (v) => setState(() {
                _resultados = LivroService.obterLivros(filtro: v);
              }),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<Livro>>(
                future: _resultados,
                builder: (context, snapshot) {
                  final livros = snapshot.data ?? [];
                  return ListView(
                    children: [
                      for (final l in livros)
                        ListTile(
                          dense: true,
                          title: Text(
                            l.titulo,
                            style: AppTextStyles.sans(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            l.autor,
                            style: AppTextStyles.sans(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.add_circle_outline,
                            color: AppColors.spineTeal,
                          ),
                          onTap: () => Navigator.of(context).pop(l),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WishlistTile extends StatelessWidget {
  const _WishlistTile({required this.index, required this.book});

  final int index;
  final Livro? book;

  bool get _semExemplar => (book?.exemplaresCount ?? 0) == 0;

  @override
  Widget build(BuildContext context) {
    if (book == null) return const SizedBox.shrink();

    final leading = ReorderableDragStartListener(
      index: index - 1,
      child: Column(
        children: [
          const Icon(Icons.drag_indicator, size: 15, color: AppColors.paperGray400),
          const SizedBox(height: 4),
          Text(
            index.toString().padLeft(2, '0'),
            style: AppTextStyles.mono(fontSize: 11, color: AppColors.textFaint),
          ),
        ],
      ),
    );

    final tile = BookRow(
      book: book!,
      coverWidth: _semExemplar ? 44 : 72,
      leading: leading,
      metaLine: _semExemplar
          ? 'NENHUM EXEMPLAR — AVISAMOS QUANDO APARECER'
          : '${book!.exemplaresCount} EXEMPLARES · ${book!.distancia} · 1 CRÉDITO + ${book!.frete}',
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
                  BoxShadow(color: AppColors.shadowStamped, offset: Offset(2, 2)),
                ],
              ),
              child: tile,
            )
          : tile;
    }

    return Opacity(opacity: 0.55, child: tile);
  }
}