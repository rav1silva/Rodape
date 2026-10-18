class Notificacao {
  Notificacao({
    required this.id,
    required this.userId,
    this.tipo,
    required this.titulo,
    required this.mensagem,
    required this.urgente,
    required this.lida,
    required this.icone,
    required this.cor,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String? tipo;
  final String titulo;
  final String mensagem;
  final bool urgente;
  final bool lida;
  final String icone;
  final String cor;
  final DateTime createdAt;

  factory Notificacao.fromMap(Map<String, dynamic> map) => Notificacao(
    id: map["id"],
    userId: map["user_id"],
    tipo: map["tipo"],
    titulo: map["titulo"],
    mensagem: map["mensagem"],
    urgente: map["urgente"],
    lida: map["lida"],
    icone: map["icone"],
    cor: map["cor"],
    createdAt: map["created_at"],
  );
}
