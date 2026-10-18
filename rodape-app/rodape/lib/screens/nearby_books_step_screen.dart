import 'package:flutter/material.dart';
import 'package:rodape/models/address.dart';
import 'package:rodape/models/livro.dart';
import 'package:rodape/models/onboarding_args.dart';
import 'package:rodape/screens/book_details_screen.dart';
import 'package:rodape/services/exemplar_service.dart';
import 'package:rodape/services/livro_service.dart';
import 'package:rodape/services/profile_service.dart';
import 'package:throttling/throttling.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/book_row.dart';
import '../widgets/rodape_button.dart';
import '../widgets/rodape_text_field.dart';
import '../widgets/step_progress_header.dart';

/// C3 · O que você quer ler — Passo 2 de 4. Lista de desejos inicial +
/// prova de liquidez (quantos exemplares já existem perto do usuário).
class NearbyBooksStepScreen extends StatefulWidget {
  const NearbyBooksStepScreen({super.key, required this.cepInfo});

  final Address cepInfo;

  @override
  State<NearbyBooksStepScreen> createState() => _NearbyBooksStepScreenState();
}

class _NearbyBooksStepScreenState extends State<NearbyBooksStepScreen> {
  final _searchController = TextEditingController();
  final Debouncing deb = Debouncing<void>(duration: const Duration(milliseconds: 400));
  Future<List<Livro>>? _tarefaAtual;

  final List<Livro> _lista = [];
  Future<List<Livro>> _obterLivros() async {
    final searchValue = _searchController.text;
    return await LivroService.obterLivros(filtro: searchValue);
  }

  void _remover(Livro book) {
    setState(() {
      _lista.remove(book);
    });
  }

  Future<void> _adicionar(Livro book) async {
    book.exemplares = await ExemplarService.obterExemplaresLivro(book);
    setState(() {
      _lista.add(book);
      _searchController.clear();
    });

    if (!mounted) {
      return;
    }
    FocusScope.of(context).unfocus();
  }

  void _abrirDetalhes(Livro book) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => BookDetailsScreen(book: book)));
  }

  @override
  void dispose() {
    deb.close();
    _searchController.dispose();
    super.dispose();
  }

  void _salvar() {
    ProfileService.registerModel.livros = _lista;

    if (!mounted) {
      return;
    }

    Navigator.of(context)
        .pushNamed('/phone', arguments: const PhoneStepArgs(isLogin: false));
  }

  @override
  Widget build(BuildContext context) {
    final comExemplar = _lista
        .where((b) => (b.exemplares?.length ?? 0) > 0)
        .toList();
    final totalExemplares = comExemplar.fold<int>(
      0,
      (sum, b) => sum + (b.exemplares?.length ?? 0),
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
              eyebrowSuffix: ' · ${widget.cepInfo.street}',
              title:
                  '$totalExemplares exemplares dos seus ${_lista.length} títulos a menos de 2 km',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: RodapeTextField(
                label: 'Adicionar título',
                controller: _searchController,
                onChanged: (_) => deb.debounce(
                  () => setState(() {
                    _tarefaAtual = _obterLivros();
                  }),
                ),
              ),
            ),
            FutureBuilder(
              future: _tarefaAtual,
              builder: (context, snapshot) {
                if (_tarefaAtual == null) {
                  return const SizedBox.shrink();
                }
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Text('Loading...');
                }

                final data = snapshot.data;

                if (data == null) {
                  return const SizedBox.shrink();
                }

                return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      border: Border.all(color: AppColors.borderHairline),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final b in data.where((b) => !_lista.contains(b)))
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
                  );
              },
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
                      opacity: book.exemplaresCount == 0 ? 0.6 : 1,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _abrirDetalhes(book),
                              child: BookRow(
                                book: book,
                                coverWidth: book.exemplaresCount == 0 ? 48 : 72,
                                metaLine: book.exemplaresCount == 0
                                    ? 'NINGUÉM TEM AINDA — AVISAMOS QUANDO APARECER'
                                    : '${book.exemplares} EXEMPLARES · ${book.frete}',
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
                    onPressed: _salvar,
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
