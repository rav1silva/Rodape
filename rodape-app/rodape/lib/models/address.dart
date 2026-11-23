
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
        cep: json['cep']?.toString() ?? '',
        state: json['state']?.toString() ?? '',
        street: json['street']?.toString() ?? '',
        city: json['city']?.toString() ?? '',
        neighborhood: json['neighborhood']?.toString() ?? '',
        timezoneName: json['timezone']?.toString() ?? '',
        location: AddressLocation.fromJson(
          Map<String, dynamic>.from(json['location'] ?? {}),
        ),
      );
}
