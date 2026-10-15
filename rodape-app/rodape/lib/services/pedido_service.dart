import 'package:rodape/models/exemplar.dart';
import 'package:rodape/models/livro.dart';
import 'package:rodape/models/pedido.dart';
import 'package:rodape/models/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PedidoService {
  static Future<Pedido?> obterPedido(Exemplar exemplar, Profile user) async {
    if (user.id == null) {
      return null;
    }

    final result = await Supabase.instance.client
        .from("pedidos")
        .select()
        .eq("exemplar_id", exemplar.id)
        .eq("solicitante_id", user.id!);

    final firstResult = result.firstOrNull;
    return firstResult != null ? Pedido.fromMap(firstResult) : null;
  }

  static Future<List<Pedido>> pedidosLivro(Livro livro) async {
    final result = await Supabase.instance.client
        .from("pedidos")
        .select()
        .eq("exemplares.livro_id", livro.id);

    return result.map(Pedido.fromMap).toList();
  }

  static Future<List<Pedido>> obterHistoricoPedidos(Profile user) async {
    if (user.id == null) {
      return [];
    }

    final result = await Supabase.instance.client
        .from("pedidos")
        .select()
        .or("destinatario_id.eq.${user.id},solicitante_id.eq.${user.id}")
        .order("created_at", ascending: false)
        .limit(3);

    return result.map(Pedido.fromMap).toList();
  }
}
