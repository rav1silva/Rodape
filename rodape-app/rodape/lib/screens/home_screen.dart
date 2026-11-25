
import 'package:flutter/material.dart';
import 'package:rodape/extensions/datetime_extensions.dart';
import 'package:rodape/models/exemplar.dart';
import 'package:rodape/models/notificacao.dart';
import 'package:rodape/models/exemplar_status.dart';
import 'package:rodape/models/pedido.dart';
import 'package:rodape/services/auth_service.dart';
import 'package:rodape/services/desejo_service.dart';
import 'package:rodape/services/exemplar_service.dart';
import 'package:rodape/services/livro_service.dart';
import 'package:rodape/services/notificacao_service.dart';
import 'package:rodape/services/profile_service.dart';
import 'package:rodape/services/pedido_service.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/book_row.dart';
import '../widgets/credit_balance_card.dart';
import '../widgets/dashed_divider.dart';
import '../widgets/rodape_button.dart';
import '../widgets/section_label.dart';
import 'notifications_screen.dart';
import 'pedidos_recebidos_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onAbrirPerto,
    required this.onAbrirEstante,
    required this.onAbrirLista,
  });

  final VoidCallback onAbrirPerto;
  final VoidCallback onAbrirEstante;
  final VoidCallback onAbrirLista;

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late Future<List<Exemplar>> _obterLivrosDesejadosFuture;
  late Future<List<Notificacao>> _obterNotificacoesFuture;
  late Future<_ProximaAcao> _obterNextActionFuture;

  void atualizarAoRetornar() {
    setState(() {
      _obterLivrosDesejadosFuture = _obterLivrosPerto();
      _obterNotificacoesFuture = _obterNotificacoes();
      _obterNextActionFuture = _obterNextAction();
    });

    _atualizarPerfil();
  }

  @override
  void initState() {
    super.initState();

    _obterLivrosDesejadosFuture = _obterLivrosPerto();
    _obterNotificacoesFuture = _obterNotificacoes();
    _obterNextActionFuture = _obterNextAction();

    _atualizarPerfil();
  }

  Future<void> _atualizarPerfil() async {
    final user = AuthService.loggedUser;

    if (user == null || user.id == null) return;

    try {
      final atualizado = await ProfileService.obterUsuarioPorId(user.id!);

      if (!mounted || atualizado == null) return;

      setState(() {
        AuthService.loggedUser = atualizado;
      });
    } catch (e) {
      debugPrint('Erro ao atualizar perfil: $e');
    }
  }

  Future<List<Exemplar>> _obterLivrosPerto() async {
    final user = AuthService.loggedUser;

    if (user == null || user.id == null) {
      return [];
    }

    final todos = await ExemplarService.obterFiltrado();
    final desejos = await DesejoService.obterDesejos(user);

    final livrosDesejados = desejos.map((d) => d.livroId).toSet();

    final exemplares = todos.where((exemplar) {
      return exemplar.status == ExemplarStatus.disponivel &&
          exemplar.donoId != user.id &&
          livrosDesejados.contains(exemplar.livroId);
    }).toList();

    for (final exemplar in exemplares) {
      exemplar.livro = await LivroService.obterById(exemplar.livroId);
    }

    return exemplares;
  }

  Future<List<Notificacao>> _obterNotificacoes() async {
    if (AuthService.loggedUser == null) {
      return [];
    }

    return NotificacaoService.obterNotificacoes(
      AuthService.loggedUser!,
    );
  }

  Future<_ProximaAcao> _obterNextAction() async {
    final user = AuthService.loggedUser;

    if (user == null || user.id == null) {
      return _acaoGenerica();
    }

    // 1. Verifica se existem pedidos recebidos pendentes.
    final pedidos = await PedidoService.pedidosRecebidos(user);

    final pedidosPendentes = pedidos
        .where((pedido) => pedido.status == PedidoStatus.pendente)
        .toList();

    if (pedidosPendentes.isNotEmpty) {
      final pedido = pedidosPendentes.first;
      final nomeSolicitante = pedido.solicitante?.nome ?? 'Alguém';
      final tituloLivro = pedido.livro?.titulo ?? 'um dos seus livros';

      return _ProximaAcao(
        titulo: 'Você recebeu um pedido!',
        descricao: '$nomeSolicitante solicitou $tituloLivro.',
        botao: 'Ver pedidos recebidos',
        icone: Icons.mark_email_unread_outlined,
        aoClicar: _abrirPedidosRecebidos,
      );
    }

    // 2. Verifica se algum livro da lista está disponível por perto.
    final desejos = await DesejoService.obterDesejos(user);

    if (desejos.isNotEmpty) {
      final livrosDesejados = desejos.map((d) => d.livroId).toSet();
      final todos = await ExemplarService.obterFiltrado();

      final disponiveis = todos.where((exemplar) {
        return exemplar.status == ExemplarStatus.disponivel &&
            exemplar.donoId != user.id &&
            livrosDesejados.contains(exemplar.livroId);
      }).toList();

      if (disponiveis.isNotEmpty) {
        final exemplar = disponiveis.first;
        final livro = await LivroService.obterById(exemplar.livroId);

        return _ProximaAcao(
          titulo: 'Encontramos um livro da sua lista!',
          descricao: livro != null
              ? '${livro.titulo} está disponível por perto.'
              : 'Um livro que você deseja está disponível por perto.',
          botao: 'Ver livro em Perto',
          icone: Icons.menu_book_outlined,
          aoClicar: widget.onAbrirPerto,
        );
      }
    } else {
      // 3. A lista de desejos está vazia.
      return _ProximaAcao(
        titulo: 'Monte sua lista de desejos',
        descricao:
            'Adicione livros que você gostaria de encontrar no Rodapé.',
        botao: 'Abrir minha lista',
        icone: Icons.bookmark_add_outlined,
        aoClicar: widget.onAbrirLista,
      );
    }

    // 4. Não há pedidos pendentes nem livros desejados disponíveis.
    return _acaoGenerica();
  }

  _ProximaAcao _acaoGenerica() {
    return _ProximaAcao(
      titulo: 'Que tal compartilhar um livro?',
      descricao:
          'Cadastre um exemplar na sua estante e ajude outro leitor a encontrar sua próxima leitura.',
      botao: 'Abrir minha estante',
      icone: Icons.library_books_outlined,
      aoClicar: widget.onAbrirEstante,
    );
  }

  Future<void> _abrirPedidosRecebidos() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PedidosRecebidosScreen(),
      ),
    );

    if (mounted) {
      atualizarAoRetornar();
    }
  }

  Widget _construirLivroPerto(Exemplar exemplar) {
    final livro = exemplar.livro!;

    final distancia = exemplar.distancia != null
        ? '${exemplar.distancia} km'
        : 'Distância indisponível';

    final frete = (exemplar.frete ?? 0)
        .toStringAsFixed(2)
        .replaceAll('.', ',');

    return BookRow(
      book: livro,
      coverWidth: 56,
      metaLine: '$distancia · ${exemplar.creditos} CRÉDITO + R\$ $frete',
    );
  }

  Widget _construirProximaAcao(_ProximaAcao acao) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                acao.icone,
                color: AppColors.stampRed600,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      acao.titulo,
                      style: AppTextStyles.sans(
                        fontSize: 15,
                        color: AppColors.wood800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      acao.descricao,
                      style: AppTextStyles.sans(
                        fontSize: 13,
                        color: AppColors.wood800,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: DashedDivider(),
          ),
          RodapeButton(
            label: acao.botao,
            variant: RodapeButtonVariant.quiet,
            size: RodapeButtonSize.sm,
            onPressed: acao.aoClicar,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper100,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            FutureBuilder<List<Notificacao>>(
              future: _obterNotificacoesFuture,
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return _HomeHeader(
                    notificacoes: snapshot.data ?? [],
                  );
                }

                return const _HomeHeader(notificacoes: []);
              },
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                children: [
                  CreditBalanceCard(
                    saldo: AuthService.loggedUser?.saldoCredito ?? 0,
                  ),
                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.all(14),
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
                    child: FutureBuilder<List<Exemplar>>(
                      future: _obterLivrosDesejadosFuture,
                      builder: (ctx, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return const Text(
                            'Não foi possível carregar os livros próximos.',
                          );
                        }

                        final data = snapshot.data ?? [];

                        final livrosExibidos = data
                            .where((exemplar) => exemplar.livro != null)
                            .take(3)
                            .toList();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionLabel(
                              label: 'Da sua lista, disponível agora',
                              trailing: '${data.length} títulos',
                            ),
                            const SizedBox(height: 12),
                            if (livrosExibidos.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  'Nenhum livro da sua lista está disponível por perto no momento.',
                                ),
                              )
                            else
                             for (var i = 0; i < livrosExibidos.length; i++)
  Padding(
    padding: EdgeInsets.only(
      bottom: i == livrosExibidos.length - 1 ? 0 : 12,
    ),
    child: _construirLivroPerto(livrosExibidos[i]),
  ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: DashedDivider(),
                            ),
                            const SizedBox(height: 10),
                            RodapeButton(
                              label: 'Ver todos em Perto',
                              variant: RodapeButtonVariant.quiet,
                              size: RodapeButtonSize.sm,
                              onPressed: widget.onAbrirPerto,
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 18),

                  const SectionLabel(
                    label: 'Sua próxima ação',
                    color: AppColors.stampRed600,
                  ),

                  const SizedBox(height: 10),

                  FutureBuilder<_ProximaAcao>(
                    future: _obterNextActionFuture,
                    builder: (ctx, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasError) {
                        return _construirProximaAcao(_acaoGenerica());
                      }

                      return _construirProximaAcao(
                        snapshot.data ?? _acaoGenerica(),
                      );
                    },
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

class _ProximaAcao {
  const _ProximaAcao({
    required this.titulo,
    required this.descricao,
    required this.botao,
    required this.icone,
    required this.aoClicar,
  });

  final String titulo;
  final String descricao;
  final String botao;
  final IconData icone;
  final VoidCallback aoClicar;
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.notificacoes});

  final List<Notificacao> notificacoes;

  @override
  Widget build(BuildContext context) {
    final badges = notificacoes.length;

    return Container(
      color: AppColors.wood800,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Text(
            'RODAPÉ',
            style: AppTextStyles.display(
              fontSize: 20,
              color: AppColors.paper050,
            ),
          ),
          const Spacer(),
          Text(
            '${DateTime.now().getNameOfDayWeek()}, ${DateTime.now().toSimplifiedDate()}',
            style: AppTextStyles.mono(
              fontSize: 10,
              color: AppColors.textOnWoodMuted,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(width: 8),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        NotificationsScreen(notificacoes: notificacoes),
                  ),
                ),
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.paper100,
                ),
              ),
              if (badges > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.stampRed600,
                      shape: BoxShape.circle,
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
