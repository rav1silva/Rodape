import 'package:flutter/material.dart';
import 'package:rodape/models/livro.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

import 'package:collection/collection.dart';

import 'carimbo_stamp.dart';

/// Capa de um exemplar. Usa [Book.coverAsset] quando existe; sem imagem (ou
/// se o asset falhar ao carregar), a cor da lombada vira o placeholder
/// um "slot" colorido com o título.
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

  final Livro book;
  final double width;
  final double? height;
  final bool showStamp;
  final bool stampCompact;

  @override
  Widget build(BuildContext context) {
    final h = height ?? width * 1.5;
    final placeholder = Container(
      padding: const EdgeInsets.all(6),
      alignment: Alignment.bottomLeft,
      color: book.corLombada != null
          ? Color(int.parse(book.corLombada!))
          : null,
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

    final cover = Container(
      width: width,
      height: h,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: book.corLombada != null
            ? Color(int.parse(book.corLombada!))
            : null,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: AppColors.wood800, width: 1),
      ),
      child: book.capaUrl == null
          ? placeholder
          : Image.network(
              book.capaUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => placeholder,
            ),
    );

    if (!showStamp) return cover;

    final minMaos = minBy(book.exemplares ?? [], (e) => e.maos)?.maos;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        cover,
        Positioned(
          bottom: -7,
          left: -8,
          child: CarimboStamp(maos: minMaos ?? 0, compact: stampCompact),
        ),
      ],
    );
  }
}
