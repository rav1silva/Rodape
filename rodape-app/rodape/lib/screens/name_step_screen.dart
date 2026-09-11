import 'package:flutter/material.dart';

import '../helpers/auth_helper.dart';
import '../helpers/models/onboarding_args.dart';
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
      _nomeController.text.trim().isNotEmpty && _sobrenomeController.text.trim().isNotEmpty;

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

    await AuthHelper.createAccount(nome: nome, sobrenome: sobrenome, telefone: widget.telefone);

    if (!mounted) return;
    setState(() => _salvando = false);

    Navigator.of(context).pushNamed(
      '/onboarding-complete',
      arguments: OnboardingCompleteArgs(nome: nome, inicial: sobrenome[0].toUpperCase()),
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
                    style: AppTextStyles.sans(fontSize: 14, color: AppColors.ink700),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: const BoxDecoration(
                color: AppColors.surfaceCard,
                border: Border(top: BorderSide(color: AppColors.borderHairline)),
              ),
              child: RodapeButton(
                label: _salvando ? 'Criando conta…' : 'Continuar',
                onPressed: (_valido && !_salvando) ? _continuar : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
