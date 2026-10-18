import 'package:intl/intl.dart';

extension DatetimeExtensions on DateTime {
  String toDate() {
    return DateFormat("dd/MM/yyyy").format(this);
  }

  String toSimplifiedDate() {
    return DateFormat("dd/MM").format(this);
  }

  String getNameOfDayWeek() {
    return switch (weekday) {
      DateTime.monday => "Segunda",
      DateTime.tuesday => "Terça",
      DateTime.wednesday => "Quarta",
      DateTime.thursday => "Quinta",
      DateTime.friday => "Sexta",
      DateTime.saturday => "Sabado",
      DateTime.sunday => "Domingo",
      _ => "",
    };
  }

  String getTimeDiff() {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inSeconds < 60) {
      return "${diff.inSeconds} segundos";
    } else if (diff.inMinutes < 60) {
      return "${diff.inMinutes} minutos";
    } else {
      return "${diff.inHours} horas";
    }
  }
}
