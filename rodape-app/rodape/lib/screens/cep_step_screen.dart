import 'package:flutter/material.dart';

import '../helpers/auth_helper.dart';
import '../helpers/helper_pref.dart';
import '../helpers/input_formatters.dart';
import '../helpers/models/cep_info.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/rodape_button.dart';
import '../widgets/rodape_text_field.dart';
import '../widgets/step_progress_header.dart';

/// C2 · Onde você está — Passo 1 de 4.
class CepStepScreen extends StatefulWidget {
  const CepStepScreen({super.key});

  @override
  State<CepStepScreen> createState() => _CepStepScreenState();
}

class _CepStepScreenState extends State<CepStepScreen> {
  final _controller = TextEditingController();

  bool _loading = false;
  String? _errorText;
  CepInfo? _resultado;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _buscarCep(String cep) async {
    setState(() {
      _loading = true;
      _errorText = null;
      _resultado = null;
    });

    try {
      final info = await AuthHelper.lookupCep(cep);
      if (!mounted) return;
      await HelperPref.saveCep(info.cep);
      setState(() => _resultado = info);
    } on InvalidCepException catch (e) {
      if (!mounted) return;
      setState(() => _errorText = e.message);
    } on ServiceAreaException catch (e) {
      if (!mounted) return;
      setState(() => _errorText = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _usarLocalizacao() {
    // Mock: sem geolocalização real, simulamos o CEP de referência do
    // layout — o comportamento (busca + confirmação) é o mesmo do
    // preenchimento manual.
    _controller.text = '01221-020';
    _buscarCep(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final digits = _controller.text.replaceAll(RegExp(r'\D'), '');
    final foraDeArea = _errorText != null && digits.length == 8 && _resultado == null;

    return Scaffold(
      backgroundColor: AppColors.paper100,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            StepProgressHeader(
              step: 1,
              totalSteps: 4,
              title: 'Onde você está',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                children: [
                  Text(
                    'O CEP calcula distância e frete. O endereço completo só entra '
                    'quando houver uma entrega de verdade.',
                    style: AppTextStyles.sans(fontSize: 15, color: AppColors.ink700),
                  ),
                  const SizedBox(height: 18),
                  RodapeTextField(
                    label: 'CEP',
                    mono: true,
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [CepInputFormatter()],
                    errorText: foraDeArea ? null : _errorText,
                    onChanged: (value) {
                      setState(() => _resultado = null);
                      final d = value.replaceAll(RegExp(r'\D'), '');
                      if (d.length == 8) _buscarCep(value);
                    },
                  ),
                  const SizedBox(height: 14),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                  if (_resultado != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        border: Border.all(color: AppColors.spineTeal),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, size: 17, color: AppColors.spineTeal),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _resultado!.enderecoLabel,
                                  style: AppTextStyles.sans(fontSize: 15, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  _resultado!.densidadeLabel.toUpperCase(),
                                  style: AppTextStyles.mono(
                                    fontSize: 11,
                                    color: AppColors.spineTeal,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 14),
                  RodapeButton(
                    label: 'Usar minha localização',
                    variant: RodapeButtonVariant.quiet,
                    icon: Icons.location_on_outlined,
                    onPressed: _loading ? null : _usarLocalizacao,
                  ),
                  if (foraDeArea) ...[
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
                            'FORA DE ÁREA',
                            style: AppTextStyles.mono(
                              fontSize: 10,
                              color: AppColors.paperGray600,
                              letterSpacing: 1.6,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Se ainda não houver cobertura no seu CEP, a gente diz na hora e '
                            'avisa quando chegar. Você não fica parado nesta tela.',
                            style: AppTextStyles.sans(fontSize: 13, color: AppColors.ink700),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                label: 'Continuar',
                onPressed: _resultado == null
                    ? null
                    : () => Navigator.of(context).pushNamed('/nearby-books', arguments: _resultado),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
