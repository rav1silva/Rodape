import 'package:dio/dio.dart';

/// Cliente HTTP único do app.
///
/// O app hoje roda 100% sobre mocks (`lib/helpers/mocks`). Quando a API do
/// Rodapé estiver disponível, aponte [baseUrl] para o ambiente correto e
/// troque as chamadas a `Mock*.load()` pelos métodos deste client nas
/// telas — a UI já consome os mesmos `models`, então a troca é local.
class DioClient {
  DioClient._();

  static const String baseUrl = 'https://api.rodape.app';

  static final Dio instance = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );
}
