import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/usuario.dart';
import '../controllers/pedido_controller.dart';
import '../controllers/cliente_controller.dart';
import '../controllers/produto_controller.dart';
import '../models/pedido.dart';
import '../models/cliente.dart';
import '../models/produto.dart';
import '../models/pedido_item.dart';
import '../models/pedido_pagamento.dart';

class PedidosScreen extends StatefulWidget {
  final Usuario usuario;

  const PedidosScreen({super.key, required this.usuario});

  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  final PedidoController _pedidoController = PedidoController();
  final ClienteController _clienteController = ClienteController();
  List<Pedido> _pedidos = [];
  Map<int, Cliente> _clientes = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Carregar pedidos
      final pedidos = await _pedidoController.listarTodos();

      // Carregar clientes para exibir nomes
      final clientes = await _clienteController.listarTodos();
      final clientesMap = <int, Cliente>{};
      for (var cliente in clientes) {
        if (cliente.id != null) {
          clientesMap[cliente.id!] = cliente;
        }
      }

      setState(() {
        _pedidos = pedidos;
        _clientes = clientesMap;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar pedidos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _excluirPedido(Pedido pedido) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar Exclusão'),
            content: Text('Deseja realmente excluir o pedido #${pedido.id}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Excluir'),
              ),
            ],
          ),
    );

    if (confirmar == true) {
      try {
        await _pedidoController.deletar(pedido.id!);
        await _carregarDados();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pedido excluído com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir pedido: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _abrirFormulario([Pedido? pedido]) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder:
                (context) =>
                    PedidoFormScreen(usuario: widget.usuario, pedido: pedido),
          ),
        )
        .then((_) => _carregarDados());
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos'),
        backgroundColor: Colors.purple.shade600,
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _pedidos.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Nenhum pedido encontrado',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Clique no botão + para criar um novo pedido',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: _pedidos.length,
                itemBuilder: (context, index) {
                  final pedido = _pedidos[index];
                  final cliente = _clientes[pedido.idCliente];

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.purple.shade600,
                        child: Text(
                          '#${pedido.id}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      title: Text(
                        cliente?.nome ?? 'Cliente não encontrado',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total: R\$ ${pedido.totalPedido.toStringAsFixed(2)}',
                          ),
                          Text('Data: ${_formatarData(pedido.dataCriacao)}'),
                          Text('Usuário: ${widget.usuario.nome}'),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'editar') {
                            _abrirFormulario(pedido);
                          } else if (value == 'excluir') {
                            _excluirPedido(pedido);
                          } else if (value == 'detalhes') {
                            _mostrarDetalhes(pedido);
                          }
                        },
                        itemBuilder:
                            (context) => [
                              const PopupMenuItem(
                                value: 'detalhes',
                                child: Row(
                                  children: [
                                    Icon(Icons.visibility, color: Colors.green),
                                    SizedBox(width: 8),
                                    Text('Detalhes'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'editar',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, color: Colors.blue),
                                    SizedBox(width: 8),
                                    Text('Editar'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'excluir',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Excluir'),
                                  ],
                                ),
                              ),
                            ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        backgroundColor: Colors.purple.shade600,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _mostrarDetalhes(Pedido pedido) async {
    try {
      final itens = await _pedidoController.buscarItensPorPedido(pedido.id!);
      final pagamentos = await _pedidoController.buscarPagamentosPorPedido(
        pedido.id!,
      );
      final cliente = _clientes[pedido.idCliente];

      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Pedido #${pedido.id}'),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Cliente: ${cliente?.nome ?? 'N/A'}'),
                      Text('Data: ${_formatarData(pedido.dataCriacao)}'),
                      Text(
                        'Total: R\$ ${pedido.totalPedido.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 16),
                      Text('Itens (${itens.length}):'),
                      ...itens.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(left: 16, top: 4),
                          child: Text(
                            '• Produto ${item.idProduto}: ${item.quantidade} x R\$ ${item.totalItem.toStringAsFixed(2)}',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Pagamentos (${pagamentos.length}):'),
                      ...pagamentos.map(
                        (pagamento) => Padding(
                          padding: const EdgeInsets.only(left: 16, top: 4),
                          child: Text(
                            '• R\$ ${pagamento.valorPagamento.toStringAsFixed(2)}',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Fechar'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar detalhes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Formulário de Pedidos
class PedidoFormScreen extends StatefulWidget {
  final Usuario usuario;
  final Pedido? pedido;

  const PedidoFormScreen({super.key, required this.usuario, this.pedido});

  @override
  State<PedidoFormScreen> createState() => _PedidoFormScreenState();
}

class _PedidoFormScreenState extends State<PedidoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final PedidoController _pedidoController = PedidoController();
  final ClienteController _clienteController = ClienteController();
  final ProdutoController _produtoController = ProdutoController();

  List<Cliente> _clientes = [];
  List<Produto> _produtos = [];
  List<PedidoItem> _itens = [];
  List<PedidoPagamento> _pagamentos = [];

  Cliente? _clienteSelecionado;
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final clientes = await _clienteController.listarTodos();
      final produtos = await _produtoController.listarAtivos();

      setState(() {
        _clientes = clientes;
        _produtos = produtos;
      });

      // Se está editando, carregar dados do pedido
      if (widget.pedido != null) {
        await _carregarPedidoExistente();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _carregarPedidoExistente() async {
    if (widget.pedido == null) return;

    try {
      final itens = await _pedidoController.buscarItensPorPedido(
        widget.pedido!.id!,
      );
      final pagamentos = await _pedidoController.buscarPagamentosPorPedido(
        widget.pedido!.id!,
      );

      setState(() {
        _clienteSelecionado = _clientes.firstWhere(
          (c) => c.id == widget.pedido!.idCliente,
          orElse: () => _clientes.first,
        );
        _itens = itens;
        _pagamentos = pagamentos;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar pedido: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _adicionarItem() {
    showDialog(
      context: context,
      builder:
          (context) => _ItemDialog(
            produtos: _produtos,
            onItemAdicionado: (item) {
              setState(() {
                _itens.add(item);
              });
            },
          ),
    );
  }

  void _editarItem(int index) {
    showDialog(
      context: context,
      builder:
          (context) => _ItemDialog(
            produtos: _produtos,
            item: _itens[index],
            onItemAdicionado: (item) {
              setState(() {
                _itens[index] = item;
              });
            },
          ),
    );
  }

  void _removerItem(int index) {
    setState(() {
      _itens.removeAt(index);
    });
  }

  void _adicionarPagamento() {
    showDialog(
      context: context,
      builder:
          (context) => _PagamentoDialog(
            onPagamentoAdicionado: (pagamento) {
              setState(() {
                _pagamentos.add(pagamento);
              });
            },
          ),
    );
  }

  void _editarPagamento(int index) {
    showDialog(
      context: context,
      builder:
          (context) => _PagamentoDialog(
            pagamento: _pagamentos[index],
            onPagamentoAdicionado: (pagamento) {
              setState(() {
                _pagamentos[index] = pagamento;
              });
            },
          ),
    );
  }

  void _removerPagamento(int index) {
    setState(() {
      _pagamentos.removeAt(index);
    });
  }

  double get _totalItens {
    return _itens.fold(0.0, (sum, item) => sum + item.totalItem);
  }

  double get _totalPagamentos {
    return _pagamentos.fold(
      0.0,
      (sum, pagamento) => sum + pagamento.valorPagamento,
    );
  }

  bool get _totaisConferem {
    return (_totalItens - _totalPagamentos).abs() < 0.01;
  }

  Future<void> _salvarPedido() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_clienteSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um cliente'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_itens.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione pelo menos um item'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_pagamentos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione pelo menos um pagamento'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_totaisConferem) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'O total dos pagamentos deve ser igual ao total dos itens',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final pedido = Pedido(
        id: widget.pedido?.id,
        idCliente: _clienteSelecionado!.id!,
        idUsuario: widget.usuario.id!,
        totalPedido: _totalItens,
        dataCriacao: widget.pedido?.dataCriacao ?? DateTime.now(),
      );

      if (widget.pedido == null) {
        await _pedidoController.inserir(pedido, _itens, _pagamentos);
      } else {
        await _pedidoController.atualizar(pedido, _itens, _pagamentos);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.pedido == null
                  ? 'Pedido criado com sucesso'
                  : 'Pedido atualizado com sucesso',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar pedido: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pedido == null ? 'Novo Pedido' : 'Editar Pedido'),
        backgroundColor: Colors.purple.shade600,
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Seleção de Cliente
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Cliente *',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<Cliente>(
                                value: _clienteSelecionado,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.person),
                                ),
                                hint: const Text('Selecione um cliente'),
                                items:
                                    _clientes.map((cliente) {
                                      return DropdownMenuItem(
                                        value: cliente,
                                        child: Text(cliente.nome),
                                      );
                                    }).toList(),
                                onChanged: (cliente) {
                                  setState(() {
                                    _clienteSelecionado = cliente;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Selecione um cliente';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Itens do Pedido
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Itens do Pedido',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: _adicionarItem,
                                      icon: const Icon(Icons.add),
                                      label: const Text('Adicionar'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child:
                                      _itens.isEmpty
                                          ? const Center(
                                            child: Text(
                                              'Nenhum item adicionado',
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          )
                                          : ListView.builder(
                                            itemCount: _itens.length,
                                            itemBuilder: (context, index) {
                                              final item = _itens[index];
                                              final produto = _produtos.firstWhere(
                                                (p) => p.id == item.idProduto,
                                                orElse:
                                                    () => Produto(
                                                      nome:
                                                          'Produto não encontrado',
                                                      unidade: 'un',
                                                      qtdEstoque: 0,
                                                      precoVenda: 0,
                                                      status: 1,
                                                    ),
                                              );

                                              return ListTile(
                                                title: Text(produto.nome),
                                                subtitle: Text(
                                                  'Qtd: ${item.quantidade} ${produto.unidade} - '
                                                  'Total: R\$ ${item.totalItem.toStringAsFixed(2)}',
                                                ),
                                                trailing: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.edit,
                                                        color: Colors.blue,
                                                      ),
                                                      onPressed:
                                                          () => _editarItem(
                                                            index,
                                                          ),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                      ),
                                                      onPressed:
                                                          () => _removerItem(
                                                            index,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                ),
                                const Divider(),
                                Text(
                                  'Total dos Itens: R\$ ${_totalItens.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Pagamentos
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Pagamentos',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: _adicionarPagamento,
                                      icon: const Icon(Icons.add),
                                      label: const Text('Adicionar'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child:
                                      _pagamentos.isEmpty
                                          ? const Center(
                                            child: Text(
                                              'Nenhum pagamento adicionado',
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          )
                                          : ListView.builder(
                                            itemCount: _pagamentos.length,
                                            itemBuilder: (context, index) {
                                              final pagamento =
                                                  _pagamentos[index];

                                              return ListTile(
                                                title: Text(
                                                  'Pagamento ${index + 1}',
                                                ),
                                                subtitle: Text(
                                                  'Valor: R\$ ${pagamento.valorPagamento.toStringAsFixed(2)}',
                                                ),
                                                trailing: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.edit,
                                                        color: Colors.blue,
                                                      ),
                                                      onPressed:
                                                          () =>
                                                              _editarPagamento(
                                                                index,
                                                              ),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                      ),
                                                      onPressed:
                                                          () =>
                                                              _removerPagamento(
                                                                index,
                                                              ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                ),
                                const Divider(),
                                Text(
                                  'Total dos Pagamentos: R\$ ${_totalPagamentos.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (!_totaisConferem)
                                  const Text(
                                    'ATENÇÃO: Totais não conferem!',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Botão Salvar
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _salvarPedido,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple.shade600,
                            foregroundColor: Colors.white,
                          ),
                          child:
                              _isSaving
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : const Text(
                                    'Salvar Pedido',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}

// Dialog para adicionar/editar itens
class _ItemDialog extends StatefulWidget {
  final List<Produto> produtos;
  final PedidoItem? item;
  final Function(PedidoItem) onItemAdicionado;

  const _ItemDialog({
    required this.produtos,
    required this.onItemAdicionado,
    this.item,
  });

  @override
  State<_ItemDialog> createState() => _ItemDialogState();
}

class _ItemDialogState extends State<_ItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantidadeController = TextEditingController();

  Produto? _produtoSelecionado;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _produtoSelecionado = widget.produtos.firstWhere(
        (p) => p.id == widget.item!.idProduto,
        orElse: () => widget.produtos.first,
      );
      _quantidadeController.text = widget.item!.quantidade.toString();
    }
  }

  @override
  void dispose() {
    _quantidadeController.dispose();
    super.dispose();
  }

  double get _total {
    if (_produtoSelecionado == null) return 0.0;
    final quantidade = double.tryParse(_quantidadeController.text) ?? 0.0;
    return quantidade * _produtoSelecionado!.precoVenda;
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_produtoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um produto'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final item = PedidoItem(
      idPedido: 0, // Será definido ao salvar o pedido
      id: widget.item?.id,
      idProduto: _produtoSelecionado!.id!,
      quantidade: double.parse(_quantidadeController.text),
      totalItem: _total,
    );

    widget.onItemAdicionado(item);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item == null ? 'Adicionar Item' : 'Editar Item'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<Produto>(
              value: _produtoSelecionado,
              decoration: const InputDecoration(
                labelText: 'Produto *',
                border: OutlineInputBorder(),
              ),
              items:
                  widget.produtos.map((produto) {
                    return DropdownMenuItem(
                      value: produto,
                      child: Text(
                        '${produto.nome} - R\$ ${produto.precoVenda.toStringAsFixed(2)}',
                      ),
                    );
                  }).toList(),
              onChanged: (produto) {
                setState(() {
                  _produtoSelecionado = produto;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Selecione um produto';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantidadeController,
              decoration: InputDecoration(
                labelText: 'Quantidade *',
                border: const OutlineInputBorder(),
                suffixText: _produtoSelecionado?.unidade ?? '',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Quantidade é obrigatória';
                }
                final quantidade = double.tryParse(value);
                if (quantidade == null || quantidade <= 0) {
                  return 'Quantidade deve ser maior que zero';
                }
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Text(
              'Total: R\$ ${_total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(onPressed: _salvar, child: const Text('Salvar')),
      ],
    );
  }
}

// Dialog para adicionar/editar pagamentos
class _PagamentoDialog extends StatefulWidget {
  final PedidoPagamento? pagamento;
  final Function(PedidoPagamento) onPagamentoAdicionado;

  const _PagamentoDialog({required this.onPagamentoAdicionado, this.pagamento});

  @override
  State<_PagamentoDialog> createState() => _PagamentoDialogState();
}

class _PagamentoDialogState extends State<_PagamentoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.pagamento != null) {
      _valorController.text = widget.pagamento!.valorPagamento.toString();
    }
  }

  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final pagamento = PedidoPagamento(
      idPedido: 0, // Será definido ao salvar o pedido
      id: widget.pagamento?.id,
      valorPagamento: double.parse(_valorController.text),
    );

    widget.onPagamentoAdicionado(pagamento);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.pagamento == null ? 'Adicionar Pagamento' : 'Editar Pagamento',
      ),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _valorController,
          decoration: const InputDecoration(
            labelText: 'Valor *',
            border: OutlineInputBorder(),
            prefixText: 'R\$ ',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Valor é obrigatório';
            }
            final valor = double.tryParse(value);
            if (valor == null || valor <= 0) {
              return 'Valor deve ser maior que zero';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(onPressed: _salvar, child: const Text('Salvar')),
      ],
    );
  }
}
