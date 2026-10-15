import 'package:rodape/models/livro.dart';

class Desejo {
  Desejo({
    this.id = "",
    required this.userId,
    required this.livroId,
    this.posicao = 0,
  });

  final String id;
  final String userId;
  final String livroId;
  int posicao = 0;

  Livro? livro;

  Map<String, dynamic> toMap() {
    return {"livro_id": livroId, "user_id": userId, "posicao": posicao};
  }

  factory Desejo.fromMap(Map<String, dynamic> map) => Desejo(
    id: map["id"],
    livroId: map["livro_id"],
    userId: map["user_id"],
    posicao: map["posicao"],
  );
}
