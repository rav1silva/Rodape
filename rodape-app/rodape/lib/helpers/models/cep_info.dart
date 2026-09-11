/// Resultado simulado de uma busca de CEP: endereço aproximado e a
/// densidade de exemplares em circulação perto dali.
class CepInfo {
  const CepInfo({
    required this.cep,
    required this.endereco,
    required this.cidade,
    required this.exemplaresPerto,
    required this.distanciaKm,
  });

  final String cep;
  final String endereco;
  final String cidade;
  final int exemplaresPerto;
  final double distanciaKm;

  String get enderecoLabel => '$endereco · $cidade';

  String get densidadeLabel =>
      '$exemplaresPerto exemplares em ${distanciaKm.toStringAsFixed(0)} km';
}
