import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Chip de filtro horizontal (ex.: "Só minha lista", "Até 3 km"), com
/// contagem opcional.
class FilterChipPill extends StatelessWidget {
  const FilterChipPill({
    super.key,
    required this.label,
    this.active = false,
    this.count,
    this.onTap,
  });

  final String label;
  final bool active;
  final int? count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.wood800 : AppColors.surfaceCard,
          border: Border.all(
            color: active ? AppColors.wood800 : AppColors.borderHairline,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          count == null ? label : '$label ($count)',
          style: AppTextStyles.sans(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: active ? AppColors.paper050 : AppColors.ink700,
          ),
        ),
      ),
    );
  }
}
