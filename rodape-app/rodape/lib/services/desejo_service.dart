import 'package:rodape/models/desejo.dart';
import 'package:rodape/models/livro.dart';
import 'package:rodape/models/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DesejoService {
  static Future<void> adicionarDesejos(List<Desejo> listaDesejo) async {
    listaDesejo = _calcularPosicao(listaDesejo);
    for (final desejo in listaDesejo) {
      await Supabase.instance.client.from("desejos").insert(desejo.toMap());
    }
  }

  static Future<void> removerDesejos(Profile user) async {
    if (user.id == null) {
      return;
    }

    await Supabase.instance.client
        .from("desejos")
        .delete()
        .eq("user_id", user.id!);
  }

  static Future<List<Desejo>> obterDesejos(Profile profile) async {
    if (profile.id == null) {
      return List.empty(growable: false);
    }

    final result = await Supabase.instance.client
        .from("desejos")
        .select()
        .eq("user_id", profile.id!);

    return result.map(Desejo.fromMap).toList();
  }

  static Future<List<Desejo>> obterDesejosPorLivro(Livro livro) async {
    final result = await Supabase.instance.client
        .from("desejos")
        .select()
        .eq("livro_id", livro.id);
    return result.map(Desejo.fromMap).toList();
  }

  static List<Desejo> _calcularPosicao(List<Desejo> listaDesejo) {
    var idx = 0;
    for (final desejo in listaDesejo) {
      desejo.posicao = idx++;
    }

    return listaDesejo;
  }
}
