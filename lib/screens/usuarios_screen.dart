import 'package:flutter/material.dart';
import '../controllers/usuario_controller.dart';
import '../models/usuario.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  final UsuarioController _controller = UsuarioController();
  List<Usuario> _usuarios = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _carregarUsuarios();
  }

  Future<void> _carregarUsuarios() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final usuarios = await _controller.listarTodos();
      setState(() {
        _usuarios = usuarios;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar usuários: $e'),
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

  Future<void> _excluirUsuario(Usuario usuario) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar Exclusão'),
            content: Text(
              'Deseja realmente excluir o usuário "${usuario.nome}"?',
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
        await _controller.deletar(usuario.id!);
        await _carregarUsuarios();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuário excluído com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir usuário: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _abrirFormulario([Usuario? usuario]) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => UsuarioFormScreen(usuario: usuario),
          ),
        )
        .then((_) => _carregarUsuarios());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuários'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _usuarios.isEmpty
              ? const Center(
                child: Text(
                  'Nenhum usuário encontrado',
                  style: TextStyle(fontSize: 16),
                ),
              )
              : ListView.builder(
                itemCount: _usuarios.length,
                itemBuilder: (context, index) {
                  final usuario = _usuarios[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade600,
                        child: Text(
                          usuario.nome.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        usuario.nome,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('ID: ${usuario.id}'),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'editar') {
                            _abrirFormulario(usuario);
                          } else if (value == 'excluir') {
                            _excluirUsuario(usuario);
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        backgroundColor: Colors.blue.shade600,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class UsuarioFormScreen extends StatefulWidget {
  final Usuario? usuario;

  const UsuarioFormScreen({super.key, this.usuario});

  @override
  State<UsuarioFormScreen> createState() => _UsuarioFormScreenState();
}

class _UsuarioFormScreenState extends State<UsuarioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _senhaController = TextEditingController();
  final UsuarioController _controller = UsuarioController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    if (widget.usuario != null) {
      _nomeController.text = widget.usuario!.nome;
      _senhaController.text = widget.usuario!.senha;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _senhaController.dispose();
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
      final usuario = Usuario(
        id: widget.usuario?.id,
        nome: _nomeController.text.trim(),
        senha: _senhaController.text,
      );

      // Validar campos obrigatórios
      if (!await _controller.validarCamposObrigatorios(usuario)) {
        throw Exception('Preencha todos os campos obrigatórios');
      }

      // Verificar se o nome já existe
      if (await _controller.nomeJaExiste(usuario.nome, idExcluir: usuario.id)) {
        throw Exception('Já existe um usuário com este nome');
      }

      if (widget.usuario == null) {
        await _controller.inserir(usuario);
      } else {
        await _controller.atualizar(usuario);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.usuario == null
                  ? 'Usuário criado com sucesso'
                  : 'Usuário atualizado com sucesso',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar usuário: $e'),
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
        title: Text(widget.usuario == null ? 'Novo Usuário' : 'Editar Usuário'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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
              TextFormField(
                controller: _senhaController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Senha *',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Senha é obrigatória';
                  }
                  if (value.length < 3) {
                    return 'Senha deve ter pelo menos 3 caracteres';
                  }
                  return null;
                },
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _salvar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
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
    );
  }
}
