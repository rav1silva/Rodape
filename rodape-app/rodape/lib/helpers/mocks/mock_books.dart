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
    descricao: 'Duas irmãs crescem numa fazenda no sertão baiano, marcadas por um segredo de infância que volta a assombrar a família anos depois.',
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
    descricao: 'A decadência da família Compson no sul dos Estados Unidos, narrada em quatro vozes distintas que misturam tempo e memória.',
  );

  static const vidasSecas = Book(
    id: 'vidas-secas',
    titulo: 'Vidas secas',
    autor: 'Graciliano Ramos',
    spineColor: AppColors.spineOlive,
    maos: 3,
    status: BookStatus.disponivel,
    exemplares: 5,
    descricao: 'Uma família de retirantes atravessa a seca no sertão nordestino em busca de sobrevivência e um lugar para chamar de seu.',
  );

  static const oCortico = Book(
    id: 'o-cortico',
    titulo: 'O cortiço',
    autor: 'Aluísio Azevedo',
    spineColor: AppColors.spineOrange,
    maos: 2,
    status: BookStatus.reservado,
    exemplares: 1,
    descricao: 'O cotidiano de um cortiço no Rio de Janeiro do século XIX, retrato cru de ambição, desejo e disputa social.',
  );

  static const horaDaEstrela = Book(
    id: 'a-hora-da-estrela',
    titulo: 'A hora da estrela',
    autor: 'Clarice Lispector',
    spineColor: AppColors.spineWine,
    maos: 5,
    status: BookStatus.caminho,
    exemplares: 1,
    descricao: 'Macabéa, uma nordestina pobre e quase invisível no Rio de Janeiro, ganha voz numa narrativa sobre existência e indiferença.',
  );

  static const quartoDeDespejo = Book(
    id: 'quarto-de-despejo',
    titulo: 'Quarto de despejo',
    autor: 'Carolina Maria de Jesus',
    spineColor: AppColors.spineTeal,
    maos: 7,
    status: BookStatus.entregue,
    exemplares: 1,
    descricao: 'O diário de uma catadora de papel que registra, com crueza, a fome e a vida numa favela de São Paulo nos anos 1950.',
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
    descricao: 'O jagunço Riobaldo relembra sua vida no sertão, entre pactos, amores e a dúvida que o persegue: existe ou não o demônio?',
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
    descricao: 'Relato histórico e literário da Guerra de Canudos, entre a terra, o clima e o povo que resistiu ao Exército brasileiro.',
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
    descricao: 'Uma mulher tem uma crise existencial ao encontrar uma barata no quarto de empregada de seu apartamento.',
  );

  static const estorvo = Book(
    id: 'estorvo',
    titulo: 'Estorvo',
    autor: 'Chico Buarque',
    spineColor: AppColors.paper300,
    maos: 0,
    status: BookStatus.disponivel,
    exemplares: 0,
    descricao: 'Um homem é perseguido — ou acredita ser — numa narrativa que confunde realidade e paranoia do início ao fim.',
  );

  static const memoriasPostumas = Book(
    id: 'memorias-postumas',
    titulo: 'Memórias póstumas',
    autor: 'Machado de Assis',
    spineColor: AppColors.spineOlive,
    maos: 7,
    status: BookStatus.entregue,
    exemplares: 0,
    descricao: 'Brás Cubas narra a própria vida já morto, com ironia e digressões sobre amor, vaidade e o sentido de tudo.',
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
