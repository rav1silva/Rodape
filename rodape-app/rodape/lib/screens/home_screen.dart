import 'package:flutter/material.dart';

import '../helpers/mocks/mock_books.dart';
import '../helpers/mocks/mock_notifications.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/book_row.dart';
import '../widgets/credit_balance_card.dart';
import '../widgets/dashed_divider.dart';
import '../widgets/rodape_button.dart';
import '../widgets/section_label.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final disponiveis = [MockBooks.tortoArado, MockBooks.somEAFuria];
    final proximaAcao = MockBooks.proximaAcao;
    final badges = MockNotifications.all.where((n) => n.urgente).length;

    return Scaffold(
      backgroundColor: AppColors.paper100,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _HomeHeader(badges: badges),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                children: [
                  CreditBalanceCard(
                    saldo: 3,
                    validade: '12/10',
                    onResgatar: () {},
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      border: Border.all(color: AppColors.wood800),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadowStamped,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionLabel(
                          label: 'Da sua lista, disponível agora',
                          trailing: '5 títulos',
                        ),
                        const SizedBox(height: 12),
                        for (final book in disponiveis) ...[
                          BookRow(
                            book: book,
                            coverWidth: 56,
                            metaLine: '${book.distanciaLabel} · 1 CRÉDITO + ${book.freteLabel}',
                          ),
                          if (book != disponiveis.last)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: DashedDivider(),
                            ),
                        ],
                        const SizedBox(height: 10),
                        RodapeButton(
                          label: 'Ver os 5 disponíveis',
                          variant: RodapeButtonVariant.quiet,
                          size: RodapeButtonSize.sm,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const SectionLabel(
                    label: 'Sua próxima ação',
                    color: AppColors.stampRed600,
                  ),
                  const SizedBox(height: 10),
                  BookRow(
                    book: proximaAcao.book,
                    coverWidth: 52,
                    subtitle: '${proximaAcao.solicitante} pediu ${proximaAcao.book.titulo}',
                    metaLine:
                        '+1 CRÉDITO AO ENTREGAR · ${proximaAcao.distanciaKm.toStringAsFixed(1)} KM · ${proximaAcao.nota.toUpperCase()}',
                  ),
                  const SizedBox(height: 12),
                  RodapeButton(label: 'Aceitar entregar', onPressed: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.badges});

  final int badges;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.wood800,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Text(
            'RODAPÉ',
            style: AppTextStyles.display(fontSize: 20, color: AppColors.paper050),
          ),
          const Spacer(),
          Text(
            'TERÇA, 25/08',
            style: AppTextStyles.mono(
              fontSize: 10,
              color: AppColors.textOnWoodMuted,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(width: 8),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                ),
                icon: const Icon(Icons.notifications_outlined, color: AppColors.paper100),
              ),
              if (badges > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.stampRed600,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
