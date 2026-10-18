import 'package:flutter/material.dart';
import 'package:rodape/extensions/datetime_extensions.dart';
import 'package:rodape/extensions/string_extensions.dart';
import 'package:rodape/models/credito.dart';
import 'package:rodape/models/exemplar_status.dart';
import 'package:rodape/models/pedido.dart';
import 'package:rodape/services/auth_service.dart';
import 'package:rodape/services/credito_service.dart';
import 'package:rodape/services/exemplar_service.dart';
import 'package:rodape/services/livro_service.dart';
import 'package:rodape/services/pedido_service.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/carimbo_stamp.dart';
import '../widgets/dashed_divider.dart';
import '../widgets/field_row.dart';
import '../widgets/rodape_button.dart';
import '../widgets/section_label.dart';
import '../widgets/stat_indicator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<List<Credito>> _historicoFuture;
  List<Pedido> _historicoPedidos = [];

  @override
  void initState() {
    super.initState();
    _obterHistoricoPedidos().then(
      (h) => setState(() {
        _historicoPedidos = h;
      }),
    );

    setState(() {
      _historicoFuture = _obterHistorico();
    });
  }

  Future<List<Credito>> _obterHistorico() async {
    if (AuthService.loggedUser == null) {
      return [];
    }

    return await CreditoService.obterHistorico(AuthService.loggedUser!);
  }

  Future<List<Pedido>> _obterHistoricoPedidos() async {
    if (AuthService.loggedUser == null) {
      return [];
    }

    final pedidos = await PedidoService.obterHistoricoPedidos(
      AuthService.loggedUser!,
    );

    for (final pedido in pedidos) {
      pedido.exemplar = await ExemplarService.obterExemplarById(
        pedido.exemplarId,
      );

      if (pedido.exemplar != null) {
        pedido.livro = await LivroService.obterById(pedido.exemplar!.livroId);
      }
    }

    return pedidos;
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.loggedUser;

    if (user == null) {
      return Column();
    }

    return Scaffold(
      backgroundColor: AppColors.paper100,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _ProfileHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: StatIndicator(
                          icon: Icons.inventory_2_outlined,
                          valor: '${user.entregues}',
                          rotulo: 'entregues',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: StatIndicator(
                          icon: Icons.move_to_inbox_outlined,
                          valor: '${user.recebidos}',
                          rotulo: 'recebidos',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: StatIndicator(
                          icon: Icons.autorenew,
                          valor: '${user.rodas}',
                          rotulo: 'rodas',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const SectionLabel(label: 'Extrato de crédito'),
                  const SizedBox(height: 6),
                  FutureBuilder(
                    future: _historicoFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        final data = snapshot.data;
                        if (data == null) {
                          return Column();
                        }

                        return Column(
                          children: data
                              .map(
                                (c) => FieldRow(
                                  label:
                                      "${c.createdAt.toSimplifiedDate()} · ${c.descricao}",
                                  value: c.valor.toString(),
                                ),
                              )
                              .toList(),
                        );
                      }

                      return Text("Loading...");
                    },
                  ),
                  const SizedBox(height: 18),
                  const SectionLabel(label: 'Histórico de circulação'),
                  const SizedBox(height: 10),
                  for (final h in _historicoPedidos) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 34,
                          height: 51,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: h.livro?.corLombada != null
                                ? Color(int.parse(h.livro!.corLombada!))
                                : Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: h.livro?.capaUrl == null
                              ? null
                              : Image.network(
                                  h.livro!.capaUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      const SizedBox.shrink(),
                                ),
                        ),
                        const SizedBox(width: 12),
                        CarimboStamp(
                          maos: h.exemplar?.maos ?? 0,
                          compact: true,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                h.livro?.titulo ?? "",
                                style: AppTextStyles.sans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                h.status.label.toUpperCase(),
                                style: AppTextStyles.mono(
                                  fontSize: 10,
                                  color: h.status.color,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: DashedDivider(),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSunken,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'FRETE MÁXIMO',
                              style: AppTextStyles.mono(
                                fontSize: 10,
                                color: AppColors.paperGray600,
                                letterSpacing: 1.6,
                              ),
                            ),
                            Text(
                              'R\$ ${user.freteMaximo.toStringAsFixed(2).replaceAll('.', ',')}',
                              style: AppTextStyles.mono(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: user.freteMaximo / 65,
                            minHeight: 4,
                            backgroundColor: AppColors.paper300,
                            valueColor: const AlwaysStoppedAnimation(
                              AppColors.wood600,
                            ),
                          ),
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

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    final user = AuthService.loggedUser;

    if (user == null) {
      return Column();
    }

    return Container(
      width: double.infinity,
      color: AppColors.wood800,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.spineTeal,
                child: Text(
                  user.nome.iniciais(),
                  style: AppTextStyles.display(
                    fontSize: 17,
                    color: AppColors.paper050,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DESDE ${user.createdAt?.toDate() ?? ""}',
                      style: AppTextStyles.mono(
                        fontSize: 10,
                        color: AppColors.textOnWoodMuted,
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${user.nome} ${user.sobrenome}",
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
                  Icons.settings_outlined,
                  color: AppColors.paper100,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.borderOnWood)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SALDO DE CRÉDITO',
                      style: AppTextStyles.mono(
                        fontSize: 10,
                        color: AppColors.textOnWoodMuted,
                        letterSpacing: 1.6,
                      ),
                    ),
                    Text(
                      '${user.saldoCredito}',
                      style: AppTextStyles.mono(
                        fontSize: 40,
                        fontWeight: FontWeight.w600,
                        color: AppColors.paper050,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Um crédito = um exemplar ${user.validadeCredito != null ? ". Validade ${user.validadeCredito}" : ""}. '
                    'Crédito só é gerado ao entregar para quem pediu o título.',
                    style: AppTextStyles.sans(
                      fontSize: 12,
                      color: AppColors.textOnWoodMuted,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          RodapeButton(
            label: 'Resgatar crédito',
            icon: Icons.paid_outlined,
            variant: RodapeButtonVariant.accent,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
