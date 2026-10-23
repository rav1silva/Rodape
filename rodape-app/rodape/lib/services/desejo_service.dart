import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:rodape/data/local_db.dart';
import 'package:rodape/models/desejo.dart';
import 'package:rodape/models/livro.dart';
import 'package:rodape/models/profile.dart';
import 'package:rodape/services/auth_service.dart';
import 'package:rodape/services/net_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class DesejoService {
  /// Muda sempre que a lista local muda; as telas escutam e recarregam.
  static final versao = ValueNotifier<int>(0);
  static bool _syncing = false;

  // ---------- leitura (sempre do aparelho) ----------

  static Future<List<Desejo>> _lerLocal(String uid) async {
    final db = await LocalDb.db;
    final rows = await db.query('desejos',
        where: 'user_id = ?', whereArgs: [uid], orderBy: 'posicao');
    return rows.map(Desejo.fromMap).toList();
  }

  static Future<List<Desejo>> obterDesejos(Profile profile) async {
    if (profile.id == null) return [];
    var lista = await _lerLocal(profile.id!);
    if (lista.isEmpty && Net.i.online) {
      await sync(); // primeira vez: baixa do Supabase
      lista = await _lerLocal(profile.id!);
    }
    return lista;
  }

  // ---------- escrita: grava no aparelho e entra na fila ----------

  static Future<void> adicionar(Profile user, Livro livro) async {
    final atuais = await _lerLocal(user.id!);
    if (atuais.any((d) => d.livroId == livro.id)) return;

    final d = Desejo(
      id: const Uuid().v4(),
      userId: user.id!,
      livroId: livro.id,
      posicao: atuais.length,
    );
    final db = await LocalDb.db;
    await db.transaction((t) async {
      await t.insert('desejos', d.toMap());
      await _enfileirar(t, 'upsert', [d.toMap()]);
    });
    _mudou();
  }

  static Future<void> remover(Profile user, Desejo desejo) async {
    final db = await LocalDb.db;
    await db.transaction((t) async {
      await t.delete('desejos', where: 'id = ?', whereArgs: [desejo.id]);
      await _enfileirar(t, 'delete', desejo.id);
      final rows = await t.query('desejos',
          where: 'user_id = ?', whereArgs: [user.id], orderBy: 'posicao');
      await _gravarOrdem(t, rows.map(Desejo.fromMap).toList());
    });
    _mudou();
  }

  static Future<void> reordenar(Profile user, List<Desejo> novaOrdem) async {
    final db = await LocalDb.db;
    await db.transaction((t) => _gravarOrdem(t, novaOrdem));
    _mudou();
  }

  static Future<void> _gravarOrdem(Transaction t, List<Desejo> lista) async {
    if (lista.isEmpty) return;
    for (var i = 0; i < lista.length; i++) {
      lista[i].posicao = i;
      await t.update('desejos', {'posicao': i},
          where: 'id = ?', whereArgs: [lista[i].id]);
    }
    await _enfileirar(t, 'upsert', lista.map((d) => d.toMap()).toList());
  }

  static Future<void> _enfileirar(Transaction t, String op, Object payload) =>
      t.insert('fila', {'op': op, 'payload': jsonEncode(payload)});

  static void _mudou() {
    versao.value++;
    sync();
  }

  // ---------- sincronização com o Supabase ----------

  /// Envia a fila na ordem e depois baixa a lista do servidor.
  static Future<void> sync() async {
    final uid = AuthService.loggedUser?.id;
    if (uid == null || !Net.i.online || _syncing) return;
    _syncing = true;
    try {
      final db = await LocalDb.db;
      final api = Supabase.instance.client;

      while (true) {
        final fila = await db.query('fila', orderBy: 'seq', limit: 1);
        if (fila.isEmpty) break;
        final op = fila.first;
        final dados = jsonDecode(op['payload'] as String);
        try {
          if (op['op'] == 'upsert') {
            await api.from('desejos').upsert(dados);
          } else {
            await api.from('desejos').delete().eq('id', dados);
          }
        } on PostgrestException {
          // o servidor recusou (ex.: duplicado): descarta para não travar a fila
        }
        await db.delete('fila', where: 'seq = ?', whereArgs: [op['seq']]);
      }

      final remoto = await api.from('desejos').select().eq('user_id', uid);

      // só troca o local se nada novo entrou na fila durante o envio
      if ((await db.query('fila', limit: 1)).isEmpty) {
        await db.transaction((t) async {
          await t.delete('desejos', where: 'user_id = ?', whereArgs: [uid]);
          for (final m in remoto) {
            await t.insert('desejos', {
              'id': m['id'],
              'user_id': m['user_id'],
              'livro_id': m['livro_id'],
              'posicao': m['posicao'],
            });
          }
        });
        debugPrint('desejos no aparelho: ${remoto.length}'); // remova depois
        versao.value++;
      }
    } catch (_) {
      // sem internet de verdade: tenta de novo quando ela voltar
    } finally {
      _syncing = false;
    }
  }

  // ---------- usados no cadastro (online, como antes) ----------

  static Future<void> adicionarDesejos(List<Desejo> listaDesejo) async {
    listaDesejo = _calcularPosicao(listaDesejo);
    for (final desejo in listaDesejo) {
      await Supabase.instance.client.from("desejos").insert(desejo.toMap());
    }
  }

  static Future<void> removerDesejos(Profile user) async {
    if (user.id == null) return;
    await Supabase.instance.client
        .from("desejos")
        .delete()
        .eq("user_id", user.id!);
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