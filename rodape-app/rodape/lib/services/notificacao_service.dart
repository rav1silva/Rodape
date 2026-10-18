import 'package:rodape/models/notificacao.dart';
import 'package:rodape/models/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificacaoService {
  static Future<List<Notificacao>> obterNotificacoes(Profile user) async {
    if (user.id == null) {
      return [];
    }

    final result = await Supabase.instance.client
        .from("notificacoes")
        .select()
        .eq("user_id", user.id!);

    return result.map(Notificacao.fromMap).toList();
  }
}
