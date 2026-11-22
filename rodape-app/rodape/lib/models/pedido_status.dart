import 'package:flutter/material.dart';
import 'package:rodape/theme/app_colors.dart';

enum PedidoStatus { pendente, aceito, aCaminho, entregue, cancelado }

extension PedidoStatusX on PedidoStatus {
  String get valor => switch (this) {
    PedidoStatus.pendente => 'pendente',
    PedidoStatus.aceito => 'aceito',
    PedidoStatus.aCaminho => 'a_caminho',
    PedidoStatus.entregue => 'entregue',
    PedidoStatus.cancelado => 'cancelado',
  };

  static PedidoStatus fromString(String v) => switch (v) {
    'pendente' => PedidoStatus.pendente,
    'aceito' => PedidoStatus.aceito,
    'a_caminho' => PedidoStatus.aCaminho,
    'entregue' => PedidoStatus.entregue,
    'cancelado' => PedidoStatus.cancelado,
    _ => throw ArgumentError('Status de pedido inválido: $v'),
  };

  String get label => switch (this) {
    PedidoStatus.pendente => 'Aguardando aceite',
    PedidoStatus.aceito => 'Aceito',
    PedidoStatus.aCaminho => 'A caminho',
    PedidoStatus.entregue => 'Entregue',
    PedidoStatus.cancelado => 'Cancelado',
  };

  Color get color => switch (this) {
    PedidoStatus.pendente => AppColors.stateReservado,
    PedidoStatus.aceito => AppColors.stateDisponivel,
    PedidoStatus.aCaminho => AppColors.stateCaminho,
    PedidoStatus.entregue => AppColors.stateEntregue,
    PedidoStatus.cancelado => AppColors.stampRed600,
  };

  Color get background => switch (this) {
    PedidoStatus.pendente => AppColors.stateReservadoBg,
    PedidoStatus.aceito => AppColors.stateDisponivelBg,
    PedidoStatus.aCaminho => AppColors.stateCaminhoBg,
    PedidoStatus.entregue => AppColors.stateEntregueBg,
    PedidoStatus.cancelado => AppColors.stampRed100,
  };
}