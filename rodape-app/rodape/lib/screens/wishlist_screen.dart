
import 'package:flutter/material.dart';
import 'package:rodape/models/desejo.dart';
import 'package:rodape/models/livro.dart';
import 'package:rodape/models/exemplar.dart';
import 'package:rodape/models/exemplar_status.dart';
import 'package:rodape/services/auth_service.dart';
import 'package:rodape/services/desejo_service.dart';
import 'package:rodape/services/livro_service.dart';
import 'package:rodape/services/exemplar_service.dart';
import 'package:rodape/services/pedido_service.dart';
import 'package:rodape/services/profile_service.dart';

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
    _carregar();
    DesejoService.sync();
  }

  @override
  void dispose() {
    DesejoService.versao.removeListener(_carregar);
    super.dispose();
  }

  Future<void> _carregar() async {
    final user = AuthService.loggedUser;

    final desejos = user == null
        ? <Desejo>[]
        : await DesejoService.obterDesejos(user);

    for (final d in desejos) {
      d.livro = await LivroService.obterById(d.livroId);

      if (d.livro != null) {
        d.livro!.exemplares =
            await ExemplarService.obterExemplaresLivro(d.livro!);
      }
    }

    if (mounted) {
      setState(() => _itens = desejos);
    }
  }

  Future<void> _resgatar(Livro livro) async {
    final user = AuthService.loggedUser;

    if (user == null || user.id == null) {
      return;
    }

    final disponiveis = (livro.exemplares ?? [])
        .where(
          (e) => e.status == ExemplarStatus.disponivel,
        )
        .toList();

    if (disponiveis.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhum exemplar disponível no momento.'),
        ),
      );
      return;
    }

    // Seleciona o primeiro exemplar disponível.
    final Exemplar exemplar = disponiveis.first;

    if (user.saldoCredito < exemplar.creditos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saldo de créditos insuficiente.'),
        ),
      );
      return;
    }

    final frete =
        (exemplar.frete ?? 0).toStringAsFixed(2).replaceAll('.', ',');

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.paper050,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: AppColors.paper300,
            width: 1,
          ),
        ),
        title: const Text(
          'Confirmar resgate?',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.ink900,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              livro.titulo,
              style: const TextStyle(
                color: AppColors.ink900,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.paper300),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.toll_rounded,
                  color: AppColors.spineMustard,
                ),
                const SizedBox(width: 10),
                const Expanded(child: Text('Créditos')),
                Text(
                  '${exemplar.creditos}',
                  style: const TextStyle(
                    color: AppColors.wood800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.local_shipping_outlined,
                  color: AppColors.spineTeal,
                ),
                const SizedBox(width: 10),
                const Expanded(child: Text('Frete')),
                Text(
                  'R\$ $frete',
                  style: const TextStyle(
                    color: AppColors.ink900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Ao confirmar, os créditos serão reservados para este pedido.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.paperGray600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.wood700,
                    foregroundColor: AppColors.paper050,
                  ),
                  child: const Text('Confirmar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await PedidoService.criar(exemplar, user);

      final atualizado =
          await ProfileService.obterUsuarioPorId(user.id!);

      if (atualizado != null) {
        AuthService.loggedUser = atualizado;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pedido realizado com sucesso!'),
        ),
      );

      await _carregar();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível realizar o resgate: $e'),
        ),
      );
    }
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

    if (user != null) {
      DesejoService.remover(user, d);
    }
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

    if (livro != null) {
      await DesejoService.adicionar(user, livro);
    }
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
                    eyebrow:
                        '${itens.length} títulos · arraste para reordenar',
                  ),
                  Container(
                    width: double.infinity,
                    color: AppColors.spineTeal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      itemCount: itens.length,
                      onReorder: _reordenar,
                      itemBuilder: (context, i) {
                        final d = itens[i];

                        return Padding(
                          key: ValueKey(d.id),
                          padding:
                              const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: _WishlistTile(
                                  index: i + 1,
                                  book: d.livro,
                                  onResgatar: d.livro == null
                                      ? null
                                      : () => _resgatar(d.livro!),
                                ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceCard,
                      border: Border(
                        top: BorderSide(
                          color: AppColors.borderHairline,
                        ),
                      ),
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

  late Future<List<Livro>> _resultados =
      LivroService.obterLivros();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: 420,
        child: Column(
          children: [
            RodapeTextField(
              label: 'Adicionar título',
              controller: _controller,
              onChanged: (v) => setState(() {
                _resultados =
                    LivroService.obterLivros(filtro: v);
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
                            style: AppTextStyles.sans(
                              fontWeight: FontWeight.w600,
                            ),
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
                          onTap: () =>
                              Navigator.of(context).pop(l),
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
  const _WishlistTile({
    required this.index,
    required this.book,
    required this.onResgatar,
  });

  final int index;
  final Livro? book;
  final VoidCallback? onResgatar;

  int get _exemplaresDisponiveis =>
      book?.exemplares
          ?.where(
            (exemplar) =>
                exemplar.status == ExemplarStatus.disponivel,
          )
          .length ??
      0;

  bool get _semExemplar => _exemplaresDisponiveis == 0;

  @override
  Widget build(BuildContext context) {
    if (book == null) {
      return const SizedBox.shrink();
    }

    final leading = ReorderableDragStartListener(
      index: index - 1,
      child: Column(
        children: [
          const Icon(
            Icons.drag_indicator,
            size: 15,
            color: AppColors.paperGray400,
          ),
          const SizedBox(height: 4),
          Text(
            index.toString().padLeft(2, '0'),
            style: AppTextStyles.mono(
              fontSize: 11,
              color: AppColors.textFaint,
            ),
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
          : '$_exemplaresDisponiveis EXEMPLARES DISPONÍVEIS · ${book!.distancia} · 1 CRÉDITO + ${book!.frete}',
      footer: _semExemplar
          ? null
          : RodapeButton(
              label: 'Resgatar com crédito',
              size: RodapeButtonSize.sm,
              variant: index == 1
                  ? RodapeButtonVariant.accent
                  : RodapeButtonVariant.quiet,
              onPressed: onResgatar,
            ),
    );

    if (!_semExemplar) {
      return index == 1
          ? Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                border: Border.all(
                  color: AppColors.wood800,
                ),
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
      child: tile,
    );
  }
}
