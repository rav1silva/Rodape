
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:rodape/services/auth_service.dart';
import 'package:rodape/services/exemplar_service.dart';
import 'package:rodape/services/livro_service.dart';

class IsbnScannerScreen extends StatefulWidget {
  const IsbnScannerScreen({super.key});

  @override
  State<IsbnScannerScreen> createState() => _IsbnScannerScreenState();
}

class _IsbnScannerScreenState extends State<IsbnScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();

  bool _processando = false;
  String _mensagem = 'Aponte a câmera para o código de barras do livro.';

  Future<void> _aoDetectar(BarcodeCapture captura) async {
    if (_processando) return;

    String? codigo;

    for (final barcode in captura.barcodes) {
      final valor = barcode.rawValue;
	debugPrint('[SCANNER] Formato: ${barcode.format}');
	debugPrint('[SCANNER] Valor: $valor');
      if (valor == null) continue;

      final normalizado = valor.replaceAll(RegExp(r'\D'), '');

      if (normalizado.length == 13 &&
          (normalizado.startsWith('978') ||
              normalizado.startsWith('979'))) {
        codigo = normalizado;
        break;
      }
    }

    if (codigo == null) return;

    setState(() {
      _processando = true;
      _mensagem = 'Consultando informações do livro...';
    });

    await _controller.stop();

    try {
      final donoId = AuthService.loggedUser?.id;

      if (donoId == null || donoId.isEmpty) {
        throw Exception('Não foi possível identificar o usuário logado.');
      }

      // Procura o livro pelo ISBN ou cadastra seus dados no catálogo.
      final livro = await LivroService.obterOuCadastrarPorIsbn(codigo);

      // Cada cadastro cria um exemplar próprio para o usuário.
      await ExemplarService.cadastrarExemplar(
        livroId: livro.id,
        donoId: donoId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${livro.titulo}" foi adicionado à sua estante.'),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _processando = false;
        _mensagem = 'Não foi possível cadastrar esse livro. Tente novamente.';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao cadastrar livro: $e'),
          duration: const Duration(seconds: 5),
        ),
      );

      await _controller.start();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final desktop = defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.windows;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear livro'),
      ),
      body: desktop
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'O scanner precisa ser testado em um dispositivo '
                  'Android ou iOS com câmera compatível.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      MobileScanner(
                        controller: _controller,
                        onDetect: _aoDetectar,
                      ),
                      Center(
                        child: Container(
                          width: 280,
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      if (_processando)
                        Container(
                          color: Colors.black54,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        _mensagem,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Enquadre o código ISBN na área indicada.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
