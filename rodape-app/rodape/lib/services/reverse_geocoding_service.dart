
import 'dart:convert';

import 'package:http/http.dart' as http;

class ReverseGeocodingService {
  static Future<String?> obterDescricao({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/reverse',
        {
          'format': 'jsonv2',
          'lat': latitude.toString(),
          'lon': longitude.toString(),
          'zoom': '18',
          'addressdetails': '1',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'RODAPE/1.0 (aplicativo Flutter)',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return null;
      }

      final dados = jsonDecode(response.body);
      final endereco = dados['address'];

      if (endereco is! Map<String, dynamic>) {
        return null;
      }

      final bairro = endereco['neighbourhood'] ??
          endereco['suburb'] ??
          endereco['quarter'] ??
          endereco['city_district'];

      final cidade = endereco['city'] ??
          endereco['town'] ??
          endereco['village'] ??
          endereco['municipality'] ??
          endereco['county'];

      final estado = endereco['state'];

      final partes = <String>[
        if (bairro != null && bairro.toString().isNotEmpty)
          bairro.toString(),
        if (cidade != null && cidade.toString().isNotEmpty)
          cidade.toString(),
        if (estado != null && estado.toString().isNotEmpty)
          estado.toString(),
      ];

      if (partes.isEmpty) {
        return null;
      }

      return partes.join(' - ');
    } catch (e) {
      return null;
    }
  }
}
