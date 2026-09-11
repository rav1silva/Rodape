import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

enum RodapeButtonVariant { primary, accent, quiet }

enum RodapeButtonSize { sm, md, lg }

/// Botão do design system Rodapé, com as três variantes e três tamanhos
/// usados no layout.
class RodapeButton extends StatelessWidget {
  const RodapeButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = RodapeButtonVariant.primary,
    this.size = RodapeButtonSize.md,
    this.icon,
    this.block = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final RodapeButtonVariant variant;
  final RodapeButtonSize size;
  final IconData? icon;

  /// Ocupa toda a largura disponível quando true (padrão no layout).
  final bool block;

  double get _height => switch (size) {
    RodapeButtonSize.sm => 34,
    RodapeButtonSize.md => 44,
    RodapeButtonSize.lg => 52,
  };

  double get _fontSize => switch (size) {
    RodapeButtonSize.sm => 13,
    RodapeButtonSize.md => 14,
    RodapeButtonSize.lg => 15,
  };

  @override
  Widget build(BuildContext context) {
    final Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: _fontSize + 3),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: GoogleFonts.ibmPlexSans(
            fontSize: _fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    final button = switch (variant) {
      RodapeButtonVariant.primary => FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.wood800,
          foregroundColor: AppColors.paper050,
          minimumSize: Size(block ? double.infinity : 0, _height),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: child,
      ),
      RodapeButtonVariant.accent => FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.spineMustard,
          foregroundColor: AppColors.wood800,
          minimumSize: Size(block ? double.infinity : 0, _height),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: child,
      ),
      RodapeButtonVariant.quiet => OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink800,
          side: const BorderSide(color: AppColors.borderHairline),
          minimumSize: Size(block ? double.infinity : 0, _height),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: child,
      ),
    };

    return block ? SizedBox(width: double.infinity, child: button) : button;
  }
}
