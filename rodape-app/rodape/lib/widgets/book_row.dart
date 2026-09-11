import 'package:flutter/material.dart';

import '../helpers/models/book.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'book_cover.dart';

/// Linha de livro reutilizada em Home, Lista de desejos e Perto de você:
/// capa + título/autor/metadados, com slots opcionais para um leading
/// (índice de prioridade) e um rodapé (botão de ação).
class BookRow extends StatelessWidget {
  const BookRow({
    super.key,
    required this.book,
    this.coverWidth = 72,
    this.leading,
    this.metaLine,
    this.subtitle,
    this.footer,
    this.titleFontSize = 17,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  final Book book;
  final double coverWidth;
  final Widget? leading;

  /// Linha mono teal com distância/crédito/frete.
  final String? metaLine;

  /// Substitui o autor padrão quando informado (ex.: "estado: bom").
  final String? subtitle;
  final Widget? footer;
  final double titleFontSize;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 10)],
        BookCover(book: book, width: coverWidth),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                book.titulo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.display(
                  fontSize: titleFontSize,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle ?? book.autor,
                style: AppTextStyles.sans(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  height: 1.2,
                ),
              ),
              if (metaLine != null) ...[
                const SizedBox(height: 4),
                Text(
                  metaLine!,
                  style: AppTextStyles.mono(
                    fontSize: 11,
                    color: AppColors.spineTeal,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
              if (footer != null) ...[
                const SizedBox(height: 8),
                footer!,
              ],
            ],
          ),
        ),
      ],
    );
  }
}
