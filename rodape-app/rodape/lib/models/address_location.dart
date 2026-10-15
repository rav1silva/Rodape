import 'package:rodape/models/coordinates.dart';

class AddressLocation {
  AddressLocation({required this.type, required this.coordinates});

  final String type;
  final Coordinates coordinates;

  factory AddressLocation.fromJson(Map<String, dynamic> json) =>
      AddressLocation(
        type: json["type"],
        coordinates: Coordinates.fromJson(json["coordinates"]),
      );
}
