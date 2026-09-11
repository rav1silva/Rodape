import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Estilos de texto do Rodapé.
///
/// Três famílias, cada uma com um papel fixo no layout:
/// - `display` (Saira Condensed): títulos grandes, em caixa alta.
/// - `sans` (IBM Plex Sans): corpo de texto e labels de produto.
/// - `mono` (IBM Plex Mono): dados (preço, distância, contagem) e eyebrows
///   em caixa alta com letter-spacing largo.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle display({
    double fontSize = 26,
    FontWeight fontWeight = FontWeight.w800,
    Color color = AppColors.ink900,
    double height = 0.98,
  }) {
    return GoogleFonts.sairaCondensed(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: 0.3,
    );
  }

  static TextStyle sans({
    double fontSize = 15,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.ink900,
    double height = 1.35,
  }) {
    return GoogleFonts.ibmPlexSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  static TextStyle mono({
    double fontSize = 11,
    FontWeight fontWeight = FontWeight.w500,
    Color color = AppColors.ink900,
    double letterSpacing = 1.4,
    bool uppercase = true,
  }) {
    return GoogleFonts.ibmPlexMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  /// Eyebrow: label pequeno mono, maiúsculo, com letter-spacing largo —
  /// usado acima de títulos em quase toda tela.
  static TextStyle eyebrow({Color color = AppColors.textFaint}) {
    return mono(fontSize: 10, letterSpacing: 1.6, color: color);
  }
}
