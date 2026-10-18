import 'package:rodape/models/credito.dart';
import 'package:rodape/models/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreditoService {
  static Future<List<Credito>> obterHistorico(Profile user) async {
    if (user.id == null) {
      return List.empty(growable: false);
    }

    final resultados = await Supabase.instance.client
        .from("creditos")
        .select()
        .eq("user_id", user.id!)
        .order("created_at", ascending: false)
        .limit(4);

    return resultados.map(Credito.fromMap).toList();
  }
}
