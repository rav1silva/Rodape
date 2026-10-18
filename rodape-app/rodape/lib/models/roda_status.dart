enum RodaStatus { aberta, fechada }

extension RodaStatusExtensions on RodaStatus {
  String getStatusString() {
    return switch (this) {
      RodaStatus.aberta => "aberta",
      RodaStatus.fechada => "fechada",
    };
  }

  static RodaStatus? fromString(String value) {
    return switch (value) {
      "aberta" => RodaStatus.aberta,
      "fechada" => RodaStatus.fechada,
      _ => null,
    };
  }
}
