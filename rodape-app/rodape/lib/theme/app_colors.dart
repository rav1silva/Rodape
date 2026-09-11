import 'package:flutter/material.dart';

/// Paleta extraída do layout oficial ("Rodapé - Telas do App v2").
///
/// A identidade visual é de livraria, não de biblioteca: fundo de madeira
/// escura, papel claro e cor vinda das "lombadas" dos livros (laranja,
/// mostarda, oliva, teal e vinho).
class AppColors {
  AppColors._();

  // Tinta / texto
  static const ink900 = Color(0xFF141B22);
  static const ink800 = Color(0xFF1C2530);
  static const ink700 = Color(0xFF26313D);
  static const ink600 = Color(0xFF374553);

  // Papel
  static const paper050 = Color(0xFFFDFAF0);
  static const paper100 = Color(0xFFF5F1E6);
  static const paper200 = Color(0xFFEAE4D5);
  static const paper300 = Color(0xFFDDD6C4);
  static const paperGray400 = Color(0xFFB9B0A0);
  static const paperGray500 = Color(0xFF8C8478);
  static const paperGray600 = Color(0xFF6B655C);

  // Madeira (cabeçalhos, nav inferior)
  static const wood800 = Color(0xFF3E2C21);
  static const wood700 = Color(0xFF54392A);
  static const wood600 = Color(0xFF6B4B34);
  static const wood400 = Color(0xFF96745A);

  // Lombadas dos livros
  static const spineOrange = Color(0xFFE3572B);
  static const spineMustard = Color(0xFFD9A521);
  static const spineOlive = Color(0xFF5C6B3A);
  static const spineTeal = Color(0xFF1F6F6B);
  static const spineWine = Color(0xFF8C2F39);

  static const spines = <Color>[
    spineOrange,
    spineMustard,
    spineOlive,
    spineTeal,
    spineWine,
  ];

  // Carimbo de circulação — azul até a 4ª mão, vermelho da 5ª em diante.
  static const stampBlue700 = Color(0xFF22343F);
  static const stampBlue600 = Color(0xFF2E4756);
  static const stampBlue400 = Color(0xFF4E6E80);
  static const stampBlue100 = Color(0xFFDCE4E8);

  static const stampRed700 = Color(0xFFA0341F);
  static const stampRed600 = Color(0xFFC8452F);
  static const stampRed400 = Color(0xFFDD7A68);
  static const stampRed100 = Color(0xFFF3DED9);

  static const stampGreen600 = Color(0xFF3F6B4F);
  static const stampGreen100 = Color(0xFFDDE6DE);

  static const stampOchre600 = Color(0xFFA8792B);
  static const stampOchre100 = Color(0xFFF0E5CE);

  // Estado do exemplar (SeloEstado)
  static const stateDisponivel = stampGreen600;
  static const stateDisponivelBg = stampGreen100;
  static const stateReservado = stampOchre600;
  static const stateReservadoBg = stampOchre100;
  static const stateCaminho = stampBlue600;
  static const stateCaminhoBg = stampBlue100;
  static const stateEntregue = paperGray600;
  static const stateEntregueBg = paper200;

  // Superfícies e bordas
  static const surfaceCard = paper050;
  static const surfaceSunken = paper200;
  static const textMuted = paperGray600;
  static const textFaint = paperGray500;
  static const textOnWoodMuted = Color(0xFFC9B7A6);
  static const borderHairline = paper300;
  static const borderData = paperGray400;
  static const borderOnWood = Color(0x42F5F1E6); // rgba(245,241,230,.26)

  static const shadowStamped = ink900;
}
