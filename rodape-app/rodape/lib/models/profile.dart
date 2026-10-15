import 'package:rodape/models/livro.dart';

class Profile {
  Profile.blank();
  Profile({
    required this.id,
    required this.telefone,
    required this.nome,
    required this.sobrenome,
    required this.cep,
    required this.saldoCredito,
    this.entregues = 0,
    this.recebidos = 0,
    this.rodas = 0,
    required this.freteMaximo,
    this.createdAt,
    this.validadeCredito,
  });

  String? id;
  List<Livro> livros = [];
  String telefone = "";
  String nome = "";
  String sobrenome = "";
  String cep = "";
  int saldoCredito = 0;
  int entregues = 0;
  int recebidos = 0;
  int rodas = 0;
  double freteMaximo = 25;
  DateTime? createdAt;
  DateTime? validadeCredito;

  Map<String, dynamic> toMap() {
    return {
      "nome": nome,
      "sobrenome": sobrenome,
      "telefone": telefone,
      "cep": cep,
      "saldo_credito": saldoCredito,
      "entregues": entregues,
      "recebidos": recebidos,
      "rodas": rodas,
      "frete_maximo": freteMaximo,
      "validade_credito": validadeCredito,
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map) => Profile(
    id: map["id"],
    nome: map["nome"],
    sobrenome: map["sobrenome"],
    telefone: map["telefone"],
    cep: map["cep"],
    saldoCredito: map["saldo_credito"],
    entregues: map["entregues"] ?? 0,
    recebidos: map["recebidos"] ?? 0,
    rodas: map["rodas"] ?? 0,
    freteMaximo: map["frete_maximo"],
    createdAt: DateTime.tryParse(map["created_at"]),
    validadeCredito: map["validade_credito"],
  );
}
