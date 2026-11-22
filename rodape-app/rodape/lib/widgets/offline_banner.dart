
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rodape/services/auth_service.dart';
import 'package:rodape/services/net_service.dart';
import 'package:rodape/theme/app_colors.dart';
import 'package:rodape/theme/app_text_styles.dart';

/// Aviso compacto de falta de conexão.
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
                  padding: EdgeInsets.fromLTRB(
                    12,
                    topInset + 5,
                    12,
                    7,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Sem conexão com a internet',
                              style: AppTextStyles.sans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              detalhe,
                              style: AppTextStyles.sans(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.9),
                                height: 1.2,
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
