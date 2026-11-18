import 'package:flutter/material.dart';
import 'package:rodape/data/legal_texts.dart';
import 'package:rodape/helpers/auth_helper.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/rodape_header.dart';
import 'legal_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _sair(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair da conta?'),
        content: const Text('Você vai precisar entrar de novo com o seu telefone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    await AuthHelper.logout();
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true)
        .pushNamedAndRemoveUntil('/', (route) => false);
  }

  void _abrir(BuildContext context, String titulo, List<(String, String)> secoes) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LegalScreen(title: titulo, sections: secoes)),
    );
  }

  Widget _item({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.borderHairline)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color ?? AppColors.ink700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.sans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: color ?? AppColors.ink900,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: AppColors.paperGray500),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper100,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            RodapeHeader(
              title: 'Configurações',
              eyebrow: 'Conta',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            _item(
              icon: Icons.description_outlined,
              label: 'Termos de uso',
              onTap: () => _abrir(context, 'Termos de uso', LegalTexts.termos),
            ),
            _item(
              icon: Icons.privacy_tip_outlined,
              label: 'Política de privacidade',
              onTap: () => _abrir(context, 'Política de privacidade', LegalTexts.privacidade),
            ),
            _item(
              icon: Icons.logout,
              label: 'Sair da conta',
              color: AppColors.stampRed600,
              onTap: () => _sair(context),
            ),
          ],
        ),
      ),
    );
  }
}