import 'package:flutter/material.dart';

import '../helpers/mocks/mock_notifications.dart';
import '../helpers/models/app_notification.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/rodape_header.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = MockNotifications.all;
    final urgentes = items.where((n) => n.urgente).length;

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
                itemCount: items.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, color: AppColors.borderHairline),
                itemBuilder: (context, index) => _NotificationTile(item: items[index]),
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

  final AppNotification item;

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
          Icon(item.icon, size: 17, color: item.color),
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
                          color: item.color,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                    Text(
                      item.tempo,
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
                    fontWeight: item.urgente ? FontWeight.w600 : FontWeight.w400,
                    color: item.urgente ? AppColors.ink900 : AppColors.textMuted,
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
