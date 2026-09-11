import '../../theme/app_colors.dart';
import '../models/book.dart';
import '../models/book_status.dart';
import '../models/delivery_request.dart';

/// Dados simulados de exemplares em circulação na rede do Rodapé.
///
/// Cobrem os mesmos títulos e números usados no layout oficial, para que a
/// UI fique fiel ao design enquanto a API real não está disponível.
class MockBooks {
  MockBooks._();

  static const tortoArado = Book(
    id: 'torto-arado',
    titulo: 'Torto arado',
    autor: 'Itamar Vieira Junior',
    spineColor: AppColors.spineMustard,
    maos: 2,
    estadoConservacao: 'bom',
    status: BookStatus.disponivel,
    exemplares: 4,
    distanciaKm: 0.6,
    freteValor: 12.90,
  );

  static const somEAFuria = Book(
    id: 'som-e-a-furia',
    titulo: 'O som e a fúria',
    autor: 'William Faulkner',
    spineColor: AppColors.spineWine,
    maos: 6,
    estadoConservacao: 'como novo',
    status: BookStatus.disponivel,
    exemplares: 2,
    distanciaKm: 1.4,
    freteValor: 16.90,
  );

  static const vidasSecas = Book(
    id: 'vidas-secas',
    titulo: 'Vidas secas',
    autor: 'Graciliano Ramos',
    spineColor: AppColors.spineOlive,
    maos: 3,
    status: BookStatus.disponivel,
    exemplares: 5,
  );

  static const oCortico = Book(
    id: 'o-cortico',
    titulo: 'O cortiço',
    autor: 'Aluísio Azevedo',
    spineColor: AppColors.spineOrange,
    maos: 2,
    status: BookStatus.reservado,
    exemplares: 1,
  );

  static const horaDaEstrela = Book(
    id: 'a-hora-da-estrela',
    titulo: 'A hora da estrela',
    autor: 'Clarice Lispector',
    spineColor: AppColors.spineWine,
    maos: 5,
    status: BookStatus.caminho,
    exemplares: 1,
  );

  static const quartoDeDespejo = Book(
    id: 'quarto-de-despejo',
    titulo: 'Quarto de despejo',
    autor: 'Carolina Maria de Jesus',
    spineColor: AppColors.spineTeal,
    maos: 7,
    status: BookStatus.entregue,
    exemplares: 1,
  );

  static const grandeSertao = Book(
    id: 'grande-sertao',
    titulo: 'Grande sertão: veredas',
    autor: 'João Guimarães Rosa',
    spineColor: AppColors.spineOrange,
    maos: 1,
    status: BookStatus.disponivel,
    exemplares: 1,
    distanciaKm: 0.9,
  );

  static const osSertoes = Book(
    id: 'os-sertoes',
    titulo: 'Os sertões',
    autor: 'Euclides da Cunha',
    spineColor: AppColors.spineOrange,
    maos: 1,
    status: BookStatus.disponivel,
    exemplares: 3,
    distanciaKm: 3.1,
    freteValor: 22.90,
  );

  static const paixaoSegundoGH = Book(
    id: 'a-paixao-segundo-gh',
    titulo: 'A paixão segundo G.H.',
    autor: 'Clarice Lispector',
    spineColor: AppColors.spineOlive,
    maos: 4,
    status: BookStatus.disponivel,
    exemplares: 1,
    distanciaKm: 2.8,
    freteValor: 19.90,
  );

  static const estorvo = Book(
    id: 'estorvo',
    titulo: 'Estorvo',
    autor: 'Chico Buarque',
    spineColor: AppColors.paper300,
    maos: 0,
    status: BookStatus.disponivel,
    exemplares: 0,
  );

  static const memoriasPostumas = Book(
    id: 'memorias-postumas',
    titulo: 'Memórias póstumas',
    autor: 'Machado de Assis',
    spineColor: AppColors.spineOlive,
    maos: 7,
    status: BookStatus.entregue,
    exemplares: 0,
  );

  /// Todo o catálogo simulado.
  static const List<Book> all = [
    tortoArado,
    somEAFuria,
    vidasSecas,
    oCortico,
    horaDaEstrela,
    quartoDeDespejo,
    grandeSertao,
    osSertoes,
    paixaoSegundoGH,
    estorvo,
    memoriasPostumas,
  ];

  /// "Minha estante" — exemplares que o usuário já cadastrou.
  static const List<Book> minhaEstante = [
    vidasSecas,
    oCortico,
    horaDaEstrela,
    quartoDeDespejo,
  ];

  /// "Perto de você" — exemplares de terceiros próximos ao usuário.
  static const List<Book> perto = [tortoArado, somEAFuria];

  /// "Lista de desejos" — títulos que o usuário quer, em ordem de
  /// prioridade.
  static const List<Book> listaDeDesejos = [
    tortoArado,
    somEAFuria,
    paixaoSegundoGH,
    osSertoes,
    estorvo,
  ];

  /// Card "Sua próxima ação" da Home: alguém pediu um livro seu.
  static const proximaAcao = DeliveryRequest(
    solicitante: 'Marina S.',
    book: grandeSertao,
    distanciaKm: 0.9,
    nota: 'Frete por conta dela',
  );
}
