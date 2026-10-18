import 'package:rodape/models/exemplar.dart';
import 'package:rodape/models/exemplar_status.dart';
import 'package:rodape/models/livro.dart';

class Pedido {
  Pedido({
    required this.id,
    required this.exemplarId,
    required this.solicitanteId,
    required this.status,
    this.rodaId,
    this.nota,
    this.frete,
    required this.destinatarioId,
  });

  final String id;
  final String exemplarId;
  final String solicitanteId;
  final String? rodaId;
  final double? frete;
  final String? nota;
  final ExemplarStatus status;
  final String destinatarioId;

  Livro? livro;
  Exemplar? exemplar;

  factory Pedido.fromMap(Map<String, dynamic> map) => Pedido(
    id: map["id"],
    exemplarId: map["exemplar_id"],
    solicitanteId: map["solicitante_id"],
    rodaId: map["roda_id"],
    status: ExemplarStatusExtensions.fromString(map["status"]),
    frete: map["frete"],
    nota: map["nota"],
    destinatarioId: map["destinatario_id"],
  );
}

// create table pedidos (           -- pedido de um exemplar (uma etapa da roda)
//   id uuid primary key default gen_random_uuid(),
//   exemplar_id uuid not null references exemplares(id) on delete cascade,
//   solicitante_id uuid not null references profiles(id),
//   roda_id uuid references rodas(id),
//   frete numeric(6,2),
//   nota text,
//   status text not null default 'pendente'
//     check (status in ('pendente','aceito','a_caminho','entregue','cancelado')),
//   created_at timestamptz default now()
