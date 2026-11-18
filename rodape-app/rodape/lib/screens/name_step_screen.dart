import 'package:flutter/material.dart';
import 'package:rodape/models/desejo.dart';
import 'package:rodape/models/onboarding_args.dart';
import 'package:rodape/services/auth_service.dart';
import 'package:rodape/services/desejo_service.dart';
import 'package:rodape/services/net_service.dart';
import 'package:rodape/services/profile_service.dart';

import '../helpers/auth_helper.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/public_profile_badge.dart';
import '../widgets/rodape_button.dart';
import '../widgets/rodape_text_field.dart';
import '../widgets/step_progress_header.dart';

/// C7 · Seu nome — Passo 4 de 4, com preview ao vivo do perfil público.
class NameStepScreen extends StatefulWidget {
  const NameStepScreen({super.key, required this.telefone});

  final String telefone;

  @override
  State<NameStepScreen> createState() => _NameStepScreenState();
}

class _NameStepScreenState extends State<NameStepScreen> {
  final _nomeController = TextEditingController();
  final _sobrenomeController = TextEditingController();
  bool _salvando = false;

  bool get _valido =>
      _nomeController.text.trim().isNotEmpty &&
      _sobrenomeController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _nomeController.dispose();
    _sobrenomeController.dispose();
    super.dispose();
  }

  Future<void> _continuar() async {
    setState(() => _salvando = true);
    final nome = _nomeController.text.trim();
    final sobrenome = _sobrenomeController.text.trim();

    ProfileService.registerModel.nome = nome;
    ProfileService.registerModel.sobrenome = sobrenome;

    // Grava no Supabase primeiro: sem internet a conta não é criada e o
    // onboarding não é marcado como concluído.
    try {
      AuthService.loggedUser = await ProfileService.cadastrarUsuario();
      if (AuthService.loggedUser?.id != null) {
        await DesejoService.removerDesejos(AuthService.loggedUser!);
        final listaDesejos = ProfileService.registerModel.livros
            .map(
              (l) => Desejo(livroId: l.id, userId: AuthService.loggedUser!.id!),
            )
            .toList();
        await DesejoService.adicionarDesejos(listaDesejos);
      }
    } catch (e) {
      debugPrint('[AUTH] Falha ao criar conta: $e');
      if (!mounted) return;
      setState(() => _salvando = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(Net.falhaMsg)));
      return;
    }

    await AuthHelper.createAccount(
      nome: nome,
      sobrenome: sobrenome,
      telefone: widget.telefone,
    );

    if (!mounted) return;
    setState(() => _salvando = false);

    Navigator.of(context).pushNamed(
      '/onboarding-complete',
      arguments: OnboardingCompleteArgs(
        nome: nome,
        inicial: sobrenome[0].toUpperCase(),
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
            StepProgressHeader(
              step: 4,
              totalSteps: 4,
              title: 'Seu nome',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: RodapeTextField(
                          label: 'Nome',
                          controller: _nomeController,
                          textCapitalization: TextCapitalization.words,
                          onChanged: (_) => setState(() {}),
                          autofocus: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RodapeTextField(
                          label: 'Sobrenome',
                          controller: _sobrenomeController,
                          textCapitalization: TextCapitalization.words,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  PublicProfileBadge(
                    nome: _nomeController.text,
                    sobrenomeInicial: _sobrenomeController.text,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Seu sobrenome completo nunca aparece para outra pessoa. Só a '
                    'inicial, do começo ao fim da troca.',
                    style: AppTextStyles.sans(
                      fontSize: 14,
                      color: AppColors.ink700,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: const BoxDecoration(
                color: AppColors.surfaceCard,
                border: Border(
                  top: BorderSide(color: AppColors.borderHairline),
                ),
              ),
              child: ListenableBuilder(
                listenable: Net.i,
                builder: (context, _) => Net.i.online
                    ? RodapeButton(
                        label: _salvando ? 'Criando conta…' : 'Continuar',
                        onPressed: (_valido && !_salvando) ? _continuar : null,
                      )
                    : const RodapeButton(
                        label: 'Sem internet',
                        icon: Icons.wifi_off_rounded,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
