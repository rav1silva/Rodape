
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rodape/models/profile.dart';
import 'package:rodape/services/auth_service.dart';
import 'package:rodape/services/profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'helper_pref.dart';
import 'models/cep_info.dart';

class InvalidCepException implements Exception {
  InvalidCepException(this.message);
  final String message;
}

class ServiceAreaException implements Exception {
  ServiceAreaException(this.message);
  final String message;
}

class AuthHelper {
  AuthHelper._();

  static bool _googleInicializado = false;

  static const _ceps = <String, CepInfo>{
    '01221020': CepInfo(
      cep: '01221-020',
      endereco: 'Dom José Gaspar',
      cidade: 'Belo Horizonte',
      exemplaresPerto: 28,
      distanciaKm: 3,
    ),
    '22041001': CepInfo(
      cep: '22041-001',
      endereco: 'Vila Buarque',
      cidade: 'São Paulo',
      exemplaresPerto: 41,
      distanciaKm: 2,
    ),
  };

  static const _cepForaDeArea = '00000000';

  static SupabaseClient get _supabase =>
      Supabase.instance.client;

  // Inicializar uma única vez, depois de carregar o .env.
  // Inicializar uma única vez, depois de carregar o .env.
static Future<void> initializeGoogleSignIn() async {
  // O Google Sign-In nativo não é inicializado no Linux.
  if (defaultTargetPlatform != TargetPlatform.android &&
      defaultTargetPlatform != TargetPlatform.iOS) {
    return;
  }

  if (_googleInicializado) return;

  final clientId = dotenv.env['GOOGLE_WEB_CLIENT_ID']?.trim();

  if (clientId == null || clientId.isEmpty) {
    throw Exception('GOOGLE_WEB_CLIENT_ID não configurado no .env.');
  }

  await GoogleSignIn.instance.initialize(
    serverClientId: clientId,
  );

  _googleInicializado = true;
}

  // Login nativo com Google integrado ao Supabase.
  static Future<AuthResponse> signInWithGoogle() async {
    if (!_googleInicializado) {
      await initializeGoogleSignIn();
    }

    final googleAccount =
        await GoogleSignIn.instance.authenticate();

    final googleAuthentication = googleAccount.authentication;
    final idToken = googleAuthentication.idToken;

    if (idToken == null) {
      throw Exception('O Google não retornou um ID Token.');
    }

    final authorization = await googleAccount.authorizationClient
            .authorizationForScopes(['email']) ??
        await googleAccount.authorizationClient
            .authorizeScopes(['email']);

    final accessToken = authorization.accessToken;

    if (accessToken.isEmpty) {
      throw Exception('O Google não retornou um Access Token.');
    }

    return _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  // Cadastro com e-mail e senha.
static Future<AuthResponse> signUpWithEmail({
  required String email,
  required String password,
  required String telefone,
}) async {
  return _supabase.auth.signUp(
    email: email.trim(),
    password: password,
    emailRedirectTo: 'com.example.rodape://login-callback/',
    data: {
      'telefone': telefone,
    },
  );
}
  // Login com e-mail e senha.
  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return _supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Busca de CEP (mantida como estava).
  static Future<CepInfo> lookupCep(String cep) async {
    final digits = cep.replaceAll(RegExp(r'\D'), '');

    await Future.delayed(const Duration(milliseconds: 900));

    if (digits.length != 8) {
      throw InvalidCepException('Digite um CEP válido (8 dígitos).');
    }

    if (digits == _cepForaDeArea) {
      throw ServiceAreaException('Ainda não chegamos nesse CEP.');
    }

    return _ceps[digits] ??
        CepInfo(
          cep: '${digits.substring(0, 5)}-${digits.substring(5)}',
          endereco: 'Rua Mock',
          cidade: 'Sua região',
          exemplaresPerto: 12,
          distanciaKm: 4,
        );
  }

  // Encerrar a sessão real do Supabase.
  static Future<void> logout() async {
    await _supabase.auth.signOut();

    try {
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      debugPrint('[AUTH] Não foi possível encerrar sessão Google: $e');
    }

    AuthService.loggedUser = null;
    ProfileService.registerModel = Profile.blank();

    await HelperPref.setOnboardingDone(false);
  }
}
