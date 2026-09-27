import 'package:flutter/material.dart';

/// Um livro do histórico de circulação do usuário (perfil).
class CirculationEntry {
  const CirculationEntry({
    required this.titulo,
    required this.spineColor,
    required this.maos,
    required this.statusLabel,
    this.statusColor,
    this.coverAsset,
  });

  final String titulo;
  final Color spineColor;
  final int maos;
  final String statusLabel;
  final Color? statusColor;

  /// Caminho de asset local da capa; sem ele, a UI usa a cor da lombada.
  final String? coverAsset;
}
