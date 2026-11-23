import 'package:flutter/foundation.dart';

import 'package:rodape/models/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  static Profile registerModel = Profile.blank();

  static final _db = Supabase.instance.client;

  static Future<Profile?> atualizarLocalizacao(Profile user) async {
    if (user.id == null) {
      throw Exception('Usuário sem identificador.');
    }

    if (user.latitude == null || user.longitude == null) {
      throw Exception('Coordenadas de localização inválidas.');
    }

    if (user.latitude! < -90 ||
        user.latitude! > 90 ||
        user.longitude! < -180 ||
        user.longitude! > 180) {
      throw Exception('Coordenadas fora dos limites permitidos.');
    }

    if (user.localizacaoOrigem != 'gps' &&
        user.localizacaoOrigem != 'cep') {
      throw Exception('Origem da localização inválida.');
    }

    final resultado = await _db
        .from('profiles')
        .update({
          'latitude': user.latitude,
          'longitude': user.longitude,
          'localizacao_origem': user.localizacaoOrigem,
        })
        .eq('id', user.id!)
        .select()
        .single();

    return Profile.fromMap(resultado);
  }

  static Future<Profile?> atualizarFreteMaximo(
    Profile user,
    double novoValor,
  ) async {
    if (user.id == null) {
      throw Exception('Usuário sem identificador.');
    }

    if (novoValor < 0) {
      throw Exception('O frete máximo não pode ser negativo.');
    }

    final resultado = await _db
        .from('profiles')
        .update({'frete_maximo': novoValor})
        .eq('id', user.id!)
        .select()
        .single();

    return Profile.fromMap(resultado);
  }

  static Future<Profile?> cadastrarUsuario() async {
    final authUserId = registerModel.authUserId;

    if (authUserId == null || authUserId.isEmpty) {
      throw Exception('Usuário sem identificador de autenticação.');
    }

    // Evita criar outro perfil para uma conta já cadastrada.
    final existente = await obterUsuarioPorAuthId(authUserId);

    if (existente != null) {
      return existente;
    }

    try {
      final resultado = await _db
          .from('profiles')
          .insert(registerModel.toMap())
          .select()
          .single();

      return Profile.fromMap(resultado);
    } catch (_) {
      // Protege também contra duas tentativas simultâneas.
      final perfilCriado = await obterUsuarioPorAuthId(authUserId);

      if (perfilCriado != null) {
        return perfilCriado;
      }

      rethrow;
    }
  }

  /// true se nenhum perfil usa esse telefone (comparando só os dígitos).
  /// Funciona sem sessão: usa a RPC `telefone_disponivel`
  /// (supabase/migrations/20261122000000_telefone_disponivel.sql).
  static Future<bool> telefoneDisponivel(String telefone) async {
    try {
      final resultado = await _db.rpc(
        'telefone_disponivel',
        params: {'p_telefone': telefone},
      );
      return resultado == true;
    } on PostgrestException catch (e) {
      // RPC ainda não criada no projeto: não trava o cadastro, e o índice
      // único em profiles continua barrando no fim.
      if (e.code == 'PGRST202') {
        debugPrint(
          '[CADASTRO] RPC telefone_disponivel não existe no Supabase. '
          'Rode a migration 20261122000000_telefone_disponivel.sql.',
        );
        return true;
      }
      rethrow;
    }
  }

  /// true quando o erro veio da restrição única de telefone em profiles.
  static bool isTelefoneDuplicado(Object erro) {
    if (erro is! PostgrestException || erro.code != '23505') return false;
    final texto = '${erro.message} ${erro.details ?? ''}'.toLowerCase();
    return texto.contains('telefone');
  }

  static Future<Profile?> obterUsuario(String telefone) async {
    final resultado = await _db
        .from('profiles')
        .select()
        .eq('telefone', telefone)
        .maybeSingle();

    return resultado == null ? null : Profile.fromMap(resultado);
  }

  static Future<Profile?> obterUsuarioPorId(String id) async {
    final resultado = await _db
        .from('profiles')
        .select()
        .eq('id', id)
        .maybeSingle();

    return resultado == null ? null : Profile.fromMap(resultado);
  }

  static Future<Profile?> obterUsuarioPorAuthId(String authUserId) async {
    final resultado = await _db
        .from('profiles')
        .select()
        .eq('auth_user_id', authUserId)
        .maybeSingle();

    return resultado == null ? null : Profile.fromMap(resultado);
  }

static Future<Profile?> atualizarDadosPessoais(Profile user) async {
  if (user.id == null) {
    throw Exception('Usuário sem identificador.');
  }

  final resultado = await _db
      .from('profiles')
      .update({
        'nome': user.nome,
        'sobrenome': user.sobrenome,
        'telefone': user.telefone,
        'cep': user.cep,
        'rua': user.rua,
        'numero': user.numero,
        'complemento': user.complemento,
      })
      .eq('id', user.id!)
      .select()
      .single();

  return Profile.fromMap(resultado);
}
}
