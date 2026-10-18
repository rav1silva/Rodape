// Argumentos passados entre as telas do fluxo de cadastro/login via rotas
// nomeadas (`Navigator.pushNamed(..., arguments: ...)`).

/// Passo "Seu telefone". [isLogin] distingue o atalho "Já tenho conta"
/// (pula direto para telefone + código, sem CEP/lista/nome) do cadastro
/// normal, que chega aqui vindo da lista de livros da região.
class PhoneStepArgs {
  const PhoneStepArgs({this.isLogin = false});

  final bool isLogin;
}

/// Passo "Código por SMS".
class OtpStepArgs {
  const OtpStepArgs({required this.telefone, required this.isLogin});

  final String telefone;
  final bool isLogin;
}

/// Tela final (conclusão do cadastro / escanear primeiros livros).
class OnboardingCompleteArgs {
  const OnboardingCompleteArgs({required this.nome, required this.inicial});

  final String nome;
  final String inicial;
}
