class Credito {
  const Credito({
    required this.id,
    required this.userId,
    required this.descricao,
    required this.valor,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String descricao;
  final int valor;
  final DateTime createdAt;

  factory Credito.fromMap(Map<String, dynamic> map) => Credito(
    id: map["id"],
    descricao: map["descricao"],
    userId: map["user_id"],
    valor: map["valor"],
    createdAt: DateTime.tryParse(map["created_at"])!,
  );
}
