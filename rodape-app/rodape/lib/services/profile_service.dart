
import 'package:rodape/models/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  static Profile registerModel = Profile.blank();

  static final _db = Supabase.instance.client;

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
        })
        .eq('id', user.id!)
        .select()
        .single();

    return Profile.fromMap(resultado);
  }
}
