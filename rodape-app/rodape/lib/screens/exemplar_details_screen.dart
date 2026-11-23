
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:rodape/models/exemplar.dart';
import 'package:rodape/models/livro.dart';
import 'package:rodape/services/auth_service.dart';
import 'package:rodape/services/exemplar_service.dart';

class ExemplarDetailsScreen extends StatefulWidget {
  const ExemplarDetailsScreen({
    super.key,
    required this.book,
    required this.exemplar,
  });

  final Livro book;
  final Exemplar exemplar;

  @override
  State<ExemplarDetailsScreen> createState() =>
      _ExemplarDetailsScreenState();
}

class _ExemplarDetailsScreenState
    extends State<ExemplarDetailsScreen> {
  final _picker = ImagePicker();

  late String _estado;

  List<Map<String, dynamic>> _fotos = [];

  bool _carregando = true;
  bool _salvando = false;

  final List<String> _estados = [
    'novo',
    'muito bom',
    'bom',
    'regular',
    'ruim',
  ];

  String? get _donoId => AuthService.loggedUser?.id;

  @override
  void initState() {
    super.initState();

    _estado = widget.exemplar.estadoDeConservacao.toLowerCase();

    _carregarFotos();
  }

  Future<void> _carregarFotos() async {
    try {
      final fotos = await ExemplarService.obterFotosExemplar(
        widget.exemplar.id,
      );

      if (!mounted) return;

      setState(() {
        _fotos = fotos;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _carregando = false);
      _mensagem('Não foi possível carregar as fotos: $e');
    }
  }

  void _mensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  Future<void> _salvar() async {
    final donoId = _donoId;

    if (donoId == null) {
      _mensagem('Usuário não identificado.');
      return;
    }

    setState(() => _salvando = true);

    try {
      await ExemplarService.atualizarExemplar(
        exemplarId: widget.exemplar.id,
        donoId: donoId,
        estadoDeConservacao: _estado,
      );

      if (!mounted) return;

      _mensagem('Exemplar atualizado com sucesso!');
      Navigator.pop(context, true);
    } catch (e) {
      _mensagem('Erro ao atualizar exemplar: $e');
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  Future<void> _adicionarFoto(ImageSource origem) async {
    final donoId = _donoId;

    if (donoId == null) {
      _mensagem('Usuário não identificado.');
      return;
    }

    try {
      final foto = await _picker.pickImage(
        source: origem,
        imageQuality: 85,
      );

      if (foto == null) return;

      setState(() => _salvando = true);

      await ExemplarService.adicionarFoto(
        exemplarId: widget.exemplar.id,
        donoId: donoId,
        foto: foto,
      );

      await _carregarFotos();

      if (mounted) {
        _mensagem('Foto adicionada!');
      }
    } catch (e) {
      _mensagem('Não foi possível adicionar a foto: $e');
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  Future<void> _excluirFoto(
    Map<String, dynamic> foto,
  ) async {
    final donoId = _donoId;

    if (donoId == null) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir foto'),
        content: const Text(
          'Deseja remover esta foto do exemplar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await ExemplarService.excluirFoto(
        fotoId: foto['id'].toString(),
        exemplarId: widget.exemplar.id,
        donoId: donoId,
      );

      await _carregarFotos();

      if (mounted) {
        _mensagem('Foto removida.');
      }
    } catch (e) {
      _mensagem('Erro ao excluir foto: $e');
    }
  }

  Future<void> _excluirExemplar() async {
    final donoId = _donoId;

    if (donoId == null) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover exemplar'),
        content: const Text(
          'Tem certeza de que deseja remover esta cópia da sua estante? '
          'As fotos vinculadas também serão excluídas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      setState(() => _salvando = true);

      await ExemplarService.excluirExemplar(
        exemplarId: widget.exemplar.id,
        donoId: donoId,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      _mensagem('Erro ao remover exemplar: $e');

      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar exemplar'),
      ),
      body: _salvando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (widget.book.capaUrl != null)
                  Center(
                    child: Image.network(
                      widget.book.capaUrl!,
                      height: 190,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.menu_book, size: 100),
                    ),
                  ),

                const SizedBox(height: 20),

                Text(
                  widget.book.titulo,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),

                const SizedBox(height: 6),

                Text('Autor: ${widget.book.autor}'),

                if (widget.book.isbn != null)
                  Text('ISBN: ${widget.book.isbn}'),

                const Divider(height: 32),

                Text(
                  'Estado de conservação',
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  initialValue: _estado,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: _estados.map((estado) {
                    return DropdownMenuItem(
                      value: estado,
                      child: Text(
                        estado[0].toUpperCase() + estado.substring(1),
                      ),
                    );
                  }).toList(),
                  onChanged: (valor) {
                    if (valor != null) {
                      setState(() => _estado = valor);
                    }
                  },
                ),

                const SizedBox(height: 28),

                Text(
                  'Fotos desta cópia',
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _adicionarFoto(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Galeria'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _adicionarFoto(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text('Câmera'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                if (_carregando)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else if (_fotos.isEmpty)
                  const Text(
                    'Nenhuma foto adicionada a esta cópia.',
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _fotos.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemBuilder: (context, index) {
                      final foto = _fotos[index];

                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            foto['url'],
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                const Icon(Icons.broken_image),
                          ),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: IconButton(
                              onPressed: () => _excluirFoto(foto),
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                const SizedBox(height: 28),

                FilledButton(
                  onPressed: _salvando ? null : _salvar,
                  child: const Text('Salvar alterações'),
                ),

                const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed: _salvando ? null : _excluirExemplar,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Remover da minha estante'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
    );
  }
}
