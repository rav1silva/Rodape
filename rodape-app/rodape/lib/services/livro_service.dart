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
  if (Net.i.online) {
    try {
      final resultado = await Supabase.instance.client
          .from("livros")
          .select()
          .order("created_at", ascending: false)
          .limit(3);

      await _salvar(
        List<Map<String, dynamic>>.from(resultado),
      );

      return resultado.map(Livro.fromMap).toList();
    } catch (e) {
      // Se falhar, tenta carregar do banco local.
    }
  }

  final db = await LocalDb.db;

  final rows = await db.query(
    'livros',
    orderBy: 'created_at DESC',
    limit: 3,
  );

  return rows.map(Livro.fromMap).toList();
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




  /// Busca um livro pelo ISBN.
/// Se já existir no Supabase, reutiliza o registro.
/// Caso contrário, consulta o Google Books e cadastra.
static Future<Livro> obterOuCadastrarPorIsbn(String isbn) async {
  final codigo = isbn.replaceAll(RegExp(r'\D'), '');

  if (codigo.length != 13 ||
      (!codigo.startsWith('978') && !codigo.startsWith('979'))) {
    throw Exception('Código ISBN-13 inválido.');
  }

  final supabase = Supabase.instance.client;

  // 1. Verifica se o livro já existe no catálogo.
  final existente = await supabase
      .from('livros')
      .select()
      .eq('isbn', codigo)
      .maybeSingle();

  if (existente != null) {
    return Livro.fromMap(
      Map<String, dynamic>.from(existente),
    );
  }

  // 2. Consulta o Google Books pela Edge Function.
  final resposta = await supabase.functions.invoke(
    'consultar-livro',
    body: {
      'isbn': codigo,
    },
  );

  if (resposta.status != 200) {
    throw Exception(
      'Não foi possível consultar os dados do livro.',
    );
  }

  final dados = Map<String, dynamic>.from(
    resposta.data as Map,
  );

  final itens = dados['items'] as List? ?? [];

  Map<String, dynamic>? informacoes;

  // 3. Confirma que o resultado realmente corresponde ao ISBN.
  for (final item in itens) {
    final volume = Map<String, dynamic>.from(item as Map);
    final info = Map<String, dynamic>.from(
      volume['volumeInfo'] as Map? ?? {},
    );

    final identificadores =
        info['industryIdentifiers'] as List? ?? [];

    final corresponde = identificadores.any((identificador) {
      final mapa = Map<String, dynamic>.from(identificador as Map);
      final valor = (mapa['identifier'] ?? '')
          .toString()
          .replaceAll(RegExp(r'\D'), '');

      return valor == codigo;
    });

    if (corresponde) {
      informacoes = info;
      break;
    }
  }

  if (informacoes == null) {
    throw Exception(
      'Não encontramos informações para esse ISBN. '
      'Confira o código ou tente novamente.',
    );
  }

  final titulo = (informacoes['title'] ?? '').toString().trim();

  final autores = informacoes['authors'] as List? ?? [];
  final autor = autores.isEmpty
      ? 'Autor não informado'
      : autores.join(', ');

  if (titulo.isEmpty) {
    throw Exception('Não encontramos o título desse livro.');
  }

  final imagens = informacoes['imageLinks'] as Map? ?? {};
  final capa = imagens['thumbnail']?.toString().replaceFirst(
    'http://',
    'https://',
  );

  final descricao = informacoes['description']?.toString()
      .replaceAll(RegExp(r'<[^>]*>'), '');

  // 4. Cadastra o livro no catálogo.
  final salvo = await supabase
      .from('livros')
      .insert({
        'titulo': titulo,
        'autor': autor,
        'descricao': descricao,
        'isbn': codigo,
        'capa_url': capa,
      })
      .select()
      .single();

  // 5. Atualiza o cache local.
  await _salvar([
    Map<String, dynamic>.from(salvo),
  ]);

  return Livro.fromMap(
    Map<String, dynamic>.from(salvo),
  );
}
}
