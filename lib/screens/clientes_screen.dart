import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/cliente_controller.dart';
import '../models/cliente.dart';
import '../services/cep_service.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final ClienteController _controller = ClienteController();
  List<Cliente> _clientes = [];
  bool _isLoading = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarClientes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _carregarClientes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final clientes = await _controller.listarTodos();
      setState(() {
        _clientes = clientes;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar clientes: $e'),
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

  Future<void> _buscarClientes(String termo) async {
    if (termo.isEmpty) {
      _carregarClientes();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final clientes = await _controller.buscarPorNome(termo);
      setState(() {
        _clientes = clientes;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao buscar clientes: $e'),
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

  Future<void> _excluirCliente(Cliente cliente) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar Exclusão'),
            content: Text(
              'Deseja realmente excluir o cliente "${cliente.nome}"?',
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
        await _controller.deletar(cliente.id!);
        await _carregarClientes();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cliente excluído com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir cliente: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _abrirFormulario([Cliente? cliente]) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => ClienteFormScreen(cliente: cliente),
          ),
        )
        .then((_) => _carregarClientes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar cliente',
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
                            _carregarClientes();
                          },
                        )
                        : null,
              ),
              onChanged: _buscarClientes,
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _clientes.isEmpty
                    ? const Center(
                      child: Text(
                        'Nenhum cliente encontrado',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                    : ListView.builder(
                      itemCount: _clientes.length,
                      itemBuilder: (context, index) {
                        final cliente = _clientes[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green.shade600,
                              child: Text(
                                cliente.nome.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              cliente.nome,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${cliente.tipo == 'F' ? 'CPF' : 'CNPJ'}: ${cliente.cpfCnpj}',
                                ),
                                if (cliente.telefone != null &&
                                    cliente.telefone!.isNotEmpty)
                                  Text('Tel: ${cliente.telefone}'),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'editar') {
                                  _abrirFormulario(cliente);
                                } else if (value == 'excluir') {
                                  _excluirCliente(cliente);
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
        backgroundColor: Colors.green.shade600,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class ClienteFormScreen extends StatefulWidget {
  final Cliente? cliente;

  const ClienteFormScreen({super.key, this.cliente});

  @override
  State<ClienteFormScreen> createState() => _ClienteFormScreenState();
}

class _ClienteFormScreenState extends State<ClienteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cpfCnpjController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _cepController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _ufController = TextEditingController();

  final ClienteController _controller = ClienteController();
  bool _isLoading = false;
  bool _buscandoCep = false;
  String _tipoSelecionado = 'F';

  @override
  void initState() {
    super.initState();
    if (widget.cliente != null) {
      final cliente = widget.cliente!;
      _nomeController.text = cliente.nome;
      _cpfCnpjController.text = cliente.cpfCnpj;
      _emailController.text = cliente.email ?? '';
      _telefoneController.text = cliente.telefone ?? '';
      _cepController.text = cliente.cep ?? '';
      _enderecoController.text = cliente.endereco ?? '';
      _bairroController.text = cliente.bairro ?? '';
      _cidadeController.text = cliente.cidade ?? '';
      _ufController.text = cliente.uf ?? '';
      _tipoSelecionado = cliente.tipo;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfCnpjController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _cepController.dispose();
    _enderecoController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _ufController.dispose();
    super.dispose();
  }

  Future<void> _buscarCep() async {
    final cep = _cepController.text.trim();
    if (!CepService.validarCep(cep)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('CEP inválido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _buscandoCep = true;
    });

    try {
      final dados = await CepService.buscarCep(cep);
      if (dados != null) {
        setState(() {
          _enderecoController.text = dados['endereco'] ?? '';
          _bairroController.text = dados['bairro'] ?? '';
          _cidadeController.text = dados['cidade'] ?? '';
          _ufController.text = dados['uf'] ?? '';
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('CEP encontrado com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('CEP não encontrado'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao buscar CEP: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _buscandoCep = false;
      });
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final cliente = Cliente(
        id: widget.cliente?.id,
        nome: _nomeController.text.trim(),
        tipo: _tipoSelecionado,
        cpfCnpj: _cpfCnpjController.text.trim(),
        email:
            _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
        telefone:
            _telefoneController.text.trim().isEmpty
                ? null
                : _telefoneController.text.trim(),
        cep:
            _cepController.text.trim().isEmpty
                ? null
                : _cepController.text.trim(),
        endereco:
            _enderecoController.text.trim().isEmpty
                ? null
                : _enderecoController.text.trim(),
        bairro:
            _bairroController.text.trim().isEmpty
                ? null
                : _bairroController.text.trim(),
        cidade:
            _cidadeController.text.trim().isEmpty
                ? null
                : _cidadeController.text.trim(),
        uf:
            _ufController.text.trim().isEmpty
                ? null
                : _ufController.text.trim(),
      );

      // Validar campos obrigatórios
      if (!await _controller.validarCamposObrigatorios(cliente)) {
        throw Exception('Preencha todos os campos obrigatórios');
      }

      // Validar CPF/CNPJ
      if (cliente.tipo == 'F' && !_controller.validarCPF(cliente.cpfCnpj)) {
        throw Exception('CPF inválido');
      }
      if (cliente.tipo == 'J' && !_controller.validarCNPJ(cliente.cpfCnpj)) {
        throw Exception('CNPJ inválido');
      }

      // Verificar se o CPF/CNPJ já existe
      if (await _controller.cpfCnpjJaExiste(
        cliente.cpfCnpj,
        idExcluir: cliente.id,
      )) {
        throw Exception(
          'Já existe um cliente com este ${cliente.tipo == 'F' ? 'CPF' : 'CNPJ'}',
        );
      }

      if (widget.cliente == null) {
        await _controller.inserir(cliente);
      } else {
        await _controller.atualizar(cliente);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.cliente == null
                  ? 'Cliente criado com sucesso'
                  : 'Cliente atualizado com sucesso',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar cliente: $e'),
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
        title: Text(widget.cliente == null ? 'Novo Cliente' : 'Editar Cliente'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Tipo de pessoa
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tipo de Pessoa *',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Física'),
                                value: 'F',
                                groupValue: _tipoSelecionado,
                                onChanged: (value) {
                                  setState(() {
                                    _tipoSelecionado = value!;
                                    _cpfCnpjController.clear();
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Jurídica'),
                                value: 'J',
                                groupValue: _tipoSelecionado,
                                onChanged: (value) {
                                  setState(() {
                                    _tipoSelecionado = value!;
                                    _cpfCnpjController.clear();
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
                const SizedBox(height: 16),

                // Nome
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
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

                // CPF/CNPJ
                TextFormField(
                  controller: _cpfCnpjController,
                  decoration: InputDecoration(
                    labelText: '${_tipoSelecionado == 'F' ? 'CPF' : 'CNPJ'} *',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.badge),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '${_tipoSelecionado == 'F' ? 'CPF' : 'CNPJ'} é obrigatório';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        !value.contains('@')) {
                      return 'E-mail inválido';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Telefone
                TextFormField(
                  controller: _telefoneController,
                  decoration: const InputDecoration(
                    labelText: 'Telefone',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // CEP
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cepController,
                        decoration: const InputDecoration(
                          labelText: 'CEP',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _buscandoCep ? null : _buscarCep,
                      child:
                          _buscandoCep
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('Buscar'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Endereço
                TextFormField(
                  controller: _enderecoController,
                  decoration: const InputDecoration(
                    labelText: 'Endereço',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.home),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Bairro
                TextFormField(
                  controller: _bairroController,
                  decoration: const InputDecoration(
                    labelText: 'Bairro',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Cidade e UF
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _cidadeController,
                        decoration: const InputDecoration(
                          labelText: 'Cidade',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_city),
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _ufController,
                        decoration: const InputDecoration(
                          labelText: 'UF',
                          border: OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.characters,
                        maxLength: 2,
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Botão Salvar
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _salvar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
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
