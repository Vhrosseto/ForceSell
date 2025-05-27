import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/produto_controller.dart';
import '../models/produto.dart';

class ProdutosScreen extends StatefulWidget {
  const ProdutosScreen({super.key});

  @override
  State<ProdutosScreen> createState() => _ProdutosScreenState();
}

class _ProdutosScreenState extends State<ProdutosScreen> {
  final ProdutoController _controller = ProdutoController();
  List<Produto> _produtos = [];
  bool _isLoading = false;
  final _searchController = TextEditingController();
  bool _mostrarApenasAtivos = true;

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _carregarProdutos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final produtos =
          _mostrarApenasAtivos
              ? await _controller.listarAtivos()
              : await _controller.listarTodos();
      setState(() {
        _produtos = produtos;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar produtos: $e'),
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

  Future<void> _buscarProdutos(String termo) async {
    if (termo.isEmpty) {
      _carregarProdutos();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final produtos = await _controller.buscarPorNome(termo);
      setState(() {
        _produtos =
            _mostrarApenasAtivos
                ? produtos.where((p) => p.status == 0).toList()
                : produtos;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao buscar produtos: $e'),
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

  Future<void> _excluirProduto(Produto produto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar Exclusão'),
            content: Text(
              'Deseja realmente excluir o produto "${produto.nome}"?',
            ),
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
        await _controller.deletar(produto.id!);
        await _carregarProdutos();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Produto excluído com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir produto: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _abrirFormulario([Produto? produto]) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => ProdutoFormScreen(produto: produto),
          ),
        )
        .then((_) => _carregarProdutos());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'filtro') {
                setState(() {
                  _mostrarApenasAtivos = !_mostrarApenasAtivos;
                });
                _carregarProdutos();
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'filtro',
                    child: Row(
                      children: [
                        Icon(
                          _mostrarApenasAtivos
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _mostrarApenasAtivos
                              ? 'Mostrar Todos'
                              : 'Apenas Ativos',
                        ),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar produto',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _carregarProdutos();
                          },
                        )
                        : null,
              ),
              onChanged: _buscarProdutos,
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _produtos.isEmpty
                    ? const Center(
                      child: Text(
                        'Nenhum produto encontrado',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                    : ListView.builder(
                      itemCount: _produtos.length,
                      itemBuilder: (context, index) {
                        final produto = _produtos[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  produto.status == 0
                                      ? Colors.orange.shade600
                                      : Colors.grey,
                              child: Text(
                                produto.nome.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              produto.nome,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration:
                                    produto.status == 1
                                        ? TextDecoration.lineThrough
                                        : null,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Preço: R\$ ${produto.precoVenda.toStringAsFixed(2)}',
                                ),
                                Text(
                                  'Estoque: ${produto.qtdEstoque} ${produto.unidade}',
                                ),
                                Text(
                                  'Status: ${produto.status == 0 ? 'Ativo' : 'Inativo'}',
                                  style: TextStyle(
                                    color:
                                        produto.status == 0
                                            ? Colors.green
                                            : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'editar') {
                                  _abrirFormulario(produto);
                                } else if (value == 'excluir') {
                                  _excluirProduto(produto);
                                }
                              },
                              itemBuilder:
                                  (context) => [
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        backgroundColor: Colors.orange.shade600,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class ProdutoFormScreen extends StatefulWidget {
  final Produto? produto;

  const ProdutoFormScreen({super.key, this.produto});

  @override
  State<ProdutoFormScreen> createState() => _ProdutoFormScreenState();
}

class _ProdutoFormScreenState extends State<ProdutoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _qtdEstoqueController = TextEditingController();
  final _precoVendaController = TextEditingController();
  final _custoController = TextEditingController();
  final _codigoBarraController = TextEditingController();

  final ProdutoController _controller = ProdutoController();
  bool _isLoading = false;
  String _unidadeSelecionada = 'un';
  int _statusSelecionado = 0;

  @override
  void initState() {
    super.initState();
    if (widget.produto != null) {
      final produto = widget.produto!;
      _nomeController.text = produto.nome;
      _qtdEstoqueController.text = produto.qtdEstoque.toString();
      _precoVendaController.text = produto.precoVenda.toString();
      _custoController.text = produto.custo?.toString() ?? '';
      _codigoBarraController.text = produto.codigoBarra ?? '';
      _unidadeSelecionada = produto.unidade;
      _statusSelecionado = produto.status;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _qtdEstoqueController.dispose();
    _precoVendaController.dispose();
    _custoController.dispose();
    _codigoBarraController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final produto = Produto(
        id: widget.produto?.id,
        nome: _nomeController.text.trim(),
        unidade: _unidadeSelecionada,
        qtdEstoque: double.parse(_qtdEstoqueController.text),
        precoVenda: double.parse(_precoVendaController.text),
        status: _statusSelecionado,
        custo:
            _custoController.text.trim().isEmpty
                ? null
                : double.parse(_custoController.text),
        codigoBarra:
            _codigoBarraController.text.trim().isEmpty
                ? null
                : _codigoBarraController.text.trim(),
      );

      // Validar campos obrigatórios
      if (!await _controller.validarCamposObrigatorios(produto)) {
        throw Exception('Preencha todos os campos obrigatórios');
      }

      // Verificar se o código de barras já existe
      if (produto.codigoBarra != null &&
          await _controller.codigoBarraJaExiste(
            produto.codigoBarra!,
            idExcluir: produto.id,
          )) {
        throw Exception('Já existe um produto com este código de barras');
      }

      if (widget.produto == null) {
        await _controller.inserir(produto);
      } else {
        await _controller.atualizar(produto);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.produto == null
                  ? 'Produto criado com sucesso'
                  : 'Produto atualizado com sucesso',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar produto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.produto == null ? 'Novo Produto' : 'Editar Produto'),
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Nome
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.inventory),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nome é obrigatório';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Unidade
                DropdownButtonFormField<String>(
                  value: _unidadeSelecionada,
                  decoration: const InputDecoration(
                    labelText: 'Unidade *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.straighten),
                  ),
                  items:
                      _controller.unidadesDisponiveis.map((unidade) {
                        return DropdownMenuItem(
                          value: unidade,
                          child: Text(unidade.toUpperCase()),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _unidadeSelecionada = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Unidade é obrigatória';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Quantidade em Estoque
                TextFormField(
                  controller: _qtdEstoqueController,
                  decoration: const InputDecoration(
                    labelText: 'Quantidade em Estoque *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.inventory_2),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Quantidade é obrigatória';
                    }
                    final quantidade = double.tryParse(value);
                    if (quantidade == null || quantidade < 0) {
                      return 'Quantidade deve ser um número válido e não negativo';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Preço de Venda
                TextFormField(
                  controller: _precoVendaController,
                  decoration: const InputDecoration(
                    labelText: 'Preço de Venda *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                    prefixText: 'R\$ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Preço de venda é obrigatório';
                    }
                    final preco = double.tryParse(value);
                    if (preco == null || preco <= 0) {
                      return 'Preço deve ser um número válido e maior que zero';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Custo (opcional)
                TextFormField(
                  controller: _custoController,
                  decoration: const InputDecoration(
                    labelText: 'Custo',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.money_off),
                    prefixText: 'R\$ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final custo = double.tryParse(value);
                      if (custo == null || custo < 0) {
                        return 'Custo deve ser um número válido e não negativo';
                      }
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Código de Barras (opcional)
                TextFormField(
                  controller: _codigoBarraController,
                  decoration: const InputDecoration(
                    labelText: 'Código de Barras',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.qr_code),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Status
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Status *',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<int>(
                                title: const Text('Ativo'),
                                value: 0,
                                groupValue: _statusSelecionado,
                                onChanged: (value) {
                                  setState(() {
                                    _statusSelecionado = value!;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<int>(
                                title: const Text('Inativo'),
                                value: 1,
                                groupValue: _statusSelecionado,
                                onChanged: (value) {
                                  setState(() {
                                    _statusSelecionado = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Botão Salvar
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _salvar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                    ),
                    child:
                        _isLoading
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
                              'Salvar',
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
      ),
    );
  }
}
