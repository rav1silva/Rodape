
import 'package:flutter/material.dart';
import 'package:rodape/data/legal_texts.dart';
import 'package:rodape/models/desejo.dart';
import 'package:rodape/models/onboarding_args.dart';
import 'package:rodape/services/auth_service.dart';
import 'package:rodape/services/desejo_service.dart';
import 'package:rodape/services/net_service.dart';
import 'package:rodape/services/profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../helpers/helper_pref.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/public_profile_badge.dart';
import '../widgets/rodape_button.dart';
import '../widgets/rodape_text_field.dart';
import '../widgets/step_progress_header.dart';
import 'legal_screen.dart';

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
  bool _aceitouTermos = false;
  bool _aceitouPrivacidade = false;

  bool get _valido =>
      _nomeController.text.trim().isNotEmpty &&
      _sobrenomeController.text.trim().isNotEmpty;

  bool get _documentosAceitos =>
      _aceitouTermos && _aceitouPrivacidade;

  @override
  void dispose() {
    _nomeController.dispose();
    _sobrenomeController.dispose();
    super.dispose();
  }

  Future<void> _abrirDocumento({
    required String titulo,
    required List<(String, String)> secoes,
    required bool termos,
  }) async {
    final resultado = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => LegalScreen(
          title: titulo,
          sections: secoes,
          mostrarAceite: true,
        ),
      ),
    );

    if (!mounted || resultado == null) return;

    setState(() {
      if (termos) {
        _aceitouTermos = resultado;
      } else {
        _aceitouPrivacidade = resultado;
      }
    });
  }

  Future<void> _continuar() async {
    if (!_documentosAceitos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Você precisa aceitar os termos e a política de privacidade.',
          ),
        ),
      );
      return;
    }

    if (!_valido || _salvando) return;

    setState(() => _salvando = true);

    final nome = _nomeController.text.trim();
    final sobrenome = _sobrenomeController.text.trim();

    try {
      // Confirma que existe uma sessão real no Supabase.
      final usuarioAutenticado =
          Supabase.instance.client.auth.currentUser;

      if (usuarioAutenticado == null) {
        throw Exception(
          'Nenhum usuário autenticado. Entre novamente na sua conta.',
        );
      }

      // Prepara os dados do perfil.
      ProfileService.registerModel
        ..authUserId = usuarioAutenticado.id
        ..telefone = widget.telefone
        ..nome = nome
        ..sobrenome = sobrenome;

      // ETAPA 1 - Criar perfil no banco.
      debugPrint('[CADASTRO] Criando perfil...');

      final perfil = await ProfileService.cadastrarUsuario();

      if (perfil == null || perfil.id == null || perfil.id!.isEmpty) {
        throw Exception('Não foi possível criar o perfil.');
      }

      AuthService.loggedUser = perfil;

      debugPrint('[CADASTRO] Perfil criado.');

     // ETAPAS 2, 3 e 4 - Processar desejos sem apagar listas vazias.
final livrosSelecionados = ProfileService.registerModel.livros;

if (livrosSelecionados.isNotEmpty) {
  final listaDesejos = livrosSelecionados
      .map(
        (livro) => Desejo(
          id: const Uuid().v4(),
          livroId: livro.id,
          userId: perfil.id!,
        ),
      )
      .toList();

  // Substitui os desejos somente quando há uma nova seleção.
  await DesejoService.removerDesejos(perfil);
  await DesejoService.adicionarDesejos(listaDesejos);
}
      debugPrint('[CADASTRO] Desejos processados.');

      // ETAPA 5 - Marcar cadastro concluído.
      await HelperPref.setOnboardingDone(true);

      if (!mounted) return;

      setState(() => _salvando = false);

      Navigator.of(context).pushNamedAndRemoveUntil(
        '/onboarding-complete',
        (route) => false,
        arguments: OnboardingCompleteArgs(
          nome: nome,
          inicial: sobrenome[0].toUpperCase(),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('[CADASTRO] Erro: $e');
      debugPrint('[CADASTRO] StackTrace: $stackTrace');

      if (!mounted) return;

      setState(() => _salvando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível concluir o cadastro: $e',
          ),
        ),
      );
    }
  }

  Widget _itemDocumento({
    required String titulo,
    required bool aceito,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border.all(color: AppColors.borderHairline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: _salvando ? null : onTap,
        leading: Icon(
          aceito ? Icons.check_circle : Icons.description_outlined,
          color: aceito
              ? AppColors.ink700
              : AppColors.paperGray500,
        ),
        title: Text(
          titulo,
          style: AppTextStyles.sans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.ink900,
          ),
        ),
        subtitle: Text(
          aceito ? 'Aceito' : 'Leia e aceite para continuar',
          style: AppTextStyles.sans(
            fontSize: 12,
            color: AppColors.ink700,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.paperGray500,
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
                    'Seu sobrenome completo nunca aparece para outra pessoa. '
                    'Só a inicial, do começo ao fim da troca.',
                    style: AppTextStyles.sans(
                      fontSize: 14,
                      color: AppColors.ink700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'ANTES DE CONTINUAR',
                    style: AppTextStyles.mono(
                      fontSize: 10,
                      color: AppColors.paperGray500,
                      letterSpacing: 1.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Leia os documentos abaixo e aceite os dois para criar sua conta.',
                    style: AppTextStyles.sans(
                      fontSize: 13,
                      color: AppColors.ink700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _itemDocumento(
                    titulo: 'Termos de uso',
                    aceito: _aceitouTermos,
                    onTap: () => _abrirDocumento(
                      titulo: 'Termos de uso',
                      secoes: LegalTexts.termos,
                      termos: true,
                    ),
                  ),
                  _itemDocumento(
                    titulo: 'Política de privacidade',
                    aceito: _aceitouPrivacidade,
                    onTap: () => _abrirDocumento(
                      titulo: 'Política de privacidade',
                      secoes: LegalTexts.privacidade,
                      termos: false,
                    ),
                  ),
                  if (!_documentosAceitos)
                    Text(
                      'Falta aceitar ${_aceitouTermos ? 'a política de privacidade' : _aceitouPrivacidade ? 'os termos de uso' : 'os dois documentos'}.',
                      style: AppTextStyles.sans(
                        fontSize: 12,
                        color: AppColors.stampRed600,
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
              child: ListenableBuilder(
                listenable: Net.i,
                builder: (context, _) => Net.i.online
                    ? RodapeButton(
                        label: _salvando
                            ? 'Criando conta...'
                            : 'Continuar',
                        onPressed: _valido &&
                                _documentosAceitos &&
                                !_salvando
                            ? _continuar
                            : null,
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
