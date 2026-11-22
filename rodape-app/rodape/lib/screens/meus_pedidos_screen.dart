
import 'package:flutter/material.dart';
import 'package:rodape/models/pedido.dart';
import 'package:rodape/services/auth_service.dart';
import 'package:rodape/services/pedido_service.dart';
import 'package:rodape/widgets/book_cover.dart';

class MeusPedidosScreen extends StatefulWidget {
  const MeusPedidosScreen({super.key});

  @override
  State<MeusPedidosScreen> createState() => _MeusPedidosScreenState();
}

class _MeusPedidosScreenState extends State<MeusPedidosScreen> {
  late Future<List<Pedido>> _pedidosFuture;
  final Set<String> _processando = {};

  static const Color _fundo = Color(0xFFF5F0E7);
  static const Color _marrom = Color(0xFF604633);
  static const Color _texto = Color(0xFF39312A);

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    final user = AuthService.loggedUser;
    _pedidosFuture = user == null
        ? Future.value([])
        : PedidoService.meusPedidos(user);
  }

  Future<void> _atualizar() async {
    setState(_carregar);
    await _pedidosFuture;
  }

  void _mensagem(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  Future<bool> _confirmar({
    required String titulo,
    required String mensagem,
    required String acao,
  }) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Voltar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _marrom,
              foregroundColor: Colors.white,
            ),
            child: Text(acao),
          ),
        ],
      ),
    );

    return resultado == true;
  }

  Future<void> _cancelar(Pedido pedido) async {
    final confirmar = await _confirmar(
      titulo: 'Cancelar pedido?',
      mensagem:
          'O pedido será cancelado e os créditos reservados '
          'serão devolvidos ao seu saldo.',
      acao: 'Cancelar pedido',
    );

    if (!confirmar || !mounted) return;

    final user = AuthService.loggedUser;

    if (user == null || user.id == null) {
      _mensagem('Faça login novamente para continuar.');
      return;
    }

    if (_processando.contains(pedido.id)) return;

    setState(() => _processando.add(pedido.id));

    try {
      await PedidoService.cancelar(pedido, user);

      if (!mounted) return;

      _mensagem('Pedido cancelado. Créditos devolvidos.');
      await _atualizar();
    } catch (e) {
      _mensagem('Não foi possível cancelar o pedido: $e');
    } finally {
      if (mounted) {
        setState(() => _processando.remove(pedido.id));
      }
    }
  }

  Future<void> _confirmarRecebimento(Pedido pedido) async {
    final confirmar = await _confirmar(
      titulo: 'Confirmar recebimento?',
      mensagem:
          'Confirme somente se você já recebeu o livro. '
          'Após a confirmação, os créditos serão transferidos '
          'para o dono do exemplar.',
      acao: 'Confirmar recebimento',
    );

    if (!confirmar || !mounted) return;

    final user = AuthService.loggedUser;

    if (user == null || user.id == null) {
      _mensagem('Faça login novamente para continuar.');
      return;
    }

    if (_processando.contains(pedido.id)) return;

    setState(() => _processando.add(pedido.id));

    try {
      await PedidoService.avancar(
        pedido,
        user,
        PedidoStatus.entregue,
      );

      if (!mounted) return;

      _mensagem('Recebimento confirmado com sucesso!');
      await _atualizar();
    } catch (e) {
      _mensagem('Não foi possível confirmar o recebimento: $e');
    } finally {
      if (mounted) {
        setState(() => _processando.remove(pedido.id));
      }
    }
  }

  String _data(DateTime? data) {
    if (data == null) return 'Não definida';

    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');

    return '$dia/$mes/${data.year}';
  }

  Widget _status(Pedido pedido) {
    final pendente = pedido.status == PedidoStatus.pendente;
    final caminho = pedido.status == PedidoStatus.aCaminho;
    final entregue = pedido.status == PedidoStatus.entregue;
    final cancelado = pedido.status == PedidoStatus.cancelado;

    final cor = pendente
        ? const Color(0xFF9A6B20)
        : caminho
            ? Colors.blue.shade800
            : entregue
                ? Colors.green.shade800
                : cancelado
                    ? Colors.red.shade700
                    : _marrom;

    final fundo = pendente
        ? const Color(0xFFFFF0CE)
        : caminho
            ? Colors.blue.shade50
            : entregue
                ? Colors.green.shade50
                : cancelado
                    ? Colors.red.shade50
                    : const Color(0xFFECE5DB);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        pedido.status.valor.replaceAll('_', ' '),
        style: TextStyle(
          color: cor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _acoes(Pedido pedido) {
    final carregando = _processando.contains(pedido.id);

    if (pedido.status == PedidoStatus.pendente) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: carregando ? null : () => _cancelar(pedido),
          icon: const Icon(Icons.cancel_outlined),
          label: const Text('Cancelar pedido'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red.shade700,
          ),
        ),
      );
    }

    if (pedido.status == PedidoStatus.aCaminho) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: carregando
              ? null
              : () => _confirmarRecebimento(pedido),
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Confirmar recebimento'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _marrom,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 13),
          ),
        ),
      );
    }

    if (pedido.status == PedidoStatus.aceito) {
      return const Text(
        'O dono aceitou seu pedido. Aguarde o envio.',
        style: TextStyle(
          color: Colors.black54,
          fontSize: 13,
        ),
      );
    }

    if (pedido.status == PedidoStatus.entregue) {
      return const Text(
        'Livro recebido. Pedido concluído!',
        style: TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    if (pedido.status == PedidoStatus.cancelado) {
      return const Text(
        'Este pedido foi cancelado.',
        style: TextStyle(
          color: Colors.black54,
          fontSize: 13,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _cartao(Pedido pedido) {
    final livro = pedido.livro;
    final carregando = _processando.contains(pedido.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8DED0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (livro != null)
                BookCover(
                  book: livro,
                  width: 76,
                  height: 112,
                  showStamp: false,
                )
              else
                Container(
                  width: 76,
                  height: 112,
                  color: _fundo,
                  child: const Icon(
                    Icons.menu_book,
                    color: _marrom,
                    size: 35,
                  ),
                ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _status(pedido),
                    const SizedBox(height: 10),
                    Text(
                      livro?.titulo ?? 'Livro não identificado',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _texto,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${pedido.exemplar?.creditos ?? 0} créditos',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (pedido.status == PedidoStatus.aCaminho) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF1F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_shipping_outlined,
                    color: Colors.blueGrey,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Previsão de entrega: ${_data(pedido.previsaoEntrega)}',
                      style: const TextStyle(
                        color: _texto,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFECE5DB)),
          const SizedBox(height: 8),
          _acoes(pedido),
          if (carregando) ...[
            const SizedBox(height: 10),
            const LinearProgressIndicator(color: _marrom),
          ],
        ],
      ),
    );
  }

  Widget _vazio() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 110),
        Icon(
          Icons.menu_book_outlined,
          size: 65,
          color: Color(0xFFB7A58F),
        ),
        SizedBox(height: 18),
        Center(
          child: Text(
            'Você ainda não solicitou nenhum livro.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _texto,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 35),
          child: Text(
            'Quando solicitar um exemplar, você poderá '
            'acompanhar o pedido por aqui.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fundo,
      appBar: AppBar(
        backgroundColor: _fundo,
        foregroundColor: _marrom,
        elevation: 0,
        title: const Text(
          'Meus pedidos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: FutureBuilder<List<Pedido>>(
        future: _pedidosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _marrom),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Não foi possível carregar seus pedidos.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _atualizar,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          final pedidos = snapshot.data ?? [];

          return RefreshIndicator(
            color: _marrom,
            onRefresh: _atualizar,
            child: pedidos.isEmpty
                ? _vazio()
                : ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                    children: [
                      Text(
                        '${pedidos.length} '
                        '${pedidos.length == 1 ? 'pedido realizado' : 'pedidos realizados'}',
                        style: const TextStyle(
                          color: _texto,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ...pedidos.map(_cartao),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
