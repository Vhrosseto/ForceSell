import 'package:flutter/material.dart';
import '../controllers/configuracao_controller.dart';
// ignore: unused_import
import '../models/configuracao.dart';
import '../database/database_helper.dart';

class ConfiguracaoScreen extends StatefulWidget {
  const ConfiguracaoScreen({super.key});

  @override
  State<ConfiguracaoScreen> createState() => _ConfiguracaoScreenState();
}

class _ConfiguracaoScreenState extends State<ConfiguracaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _linkServidorController = TextEditingController();
  final ConfiguracaoController _controller = ConfiguracaoController();
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _carregarConfiguracao();
  }

  @override
  void dispose() {
    _linkServidorController.dispose();
    super.dispose();
  }

  Future<void> _carregarConfiguracao() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final configuracao = await _controller.obterConfiguracao();
      setState(() {
        _linkServidorController.text = configuracao.linkServidor;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar configuração: $e'),
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

  Future<void> _salvarConfiguracao() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final novoLink = _linkServidorController.text.trim();

      if (!_controller.validarUrl(novoLink)) {
        throw Exception(
          'URL do servidor inválida. Use o formato: host:porta (ex: localhost:8080)',
        );
      }

      await _controller.atualizarLinkServidor(novoLink);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuração salva com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar configuração: $e'),
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

  Future<void> _testarConexao() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final link = _linkServidorController.text.trim();
      final urlFormatada = _controller.formatarUrl(link);

      // Aqui você pode implementar um teste real de conexão
      // Por enquanto, vamos simular um teste
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Testando conexão com: $urlFormatada'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao testar conexão: $e'),
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

  void _restaurarPadrao() {
    setState(() {
      _linkServidorController.text = 'localhost:8080';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: Colors.grey.shade600,
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.dns, color: Colors.grey.shade600),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Servidor de Sincronização',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _linkServidorController,
                                decoration: const InputDecoration(
                                  labelText: 'Link do Servidor *',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.link),
                                  helperText:
                                      'Formato: host:porta (ex: localhost:8080)',
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Link do servidor é obrigatório';
                                  }
                                  if (!_controller.validarUrl(value.trim())) {
                                    return 'URL inválida. Use o formato: host:porta';
                                  }
                                  return null;
                                },
                                textInputAction: TextInputAction.done,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed:
                                          _isLoading ? null : _testarConexao,
                                      icon:
                                          _isLoading
                                              ? const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                              : const Icon(Icons.wifi_find),
                                      label: const Text('Testar Conexão'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: _restaurarPadrao,
                                    icon: const Icon(Icons.restore),
                                    label: const Text('Padrão'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Informações sobre os endpoints
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Endpoints de Sincronização',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildEndpointInfo(
                                'GET',
                                '/usuarios',
                                'Buscar usuários',
                              ),
                              _buildEndpointInfo(
                                'GET',
                                '/clientes',
                                'Buscar clientes',
                              ),
                              _buildEndpointInfo(
                                'GET',
                                '/produtos',
                                'Buscar produtos',
                              ),
                              _buildEndpointInfo(
                                'GET',
                                '/pedidos',
                                'Buscar pedidos',
                              ),
                              const Divider(),
                              _buildEndpointInfo(
                                'POST',
                                '/usuarios',
                                'Enviar usuários',
                              ),
                              _buildEndpointInfo(
                                'POST',
                                '/clientes',
                                'Enviar clientes',
                              ),
                              _buildEndpointInfo(
                                'POST',
                                '/produtos',
                                'Enviar produtos',
                              ),
                              _buildEndpointInfo(
                                'POST',
                                '/pedidos',
                                'Enviar pedidos',
                              ),
                              const Divider(),
                              _buildEndpointInfo(
                                'DELETE',
                                '/usuarios',
                                'Excluir usuários',
                              ),
                              _buildEndpointInfo(
                                'DELETE',
                                '/clientes',
                                'Excluir clientes',
                              ),
                              _buildEndpointInfo(
                                'DELETE',
                                '/produtos',
                                'Excluir produtos',
                              ),
                              _buildEndpointInfo(
                                'DELETE',
                                '/pedidos',
                                'Excluir pedidos',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed:
                              _isSaving
                                  ? null
                                  : () async {
                                    setState(() {
                                      _isSaving = true;
                                    });
                                    try {
                                      final dbHelper = DatabaseHelper();
                                      await dbHelper.clearAllTables();
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          // ignore: use_build_context_synchronously
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Todos os dados deletados com sucesso',
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          // ignore: use_build_context_synchronously
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Erro ao deletar dados: $e',
                                            ),
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
                                  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade600,
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
                                    'Deletar Todos os Dados',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
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
                          onPressed: _isSaving ? null : _salvarConfiguracao,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade600,
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
                                    'Salvar Configuração',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 16), // Espaço extra no final
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildEndpointInfo(
    String method,
    String endpoint,
    String description,
  ) {
    Color methodColor;
    switch (method) {
      case 'GET':
        methodColor = Colors.green;
        break;
      case 'POST':
        methodColor = Colors.blue;
        break;
      case 'DELETE':
        methodColor = Colors.red;
        break;
      default:
        methodColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: methodColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              method,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              endpoint,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            description,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
