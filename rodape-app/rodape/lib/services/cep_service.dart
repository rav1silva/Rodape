import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rodape/models/address.dart';

class CepService {
  static Future<Address?> obterInformacoesCep(String cep) async {
    cep = cep.replaceAll("-", "");
    final uri = Uri.https("brasilapi.com.br", "/api/cep/v2/$cep");
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      return null;
    }

    final responseBody = jsonDecode(response.body);
    return Address.fromJson(responseBody);
  }
}
