import 'package:flutter/foundation.dart';
import 'package:rodape/models/profile.dart';

class AuthService {
  static final ValueNotifier<Profile?> perfilNotifier =
      ValueNotifier<Profile?>(null);

  static Profile? get loggedUser => perfilNotifier.value;

  static set loggedUser(Profile? perfil) {
    perfilNotifier.value = perfil;
  }
}