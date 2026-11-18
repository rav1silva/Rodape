import 'package:rodape/data/local_db.dart';
import 'package:rodape/models/livro.dart';
import 'package:rodape/services/net_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LivroService {
  static Map<String, Object?> _linha(Map<String, dynamic> m) => {
    'id': m['id'],
    'titulo': m['titulo'],
    'autor': m['autor'],
    'descricao': m['descricao'],
    'isbn': m['isbn'],
    'capa_url': m['capa_url'],
    'cor_lombada': m['cor_lombada'],
  };

  static Future<void> _salvar(List<Map<String, dynamic>> remoto) async {
    final db = await LocalDb.db;
    final batch = db.batch();
    for (final m in remoto) {
      batch.insert('livros', _linha(m),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  /// Baixa o catálogo do Supabase para o aparelho.
  static Future<void> atualizarCache() async {
    if (!Net.i.online) return;
    try {
      await _salvar(await Supabase.instance.client.from("livros").select());
    } catch (_) {}
  }

  /// Com internet busca no Supabase (e guarda); sem internet lê do aparelho.
  static Future<List<Livro>> obterLivros({String? filtro}) async {
    final f = filtro?.trim();

    if (Net.i.online) {
      try {
        var query = Supabase.instance.client.from("livros").select();
        if (f != null && f.isNotEmpty) {
          query = query.like("titulo", "%$f%");
        }
        final remoto = await query;
        await _salvar(remoto);
        return remoto.map(Livro.fromMap).toList();
      } catch (_) {
        // falhou de verdade: cai para o aparelho
      }
    }

    final db = await LocalDb.db;
    final rows = (f == null || f.isEmpty)
        ? await db.query('livros')
        : await db.query('livros', where: 'titulo LIKE ?', whereArgs: ['%$f%']);
    return rows.map(Livro.fromMap).toList();
  }

  /// Primeiro no aparelho; só vai à rede se não achar.
  static Future<Livro?> obterById(String id) async {
    final db = await LocalDb.db;
    final rows =
        await db.query('livros', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isNotEmpty) return Livro.fromMap(rows.first);

    if (Net.i.online) {
      try {
        final r =
            await Supabase.instance.client.from("livros").select().eq("id", id);
        if (r.isNotEmpty) {
          await _salvar(r);
          return Livro.fromMap(r.first);
        }
      } catch (_) {}
    }
    return null;
  }

  static Future<List<Livro>> obter3Ultimos() async {
    final resultado = await Supabase.instance.client
        .from("livros")
        .select()
        .order("id", ascending: false)
        .limit(3);

    return resultado.map(Livro.fromMap).toList();
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