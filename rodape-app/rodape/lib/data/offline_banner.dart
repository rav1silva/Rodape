import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rodape/services/auth_service.dart';
import 'package:rodape/services/net_service.dart';
import 'package:rodape/theme/app_colors.dart';
import 'package:rodape/theme/app_text_styles.dart';

/// Aviso compacto de falta de conexão (uma linha).
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

        final texto = AuthService.loggedUser == null
            ? 'Sem conexão · não é possível entrar agora'
            : 'Sem conexão · alterações serão enviadas ao voltar';

        final topInset = MediaQuery.paddingOf(context).top;

        return Column(
          children: [
            AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.light,
              child: Material(
                color: _color,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(12, topInset + 2, 12, 3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 13),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          texto,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.sans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.1,
                          ),
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