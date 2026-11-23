
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:rodape/models/exemplar_status.dart';
import 'package:rodape/models/livro.dart';
import 'package:rodape/models/exemplar.dart';
import 'package:rodape/services/exemplar_service.dart';
import 'package:rodape/services/livro_service.dart';
import 'package:rodape/services/pedido_service.dart';
import 'package:rodape/services/auth_service.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/book_cover.dart';
import '../widgets/filter_chip_pill.dart';
import '../widgets/rodape_button.dart';
import '../widgets/rodape_header.dart';
import '../widgets/status_badge.dart';

import 'isbn_scanner_screen.dart';
import 'pedidos_recebidos_screen.dart';
import 'exemplar_details_screen.dart';

class ShelfScreen extends StatefulWidget {
  const ShelfScreen({super.key});

  @override
  State<ShelfScreen> createState() => _ShelfScreenState();
}

class _ShelfScreenState extends State<ShelfScreen> {
  late Future<List<Livro>> _fetchFuture;

  ExemplarStatus? _filtro;

  Future<void> _abrirScanner() async {
    if (defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.windows) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'O escaneamento precisa ser testado em um dispositivo com câmera compatível.',
          ),
        ),
      );
      return;
    }

    final resultado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const IsbnScannerScreen(),
      ),
    );

    if (resultado == true && mounted) {
      setState(() {
        _fetchFuture = _obterLivrosDisponiveis();
      });
    }
  }

  Future<List<Livro>> _obterLivrosDisponiveis() async {
    final usuario = AuthService.loggedUser;

    if (usuario == null || usuario.id == null) {
      return [];
    }

    final livros = await LivroService.obterLivros();

    for (final livro in livros) {
      final exemplares = await ExemplarService.obterExemplaresLivro(
        livro,
        donoId: usuario.id!,
      );

      livro.exemplares = exemplares;
      livro.pedidos = await PedidoService.pedidosLivro(livro);
    }

    return livros.where((livro) => livro.exemplaresCount > 0).toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchFuture = _obterLivrosDisponiveis();
  }

  Widget _botaoEscanear() {
    return Container(
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
        label: 'Escanear livro',
        icon: Icons.qr_code_scanner,
        onPressed: _abrirScanner,
      ),
    );
  }

  void _abrirPedidosRecebidos() {
    if (AuthService.loggedUser == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PedidosRecebidosScreen(),
      ),
    );
  }

  Future<void> _abrirDetalhes(
    Livro livro,
    Exemplar exemplar,
  ) async {
    final atualizado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ExemplarDetailsScreen(
          book: livro,
          exemplar: exemplar,
        ),
      ),
    );

    if (atualizado == true && mounted) {
      setState(() {
        _fetchFuture = _obterLivrosDisponiveis();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper100,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Livro>>(
                future: _fetchFuture,
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Não foi possível carregar sua estante.',
                        style: AppTextStyles.sans(
                          fontSize: 14,
                          color: AppColors.ink700,
                        ),
                      ),
                    );
                  }

                  final data = snapshot.data ?? [];

                  if (data.isEmpty) {
                    return const _EmptyShelf();
                  }

                  // Transforma os livros em uma lista de exemplares individuais.
                  final itens = data.expand((livro) {
                    return (livro.exemplares ?? []).map(
                      (exemplar) => _ShelfItem(
                        book: livro,
                        exemplar: exemplar,
                      ),
                    );
                  }).toList();

                  final exemplares = itens.length;

                  final pedidos = data.fold<int>(
                    0,
                    (total, livro) =>
                        total + (livro.pedidos?.length ?? 0),
                  );

                  // O filtro agora é aplicado individualmente a cada exemplar.
                  final itensFiltrados = _filtro == null
                      ? itens
                      : itens
                          .where(
                            (item) => item.exemplar.status == _filtro,
                          )
                          .toList();

                  return Column(
                    children: [
                      RodapeHeader(
                        title: 'Minha estante',
                        eyebrow: '$exemplares exemplares · $pedidos pedidos',
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          16,
                          12,
                          16,
                          10,
                        ),
                        child: SizedBox(
                          height: 30,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              FilterChipPill(
                                label: 'Todos',
                                count: exemplares,
                                active: _filtro == null,
                                onTap: () {
                                  setState(() => _filtro = null);
                                },
                              ),
                              const SizedBox(width: 6),
                              for (final status in ExemplarStatus.values) ...[
                                FilterChipPill(
                                  label: status.label,
                                  count: itens
                                      .where(
                                        (item) =>
                                            item.exemplar.status == status,
                                      )
                                      .length,
                                  active: _filtro == status,
                                  onTap: () {
                                    setState(() => _filtro = status);
                                  },
                                ),
                                const SizedBox(width: 6),
                              ],
                            ],
                          ),
                        ),
                      ),
                      if (pedidos > 0)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            16,
                            0,
                            16,
                            14,
                          ),
                          child: Material(
                            color: AppColors.spineMustard,
                            borderRadius: BorderRadius.circular(5),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(5),
                              onTap: _abrirPedidosRecebidos,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 11,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.group_outlined,
                                      size: 17,
                                      color: AppColors.wood800,
                                    ),
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
                                    const Icon(
                                      Icons.arrow_forward,
                                      size: 17,
                                      color: AppColors.wood800,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      Expanded(
                        child: itensFiltrados.isEmpty
                            ? Center(
                                child: Text(
                                  'Nenhum exemplar com esse status.',
                                  style: AppTextStyles.sans(
                                    fontSize: 14,
                                    color: AppColors.ink700,
                                  ),
                                ),
                              )
                            : GridView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  12,
                                ),
                                gridDelegate:
                                    const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 190,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  childAspectRatio: 171 / 245,
                                ),
                                itemCount: itensFiltrados.length,
                                itemBuilder: (context, index) {
                                  final item = itensFiltrados[index];

                                  return _ShelfTile(
                                    book: item.book,
                                    exemplar: item.exemplar,
                                    onTap: () {
                                      _abrirDetalhes(
                                        item.book,
                                        item.exemplar,
                                      );
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // O botão fica fora do FutureBuilder e aparece sempre.
            _botaoEscanear(),
          ],
        ),
      ),
    );
  }
}

// Representa um livro junto de uma cópia específica.
class _ShelfItem {
  const _ShelfItem({
    required this.book,
    required this.exemplar,
  });

  final Livro book;
  final Exemplar exemplar;
}

class _ShelfTile extends StatelessWidget {
  const _ShelfTile({
    required this.book,
    required this.exemplar,
    required this.onTap,
  });

  final Livro book;
  final Exemplar exemplar;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: BookCover(
                book: book,
                width: 171,
                height: 180,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              book.titulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.sans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            StatusBadge(status: exemplar.status),
            const SizedBox(height: 4),
            Text(
              'Conservação: ${exemplar.estadoDeConservacao}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.sans(
                fontSize: 11,
                color: AppColors.ink700,
              ),
            ),
          ],
        ),
      ),
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
            style: AppTextStyles.sans(
              fontSize: 15,
              color: AppColors.ink700,
            ),
          ),
        ],
      ),
    );
  }
}

