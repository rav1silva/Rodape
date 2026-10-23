import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:rodape/services/livro_service.dart';
import 'package:rodape/services/desejo_service.dart';

/// Estado da conexão. Ao voltar a internet, atualiza o catálogo local.
class Net extends ChangeNotifier {
  static final i = Net._();
  Net._();

  bool online = true;

  Future<void> init() async {
    online = await InternetConnection().hasInternetAccess;
    notifyListeners();
    InternetConnection().onStatusChange.listen((status) {
      final on = status == InternetStatus.connected;
      if (on == online) return;
      online = on;
      notifyListeners();
      if (on) {
        LivroService.atualizarCache();
        DesejoService.sync();
      }
    });
  }
}