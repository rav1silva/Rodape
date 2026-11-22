
import 'package:rodape/models/exemplar.dart';
import 'package:rodape/models/livro.dart';
import 'package:rodape/models/profile.dart';
import 'package:rodape/models/pedido_status.dart';

// Quem importa pedido.dart também recebe o PedidoStatus e o label/color dele.
export 'package:rodape/models/pedido_status.dart';

class Pedido {
  Pedido({
    required this.id,
    required this.exemplarId,
    required this.solicitanteId,
    required this.status,
    this.rodaId,
    this.nota,
    this.frete,
    this.previsaoEntrega,
    this.createdAt,
    required this.destinatarioId,
    this.solicitante,
  });

  final String id;
  final String exemplarId;
  final String solicitanteId;
  final String? rodaId;
  final double? frete;
  final String? nota;
  final PedidoStatus status;
  final DateTime? previsaoEntrega;
  final DateTime? createdAt;
  final String destinatarioId;

  Profile? solicitante;
  Livro? livro;
  Exemplar? exemplar;

  factory Pedido.fromMap(Map<String, dynamic> map) => Pedido(
    id: map["id"],
    exemplarId: map["exemplar_id"],
    solicitanteId: map["solicitante_id"],
    rodaId: map["roda_id"],
    status: PedidoStatusX.fromString(map["status"]),
    frete: (map["frete"] as num?)?.toDouble(),
    nota: map["nota"],
    previsaoEntrega: DateTime.tryParse(map["previsao_entrega"] ?? ""),
    createdAt: DateTime.tryParse(map["created_at"] ?? ""),
    destinatarioId: map["destinatario_id"],
  );
}
