
import 'package:rodape/models/livro.dart';

class Profile {
  Profile.blank();

  Profile({
    required this.id,
    this.authUserId,
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
    this.aceitaRetiradaPresencial = false,
    this.pontoEncontro,
    this.aceitaUber = false,
    this.aceitaTransportadora = false,
    this.latitude,
    this.longitude,
    this.localizacaoOrigem,
  });

  String? id;
  String? authUserId;

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

  // Preferências de entrega
  bool aceitaRetiradaPresencial = false;
  String? pontoEncontro;
  bool aceitaUber = false;
  bool aceitaTransportadora = false;

  // Localização do usuário
  double? latitude;
  double? longitude;
  String? localizacaoOrigem;

  Map<String, dynamic> toMap() {
    return {
      "auth_user_id": authUserId,
      "nome": nome,
      "sobrenome": sobrenome,
      "telefone": telefone,
      "cep": cep,
      "saldo_credito": saldoCredito,
      "entregues": entregues,
      "recebidos": recebidos,
      "rodas": rodas,
      "frete_maximo": freteMaximo,
      "validade_credito": validadeCredito?.toIso8601String(),
      "aceita_retirada_presencial": aceitaRetiradaPresencial,
      "ponto_encontro": pontoEncontro,
      "aceita_uber": aceitaUber,
      "aceita_transportadora": aceitaTransportadora,
      "latitude": latitude,
      "longitude": longitude,
      "localizacao_origem": localizacaoOrigem,
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map) => Profile(
    id: map["id"]?.toString(),
    authUserId: map["auth_user_id"]?.toString(),
    nome: map["nome"] ?? "",
    sobrenome: map["sobrenome"] ?? "",
    telefone: map["telefone"] ?? "",
    cep: map["cep"] ?? "",
    saldoCredito: (map["saldo_credito"] as num?)?.toInt() ?? 0,
    entregues: (map["entregues"] as num?)?.toInt() ?? 0,
    recebidos: (map["recebidos"] as num?)?.toInt() ?? 0,
    rodas: (map["rodas"] as num?)?.toInt() ?? 0,
    freteMaximo: (map["frete_maximo"] as num?)?.toDouble() ?? 25,
    createdAt: DateTime.tryParse(map["created_at"]?.toString() ?? ""),
    validadeCredito: DateTime.tryParse(
      map["validade_credito"]?.toString() ?? "",
    ),
    aceitaRetiradaPresencial:
        map["aceita_retirada_presencial"] as bool? ?? false,
    pontoEncontro: map["ponto_encontro"]?.toString(),
    aceitaUber: map["aceita_uber"] as bool? ?? false,
    aceitaTransportadora:
        map["aceita_transportadora"] as bool? ?? false,
    latitude: (map["latitude"] as num?)?.toDouble(),
    longitude: (map["longitude"] as num?)?.toDouble(),
    localizacaoOrigem: map["localizacao_origem"]?.toString(),
  );
}
