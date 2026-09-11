/// Uma linha do extrato de crédito do usuário.
class CreditTransaction {
  const CreditTransaction({
    required this.data,
    required this.descricao,
    required this.valor,
  });

  final String data;
  final String descricao;

  /// Positivo (entrega) ou negativo (resgate / expiração).
  final int valor;

  String get valorLabel => valor >= 0 ? '+$valor' : '$valor';
}
