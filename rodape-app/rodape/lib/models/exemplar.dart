import 'package:rodape/models/exemplar_status.dart';
import 'package:rodape/models/livro.dart';
import 'package:rodape/models/profile.dart';

class Exemplar {
  Exemplar({
    required this.id,
    required this.livroId,
    required this.donoId,
    required this.estadoDeConservacao,
    required this.status,
    required this.maos,
    required this.creditos,
    this.distancia,
    this.frete,
  });

  final String id;
  final String livroId;
  final String donoId;
  final String estadoDeConservacao;
  final ExemplarStatus status;
  final int maos;
  final int creditos;
  final double? distancia;
  final double? frete;

  Livro? livro;
  Profile? desejadoPor;

  factory Exemplar.fromMap(Map<String, dynamic> map) => Exemplar(
    id: map["id"],
    livroId: map["livro_id"],
    donoId: map["dono_id"],
    estadoDeConservacao: map["estado_conservacao"],
    status: ExemplarStatusExtensions.fromString(map["status"]),
    maos: map["maos"],
    creditos: map["creditos"],
    distancia: map["distancia"],
    frete: map["frete"],
  );
}
