
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
  final TextEditingController _isbnController = TextEditingController();

  bool _processando = false;
  bool _scannerAtivo = false;
  String _mensagem = 'Aponte a câmera para o código de barras do livro.';

  bool get _desktop =>
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.windows;

  Future<void> _cadastrarLivro(String isbn) async {
    if (_processando) return;

    final codigo = isbn.replaceAll(RegExp(r'\D'), '');

    if (codigo.length != 13 ||
        (!codigo.startsWith('978') && !codigo.startsWith('979'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite um ISBN-13 válido, com 13 números.'),
        ),
      );
      return;
    }

    setState(() {
      _processando = true;
      _mensagem = 'Consultando informações do livro...';
    });

    if (_scannerAtivo) {
      await _controller.stop();
      _scannerAtivo = false;
    }

    try {
      final donoId = AuthService.loggedUser?.id;

      if (donoId == null || donoId.isEmpty) {
        throw Exception('Não foi possível identificar o usuário logado.');
      }

      // Procura o livro no catálogo ou consulta o Google Books.
      final livro = await LivroService.obterOuCadastrarPorIsbn(codigo);

      // Cria um exemplar individual para o usuário.
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

      if (!_desktop) {
        try {
          await _controller.start();
          _scannerAtivo = true;
        } catch (_) {}
      }
    }
  }

  Future<void> _aoDetectar(BarcodeCapture captura) async {
    if (_processando) return;

    for (final barcode in captura.barcodes) {
      final valor = barcode.rawValue;
      debugPrint('[SCANNER] Formato: ${barcode.format}');
      debugPrint('[SCANNER] Valor: $valor');

      if (valor == null) continue;

      final normalizado = valor.replaceAll(RegExp(r'\D'), '');

      if (normalizado.length == 13 &&
          (normalizado.startsWith('978') ||
              normalizado.startsWith('979'))) {
        await _cadastrarLivro(normalizado);
        return;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _isbnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar livro'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (!_desktop)
                SizedBox(
                  height: 350,
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _desktop
                          ? 'Não é possível utilizar o scanner nesta plataforma.'
                          : 'Enquadre o código ISBN na área indicada.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      _mensagem,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 24),

                    const Divider(),

                    const SizedBox(height: 16),

                    const Text(
                      'Não conseguiu escanear?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Digite manualmente os 13 números do ISBN '
                      'que aparecem no código de barras do livro.',
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: _isbnController,
                      enabled: !_processando,
                      keyboardType: TextInputType.number,
                      maxLength: 13,
                      decoration: const InputDecoration(
                        labelText: 'ISBN-13',
                        hintText: 'Ex.: 9788535902778',
                        border: OutlineInputBorder(),
                        counterText: '',
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _processando
                            ? null
                            : () => _cadastrarLivro(_isbnController.text),
                        child: _processando
                            ? const CircularProgressIndicator()
                            : const Text('Buscar livro'),
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'O livro será procurado no catálogo. '
                      'Se não estiver cadastrado, tentaremos buscar '
                      'suas informações automaticamente.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
