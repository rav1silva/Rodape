class Coordinates {
  const Coordinates({required this.latitude, required this.longitude});

  final String longitude;
  final String latitude;

  factory Coordinates.fromJson(Map<String, dynamic> json) =>
      Coordinates(latitude: json["latitude"], longitude: json["longitude"]);
}
