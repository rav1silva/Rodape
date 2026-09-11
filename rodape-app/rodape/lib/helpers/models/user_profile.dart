/// Perfil do usuário logado.
class UserProfile {
  const UserProfile({
    required this.nome,
    required this.iniciais,
    required this.desde,
    required this.saldoCredito,
    required this.validadeCredito,
    required this.entregues,
    required this.recebidos,
    required this.rodas,
    required this.freteMaximo,
  });

  final String nome;
  final String iniciais;
  final String desde;
  final int saldoCredito;
  final String validadeCredito;
  final int entregues;
  final int recebidos;
  final int rodas;
  final double freteMaximo;
}
