import 'package:flutter/material.dart';

import '../helpers/mocks/mock_books.dart';
import '../helpers/models/book.dart';
import '../helpers/models/cep_info.dart';
import '../helpers/models/onboarding_args.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/book_row.dart';
import '../widgets/rodape_button.dart';
import '../widgets/rodape_text_field.dart';
import '../widgets/step_progress_header.dart';
import 'book_details_screen.dart';

/// C3 · O que você quer ler — Passo 2 de 4. Lista de desejos inicial +
/// prova de liquidez (quantos exemplares já existem perto do usuário).
class NearbyBooksStepScreen extends StatefulWidget {
  const NearbyBooksStepScreen({super.key, required this.cepInfo});

  final CepInfo cepInfo;

  @override
  State<NearbyBooksStepScreen> createState() => _NearbyBooksStepScreenState();
}

class _NearbyBooksStepScreenState extends State<NearbyBooksStepScreen> {
  final _searchController = TextEditingController();

  final List<Book> _lista = [];

  List<Book> get _sugestoes {
    final termo = _searchController.text.trim().toLowerCase();
    if (termo.isEmpty) return const [];
    return MockBooks.all
        .where((b) => !_lista.contains(b))
        .where(
          (b) =>
              b.titulo.toLowerCase().contains(termo) ||
              b.autor.toLowerCase().contains(termo),
        )
        .take(4)
        .toList();
  }

  void _remover(Book book) {
    setState(() {
      _lista.remove(book);
    });
  }

  void _adicionar(Book book) {
    setState(() {
      _lista.add(book);
      _searchController.clear();
    });
    FocusScope.of(context).unfocus();
  }

  void _abrirDetalhes(Book book) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => BookDetailsScreen(book: book)));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final comExemplar = _lista.where((b) => b.exemplares > 0).toList();
    final totalExemplares = comExemplar.fold<int>(
      0,
      (sum, b) => sum + b.exemplares,
    );

    return Scaffold(
      backgroundColor: AppColors.paper100,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            StepProgressHeader(
              step: 2,
              totalSteps: 4,
              eyebrowSuffix: ' · ${widget.cepInfo.endereco}',
              title:
                  '$totalExemplares exemplares dos seus ${_lista.length} títulos a menos de 2 km',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: RodapeTextField(
                label: 'Adicionar título',
                controller: _searchController,
                onChanged: (_) => setState(() {}),
              ),
            ),
            if (_sugestoes.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  border: Border.all(color: AppColors.borderHairline),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final b in _sugestoes)
                      ListTile(
                        dense: true,
                        title: Text(
                          b.titulo,
                          style: AppTextStyles.sans(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          b.autor,
                          style: AppTextStyles.sans(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.add_circle_outline,
                          color: AppColors.spineTeal,
                        ),
                        onTap: () => _adicionar(b),
                      ),
                  ],
                ),
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                children: [
                  Text(
                    'SUA LISTA',
                    style: AppTextStyles.mono(
                      fontSize: 10,
                      color: AppColors.paperGray500,
                      letterSpacing: 1.6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final book in _lista) ...[
                    Opacity(
                      opacity: book.exemplares == 0 ? 0.6 : 1,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _abrirDetalhes(book),
                              child: BookRow(
                                book: book,
                                coverWidth: book.exemplares == 0 ? 48 : 72,
                                metaLine: book.exemplares == 0
                                    ? 'NINGUÉM TEM AINDA — AVISAMOS QUANDO APARECER'
                                    : '${book.exemplares} EXEMPLARES · ${book.distanciaLabel} · ENTREGA ${book.freteLabel}',
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              size: 18,
                              color: AppColors.paperGray500,
                            ),
                            tooltip: 'Remover',
                            onPressed: () => _remover(book),
                          ),
                        ],
                      ),
                    ),
                    if (book != _lista.last) const SizedBox(height: 14),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              decoration: const BoxDecoration(
                color: AppColors.surfaceCard,
                border: Border(
                  top: BorderSide(color: AppColors.borderHairline),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Crie sua conta para resgatar',
                    style: AppTextStyles.display(fontSize: 22),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Um crédito paga um exemplar; quem recebe paga a entrega. Sua lista fica guardada.',
                    style: AppTextStyles.sans(
                      fontSize: 13,
                      color: AppColors.ink700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  RodapeButton(
                    label: 'Criar conta',
                    variant: RodapeButtonVariant.accent,
                    onPressed: () => Navigator.of(context).pushNamed(
                      '/phone',
                      arguments: const PhoneStepArgs(isLogin: false),
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
