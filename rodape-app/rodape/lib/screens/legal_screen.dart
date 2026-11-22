import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/rodape_button.dart';
import '../widgets/rodape_header.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({
    super.key,
    required this.title,
    required this.sections,
    this.mostrarAceite = false,
  });

  final String title;
  final List<(String, String)> sections;
  final bool mostrarAceite;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper100,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            RodapeHeader(
              title: title,
              eyebrow: 'Atualizado em novembro de 2026',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  for (final (titulo, texto) in sections) ...[
                    Text(
                      titulo.toUpperCase(),
                      style: AppTextStyles.mono(
                        fontSize: 10,
                        color: AppColors.paperGray500,
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      texto,
                      style: AppTextStyles.sans(
                        fontSize: 14,
                        color: AppColors.ink700,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
            if (mostrarAceite)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceCard,
                  border: Border(
                    top: BorderSide(color: AppColors.borderHairline),
                  ),
                ),
                child: Column(
                  children: [
                    RodapeButton(
                      label: 'Aceitar',
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Não aceitar'),
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
