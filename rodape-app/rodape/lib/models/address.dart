import 'package:rodape/models/address_location.dart';

class Address {
  const Address({
    required this.cep,
    required this.state,
    required this.street,
    required this.city,
    required this.neighborhood,
    required this.timezoneName,
    required this.location,
  });

  final String cep;
  final String state;
  final String city;
  final String neighborhood;
  final String street;
  final String timezoneName;
  final AddressLocation location;

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    cep: json["cep"],
    state: json["state"],
    street: json["street"],
    city: json["city"],
    neighborhood: json["neighborhood"],
    timezoneName: json["timezoneName"],
    location: AddressLocation.fromJson(json["location"]),
  );
}
