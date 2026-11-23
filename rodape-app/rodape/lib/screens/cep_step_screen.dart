
import 'package:flutter/material.dart';
import 'package:rodape/models/address.dart';
import 'package:rodape/services/cep_service.dart';
import 'package:rodape/services/location_service.dart';
import 'package:rodape/services/net_service.dart';
import 'package:rodape/services/profile_service.dart';
import 'package:rodape/services/reverse_geocoding_service.dart';

import '../helpers/auth_helper.dart';
import '../helpers/helper_pref.dart';
import '../helpers/input_formatters.dart';
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
  final _ruaController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();

  bool _loading = false;
  bool _gpsSelecionado = false;

  String? _errorText;
  String? _descricaoGps;

  Address? _resultado;

  bool get _localizacaoSelecionada =>
      _resultado != null || _gpsSelecionado;

  @override
  void dispose() {
    _controller.dispose();
    _ruaController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    super.dispose();
  }

  void _limparLocalizacao() {
    ProfileService.registerModel.latitude = null;
    ProfileService.registerModel.longitude = null;
    ProfileService.registerModel.localizacaoOrigem = null;

    _gpsSelecionado = false;
    _descricaoGps = null;
  }

  Future<void> _buscarCep(String cep) async {
    final digitos = cep.replaceAll(RegExp(r'\D'), '');

    if (digitos.length != 8) {
      return;
    }

    _limparLocalizacao();

    if (!Net.i.online) {
      setState(() {
        _errorText = 'Sem internet para consultar o CEP.';
        _resultado = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorText = null;
      _resultado = null;
    });

    try {
      final address = await CepService.obterInformacoesCep(digitos);

      if (!mounted) return;

      if (address == null) {
        setState(() {
          _errorText =
              'Não foi possível localizar esse CEP. Confira os números e tente novamente.';
        });
        return;
      }

      final latitude = double.tryParse(
        address.location.coordinates.latitude ?? '',
      );

      final longitude = double.tryParse(
        address.location.coordinates.longitude ?? '',
      );

      ProfileService.registerModel.latitude = latitude;
      ProfileService.registerModel.longitude = longitude;

      ProfileService.registerModel.localizacaoOrigem =
          latitude != null && longitude != null ? 'cep' : null;

      ProfileService.registerModel.cep = address.cep;

      await HelperPref.saveCep(address.cep);

      if (!mounted) return;

      setState(() {
        _resultado = address;
        _ruaController.text = address.street;
        _errorText = null;
      });
    } on InvalidCepException catch (e) {
      if (!mounted) return;
      setState(() => _errorText = e.message);
    } on ServiceAreaException catch (e) {
      if (!mounted) return;
      setState(() => _errorText = e.message);
    } catch (e) {
      debugPrint('[CEP] Falha na consulta: $e');

      if (!mounted) return;

      setState(() {
        _errorText = Net.falhaMsg;
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _usarLocalizacao() async {
    setState(() {
      _loading = true;
      _errorText = null;
      _resultado = null;
      _gpsSelecionado = false;
      _descricaoGps = null;
    });

    try {
      final position = await LocationService.obterLocalizacaoAtual();

      if (!mounted) return;

      final descricao =
          await ReverseGeocodingService.obterDescricao(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (!mounted) return;

      ProfileService.registerModel.latitude = position.latitude;
      ProfileService.registerModel.longitude = position.longitude;
      ProfileService.registerModel.localizacaoOrigem = 'gps';
      ProfileService.registerModel.cep = '';

      _controller.clear();

      setState(() {
        _gpsSelecionado = true;
        _descricaoGps = descricao;
        _errorText = null;
      });
    } catch (e) {
      debugPrint('[GPS] Falha ao obter localização: $e');

      if (!mounted) return;

      setState(() {
        _errorText = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _nextStep() async {
    final user = ProfileService.registerModel;

    if (_resultado != null) {
      user.cep = _resultado!.cep;
    } else if (_gpsSelecionado) {
      user.cep = '';
    } else {
      return;
    }

    user.rua = _ruaController.text.trim();
    user.numero = _numeroController.text.trim();
    user.complemento = _complementoController.text.trim();

    await HelperPref.saveCep(user.cep);

    if (!mounted) return;

    Navigator.of(context).pushNamed(
      '/nearby-books',
      arguments: _resultado,
    );
  }

  Widget _campoEndereco({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.streetAddress,
  }) {
    return RodapeTextField(
      label: label,
      controller: controller,
      keyboardType: keyboardType,
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
                    'Use a localização do aparelho para calcular distâncias. '
                    'Se preferir, informe seu CEP; nesse caso, a localização '
                    'será aproximada.',
                    style: AppTextStyles.sans(
                      fontSize: 15,
                      color: AppColors.ink700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  RodapeTextField(
                    label: 'CEP',
                    mono: true,
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [CepInputFormatter()],
                    errorText: _errorText,
                    onChanged: (value) {
                      setState(() {
                        _resultado = null;
                        _errorText = null;
                        _ruaController.clear();
                        _limparLocalizacao();
                      });

                      final digitos =
                          value.replaceAll(RegExp(r'\D'), '');

                      if (digitos.length == 8) {
                        _buscarCep(value);
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  if (_resultado != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        border: Border.all(color: AppColors.spineTeal),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 17,
                            color: AppColors.spineTeal,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _resultado!.street.isNotEmpty
                                      ? _resultado!.street
                                      : 'CEP localizado',
                                  style: AppTextStyles.sans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Localização aproximada pelo CEP',
                                  style: AppTextStyles.sans(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_gpsSelecionado)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        border: Border.all(color: AppColors.spineTeal),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.my_location,
                            size: 17,
                            color: AppColors.spineTeal,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _descricaoGps != null
                                      ? 'Localização encontrada'
                                      : 'Localização obtida pelo GPS',
                                  style: AppTextStyles.sans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  _descricaoGps ??
                                      'Não foi possível identificar o bairro e a cidade.',
                                  style: AppTextStyles.sans(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_localizacaoSelecionada) ...[
                    const SizedBox(height: 18),
                    Text(
                      'Endereço',
                      style: AppTextStyles.sans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _campoEndereco(
                      label: 'Rua',
                      controller: _ruaController,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _campoEndereco(
                            label: 'Número',
                            controller: _numeroController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: _campoEndereco(
                            label: 'Complemento',
                            controller: _complementoController,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 14),
                  ListenableBuilder(
                    listenable: Net.i,
                    builder: (context, _) => RodapeButton(
                      label: 'Usar minha localização',
                      variant: RodapeButtonVariant.quiet,
                      icon: Icons.location_on_outlined,
                      onPressed: _loading ? null : _usarLocalizacao,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              decoration: const BoxDecoration(
                color: AppColors.surfaceCard,
                border: Border(
                  top: BorderSide(color: AppColors.borderHairline),
                ),
              ),
              child: RodapeButton(
                label: 'Continuar',
                onPressed:
                    _localizacaoSelecionada && !_loading
                        ? _nextStep
                        : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
