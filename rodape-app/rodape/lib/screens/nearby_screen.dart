
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';
import 'package:rodape/models/exemplar.dart';
import 'package:rodape/models/exemplar_status.dart';
import 'package:rodape/services/exemplar_service.dart';
import 'package:rodape/services/livro_service.dart';
import 'package:rodape/services/auth_service.dart';
import 'package:rodape/services/net_service.dart';
import 'package:rodape/services/pedido_service.dart';
import 'package:rodape/services/profile_service.dart';
import 'package:rodape/services/desejo_service.dart';
import 'package:rodape/extensions/datetime_extensions.dart';


import '../theme/app_text_styles.dart';
import '../widgets/book_row.dart';
import '../widgets/filter_chip_pill.dart';
import '../widgets/rodape_button.dart';

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key});

  @override
  NearbyScreenState createState() => NearbyScreenState();
}

class NearbyScreenState extends State<NearbyScreen> {
  late Future<List<Exemplar>> _obterExemplaresFuture;
  final Map<String, String> _nomesDonos = {};

  bool _soMinhaLista = true;
  bool _ate3Km = false;
  bool _bomOuMelhor = false;
  bool _freteAte25 = false;

  @override
  void initState() {
    super.initState();
    _obterExemplaresFuture = _obterExemplares();
  }

  void atualizarAoRetornar() {
  _atualizarFiltros();
}
  Future<List<Exemplar>> _obterExemplares() async {
    final user = AuthService.loggedUser;

    final todos = await ExemplarService.obterFiltrado(
  freteMaximo: _freteAte25 ? user?.freteMaximo : null,
);
    final desejos = user != null
        ? await DesejoService.obterDesejos(user)
        : [];

    final livrosDesejados =
        desejos.map((d) => d.livroId).toSet();

    var exemplares = todos.where((e) {
      return e.status == ExemplarStatus.disponivel &&
          e.donoId != user?.id;
    }).toList();

    if (_soMinhaLista) {
      exemplares = exemplares
          .where((e) => livrosDesejados.contains(e.livroId))
          .toList();
    }

    if (_ate3Km) {
      exemplares = exemplares
          .where((e) =>
              e.distancia != null && e.distancia! <= 3)
          .toList();
    }

    if (_bomOuMelhor) {
      exemplares = exemplares.where((e) {
        final estado =
            e.estadoDeConservacao.toLowerCase();

        return estado.contains('bom') ||
            estado.contains('excelente') ||
            estado.contains('novo');
      }).toList();
    }


    _nomesDonos.clear();
    final nomesPorDono = <String, String>{};

    for (final exemplar in exemplares) {
      exemplar.livro =
          await LivroService.obterById(exemplar.livroId);

      // Cada exemplar pertence a um usuário específico.
      if (!nomesPorDono.containsKey(exemplar.donoId)) {
        final dono = await ProfileService.obterUsuarioPorId(exemplar.donoId);
        nomesPorDono[exemplar.donoId] =
            dono?.nome ?? 'Proprietário não identificado';
      }
      _nomesDonos[exemplar.id] = nomesPorDono[exemplar.donoId]!;
    }

    return exemplares;
  }

  void _atualizarFiltros() {
    setState(() {
      _obterExemplaresFuture = _obterExemplares();
    });
  }

  Future<void> _resgatar(Exemplar e) async {
    final user = AuthService.loggedUser;

    if (user == null || e.livro == null) return;

    if (user.saldoCredito < e.creditos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saldo de créditos insuficiente.'),
        ),
      );
      return;
    }

    final frete =
        (e.frete ?? 0).toStringAsFixed(2).replaceAll('.', ',');

    final previsao =
        DateTime.now().add(const Duration(days: 3));



final ok = await showDialog<bool>(
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
    titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
    contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
    actionsPadding: const EdgeInsets.fromLTRB(20, 12, 20, 20),

    title: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.paper100,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.paper300,
            ),
          ),
          child: const Icon(
            Icons.menu_book_rounded,
            size: 34,
            color: AppColors.wood700,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Confirmar pedido?',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.ink900,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Confira os detalhes antes de continuar.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.paperGray600,
            fontSize: 13,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    ),

    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.paper100,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.paper300,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'LIVRO SELECIONADO',
                style: TextStyle(
                  color: AppColors.wood600,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                e.livro!.titulo,
                style: const TextStyle(
                  color: AppColors.ink900,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              const Divider(color: AppColors.paper300),
              const SizedBox(height: 10),

              Row(
                children: [
                  const Icon(
                    Icons.toll_rounded,
                    color: AppColors.spineMustard,
                    size: 21,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Créditos',
                      style: TextStyle(
                        color: AppColors.ink700,
                      ),
                    ),
                  ),
                  Text(
                    '${e.creditos}',
                    style: const TextStyle(
                      color: AppColors.wood800,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  const Icon(
                    Icons.local_shipping_outlined,
                    color: AppColors.spineTeal,
                    size: 21,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Frete',
                      style: TextStyle(
                        color: AppColors.ink700,
                      ),
                    ),
                  ),
                  Text(
                    'R\$ $frete',
                    style: const TextStyle(
                      color: AppColors.ink900,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  const Icon(
                    Icons.calendar_month_outlined,
                    color: AppColors.wood600,
                    size: 21,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Previsão de chegada',
                      style: TextStyle(
                        color: AppColors.ink700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 31),
                child: Text(
                  previsao.toSimplifiedDate(),
                  style: const TextStyle(
                    color: AppColors.ink900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),
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
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.wood700,
                side: const BorderSide(
                  color: AppColors.wood600,
                ),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Confirmar'),
            ),
          ),
        ],
      ),
    ],
  ),
);


    if (ok != true) return;

    try {
      await PedidoService.criar(e, user);

      final novo =
          await ProfileService.obterUsuarioPorId(user.id!);

      if (novo != null) {
        AuthService.loggedUser = novo;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pedido criado! Acompanhe em Perfil > Meus pedidos.',
          ),
        ),
      );

      setState(() {
        _obterExemplaresFuture = _obterExemplares();
      });
    } on PostgrestException catch (err) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err.message)),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Sem conexão. Tente de novo quando a internet voltar.',
          ),
        ),
      );
    }
  }

  Widget _construirFiltros() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: SizedBox(
        height: 30,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            FilterChipPill(
              label: 'Só minha lista',
              active: _soMinhaLista,
              onTap: () {
                _soMinhaLista = !_soMinhaLista;
                _atualizarFiltros();
              },
            ),
            const SizedBox(width: 6),

            FilterChipPill(
              label: 'Até 3 km',
              active: _ate3Km,
              onTap: () {
                _ate3Km = !_ate3Km;
                _atualizarFiltros();
              },
            ),
            const SizedBox(width: 6),

            FilterChipPill(
              label: 'Bom ou melhor',
              active: _bomOuMelhor,
              onTap: () {
                _bomOuMelhor = !_bomOuMelhor;
                _atualizarFiltros();
              },
            ),
            const SizedBox(width: 6),

            FilterChipPill(
              label: 'Frete até R\$ ${(AuthService.loggedUser?.freteMaximo ?? 25).toStringAsFixed(2).replaceAll('.', ',')}',
              active: _freteAte25,
              onTap: () {
                _freteAte25 = !_freteAte25;
                _atualizarFiltros();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirLivro(Exemplar exemplar) {
    final livro = exemplar.livro!;
    final nomeDono = _nomesDonos[exemplar.id] ??
        'Proprietário não identificado';

    final distancia = exemplar.distancia != null
        ? '${exemplar.distancia} km'
        : 'Distância indisponível';

    final frete = exemplar.frete != null
        ? exemplar.frete!.toStringAsFixed(2).replaceAll('.', ',')
        : '--';

    return Container(
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
        book: livro,
        coverWidth: 112,
        crossAxisAlignment: CrossAxisAlignment.start,
        subtitle:
            'Dono: $nomeDono\n${livro.autor}\nEstado: ${exemplar.estadoDeConservacao}',
        metaLine:
            '$distancia\n${exemplar.creditos} CRÉDITO + R\$ $frete',
        footer: ListenableBuilder(
          listenable: Net.i,
          builder: (context, _) => RodapeButton(
            label: 'Resgatar com crédito',
            icon: Icons.paid_outlined,
            size: RodapeButtonSize.sm,
            variant: RodapeButtonVariant.accent,
            onPressed: Net.i.online
                ? () => _resgatar(exemplar)
                : null,
          ),
        ),
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

            _construirFiltros(),

            const Divider(
              height: 1,
              color: AppColors.borderHairline,
            ),

            Expanded(
              child: FutureBuilder<List<Exemplar>>(
                future: _obterExemplaresFuture,
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Erro ao carregar exemplares:\n'
                          '${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  final data = snapshot.data ?? [];

                  if (data.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'Nenhum exemplar encontrado.\n'
                          'Tente desativar alguns filtros.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(
                        16, 14, 16, 24),
                    children: [
                      for (final exemplar in data) ...[
                        if (exemplar.livro != null)
                          _construirLivro(exemplar),
                        const SizedBox(height: 16),
                      ],
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
