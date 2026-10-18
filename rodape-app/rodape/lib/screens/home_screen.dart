import 'package:flutter/material.dart';
import 'package:rodape/extensions/datetime_extensions.dart';
import 'package:rodape/models/exemplar.dart';
import 'package:rodape/models/notificacao.dart';
import 'package:rodape/services/auth_service.dart';
import 'package:rodape/services/desejo_service.dart';
import 'package:rodape/services/exemplar_service.dart';
import 'package:rodape/services/livro_service.dart';
import 'package:rodape/services/notificacao_service.dart';
import 'package:rodape/services/profile_service.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/book_row.dart';
import '../widgets/credit_balance_card.dart';
import '../widgets/dashed_divider.dart';
import '../widgets/rodape_button.dart';
import '../widgets/section_label.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Exemplar>> _obterLivrosDesejadosFuture;
  late Future<List<Notificacao>> _obterNotificacoesFuture;
  late Future<List<Exemplar>> _obterNextActionFuture;

  @override
  void initState() {
    super.initState();
    setState(() {
      _obterLivrosDesejadosFuture = _obterLivrosDesejados();
      _obterNotificacoesFuture = _obterNotificacoes();
      _obterNextActionFuture = _obterNextAction();
    });
  }

  Future<List<Exemplar>> _obterLivrosDesejados() async {
    if (AuthService.loggedUser == null) {
      return [];
    }

    final exemplaresDesejados = await ExemplarService.obterExemplaresDesejados(
      AuthService.loggedUser!,
    );

    for (final exemplar in exemplaresDesejados) {
      exemplar.livro = await LivroService.obterById(exemplar.livroId);
    }

    return exemplaresDesejados;
  }

  Future<List<Notificacao>> _obterNotificacoes() async {
    if (AuthService.loggedUser == null) {
      return [];
    }

    return await NotificacaoService.obterNotificacoes(AuthService.loggedUser!);
  }

  Future<List<Exemplar>> _obterNextAction() async {
    if (AuthService.loggedUser == null) {
      return [];
    }

    final exemplares = await ExemplarService.obterExemplaresDesejados(
      AuthService.loggedUser!,
    );

    for (final exemplar in exemplares) {
      exemplar.livro = await LivroService.obterById(exemplar.livroId);
      final desejo = await DesejoService.obterDesejosPorLivro(exemplar.livro!);
      final firstDesejo = desejo.firstOrNull;
      if (firstDesejo != null) {
        exemplar.desejadoPor = await ProfileService.obterUsuarioPorId(
          firstDesejo.userId,
        );
      }
    }

    return exemplares;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper100,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            FutureBuilder(
              future: _obterNotificacoesFuture,
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  final data = snapshot.data;
                  if (data == null) {
                    return _HomeHeader(notificacoes: []);
                  }

                  return _HomeHeader(notificacoes: data);
                }
                return _HomeHeader(notificacoes: []);
              },
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                children: [
                  CreditBalanceCard(
                    saldo: AuthService.loggedUser?.saldoCredito ?? 0,
                    validade:
                        AuthService.loggedUser?.validadeCredito
                            ?.toSimplifiedDate() ??
                        "",
                    onResgatar: () {},
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
                    child: FutureBuilder(
                      future: _obterLivrosDesejadosFuture,
                      builder: (ctx, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          final data = snapshot.data;
                          if (data == null) {
                            return Column();
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SectionLabel(
                                label: 'Da sua lista, disponível agora',
                                trailing: '${data.length} títulos',
                              ),
                              const SizedBox(height: 12),
                              for (final book in data) ...[
                                if (book.livro != null)
                                  BookRow(
                                    book: book.livro!,
                                    coverWidth: 56,
                                    metaLine:
                                        '${book.distancia ?? 0} · 1 CRÉDITO + ${book.frete ?? 0}',
                                  ),
                              ],
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: DashedDivider(),
                              ),
                              const SizedBox(height: 10),
                              RodapeButton(
                                label: 'Ver os ${data.length} disponíveis',
                                variant: RodapeButtonVariant.quiet,
                                size: RodapeButtonSize.sm,
                                onPressed: () {},
                              ),
                            ],
                          );
                        }

                        return Text("Loading...");
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  const SectionLabel(
                    label: 'Sua próxima ação',
                    color: AppColors.stampRed600,
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder(
                    future: _obterNextActionFuture,
                    builder: (ctx, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        final data = snapshot.data;
                        if (data == null) {
                          return Column();
                        }

                        final firstBook = data.firstOrNull;

                        if (firstBook?.livro == null) {
                          return Column();
                        }

                        return BookRow(
                          book: firstBook!.livro!,
                          coverWidth: 52,
                          subtitle:
                              '${firstBook.desejadoPor?.nome ?? ""} pediu ${firstBook.livro!.titulo}',
                          metaLine:
                              '+1 CRÉDITO AO ENTREGAR · ${firstBook.distancia ?? 0} KM',
                        );
                      }

                      return Text("Loading...");
                    },
                  ),
                  const SizedBox(height: 12),
                  RodapeButton(label: 'Aceitar entregar', onPressed: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
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
