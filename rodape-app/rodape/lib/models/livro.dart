import 'package:collection/collection.dart';
import 'package:rodape/models/exemplar.dart';
import 'package:rodape/models/pedido.dart';

class Livro {
  Livro({
    required this.id,
    required this.autor,
    required this.titulo,
    this.descricao,
    this.isbn,
    this.capaUrl,
    this.corLombada,
    this.exemplares,
  });

  final String id;
  final String titulo;
  final String autor;
  final String? descricao;
  final String? isbn;
  final String? capaUrl;
  final String? corLombada;

  List<Exemplar>? exemplares;
  List<Pedido>? pedidos;

  factory Livro.fromMap(Map<String, dynamic> map) => Livro(
    id: map["id"],
    titulo: map["titulo"],
    autor: map["autor"],
    descricao: map["descricao"],
    isbn: map["isbn"],
    capaUrl: map["capa_url"],
    corLombada: map["cor_lombada"],
  );

  double? get frete {
    if (exemplares == null) {
      return null;
    }
    return minBy(exemplares!, (e) => e.frete)?.frete;
  }

  int get exemplaresCount {
    return exemplares?.length ?? 0;
  }

  String get estadoDeConservacao {
    return exemplares?.firstOrNull?.estadoDeConservacao ?? "Desconhecido";
  }

  double? get distancia {
    if (exemplares == null) {
      return null;
    }

    return minBy(exemplares!, (e) => e.distancia)?.distancia;
  }
}
