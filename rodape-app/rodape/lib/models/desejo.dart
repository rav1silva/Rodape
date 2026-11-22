
import 'package:rodape/models/livro.dart';
import 'package:uuid/uuid.dart';

class Desejo {
  Desejo({
    String? id,
    required this.userId,
    required this.livroId,
    this.posicao = 0,
  }) : id = (id == null || id.isEmpty)
            ? const Uuid().v4()
            : id;

  final String id;
  final String userId;
  final String livroId;
  int posicao;

  Livro? livro;

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "livro_id": livroId,
      "user_id": userId,
      "posicao": posicao,
    };
  }

  factory Desejo.fromMap(Map<String, dynamic> map) => Desejo(
        id: map["id"]?.toString(),
        livroId: map["livro_id"],
        userId: map["user_id"],
        posicao: map["posicao"] ?? 0,
      );
}
