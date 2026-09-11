import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Estado de circulação de um exemplar na estante de alguém.
enum BookStatus { disponivel, reservado, caminho, entregue }

extension BookStatusX on BookStatus {
  String get label => switch (this) {
    BookStatus.disponivel => 'Disponível',
    BookStatus.reservado => 'Reservado',
    BookStatus.caminho => 'A caminho',
    BookStatus.entregue => 'Entregue',
  };

  Color get color => switch (this) {
    BookStatus.disponivel => AppColors.stateDisponivel,
    BookStatus.reservado => AppColors.stateReservado,
    BookStatus.caminho => AppColors.stateCaminho,
    BookStatus.entregue => AppColors.stateEntregue,
  };

  Color get background => switch (this) {
    BookStatus.disponivel => AppColors.stateDisponivelBg,
    BookStatus.reservado => AppColors.stateReservadoBg,
    BookStatus.caminho => AppColors.stateCaminhoBg,
    BookStatus.entregue => AppColors.stateEntregueBg,
  };
}
