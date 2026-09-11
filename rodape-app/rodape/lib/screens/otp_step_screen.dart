import 'dart:async';

import 'package:flutter/material.dart';

import '../helpers/auth_helper.dart';
import '../helpers/models/onboarding_args.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/otp_input_field.dart';
import '../widgets/rodape_button.dart';
import '../widgets/step_progress_header.dart';

/// C6 · Código por SMS — Passo 3 de 4 (também usada no login, "L2").
class OtpStepScreen extends StatefulWidget {
  const OtpStepScreen({super.key, required this.args});

  final OtpStepArgs args;

  @override
  State<OtpStepScreen> createState() => _OtpStepScreenState();
}

class _OtpStepScreenState extends State<OtpStepScreen> {
  static const _segundosReenvio = 42;

  final _otpKey = GlobalKey<OtpInputFieldState>();

  String _codigo = '';
  bool _verificando = false;
  bool _reenviando = false;
  String? _erro;
  int _restante = _segundosReenvio;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _iniciarContagem();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _iniciarContagem() {
    _timer?.cancel();
    setState(() => _restante = _segundosReenvio);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_restante <= 1) {
        t.cancel();
        setState(() => _restante = 0);
      } else {
        setState(() => _restante -= 1);
      }
    });
  }

  Future<void> _reenviar() async {
    setState(() => _reenviando = true);
    final codigo = await AuthHelper.sendSmsCode(widget.args.telefone);
    if (!mounted) return;
    setState(() => _reenviando = false);
    _iniciarContagem();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Novo código de teste (mock): $codigo')),
    );
  }

  Future<void> _confirmar() async {
    setState(() {
      _verificando = true;
      _erro = null;
    });

    final ok = await AuthHelper.verifyCode(_codigo);

    if (!mounted) return;
    setState(() => _verificando = false);

    if (!ok) {
      setState(() => _erro = 'Código incorreto. Confira os 6 dígitos do SMS.');
      _otpKey.currentState?.clear();
      return;
    }

    if (widget.args.isLogin) {
      await AuthHelper.loginExisting(telefone: widget.args.telefone);
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } else {
      if (!mounted) return;
      Navigator.of(context).pushNamed('/name', arguments: widget.args.telefone);
    }
  }

  @override
  Widget build(BuildContext context) {
    final podeReenviar = _restante == 0 && !_reenviando;

    return Scaffold(
      backgroundColor: AppColors.paper100,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            StepProgressHeader(
              step: 3,
              totalSteps: 4,
              title: 'Código por SMS',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        widget.args.telefone,
                        style: AppTextStyles.mono(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink900,
                          letterSpacing: 0.4,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: Text(
                          'Corrigir',
                          style: AppTextStyles.mono(fontSize: 11, letterSpacing: 1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  OtpInputField(
                    key: _otpKey,
                    hasError: _erro != null,
                    onChanged: (value) => setState(() {
                      _codigo = value;
                      if (_erro != null) _erro = null;
                    }),
                    onCompleted: (_) => _confirmar(),
                  ),
                  if (_erro != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _erro!,
                      style: AppTextStyles.sans(fontSize: 12, color: AppColors.stampRed600),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'REENVIAR EM',
                        style: AppTextStyles.mono(
                          fontSize: 10,
                          color: AppColors.paperGray500,
                          letterSpacing: 1.6,
                        ),
                      ),
                      podeReenviar
                          ? TextButton(
                              onPressed: _reenviar,
                              style: TextButton.styleFrom(padding: EdgeInsets.zero),
                              child: Text(
                                'Reenviar código',
                                style: AppTextStyles.mono(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.spineTeal,
                                ),
                              ),
                            )
                          : Text(
                              _formatarTempo(_restante),
                              style: AppTextStyles.mono(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink900,
                                letterSpacing: 0.4,
                              ),
                            ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSunken,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'SE DER ERRADO',
                          style: AppTextStyles.mono(
                            fontSize: 10,
                            color: AppColors.paperGray600,
                            letterSpacing: 1.6,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Código incorreto: confira os 6 dígitos do SMS.\n'
                          'Código expirado: peça outro, chega em segundos.',
                          style: AppTextStyles.sans(fontSize: 13, color: AppColors.ink700),
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
                label: _verificando ? 'Confirmando…' : 'Confirmar código',
                onPressed: (_codigo.length == 6 && !_verificando) ? _confirmar : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatarTempo(int segundos) {
    final m = (segundos ~/ 60).toString().padLeft(2, '0');
    final s = (segundos % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
