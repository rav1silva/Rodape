import 'package:rodape/models/exemplar.dart';
import 'package:rodape/models/livro.dart';
import 'package:rodape/models/pedido.dart';
import 'package:rodape/models/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PedidoService {
  static final _db = Supabase.instance.client;

  static Future<Pedido?> obterPedido(Exemplar exemplar, Profile user) async {
    if (user.id == null) return null;

    final result = await _db
        .from("pedidos")
        .select()
        .eq("exemplar_id", exemplar.id)
        .eq("solicitante_id", user.id!);

    final first = result.firstOrNull;
    return first != null ? Pedido.fromMap(first) : null;
  }

 static Future<List<Pedido>> pedidosLivro(Livro livro) async {
  // Primeiro, busca os exemplares associados ao livro.
  final exemplares = await _db
      .from("exemplares")
      .select("id")
      .eq("livro_id", livro.id);

  final ids = exemplares
      .map((e) => e["id"] as String)
      .toList();

  if (ids.isEmpty) {
    return [];
  }

  // Depois, busca os pedidos desses exemplares.
  final result = await _db
      .from("pedidos")
      .select()
      .inFilter("exemplar_id", ids);

  return result.map(Pedido.fromMap).toList();
}

  static Future<List<Pedido>> obterHistoricoPedidos(Profile user) async {
    if (user.id == null) return [];

    final result = await _db
        .from("pedidos")
        .select()
        .or("destinatario_id.eq.${user.id},solicitante_id.eq.${user.id}")
        .order("created_at", ascending: false)
        .limit(3);

    return result.map(Pedido.fromMap).toList();
  }

  // ---------- fluxo de entregas ----------

  /// Pedidos que o usuário fez, já com exemplar e livro (para a tela "Meus pedidos").
  static Future<List<Pedido>> meusPedidos(Profile user) async {
    if (user.id == null) return [];

    final result = await _db
        .from("pedidos")
        .select("*, exemplares(*, livros(*))")
        .eq("solicitante_id", user.id!)
        .order("created_at", ascending: false);

    return result.map((m) {
      final p = Pedido.fromMap(m);
      final ex = m["exemplares"] as Map<String, dynamic>?;
      if (ex != null) {
        p.exemplar = Exemplar.fromMap(ex);
        final lv = ex["livros"] as Map<String, dynamic>?;
        if (lv != null) p.livro = Livro.fromMap(lv);
      }
      return p;
    }).toList();
  }

  /// Compra o exemplar com 1 crédito (função criar_pedido no Supabase).
  static Future<String> criar(Exemplar exemplar, Profile user) async {
    final id = await _db.rpc("criar_pedido", params: {
      "p_exemplar": exemplar.id,
      "p_solicitante": user.id,
    });
    return id as String;
  }

  /// Cancela e devolve o crédito (função cancelar_pedido).
  static Future<void> cancelar(Pedido pedido, Profile user) async {
    await _db.rpc("cancelar_pedido", params: {
      "p_pedido": pedido.id,
      "p_usuario": user.id,
    });
  }

  /// Avança o status: aceito, a_caminho ou entregue (função avancar_pedido).
  static Future<void> avancar(Pedido pedido, Profile user, PedidoStatus novo) async {
    await _db.rpc("avancar_pedido", params: {
      "p_pedido": pedido.id,
      "p_usuario": user.id,
      "p_novo": novo.valor,
    });
  }


  static Future<List<Pedido>> pedidosRecebidos(Profile user) async {
    if (user.id == null) return [];

    final resultado = await _db
        .from("pedidos")
        .select('''
          *,
          exemplares(
            *,
            livros(*)
          ),
          solicitante:profiles!pedidos_solicitante_id_fkey(*)
        ''')
        .eq("destinatario_id", user.id!)
        .order("created_at", ascending: false);

    return resultado.map((m) {
      final pedido = Pedido.fromMap(m);

      final ex = m["exemplares"] as Map<String, dynamic>?;
      if (ex != null) {
        pedido.exemplar = Exemplar.fromMap(ex);

        final lv = ex["livros"] as Map<String, dynamic>?;
        if (lv != null) {
          pedido.livro = Livro.fromMap(lv);
        }
      }

      final solicitanteMap = m["solicitante"] as Map<String, dynamic>?;
      if (solicitanteMap != null) {
        pedido.solicitante = Profile.fromMap(solicitanteMap);
      }

      return pedido;
    }).toList();
  }

}