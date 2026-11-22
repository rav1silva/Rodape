
import 'package:flutter/material.dart';
import 'package:rodape/models/onboarding_args.dart';
import 'package:rodape/services/auth_service.dart';
import 'package:rodape/services/net_service.dart';
import 'package:rodape/services/profile_service.dart';

import '../helpers/auth_helper.dart';
import '../helpers/helper_pref.dart';
import '../helpers/input_formatters.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/rodape_button.dart';
import '../widgets/rodape_text_field.dart';
import '../widgets/step_progress_header.dart';

class PhoneStepScreen extends StatefulWidget {
  const PhoneStepScreen({super.key, required this.args});

  final PhoneStepArgs args;

  @override
  State<PhoneStepScreen> createState() => _PhoneStepScreenState();
}

class _PhoneStepScreenState extends State<PhoneStepScreen> {
  final _ddiController = TextEditingController(text: '+55 11');
  final _numeroController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _enviando = false;
  bool _mostrarSenha = false;
  bool _aguardandoTelefone = false;

  String? _authUserIdPendente;

  bool get _numeroValido =>
      _numeroController.text.replaceAll(RegExp(r'\D'), '').length >= 8;

  bool get _emailValido =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
          .hasMatch(_emailController.text.trim());

  bool get _senhaValida => _senhaController.text.length >= 6;

  String get _telefone =>
      '${_ddiController.text} ${_numeroController.text}'.trim();

  bool get _isLogin => widget.args.isLogin;

  @override
  void dispose() {
    _ddiController.dispose();
    _numeroController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _mensagem(String texto) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  Future<void> _continuarCadastro(
    String authUserId, {
    String? telefone,
  }) async {
    final telefoneCadastro = telefone ?? _telefone;

    ProfileService.registerModel.authUserId = authUserId;
    ProfileService.registerModel.telefone = telefoneCadastro;

    if (!mounted) return;

    setState(() {
      _enviando = false;
      _aguardandoTelefone = false;
      _authUserIdPendente = null;
    });

    Navigator.of(context).pushNamed(
      '/name',
      arguments: telefoneCadastro,
    );
  }

  Future<void> _verificarPerfil(
    String authUserId, {
    String? telefoneSalvo,
  }) async {
    final perfil =
        await ProfileService.obterUsuarioPorAuthId(authUserId);
debugPrint('[AUTH] Telefone recuperado: $telefoneSalvo');
debugPrint('[AUTH] Perfil encontrado: ${perfil != null}');
    if (!mounted) return;

    if (perfil != null) {
      AuthService.loggedUser = perfil;
      await HelperPref.setOnboardingDone(true);

      if (!mounted) return;

      setState(() {
        _enviando = false;
        _aguardandoTelefone = false;
        _authUserIdPendente = null;
      });

      Navigator.of(context).pushNamedAndRemoveUntil(
        '/home',
        (route) => false,
      );

      return;
    }

    // Recupera o telefone salvo nos metadados do Supabase.
    if (telefoneSalvo != null && telefoneSalvo.trim().isNotEmpty) {
      await _continuarCadastro(
        authUserId,
        telefone: telefoneSalvo,
      );
      return;
    }

    // Conta antiga ou sem telefone salvo.
    if (_isLogin) {
      setState(() {
        _enviando = false;
        _aguardandoTelefone = true;
        _authUserIdPendente = authUserId;
      });

      _mensagem(
        'Não encontramos um telefone salvo nesta conta. '
        'Informe seu telefone para concluir o cadastro.',
      );

      return;
    }

    await _continuarCadastro(authUserId);
  }

  Future<void> _entrarComEmail() async {
    // A conta já foi autenticada, mas ainda não tem perfil.
    // Nesse caso, coleta o telefone que está faltando.
    if (_aguardandoTelefone) {
      if (!_numeroValido) {
        _mensagem('Informe seu telefone para concluir o cadastro.');
        return;
      }

      final authUserId = _authUserIdPendente;

      if (authUserId == null) {
        _mensagem(
          'Não foi possível recuperar sua autenticação. Entre novamente.',
        );
        return;
      }

      await _continuarCadastro(authUserId);
      return;
    }

    if (!_emailValido || !_senhaValida) {
      _mensagem(
        'Informe um e-mail válido e uma senha com pelo menos 6 caracteres.',
      );
      return;
    }

    if (!_isLogin && !_numeroValido) {
      _mensagem('Informe seu telefone para concluir o cadastro.');
      return;
    }

    setState(() => _enviando = true);

    try {
      if (_isLogin) {
        final resposta = await AuthHelper.signInWithEmail(
          email: _emailController.text,
          password: _senhaController.text,
        );

        final usuario = resposta.user;
        debugPrint('[AUTH] Sessão retornada: ${resposta.session != null}');
debugPrint('[AUTH] Usuário retornado: ${usuario != null}');

        if (usuario == null) {
          throw Exception('Não foi possível identificar a conta.');
        }

        await _verificarPerfil(
          usuario.id,
          telefoneSalvo: usuario.userMetadata?['telefone']?.toString(),
        );
      } else {
        final resposta = await AuthHelper.signUpWithEmail(
          email: _emailController.text,
          password: _senhaController.text,
          telefone: _telefone,
        );

        final usuario = resposta.user;

        if (usuario == null) {
          throw Exception('O Supabase não retornou o usuário.');
        }

        if (resposta.session == null) {
          setState(() => _enviando = false);

          _mensagem(
            'Cadastro iniciado! Confirme seu e-mail. Depois, entre '
            'com sua conta para concluir seu cadastro.',
          );
          return;
        }

        await _continuarCadastro(
          usuario.id,
          telefone: _telefone,
        );
      }
    } catch (e) {
      debugPrint('[AUTH] Erro no e-mail: $e');

      if (!mounted) return;

      setState(() => _enviando = false);
      _mensagem(
        'Não foi possível autenticar. Verifique seus dados e tente novamente.',
      );
    }
  }

  Future<void> _continuarComGoogle() async {
    if (!_isLogin && !_numeroValido) {
      _mensagem('Informe seu telefone para concluir o cadastro.');
      return;
    }

    setState(() => _enviando = true);

    try {
      final resposta = await AuthHelper.signInWithGoogle();
      final usuario = resposta.user;

      if (usuario == null) {
        throw Exception('O Google não retornou um usuário.');
      }

      await _verificarPerfil(
        usuario.id,
        telefoneSalvo: usuario.userMetadata?['telefone']?.toString(),
      );
    } catch (e) {
      debugPrint('[AUTH] Erro no Google: $e');

      if (!mounted) return;

      setState(() => _enviando = false);
      _mensagem('Não foi possível entrar com Google. Tente novamente.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLogin = _isLogin;
    final mostrarTelefone = !isLogin || _aguardandoTelefone;

    return Scaffold(
      backgroundColor: AppColors.paper100,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            StepProgressHeader(
              step: 3,
              totalSteps: 4,
              title: _aguardandoTelefone
                  ? 'Complete seu cadastro'
                  : isLogin
                      ? 'Entrar na conta'
                      : 'Criar sua conta',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                children: [
                  Text(
                    _aguardandoTelefone
                        ? 'Sua autenticação foi concluída. Informe seu telefone para criar seu perfil no Rodapé.'
                        : isLogin
                            ? 'Entre com seu e-mail e senha ou utilize sua conta Google.'
                            : 'Crie sua conta para começar a trocar livros com outras pessoas.',
                    style: AppTextStyles.sans(
                      fontSize: 15,
                      color: AppColors.ink700,
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (mostrarTelefone) ...[
                    Text(
                      'SEU TELEFONE',
                      style: AppTextStyles.mono(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
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
                    const SizedBox(height: 20),
                  ],

                  if (!_aguardandoTelefone) ...[
                    Text(
                      'E-MAIL',
                      style: AppTextStyles.mono(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'seuemail@exemplo.com',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'SENHA',
                      style: AppTextStyles.mono(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _senhaController,
                      obscureText: !_mostrarSenha,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Mínimo de 6 caracteres',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _mostrarSenha = !_mostrarSenha;
                            });
                          },
                          icon: Icon(
                            _mostrarSenha
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Text(
                      'OU',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.mono(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ListenableBuilder(
                      listenable: Net.i,
                      builder: (context, _) => RodapeButton(
                        label: 'Continuar com Google',
                        variant: RodapeButtonVariant.quiet,
                        size: RodapeButtonSize.sm,
                        onPressed: (_enviando ||
                                !Net.i.online ||
                                _aguardandoTelefone)
                            ? null
                            : _continuarComGoogle,
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                  Text(
                    _aguardandoTelefone
                        ? 'Seu telefone será o identificador principal do seu perfil no Rodapé.'
                        : isLogin
                            ? 'O telefone não é necessário para entrar. Sua conta será localizada pelo vínculo com o Supabase.'
                            : 'Seu telefone será usado como identificador no Rodapé e para combinar as entregas.',
                    style: AppTextStyles.sans(
                      fontSize: 12,
                      color: AppColors.textMuted,
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
                builder: (context, _) => RodapeButton(
                  label: _enviando
                      ? 'Aguarde...'
                      : _aguardandoTelefone
                          ? 'Continuar cadastro'
                          : isLogin
                              ? 'Entrar com e-mail'
                              : 'Criar conta com e-mail',
                  onPressed: (_enviando || !Net.i.online)
                      ? null
                      : _entrarComEmail,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
