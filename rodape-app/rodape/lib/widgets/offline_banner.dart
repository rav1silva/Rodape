import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rodape/services/auth_service.dart';
import 'package:rodape/services/net_service.dart';
import 'package:rodape/theme/app_colors.dart';
import 'package:rodape/theme/app_text_styles.dart';

/// Aviso de "sem conexão". Para o usuário logado, avisa que as alterações
/// ficam guardadas; antes do login, avisa que entrar/criar conta não é
/// possível até a internet voltar.
///
/// Envolve o app inteiro (via `MaterialApp.builder`).
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, required this.child});

  final Widget child;

  static const _color = AppColors.stampRed600;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Net.i,
      builder: (context, _) {
        if (Net.i.online) return child;

        final detalhe = AuthService.loggedUser == null
            ? 'Não é possível entrar nem criar conta até ela voltar.'
            : 'Suas alterações serão enviadas quando ela voltar.';
        final topInset = MediaQuery.paddingOf(context).top;
        return Column(
          children: [
            AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.light,
              child: Material(
                color: _color,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, topInset + 10, 16, 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Sem conexão com a internet',
                              style: AppTextStyles.sans(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              detalhe,
                              style: AppTextStyles.sans(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.9),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: child,
              ),
            ),
          ],
        );
      },
    );
  }
}
