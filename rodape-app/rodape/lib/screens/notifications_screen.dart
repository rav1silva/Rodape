import 'package:flutter/material.dart';
import 'package:rodape/extensions/datetime_extensions.dart';
import 'package:rodape/models/notificacao.dart';
import 'package:string_to_icon/string_to_icon.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/rodape_header.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key, required this.notificacoes});

  final List<Notificacao> notificacoes;

  @override
  Widget build(BuildContext context) {
    final urgentes = notificacoes.where((n) => n.urgente).length;

    return Scaffold(
      backgroundColor: AppColors.paper100,
      body: SafeArea(
        child: Column(
          children: [
            RodapeHeader(
              title: 'Notificações',
              eyebrow: '$urgentes exigem ação',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: notificacoes.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, color: AppColors.borderHairline),
                itemBuilder: (context, index) =>
                    _NotificationTile(item: notificacoes[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item});

  final Notificacao item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(
          left: BorderSide(
            color: item.urgente ? AppColors.stampRed600 : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            IconMapper.getIconData(item.icone),
            size: 17,
            color: Color(int.parse(item.cor)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.titulo.toUpperCase(),
                        style: AppTextStyles.mono(
                          fontSize: 10,
                          color: Color(int.parse(item.cor)),
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                    Text(
                      "há ${item.createdAt.getTimeDiff()}",
                      style: AppTextStyles.mono(
                        fontSize: 10,
                        color: AppColors.textFaint,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  item.mensagem,
                  style: AppTextStyles.sans(
                    fontSize: item.urgente ? 15 : 14,
                    fontWeight: item.urgente
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: item.urgente
                        ? AppColors.ink900
                        : AppColors.textMuted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
