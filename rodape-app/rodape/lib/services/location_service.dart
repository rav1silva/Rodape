
import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Position> obterLocalizacaoAtual() async {
    // Verifica se o serviço de localização do aparelho está ligado.
    final servicoAtivo = await Geolocator.isLocationServiceEnabled();

    if (!servicoAtivo) {
      throw Exception(
        'Ative a localização do aparelho para continuar.',
      );
    }

    // Verifica a permissão do aplicativo.
    LocationPermission permissao =
        await Geolocator.checkPermission();

    // Solicita permissão somente quando necessário.
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }

    if (permissao == LocationPermission.denied) {
      throw Exception(
        'Permissão de localização não concedida.',
      );
    }

    if (permissao == LocationPermission.deniedForever) {
      throw Exception(
        'A permissão foi bloqueada. '
        'Altere-a nas configurações do aplicativo.',
      );
    }

    // Obtém a localização atual, com limite de espera.
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
  }
}
