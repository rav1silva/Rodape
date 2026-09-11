import 'package:flutter/material.dart';

/// Um item da tela de notificações.
class AppNotification {
  const AppNotification({
    required this.titulo,
    required this.mensagem,
    required this.tempo,
    required this.icon,
    required this.color,
    this.urgente = false,
  });

  final String titulo;
  final String mensagem;
  final String tempo;
  final IconData icon;
  final Color color;

  /// Urgentes ganham uma barra lateral vermelha (exigem ação do usuário).
  final bool urgente;
}
