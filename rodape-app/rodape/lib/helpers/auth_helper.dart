import 'dart:math';

import 'package:flutter/foundation.dart';

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

/// Simulador de autenticação e dos serviços externos do cadastro (busca de
/// CEP, envio/validação de SMS).
///
/// Nenhuma chamada de rede acontece de verdade — cada método tem um
/// `Future.delayed` para imitar latência real e mantém a mesma assinatura
/// que uma implementação sobre [DioClient] teria, para a troca ser local
/// quando a API existir.
class AuthHelper {
  AuthHelper._();

  static String? _ultimoCodigoEnviado;

  /// CEPs "cadastrados" no mock, para variar a resposta de forma
  /// previsível. Qualquer outro CEP com 8 dígitos cai no caso genérico.
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

  /// CEP usado para simular "fora de área" (nenhuma cobertura ainda).
  static const _cepForaDeArea = '00000000';

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

  /// Envia (simula) um código de 6 dígitos por SMS e devolve o próprio
  /// código gerado — útil para a UI mostrar um atalho de teste, já que não
  /// há SMS real neste ambiente.
  static Future<String> sendSmsCode(String telefone) async {
    await Future.delayed(const Duration(milliseconds: 1100));
    _ultimoCodigoEnviado = (100000 + Random().nextInt(900000)).toString();
    debugPrint('[MOCK SMS] Código enviado para $telefone: $_ultimoCodigoEnviado');
    return _ultimoCodigoEnviado!;
  }

  static Future<bool> verifyCode(String codigo) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return codigo.length == 6 && codigo == _ultimoCodigoEnviado;
  }

  static Future<void> createAccount({
    required String nome,
    required String sobrenome,
    required String telefone,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    debugPrint('[MOCK AUTH] Conta criada: $nome $sobrenome · $telefone');
    await HelperPref.saveAuthToken('mock-token-${DateTime.now().millisecondsSinceEpoch}');
    await HelperPref.setOnboardingDone(true);
  }

  static Future<void> loginExisting({required String telefone}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    debugPrint('[MOCK AUTH] Login efetuado: $telefone');
    await HelperPref.saveAuthToken('mock-token-${DateTime.now().millisecondsSinceEpoch}');
    await HelperPref.setOnboardingDone(true);
  }
}
