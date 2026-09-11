import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../models/app_notification.dart';

class MockNotifications {
  MockNotifications._();

  static const List<AppNotification> all = [
    AppNotification(
      titulo: 'Roda encontrada',
      mensagem:
          'Você entrega O cortiço para Bruno M. e ganha 1 crédito. Aceite até 28/08.',
      tempo: 'há 12 min',
      icon: Icons.autorenew,
      color: AppColors.stampRed600,
      urgente: true,
    ),
    AppNotification(
      titulo: 'Pediram um livro seu',
      mensagem:
          'Marina S. pediu Grande sertão: veredas. Entregar gera 1 crédito e não custa nada.',
      tempo: 'há 20 min',
      icon: Icons.group_outlined,
      color: AppColors.stampRed600,
      urgente: true,
    ),
    AppNotification(
      titulo: 'Crédito prestes a expirar',
      mensagem: '1 crédito expira em 12/10. Resgate em qualquer exemplar da sua lista.',
      tempo: 'há 3 h',
      icon: Icons.schedule,
      color: AppColors.stampRed600,
      urgente: true,
    ),
    AppNotification(
      titulo: 'Crédito recebido',
      mensagem: 'Você entregou O cortiço a Bruno M. Saldo: 4 créditos.',
      tempo: 'ontem',
      icon: Icons.paid_outlined,
      color: AppColors.spineTeal,
    ),
    AppNotification(
      titulo: 'Livro da sua lista disponível',
      mensagem: 'Torto arado, a 0,6 km. Prioridade 01 da sua lista · frete R\$ 12,90.',
      tempo: 'ontem',
      icon: Icons.local_library_outlined,
      color: AppColors.wood600,
    ),
    AppNotification(
      titulo: 'Parte concluída',
      mensagem: 'Diego F. entregou Grande sertão a Carla T. na roda #4172.',
      tempo: '22/08',
      icon: Icons.check_circle_outline,
      color: AppColors.stateDisponivel,
    ),
    AppNotification(
      titulo: 'Exemplar a caminho',
      mensagem: 'Jonas R. saiu para entrega com Memórias póstumas. Chega entre 15:00 e 16:30.',
      tempo: '21/08',
      icon: Icons.local_shipping_outlined,
      color: AppColors.stateCaminho,
    ),
    AppNotification(
      titulo: 'Entrega atrasada',
      mensagem: 'Carla T. ainda não entregou Torto arado. Seu crédito segue disponível.',
      tempo: '20/08',
      icon: Icons.schedule,
      color: AppColors.paperGray600,
    ),
  ];
}
