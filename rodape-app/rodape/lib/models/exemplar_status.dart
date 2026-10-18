import 'package:flutter/services.dart';
import 'package:rodape/theme/app_colors.dart';

enum ExemplarStatus { disponivel, reservado, caminho, entregue }

extension ExemplarStatusExtensions on ExemplarStatus {
  String getStatusString() {
    switch (this) {
      case ExemplarStatus.disponivel:
        return "disponivel";
      case ExemplarStatus.reservado:
        return "reservado";
      case ExemplarStatus.caminho:
        return "caminho";
      case ExemplarStatus.entregue:
        return "entregue";
    }
  }

  static ExemplarStatus fromString(String value) {
    switch (value) {
      case "disponivel":
        return ExemplarStatus.disponivel;
      case "reservado":
        return ExemplarStatus.reservado;
      case "caminho":
        return ExemplarStatus.caminho;
      case "entregue":
        return ExemplarStatus.entregue;
      default:
        throw ArgumentError("Valor inválido");
    }
  }

  Color get background => switch (this) {
    ExemplarStatus.disponivel => AppColors.stateDisponivel,
    ExemplarStatus.reservado => AppColors.stateReservado,
    ExemplarStatus.caminho => AppColors.stateCaminho,
    ExemplarStatus.entregue => AppColors.stateEntregue,
  };

  Color get color => switch (this) {
    ExemplarStatus.disponivel => AppColors.stateDisponivel,
    ExemplarStatus.reservado => AppColors.stateReservado,
    ExemplarStatus.caminho => AppColors.stateCaminho,
    ExemplarStatus.entregue => AppColors.stateEntregue,
  };

  String get label => switch (this) {
    ExemplarStatus.disponivel => 'Disponível',
    ExemplarStatus.reservado => 'Reservado',
    ExemplarStatus.caminho => 'A caminho',
    ExemplarStatus.entregue => 'Entregue',
  };
}
