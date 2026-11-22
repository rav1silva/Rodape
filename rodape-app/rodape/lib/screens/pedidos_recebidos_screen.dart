
import 'package:flutter/material.dart';
import 'package:rodape/models/pedido.dart';
import 'package:rodape/services/auth_service.dart';
import 'package:rodape/services/pedido_service.dart';
import 'package:rodape/widgets/book_cover.dart';

class PedidosRecebidosScreen extends StatefulWidget {
  const PedidosRecebidosScreen({super.key});

  @override
  State<PedidosRecebidosScreen> createState() =>
      _PedidosRecebidosScreenState();
}

class _PedidosRecebidosScreenState
    extends State<PedidosRecebidosScreen> {
  late Future<List<Pedido>> _pedidosFuture;

  final Set<String> _processando = {};

  static const Color _fundo = Color(0xFFF5F0E7);
  static const Color _marrom = Color(0xFF604633);
  static const Color _texto = Color(0xFF39312A);

  @override
  void initState() {
    super.initState();
    _carregarPedidos();
  }

  void _carregarPedidos() {
    final user = AuthService.loggedUser;

    _pedidosFuture = user == null
        ? Future.value([])
        : PedidoService.pedidosRecebidos(user);
  }

  Future<void> _atualizar() async {
    setState(_carregarPedidos);
    await _pedidosFuture;
  }

  void _mensagem(String texto) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  Future<void> _executarAcao(
    Pedido pedido,
    PedidoStatus novoStatus,
  ) async {
    final user = AuthService.loggedUser;

    if (user == null || user.id == null) {
      _mensagem('Faça login novamente para continuar.');
      return;
    }

    if (_processando.contains(pedido.id)) return;

    setState(() {
      _processando.add(pedido.id);
    });

    try {
      await PedidoService.avancar(pedido, user, novoStatus);

      if (!mounted) return;

      _mensagem(
        novoStatus == PedidoStatus.aceito
            ? 'Pedido aceito com sucesso!'
            : 'Livro marcado como a caminho!',
      );

      await _atualizar();
    } catch (e) {
      _mensagem('Não foi possível atualizar o pedido: $e');
    } finally {
      if (mounted) {
        setState(() {
          _processando.remove(pedido.id);
        });
      }
    }
  }

  Future<void> _recusarPedido(Pedido pedido) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recusar pedido?'),
        content: const Text(
          'O pedido será cancelado e os créditos reservados '
          'serão devolvidos ao comprador.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Voltar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Recusar pedido'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    final user = AuthService.loggedUser;

    if (user == null || user.id == null) {
      _mensagem('Faça login novamente para continuar.');
      return;
    }

    if (_processando.contains(pedido.id)) return;

    setState(() {
      _processando.add(pedido.id);
    });

    try {
      await PedidoService.cancelar(pedido, user);

      if (!mounted) return;

      _mensagem('Pedido recusado. Créditos devolvidos ao comprador.');

      await _atualizar();
    } catch (e) {
      _mensagem('Não foi possível recusar o pedido: $e');
    } finally {
      if (mounted) {
        setState(() {
          _processando.remove(pedido.id);
        });
      }
    }
  }

  String _formatarFrete(double? valor) {
    return 'R\$ ${(valor ?? 0).toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _formatarData(DateTime? data) {
    if (data == null) return 'Não definida';

    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');

    return '$dia/$mes/${data.year}';
  }

  Widget _informacao({
    required IconData icone,
    required String titulo,
    required String valor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _fundo,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icone, color: _marrom, size: 19),
            const SizedBox(height: 7),
            Text(
              titulo,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              valor,
              style: const TextStyle(
                color: _texto,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _status(Pedido pedido) {
    final pendente = pedido.status == PedidoStatus.pendente;
    final aCaminho = pedido.status == PedidoStatus.aCaminho;

    final cor = pendente
        ? const Color(0xFF9A6B20)
        : aCaminho
            ? Colors.blue.shade800
            : _marrom;

    final fundo = pendente
        ? const Color(0xFFFFF0CE)
        : aCaminho
            ? Colors.blue.shade50
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            pendente
                ? Icons.schedule
                : aCaminho
                    ? Icons.local_shipping_outlined
                    : Icons.bookmark_outline,
            color: cor,
            size: 15,
          ),
          const SizedBox(width: 6),
          Text(
            pedido.status.valor.replaceAll('_', ' '),
            style: TextStyle(
              color: cor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _acoesPedido(Pedido pedido) {
    final carregando = _processando.contains(pedido.id);

    if (pedido.status == PedidoStatus.pendente) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: carregando
                  ? null
                  : () => _recusarPedido(pedido),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
              ),
              child: const Text('Recusar'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: carregando
                  ? null
                  : () => _executarAcao(
                        pedido,
                        PedidoStatus.aceito,
                      ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _marrom,
                foregroundColor: Colors.white,
              ),
              child: const Text('Aceitar'),
            ),
          ),
        ],
      );
    }

    if (pedido.status == PedidoStatus.aceito) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: carregando
              ? null
              : () => _executarAcao(
                    pedido,
                    PedidoStatus.aCaminho,
                  ),
          icon: const Icon(Icons.local_shipping_outlined),
          label: const Text('Marcar como enviado'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _marrom,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 13),
          ),
        ),
      );
    }

    if (pedido.status == PedidoStatus.aCaminho) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF1F8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.event_outlined,
              color: Colors.blueGrey,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                'Previsão de entrega: ${_formatarData(pedido.previsaoEntrega)}',
                style: const TextStyle(
                  color: _texto,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _cartaoPedido(Pedido pedido) {
    final livro = pedido.livro;
    final solicitante = pedido.solicitante;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8DED0)),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                    decoration: BoxDecoration(
                      color: _fundo,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.menu_book,
                      size: 35,
                      color: _marrom,
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
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            size: 17,
                            color: _marrom,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              solicitante?.nome ?? 'Usuário',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Divider(color: Color(0xFFECE5DB)),
            const SizedBox(height: 10),
            Row(
              children: [
                _informacao(
                  icone: Icons.auto_awesome,
                  titulo: 'Créditos',
                  valor: '${pedido.exemplar?.creditos ?? 0}',
                ),
                const SizedBox(width: 10),
                _informacao(
                  icone: Icons.local_shipping_outlined,
                  titulo: 'Frete',
                  valor: _formatarFrete(pedido.frete),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _acoesPedido(pedido),
            if (carregandoPlaceholder(pedido)) ...[
              const SizedBox(height: 10),
              const LinearProgressIndicator(color: _marrom),
            ],
          ],
        ),
      ),
    );
  }

  bool carregandoPlaceholder(Pedido pedido) {
    return _processando.contains(pedido.id);
  }

  Widget _estadoVazio() {
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
            'Nenhum pedido por enquanto',
            style: TextStyle(
              color: _texto,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 35),
          child: Text(
            'Quando alguém solicitar um dos seus livros, '
            'o pedido aparecerá aqui.',
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
          'Pedidos recebidos',
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
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 45,
                      color: _marrom,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Não foi possível carregar os pedidos.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: _atualizar,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          final pedidos = snapshot.data ?? [];

          return RefreshIndicator(
            color: _marrom,
            onRefresh: _atualizar,
            child: pedidos.isEmpty
                ? _estadoVazio()
                : ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _marrom,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.inbox_outlined,
                              color: Colors.white,
                              size: 30,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Sua estante está em movimento!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${pedidos.length} '
                                    '${pedidos.length == 1 ? 'pedido recebido' : 'pedidos recebidos'}',
                                    style: const TextStyle(
                                      color: Color(0xFFE8D8C2),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Solicitações',
                        style: TextStyle(
                          color: _texto,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...pedidos.map(
                        (pedido) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _cartaoPedido(pedido),
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
