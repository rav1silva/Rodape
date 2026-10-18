import 'package:rodape/models/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  static Profile registerModel = Profile.blank();

  static Future<Profile?> cadastrarUsuario() async {
    final inseredRow = await Supabase.instance.client
        .from("profiles")
        .insert(registerModel.toMap())
        .select();

    final first = inseredRow.firstOrNull;
    return first != null ? Profile.fromMap(first) : null;
  }

  static Future<Profile?> obterUsuario(String telefone) async {
    final result = await Supabase.instance.client
        .from("profiles")
        .select()
        .eq("telefone", telefone);

    final firstResult = result.firstOrNull;
    return firstResult != null ? Profile.fromMap(firstResult) : null;
  }

  static Future<Profile?> obterUsuarioPorId(String id) async {
    final result = await Supabase.instance.client
        .from("profiles")
        .select()
        .eq("id", id);

    final first = result.firstOrNull;
    return first != null ? Profile.fromMap(first) : null;
  }
}
