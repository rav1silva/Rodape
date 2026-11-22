import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rodape/models/onboarding_args.dart';
import 'package:rodape/services/auth_service.dart';
import 'package:rodape/services/net_service.dart';
import 'package:rodape/services/profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

class _PhoneStepScreenState extends State<PhoneStepScreen>
    with WidgetsBindingObserver {
  /// De quanto em quanto tempo a tela confere sozinha se o e-mail já foi
  /// confirmado (cobre quem abre o link em outro aparelho, ex.: no PC).
  static const _intervaloVerificacao = Duration(seconds: 15);

  /// Depois desse tempo a verificação automática para (evita bater no
  /// limite de requisições do Supabase). O botão "Já confirmei" continua.
  static const _tempoMaximoVerificacao = Duration(minutes: 10);

  /// Intervalo mínimo entre reenvios do e-mail de confirmação.
  static const _cooldownReenvioSegundos = 60;

  final _ddiController = TextEditingController(text: '+55 11');
  final _numeroController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  late bool _modoLogin = widget.args.isLogin;

  bool _enviando = false;
  bool _mostrarSenha = false;
  bool _aguardandoTelefone = false;

  String? _authUserIdPendente;

  /// Erro exibido embaixo do campo de número (ex.: telefone já em uso).
  String? _erroTelefone;

  // Espera pela confirmação do e-mail.
  bool _aguardandoConfirmacao = false;
  bool _verificandoConfirmacao = false;
  bool _emailConfirmado = false;
  bool _finalizando = false;
  User? _usuarioConfirmado;
  DateTime? _inicioEspera;
  int _segundosParaReenviar = 0;

  StreamSubscription<AuthState>? _authSub;
  Timer? _timerVerificacao;
  Timer? _timerReenvio;

  bool get _numeroValido =>
      _numeroController.text.replaceAll(RegExp(r'\D'), '').length >= 8;

  bool get _emailValido => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
      .hasMatch(_emailController.text.trim());

  bool get _senhaValida => _senhaController.text.length >= 6;

  String get _telefone =>
      '${_ddiController.text} ${_numeroController.text}'.trim();

  String get _email => _emailController.text.trim();

  bool get _isLogin => _modoLogin;

  bool get _emEspera => _aguardandoConfirmacao || _emailConfirmado;

  bool get _verificacaoAutomaticaAtiva => _timerVerificacao?.isActive ?? false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Quando o usuário toca no link do e-mail neste aparelho, o deep link
    // reabre o app e o supabase_flutter troca o código por uma sessão,
    // disparando `signedIn` aqui.
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen(
      _onAuthState,
      onError: _onAuthErro,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSub?.cancel();
    _timerVerificacao?.cancel();
    _timerReenvio?.cancel();
    _ddiController.dispose();
    _numeroController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !_aguardandoConfirmacao) return;

    // Voltou do app de e-mail. Dá um instante para o deep link (se houver)
    // ser processado antes; senão, confere por conta própria.
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _checarConfirmacao(silencioso: true);
    });
  }

  void _mensagem(String texto) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  // ---------------------------------------------------------------------
  // Confirmação de e-mail
  // ---------------------------------------------------------------------

  void _onAuthState(AuthState data) {
    if (!_aguardandoConfirmacao) return;

    final usuario = data.session?.user;
    if (data.event != AuthChangeEvent.signedIn || usuario == null) return;
    if (usuario.emailConfirmedAt == null) return;

    _confirmacaoRecebida(usuario);
  }

  void _onAuthErro(Object erro) {
    debugPrint('[AUTH] Erro no deep link: $erro');
    if (!_aguardandoConfirmacao) return;

    _mensagem(
      'Esse link expirou ou já foi usado. Toque em "Reenviar e-mail" '
      'para receber um novo.',
    );
  }

  void _iniciarEspera({required bool emailAcabouDeSerEnviado}) {
    FocusScope.of(context).unfocus();

    setState(() {
      _enviando = false;
      _aguardandoConfirmacao = true;
      _emailConfirmado = false;
      _finalizando = false;
      _usuarioConfirmado = null;
    });

    _iniciarCooldownReenvio(
      emailAcabouDeSerEnviado ? _cooldownReenvioSegundos : 0,
    );
    _iniciarVerificacaoAutomatica();
  }

  void _iniciarVerificacaoAutomatica() {
    _timerVerificacao?.cancel();
    _inicioEspera = DateTime.now();

    _timerVerificacao = Timer.periodic(_intervaloVerificacao, (timer) {
      final inicio = _inicioEspera;
      if (inicio == null ||
          DateTime.now().difference(inicio) > _tempoMaximoVerificacao) {
        timer.cancel();
        if (mounted) setState(() {});
        return;
      }

      // Só confere com o app em primeiro plano.
      if (WidgetsBinding.instance.lifecycleState ==
          AppLifecycleState.resumed) {
        _checarConfirmacao(silencioso: true);
      }
    });
  }

  void _iniciarCooldownReenvio(int segundos) {
    _timerReenvio?.cancel();
    setState(() => _segundosParaReenviar = segundos);
    if (segundos <= 0) return;

    _timerReenvio = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _segundosParaReenviar--);
      if (_segundosParaReenviar <= 0) timer.cancel();
    });
  }

  void _pararEspera() {
    _timerVerificacao?.cancel();
    _timerReenvio?.cancel();
    _aguardandoConfirmacao = false;
    _emailConfirmado = false;
    _finalizando = false;
    _verificandoConfirmacao = false;
    _usuarioConfirmado = null;
    _segundosParaReenviar = 0;
  }

  void _voltarAoFormulario() {
    setState(_pararEspera);
  }

  /// Confere se o e-mail já foi confirmado tentando entrar com o e-mail e
  /// a senha que a pessoa acabou de digitar. O Supabase recusa com
  /// `email_not_confirmed` enquanto o link não for aberto.
  Future<void> _checarConfirmacao({required bool silencioso}) async {
    if (!_aguardandoConfirmacao || _verificandoConfirmacao || _finalizando) {
      return;
    }
    if (!Net.i.online) {
      if (!silencioso) _mensagem('Sem conexão. Tente de novo em instantes.');
      return;
    }

    setState(() => _verificandoConfirmacao = true);

    try {
      final atual = Supabase.instance.client.auth.currentUser;
      if (atual != null && atual.emailConfirmedAt != null) {
        await _confirmacaoRecebida(atual);
        return;
      }

      final resposta = await AuthHelper.signInWithEmail(
        email: _email,
        password: _senhaController.text,
      );

      final usuario = resposta.user;
      if (usuario != null) {
        await _confirmacaoRecebida(usuario);
      }
    } catch (e) {
      if (AuthHelper.isEmailNotConfirmed(e)) {
        if (!silencioso) {
          _mensagem(
            'Ainda não recebemos a confirmação. Abra o link que enviamos '
            'para $_email.',
          );
        }
      } else {
        debugPrint('[AUTH] Erro ao verificar confirmação: $e');
        if (!silencioso) {
          _mensagem(
            'Não foi possível verificar agora. Confira sua conexão e '
            'tente novamente.',
          );
        }
      }
    } finally {
      if (mounted) setState(() => _verificandoConfirmacao = false);
    }
  }

  Future<void> _confirmacaoRecebida(User usuario) async {
    if (!mounted || _emailConfirmado) return;

    _timerVerificacao?.cancel();
    _timerReenvio?.cancel();

    setState(() {
      _aguardandoConfirmacao = false;
      _emailConfirmado = true;
      _usuarioConfirmado = usuario;
    });

    // Deixa a confirmação visível por um instante antes de seguir.
    await Future.delayed(const Duration(milliseconds: 1200));
    await _prosseguirAposConfirmacao();
  }

  Future<void> _prosseguirAposConfirmacao() async {
    final usuario = _usuarioConfirmado;
    if (!mounted || usuario == null || _finalizando) return;

    setState(() => _finalizando = true);

    try {
      await _verificarPerfil(
        usuario.id,
        telefoneSalvo: usuario.userMetadata?['telefone']?.toString() ??
            (_numeroValido ? _telefone : null),
      );
    } catch (e) {
      debugPrint('[AUTH] Erro ao concluir após confirmação: $e');
      if (!mounted) return;

      setState(() => _finalizando = false);
      _mensagem(
        'Seu e-mail foi confirmado, mas não conseguimos carregar seu '
        'perfil. Toque em "Continuar" para tentar de novo.',
      );
    }
  }

  Future<void> _reenviarEmail() async {
    if (_segundosParaReenviar > 0 || !Net.i.online) return;

    try {
      await AuthHelper.resendSignupEmail(_email);
      _iniciarCooldownReenvio(_cooldownReenvioSegundos);

      // Reabre a janela de verificação automática, se já tinha expirado.
      if (!_verificacaoAutomaticaAtiva) _iniciarVerificacaoAutomatica();

      _mensagem('Enviamos um novo link para $_email.');
    } on AuthException catch (e) {
      debugPrint('[AUTH] Erro ao reenviar: $e');

      if (e.code == 'over_email_send_rate_limit' || e.statusCode == '429') {
        _iniciarCooldownReenvio(_cooldownReenvioSegundos);
        _mensagem(
          'Muitos envios seguidos. Aguarde um pouco antes de pedir outro.',
        );
      } else {
        _mensagem('Não foi possível reenviar o e-mail. Tente novamente.');
      }
    } catch (e) {
      debugPrint('[AUTH] Erro ao reenviar: $e');
      _mensagem('Não foi possível reenviar o e-mail. Tente novamente.');
    }
  }

  // ---------------------------------------------------------------------
  // Fluxo de cadastro/login
  // ---------------------------------------------------------------------

  /// Confere, antes de criar a conta, se o telefone já pertence a outro
  /// perfil. Assim nenhum e-mail de confirmação é enviado à toa.
  Future<bool> _telefoneLiberado() async {
    try {
      final disponivel = await ProfileService.telefoneDisponivel(_telefone);
      if (disponivel) return true;

      if (!mounted) return false;
      setState(() {
        _enviando = false;
        _erroTelefone = 'Este telefone já está em uso em outra conta.';
      });
      _mensagem(
        'Este telefone já está cadastrado. Entre com a conta dele ou '
        'use outro número.',
      );
      return false;
    } catch (e) {
      debugPrint('[CADASTRO] Erro ao verificar telefone: $e');
      if (!mounted) return false;
      setState(() => _enviando = false);
      _mensagem(
        'Não foi possível verificar o telefone agora. Tente novamente.',
      );
      return false;
    }
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
      _pararEspera();
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
    final perfil = await ProfileService.obterUsuarioPorAuthId(authUserId);
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
        _pararEspera();
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
        _pararEspera();
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

      setState(() => _enviando = true);
      if (!await _telefoneLiberado()) return;

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
          email: _email,
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
        if (!await _telefoneLiberado()) return;

        final resposta = await AuthHelper.signUpWithEmail(
          email: _email,
          password: _senhaController.text,
          telefone: _telefone,
        );

        if (!mounted) return;

        // E-mail já tem conta confirmada: vira login com os mesmos dados.
        if (AuthHelper.isExistingAccount(resposta)) {
          setState(() {
            _enviando = false;
            _modoLogin = true;
          });
          _mensagem(
            'Este e-mail já tem conta no Rodapé. Confira a senha e toque '
            'em "Entrar com e-mail".',
          );
          return;
        }

        final usuario = resposta.user;

        if (usuario == null) {
          throw Exception('O Supabase não retornou o usuário.');
        }

        // Confirmação de e-mail ligada: a tela passa a esperar o link.
        if (resposta.session == null) {
          _iniciarEspera(emailAcabouDeSerEnviado: true);
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

      if (AuthHelper.isEmailNotConfirmed(e)) {
        // Conta criada antes, mas o link nunca foi aberto.
        _iniciarEspera(emailAcabouDeSerEnviado: false);
        _mensagem(
          'Seu e-mail ainda não foi confirmado. Abra o link que enviamos '
          'ou peça um novo.',
        );
      } else if (AuthHelper.isInvalidCredentials(e)) {
        _mensagem('E-mail ou senha incorretos.');
      } else if (e is AuthException && e.code == 'user_already_exists') {
        setState(() => _modoLogin = true);
        _mensagem(
          'Este e-mail já tem conta no Rodapé. Toque em "Entrar com e-mail".',
        );
      } else if (e is AuthException && e.code == 'weak_password') {
        _mensagem('Escolha uma senha mais forte.');
      } else if (e is AuthException &&
          e.code == 'over_email_send_rate_limit') {
        _mensagem(
          'Muitas tentativas seguidas. Aguarde alguns minutos e tente de novo.',
        );
      } else {
        _mensagem(
          'Não foi possível autenticar. Verifique seus dados e tente '
          'novamente.',
        );
      }
    }
  }

  Future<void> _continuarComGoogle() async {
    if (!_isLogin && !_numeroValido) {
      _mensagem('Informe seu telefone para concluir o cadastro.');
      return;
    }

    setState(() => _enviando = true);

    if (!_isLogin && !await _telefoneLiberado()) return;

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

  // ---------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------

  String get _tituloHeader {
    if (_emailConfirmado) return 'E-mail confirmado';
    if (_aguardandoConfirmacao) return 'Confirme seu e-mail';
    if (_aguardandoTelefone) return 'Complete seu cadastro';
    return _isLogin ? 'Entrar na conta' : 'Criar sua conta';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Na espera, "voltar" retorna ao formulário em vez de sair da tela.
      canPop: !_emEspera,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || _finalizando) return;
        _voltarAoFormulario();
      },
      child: Scaffold(
        backgroundColor: AppColors.paper100,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              StepProgressHeader(
                step: 3,
                totalSteps: 4,
                title: _tituloHeader,
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _emEspera
                      ? _buildEspera()
                      : _buildFormulario(),
                ),
              ),
              _buildRodape(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRodape() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(
          top: BorderSide(color: AppColors.borderHairline),
        ),
      ),
      child: ListenableBuilder(
        listenable: Net.i,
        builder: (context, _) {
          if (_emailConfirmado) {
            return RodapeButton(
              label: _finalizando ? 'Aguarde...' : 'Continuar',
              onPressed: _finalizando ? null : _prosseguirAposConfirmacao,
            );
          }

          if (_aguardandoConfirmacao) {
            return RodapeButton(
              label: _verificandoConfirmacao ? 'Verificando...' : 'Já confirmei',
              icon: Icons.mark_email_read_outlined,
              onPressed: (_verificandoConfirmacao || !Net.i.online)
                  ? null
                  : () => _checarConfirmacao(silencioso: false),
            );
          }

          return RodapeButton(
            label: _enviando
                ? 'Aguarde...'
                : _aguardandoTelefone
                    ? 'Continuar cadastro'
                    : _isLogin
                        ? 'Entrar com e-mail'
                        : 'Criar conta com e-mail',
            onPressed:
                (_enviando || !Net.i.online) ? null : _entrarComEmail,
          );
        },
      ),
    );
  }

  Widget _buildEspera() {
    final confirmado = _emailConfirmado;

    return ListView(
      key: const ValueKey('espera'),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: confirmado
                  ? AppColors.stampGreen600
                  : AppColors.borderHairline,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: confirmado
                      ? AppColors.stampGreen100
                      : AppColors.stampOchre100,
                ),
                child: Icon(
                  confirmado
                      ? Icons.check_rounded
                      : Icons.mark_email_unread_outlined,
                  size: 32,
                  color: confirmado
                      ? AppColors.stampGreen600
                      : AppColors.spineOrange,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                confirmado ? 'E-mail confirmado!' : 'Confira sua caixa de entrada',
                textAlign: TextAlign.center,
                style: AppTextStyles.display(fontSize: 26),
              ),
              const SizedBox(height: 10),
              if (confirmado)
                Text(
                  _isLogin
                      ? 'Tudo certo. Entrando na sua conta…'
                      : 'Tudo certo. Agora é só terminar seu perfil.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.sans(
                    fontSize: 15,
                    color: AppColors.ink700,
                  ),
                )
              else
                Text.rich(
                  TextSpan(
                    style: AppTextStyles.sans(
                      fontSize: 15,
                      color: AppColors.ink700,
                    ),
                    children: [
                      const TextSpan(text: 'Enviamos um link de confirmação para '),
                      TextSpan(
                        text: _email,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const TextSpan(
                        text: '. Abra o link neste celular e você volta para '
                            'cá automaticamente.',
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 20),
              _buildStatusEspera(confirmado),
            ],
          ),
        ),
        if (!confirmado) ...[
          const SizedBox(height: 20),
          Text(
            'Abriu o link em outro aparelho? Toque em "Já confirmei". '
            'Não chegou? Confira o spam e a aba Promoções.',
            style: AppTextStyles.sans(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          ListenableBuilder(
            listenable: Net.i,
            builder: (context, _) => RodapeButton(
              label: _segundosParaReenviar > 0
                  ? 'Reenviar e-mail (${_formatarSegundos(_segundosParaReenviar)})'
                  : 'Reenviar e-mail',
              variant: RodapeButtonVariant.quiet,
              size: RodapeButtonSize.sm,
              icon: Icons.refresh_rounded,
              onPressed: (_segundosParaReenviar > 0 || !Net.i.online)
                  ? null
                  : _reenviarEmail,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: _voltarAoFormulario,
              child: Text(
                'Usar outro e-mail',
                style: AppTextStyles.mono(
                  fontSize: 12,
                  color: AppColors.ink900,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusEspera(bool confirmado) {
    final aguardandoSozinho =
        confirmado || _verificacaoAutomaticaAtiva || _verificandoConfirmacao;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (aguardandoSozinho) ...[
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: confirmado
                  ? AppColors.stampGreen600
                  : AppColors.spineOrange,
            ),
          ),
          const SizedBox(width: 10),
        ],
        Flexible(
          child: Text(
            confirmado
                ? (_isLogin ? 'Entrando' : 'Preparando seu perfil')
                : aguardandoSozinho
                    ? 'Aguardando confirmação'
                    : 'Toque em "Já confirmei" após abrir o link',
            textAlign: TextAlign.center,
            style: AppTextStyles.mono(
              fontSize: 11,
              color: AppColors.textMuted,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ],
    );
  }

  String _formatarSegundos(int s) =>
      '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';

  Widget _buildFormulario() {
    final isLogin = _isLogin;
    final mostrarTelefone = !isLogin || _aguardandoTelefone;

    return ListView(
      key: const ValueKey('formulario'),
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
                  onChanged: (_) => setState(() => _erroTelefone = null),
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
                  errorText: _erroTelefone,
                  onChanged: (_) => setState(() => _erroTelefone = null),
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
                  _mostrarSenha ? Icons.visibility_off : Icons.visibility,
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
              onPressed: (_enviando || !Net.i.online || _aguardandoTelefone)
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
    );
  }
}
