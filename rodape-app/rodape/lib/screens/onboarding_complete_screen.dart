import 'package:flutter/material.dart';

import '../helpers/models/onboarding_args.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/rodape_button.dart';

/// C8 · Seus primeiros livros — tela de conclusão do cadastro.
///
/// Restrição do escopo atual: nenhuma câmera/scanner real é aberta aqui.
/// "Escanear livro" apenas simula a ação (print + snackbar mock) e
/// permanece na tela; "Depois" é quem de fato navega para a Home.
class OnboardingCompleteScreen extends StatelessWidget {
  const OnboardingCompleteScreen({super.key, required this.args});

  final OnboardingCompleteArgs args;

  void _escanearLivroMock(BuildContext context) {
    debugPrint('[MOCK SCANNER] Escanear livro acionado — câmera/leitor de '
        'código de barras ainda não implementados.');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Escaneamento de código de barras — em breve (mock).'),
      ),
    );
  }

  void _irParaHome(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper100,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.wood800,
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'CONTA CRIADA · ${args.nome} ${args.inicial}.',
                    style: AppTextStyles.mono(
                      fontSize: 10,
                      color: AppColors.textOnWoodMuted,
                      letterSpacing: 1.6,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '3 pessoas a 1 km querem livros que podem estar na sua estante',
                    style: AppTextStyles.display(fontSize: 30, color: AppColors.paper050),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var i = 0; i < AppColors.spines.length; i++)
                        Container(
                          width: 26,
                          height: 82.0 + (i * 8 % 40),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: AppColors.spines[i],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Escaneie o código de barras dos livros que você já leu. Cada '
                    'exemplar entra na rede na hora e pode fechar uma roda hoje.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.sans(fontSize: 15, color: AppColors.ink700),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSunken,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'A REGRA DO CRÉDITO',
                          style: AppTextStyles.mono(
                            fontSize: 10,
                            color: AppColors.paperGray600,
                            letterSpacing: 1.6,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Cadastrar não gera crédito. O crédito entra quando você '
                          'entrega para quem pediu o título.',
                          style: AppTextStyles.sans(fontSize: 13, color: AppColors.ink700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              decoration: const BoxDecoration(
                color: AppColors.surfaceCard,
                border: Border(top: BorderSide(color: AppColors.borderHairline)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RodapeButton(
                    label: 'Escanear livro',
                    icon: Icons.qr_code_scanner,
                    onPressed: () => _escanearLivroMock(context),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => _irParaHome(context),
                    child: Text(
                      'Depois',
                      style: AppTextStyles.mono(
                        fontSize: 12,
                        color: AppColors.ink900,
                        letterSpacing: 1,
                      ),
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
