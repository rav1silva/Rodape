import 'package:rodape/models/roda_status.dart';

class Roda {
  Roda({required this.id, required this.fechadaEm, required this.status});

  final String id;
  final RodaStatus status;
  final DateTime fechadaEm;

  factory Roda.fromMap(Map<String, dynamic> map) => Roda(
    id: map["id"],
    status: RodaStatusExtensions.fromString(map["status"])!,
    fechadaEm: DateTime.now(),
  );
}
