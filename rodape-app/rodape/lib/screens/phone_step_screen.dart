import 'package:flutter/material.dart';

import '../helpers/auth_helper.dart';
import '../helpers/input_formatters.dart';
import '../helpers/models/onboarding_args.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/rodape_button.dart';
import '../widgets/rodape_text_field.dart';
import '../widgets/step_progress_header.dart';

/// C5 · Seu telefone — Passo 3 de 4 (cadastro) ou atalho "Já tenho conta"
/// (login: mesma tela, pula direto para cá).
class PhoneStepScreen extends StatefulWidget {
  const PhoneStepScreen({super.key, required this.args});

  final PhoneStepArgs args;

  @override
  State<PhoneStepScreen> createState() => _PhoneStepScreenState();
}

class _PhoneStepScreenState extends State<PhoneStepScreen> {
  final _ddiController = TextEditingController(text: '+55 11');
  final _numeroController = TextEditingController();
  bool _enviando = false;

  bool get _numeroValido => _numeroController.text.replaceAll(RegExp(r'\D'), '').length >= 8;

  @override
  void dispose() {
    _ddiController.dispose();
    _numeroController.dispose();
    super.dispose();
  }

  Future<void> _enviarCodigo() async {
    setState(() => _enviando = true);
    final telefone = '${_ddiController.text} ${_numeroController.text}';
    final codigo = await AuthHelper.sendSmsCode(telefone);
    if (!mounted) return;
    setState(() => _enviando = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Código de teste (mock): $codigo')),
    );

    Navigator.of(context).pushNamed(
      '/otp',
      arguments: OtpStepArgs(telefone: telefone, isLogin: widget.args.isLogin),
    );
  }

  void _atalhoSocial(String provedor) {
    debugPrint('[MOCK AUTH] Atalho "$provedor" acionado — em breve.');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Continuar com $provedor — em breve.')),
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
              step: 3,
              totalSteps: 4,
              title: 'Seu telefone',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                children: [
                  Text(
                    'O número serve para entrar no app e para o entregador te achar '
                    'no dia da troca.',
                    style: AppTextStyles.sans(fontSize: 15, color: AppColors.ink700),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 96,
                        child: RodapeTextField(
                          label: 'DDI+DDD',
                          mono: true,
                          controller: _ddiController,
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RodapeTextField(
                          label: 'Número',
                          mono: true,
                          controller: _numeroController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [PhoneInputFormatter()],
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'ENVIAMOS UM SMS COM 6 DÍGITOS',
                    style: AppTextStyles.mono(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.only(top: 12),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: AppColors.borderData)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ATALHOS',
                          style: AppTextStyles.mono(
                            fontSize: 10,
                            color: AppColors.paperGray500,
                            letterSpacing: 1.6,
                          ),
                        ),
                        const SizedBox(height: 8),
                        RodapeButton(
                          label: 'Continuar com Google',
                          variant: RodapeButtonVariant.quiet,
                          size: RodapeButtonSize.sm,
                          onPressed: () => _atalhoSocial('Google'),
                        ),
                        const SizedBox(height: 8),
                        RodapeButton(
                          label: 'Continuar com Apple',
                          variant: RodapeButtonVariant.quiet,
                          size: RodapeButtonSize.sm,
                          onPressed: () => _atalhoSocial('Apple'),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Pelo atalho, o telefone é pedido antes da primeira entrega.',
                          style: AppTextStyles.sans(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
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
                label: _enviando ? 'Enviando…' : 'Enviar código',
                onPressed: (!_numeroValido || _enviando) ? null : _enviarCodigo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
