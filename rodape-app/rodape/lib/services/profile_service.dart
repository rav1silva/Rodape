import 'package:rodape/models/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  static Profile registerModel = Profile();

  static Future<void> cadastrarUsuario() async {
    await Supabase.instance.client.from("profiles").insert({
      "nome": registerModel.nome,
      "sobrenome": registerModel.sobrenome,
      "telefone": "${registerModel.ddd}${registerModel.numeroCelular}",
      "cep": registerModel.cep,
    });
  }
}
