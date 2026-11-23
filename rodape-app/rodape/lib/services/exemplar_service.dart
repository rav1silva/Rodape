
import 'package:rodape/models/exemplar.dart';
import 'package:rodape/models/livro.dart';
import 'package:rodape/models/profile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExemplarService {
  static final _supabase = Supabase.instance.client;
  static const _bucket = 'fotos-exemplares';

  static Future<void> _verificarDono({
    required String exemplarId,
    required String donoId,
  }) async {
    final resultado = await _supabase
        .from('exemplares')
        .select('id')
        .eq('id', exemplarId)
        .eq('dono_id', donoId)
        .maybeSingle();

    if (resultado == null) {
      throw Exception('Exemplar não encontrado para este usuário.');
    }
  }

  static Future<List<Exemplar>> obterExemplaresLivro(
    Livro livro, {
    String? donoId,
  }) async {
    var query = _supabase
        .from('exemplares')
        .select()
        .eq('livro_id', livro.id);

    if (donoId != null) {
      query = query.eq('dono_id', donoId);
    }

    final resultado = await query;
    return resultado.map(Exemplar.fromMap).toList();
  }

  static Future<void> cadastrarExemplar({
    required String livroId,
    required String donoId,
  }) async {
    await _supabase.from('exemplares').insert({
      'livro_id': livroId,
      'dono_id': donoId,
    });
  }

  static Future<Exemplar?> obterExemplarById(String id) async {
    final resultado = await _supabase
        .from('exemplares')
        .select()
        .eq('id', id);

    final first = resultado.firstOrNull;
    return first != null ? Exemplar.fromMap(first) : null;
  }

  static Future<List<Exemplar>> obterExemplaresDesejados(
    Profile user,
  ) async {
    if (user.id == null) return [];

    final resultado = await _supabase
        .from('exemplares')
        .select()
        .eq('livros.desejos.user_id', user.id!);

    return resultado.map(Exemplar.fromMap).toList();
  }

  static Future<List<Exemplar>> obterLivrosDisponiveisRodas(
    Profile user,
  ) async {
    if (user.id == null) return [];

    final resultado = await _supabase
        .from('exemplares')
        .select()
        .eq('dono_id', user.id!)
        .not('livros.desejos.id', 'is', null);

    final pedidos = await _supabase
        .from('pedidos')
        .select()
        .or('solicitante_id.eq.${user.id},dono_id.eq.${user.id}');

    final pedidosExemplaresId =
        pedidos.map((p) => p['exemplar_id']).toList();

    return resultado
        .where((e) => !pedidosExemplaresId.contains(e['id']))
        .map(Exemplar.fromMap)
        .toList();
  }

  static Future<List<Exemplar>> obterFiltrado({
    double? distanciaMaxima,
    List<String>? estadoDeConservacao,
    double? freteMaximo,
  }) async {
    var query = _supabase.from('exemplares').select();

    if (distanciaMaxima != null) {
      query = query.lte('distancia', distanciaMaxima);
    }

    if (estadoDeConservacao != null) {
      query = query.contains(
        'estado_conservacao',
        estadoDeConservacao,
      );
    }

    if (freteMaximo != null) {
      query = query.lte('frete', freteMaximo);
    }

    final result = await query;
    return result.map(Exemplar.fromMap).toList();
  }

  // Atualiza somente as informações editáveis do exemplar.
  // O status é controlado pelo fluxo de pedidos.
  static Future<void> atualizarExemplar({
    required String exemplarId,
    required String donoId,
    String? estadoDeConservacao,
  }) async {
    await _verificarDono(
      exemplarId: exemplarId,
      donoId: donoId,
    );

    final dados = <String, dynamic>{};

    if (estadoDeConservacao != null) {
      dados['estado_conservacao'] = estadoDeConservacao;
    }

    if (dados.isEmpty) return;

    await _supabase
        .from('exemplares')
        .update(dados)
        .eq('id', exemplarId)
        .eq('dono_id', donoId);
  }

  // Consulta as fotos de um exemplar.
  static Future<List<Map<String, dynamic>>> obterFotosExemplar(
    String exemplarId,
  ) async {
    final resultado = await _supabase
        .from('fotos_exemplares')
        .select()
        .eq('exemplar_id', exemplarId)
        .order('created_at');

    return List<Map<String, dynamic>>.from(resultado);
  }

  // Envia uma foto para o Storage e registra sua URL.
  static Future<Map<String, dynamic>> adicionarFoto({
    required String exemplarId,
    required String donoId,
    required XFile foto,
  }) async {
    await _verificarDono(
      exemplarId: exemplarId,
      donoId: donoId,
    );

    final extensao = foto.name.contains('.')
        ? foto.name.split('.').last.toLowerCase()
        : 'jpg';

    const tipos = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'webp': 'image/webp',
      'heic': 'image/heic',
    };

    final contentType = tipos[extensao] ?? 'image/jpeg';

    final caminho =
        '$donoId/$exemplarId/${DateTime.now().microsecondsSinceEpoch}.$extensao';

    await _supabase.storage.from(_bucket).uploadBinary(
      caminho,
      await foto.readAsBytes(),
      fileOptions: FileOptions(
        contentType: contentType,
      ),
    );

    final url = _supabase.storage
        .from(_bucket)
        .getPublicUrl(caminho);

    try {
      final resultado = await _supabase
          .from('fotos_exemplares')
          .insert({
            'exemplar_id': exemplarId,
            'url': url,
          })
          .select()
          .single();

      return Map<String, dynamic>.from(resultado);
    } catch (e) {
      await _supabase.storage.from(_bucket).remove([caminho]);
      rethrow;
    }
  }

  static String? _obterCaminhoStorage(String url) {
    final segmentos = Uri.parse(url).pathSegments;
    final indice = segmentos.indexOf(_bucket);

    if (indice == -1 || indice + 1 >= segmentos.length) {
      return null;
    }

    return segmentos.skip(indice + 1).join('/');
  }

  // Exclui uma foto do Storage e da tabela.
  static Future<void> excluirFoto({
    required String fotoId,
    required String exemplarId,
    required String donoId,
  }) async {
    await _verificarDono(
      exemplarId: exemplarId,
      donoId: donoId,
    );

    final foto = await _supabase
        .from('fotos_exemplares')
        .select()
        .eq('id', fotoId)
        .eq('exemplar_id', exemplarId)
        .maybeSingle();

    if (foto == null) {
      throw Exception('Foto não encontrada.');
    }

    final caminho = _obterCaminhoStorage(foto['url']);

    if (caminho != null) {
      await _supabase.storage.from(_bucket).remove([caminho]);
    }

    await _supabase
        .from('fotos_exemplares')
        .delete()
        .eq('id', fotoId)
        .eq('exemplar_id', exemplarId);
  }

  // Exclui todas as fotos e depois o exemplar.
  static Future<void> excluirExemplar({
    required String exemplarId,
    required String donoId,
  }) async {
    await _verificarDono(
      exemplarId: exemplarId,
      donoId: donoId,
    );

    final fotos = await obterFotosExemplar(exemplarId);

    for (final foto in fotos) {
      final caminho = _obterCaminhoStorage(foto['url']);

      if (caminho != null) {
        await _supabase.storage.from(_bucket).remove([caminho]);
      }
    }

    await _supabase
        .from('exemplares')
        .delete()
        .eq('id', exemplarId)
        .eq('dono_id', donoId);
  }
}
