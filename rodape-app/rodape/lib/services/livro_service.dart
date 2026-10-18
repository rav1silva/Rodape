import 'package:rodape/models/livro.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LivroService {
  static Future<List<Livro>> obterLivros({String? filtro}) async {
    var query = Supabase.instance.client.from("livros").select();
    if (filtro != null) {
      query = query.like("titulo", "%$filtro%");
    }

    final results = await query;
    return results.map(Livro.fromMap).toList();
  }

  static Future<List<Livro>> obter3Ultimos() async {
    final resultado = await Supabase.instance.client
        .from("livros")
        .select()
        .order("id", ascending: false)
        .limit(3);

    return resultado.map(Livro.fromMap).toList();
  }

  static Future<Livro?> obterById(String id) async {
    final resultado = await Supabase.instance.client
        .from("livros")
        .select()
        .eq("id", id);

    final livro = resultado.firstOrNull;
    return livro != null ? Livro.fromMap(livro) : null;
  }

  static Future<Livro?> obterLivroPorExemplar(String exemplarId) async {
    final resultado = await Supabase.instance.client
        .from("livros")
        .select()
        .eq("exemplares.livro_id", exemplarId)
        .limit(1);

    final first = resultado.firstOrNull;
    return first != null ? Livro.fromMap(first) : null;
  }
}
