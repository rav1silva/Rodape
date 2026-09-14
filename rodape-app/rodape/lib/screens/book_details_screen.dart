import 'package:flutter/material.dart';

import '../helpers/models/book.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/book_row.dart';

class BookDetailsScreen extends StatelessWidget {
  const BookDetailsScreen({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper100,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
              child: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back, color: AppColors.ink700),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                children: [
                  Center(
                    child: BookRow(
                      book: book,
                      coverWidth: 120,
                      crossAxisAlignment: CrossAxisAlignment.start,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(book.titulo, style: AppTextStyles.display(fontSize: 24)),
                  const SizedBox(height: 4),
                  Text(
                    book.autor,
                    style: AppTextStyles.sans(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'SOBRE O LIVRO',
                    style: AppTextStyles.mono(
                      fontSize: 10,
                      color: AppColors.paperGray500,
                      letterSpacing: 1.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.descricao ?? 'Sem descrição disponível.',
                    style: AppTextStyles.sans(
                      fontSize: 14,
                      color: AppColors.ink700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'DETALHES',
                    style: AppTextStyles.mono(
                      fontSize: 10,
                      color: AppColors.paperGray500,
                      letterSpacing: 1.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Estado de conservação: ${book.estadoConservacao}\n'
                    'Exemplares por perto: ${book.exemplares}\n'
                    '${book.distanciaKm != null ? 'Distância: ${book.distanciaLabel}\n' : ''}'
                    '${book.freteValor != null ? 'Frete: ${book.freteLabel}' : ''}',
                    style: AppTextStyles.sans(
                      fontSize: 13,
                      color: AppColors.ink700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
