import 'package:flutter/material.dart';
import 'package:rodape/services/auth_service.dart';
import 'package:rodape/services/net_service.dart';

/// Aviso de "sem conexão" para o usuário logado.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Net.i,
      builder: (_, _) {
        if (Net.i.online || AuthService.loggedUser == null) {
          return const SizedBox.shrink();
        }
        return Material(
          color: const Color(0xFFB4561F),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: const Text(
              'Sem conexão com a internet. Suas alterações serão enviadas quando ela voltar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        );
      },
    );
  }
}