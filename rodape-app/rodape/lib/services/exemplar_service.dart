import 'package:rodape/models/exemplar.dart';
import 'package:rodape/models/livro.dart';
import 'package:rodape/models/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExemplarService {
  static Future<List<Exemplar>> obterExemplaresLivro(Livro livro) async {
    final resultado = await Supabase.instance.client
        .from("exemplares")
        .select()
        .eq("livro_id", livro.id);

    return resultado.map(Exemplar.fromMap).toList();
  }

  static Future<Exemplar?> obterExemplarById(String id) async {
    final resultado = await Supabase.instance.client
        .from("exemplares")
        .select()
        .eq("id", id);

    final first = resultado.firstOrNull;
    return first != null ? Exemplar.fromMap(first) : null;
  }

  static Future<List<Exemplar>> obterExemplaresDesejados(Profile user) async {
    if (user.id == null) {
      return [];
    }

    final resultado = await Supabase.instance.client
        .from("exemplares")
        .select()
        .eq("livros.desejos.user_id", user.id!);
    return resultado.map(Exemplar.fromMap).toList();
  }

  static Future<List<Exemplar>> obterLivrosDisponiveisRodas(
    Profile user,
  ) async {
    if (user.id == null) {
      return [];
    }
    final resultado = await Supabase.instance.client
        .from("exemplares")
        .select()
        .eq("dono_id", user.id!)
        .not("livros.desejos.id", "is", null);

    final pedidos = await Supabase.instance.client
        .from("pedidos")
        .select()
        .or("solicitante_id.eq.${user.id},dono_id.eq.${user.id}");

    final pedidosExemplaresId = pedidos.map((p) => p["exemplar_id"]).toList();
    return resultado
        .where((e) => !pedidosExemplaresId.contains(e["id"]))
        .map(Exemplar.fromMap)
        .toList();
  }

  static Future<List<Exemplar>> obterFiltrado({
    double? distanciaMaxima,
    List<String>? estadoDeConservacao,
    double? freteMaximo,
  }) async {
    var query = Supabase.instance.client.from("exemplares").select();

    if (distanciaMaxima != null) {
      query = query.lte("distancia", distanciaMaxima);
    }

    if (estadoDeConservacao != null) {
      query = query.contains("estado_conservacao", estadoDeConservacao);
    }

    if (freteMaximo != null) {
      query = query.lte("frete", freteMaximo);
    }

    final result = await query;
    return result.map(Exemplar.fromMap).toList();
  }
}
