import 'package:flutter/material.dart';

import 'book_status.dart';

/// Um exemplar de livro em circulação na rede do Rodapé.
///
/// [maos] é o número de leitores por quem o exemplar já passou — alimenta o
/// carimbo de circulação (azul até a 4ª mão, vermelho da 5ª em diante).
class Book {
  const Book({
    required this.id,
    required this.titulo,
    required this.autor,
    required this.spineColor,
    required this.maos,
    this.estadoConservacao = 'bom',
    this.status = BookStatus.disponivel,
    this.exemplares = 1,
    this.distanciaKm,
    this.creditos = 1,
    this.freteValor,
    this.coverAsset,
  });

  final String id;
  final String titulo;
  final String autor;
  final Color spineColor;

  /// Número de leitores anteriores (dono atual incluso).
  final int maos;

  final String estadoConservacao;
  final BookStatus status;
  final int exemplares;
  final double? distanciaKm;
  final int creditos;
  final double? freteValor;

  /// Caminho de asset local da capa, quando existir. Sem asset, a UI usa a
  /// cor da lombada como placeholder.
  final String? coverAsset;

  String get distanciaLabel =>
      distanciaKm == null ? '' : '${distanciaKm!.toStringAsFixed(1)} km';

  String get freteLabel =>
      freteValor == null ? '' : 'R\$ ${freteValor!.toStringAsFixed(2).replaceAll('.', ',')}';
}
