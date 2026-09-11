import 'package:flutter/material.dart';

import '../helpers/models/book.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'carimbo_stamp.dart';

/// Capa de um exemplar. Sem imagem real, a cor da lombada é o
/// protagonista — cada capa é um "slot" colorido com o título.
///
/// Quando [showStamp] é true, o carimbo de circulação ([book.maos]) fica
/// ancorado no canto inferior esquerdo, sobrepondo a capa.
class BookCover extends StatelessWidget {
  const BookCover({
    super.key,
    required this.book,
    this.width = 84,
    this.height,
    this.showStamp = true,
    this.stampCompact = true,
  });

  final Book book;
  final double width;
  final double? height;
  final bool showStamp;
  final bool stampCompact;

  @override
  Widget build(BuildContext context) {
    final h = height ?? width * 1.5;
    final cover = Container(
      width: width,
      height: h,
      padding: const EdgeInsets.all(6),
      alignment: Alignment.bottomLeft,
      decoration: BoxDecoration(
        color: book.spineColor,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: AppColors.wood800, width: 1),
      ),
      child: Text(
        book.titulo,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.display(
          fontSize: width * 0.16,
          color: AppColors.paper050,
          height: 0.95,
        ),
      ),
    );

    if (!showStamp) return cover;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        cover,
        Positioned(
          bottom: -7,
          left: -8,
          child: CarimboStamp(maos: book.maos, compact: stampCompact),
        ),
      ],
    );
  }
}
