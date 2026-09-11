import 'package:flutter/material.dart';

import '../helpers/models/book_status.dart';
import '../theme/app_text_styles.dart';

/// Selo de estado de um exemplar (SeloEstado): disponível / reservado /
/// a caminho / entregue.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final BookStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.background,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        status.label.toUpperCase(),
        style: AppTextStyles.mono(
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          color: status.color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
