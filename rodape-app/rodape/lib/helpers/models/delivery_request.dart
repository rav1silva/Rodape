import 'book.dart';

/// Pedido de entrega de um exemplar seu — mostrado no card "Sua próxima
/// ação" da Home.
class DeliveryRequest {
  const DeliveryRequest({
    required this.solicitante,
    required this.book,
    required this.distanciaKm,
    required this.nota,
  });

  final String solicitante;
  final Book book;
  final double distanciaKm;
  final String nota;
}
