import 'package:flutter/material.dart';
import '../services/sync_service.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> with TickerProviderStateMixin {
  final SyncService _syncService = SyncService();
  bool _isSyncing = false;
  bool _syncCompleted = false;
  Map<String, List<String>> _erros = {};
  late TabController _tabController;
  String _statusAtual = '';
  int _progressoAtual = 0;
  // ignore: prefer_final_fields
  int _totalEtapas = 7;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSincronizacao() async {
    setState(() {
      _isSyncing = true;
      _syncCompleted = false;
      _erros.clear();
      _progressoAtual = 0;
    });

    try {
      // Etapa 1: Verificar configuração
      setState(() {
        _statusAtual = 'Verificando configuração do servidor...';
        _progressoAtual = 1;
      });
      await Future.delayed(const Duration(milliseconds: 500));

      // Etapa 2: Buscar usuários
      setState(() {
        _statusAtual = 'Buscando usuários do servidor...';
        _progressoAtual = 2;
      });
      await Future.delayed(const Duration(milliseconds: 500));

      // Etapa 3: Buscar clientes
      setState(() {
        _statusAtual = 'Buscando clientes do servidor...';
        _progressoAtual = 3;
      });
      await Future.delayed(const Duration(milliseconds: 500));

      // Etapa 4: Buscar produtos
      setState(() {
        _statusAtual = 'Buscando produtos do servidor...';
        _progressoAtual = 4;
      });
      await Future.delayed(const Duration(milliseconds: 500));

      // Etapa 5: Enviar dados locais
      setState(() {
        _statusAtual = 'Enviando dados locais para o servidor...';
        _progressoAtual = 5;
      });
      await Future.delayed(const Duration(milliseconds: 500));

      // Executar sincronização real
      await _syncService.sincronizar();

      // Etapa 6: Processando resultados
      setState(() {
        _statusAtual = 'Processando resultados...';
        _progressoAtual = 6;
      });
      await Future.delayed(const Duration(milliseconds: 500));

      // Etapa 7: Finalizado
      setState(() {
        _statusAtual = 'Sincronização finalizada';
        _progressoAtual = 7;
        _erros = _syncService.errosPorEntidade;
        _syncCompleted = true;
      });

      if (_syncService.erros.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Sincronização concluída com sucesso!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '⚠️ Sincronização concluída com ${_syncService.erros.length} erro(s)',
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Ver Detalhes',
                onPressed: () => _tabController.animateTo(1),
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _statusAtual = 'Erro durante a sincronização';
        _erros['Geral'] = ['Erro durante a sincronização: $e'];
        _syncCompleted = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro durante a sincronização: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sincronização de Dados'),
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
        bottom:
            _syncCompleted || _isSyncing
                ? TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: const [
                    Tab(icon: Icon(Icons.dashboard), text: 'Status'),
                    Tab(icon: Icon(Icons.error_outline), text: 'Detalhes'),
                  ],
                )
                : null,
      ),
      body:
          _syncCompleted || _isSyncing
              ? TabBarView(
                controller: _tabController,
                children: [_buildStatusTab(), _buildDetalhesTab()],
              )
              : _buildInicialTab(),
    );
  }

  Widget _buildInicialTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card de informações
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.sync,
                          color: Colors.teal.shade600,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sincronização de Dados',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Mantenha seus dados atualizados com o servidor',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'O que será sincronizado:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoItem(
                    Icons.download,
                    'Buscar dados atualizados do servidor',
                    Colors.blue,
                  ),
                  _buildInfoItem(
                    Icons.upload,
                    'Enviar novos registros para o servidor',
                    Colors.green,
                  ),
                  _buildInfoItem(
                    Icons.update,
                    'Atualizar datas de última alteração',
                    Colors.orange,
                  ),
                  _buildInfoItem(
                    Icons.assessment,
                    'Gerar relatório detalhado de resultados',
                    Colors.purple,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Card de aviso
          Card(
            color: Colors.amber.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.amber.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Importante',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Certifique-se de que o servidor está configurado corretamente nas configurações antes de iniciar a sincronização.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Botão de sincronização
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _iniciarSincronizacao,
              icon: const Icon(Icons.sync, size: 24),
              label: const Text(
                'Iniciar Sincronização',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Card de progresso
          if (_isSyncing) ...[
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Sincronizando...',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    LinearProgressIndicator(
                      value: _progressoAtual / _totalEtapas,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.teal.shade600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _statusAtual,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '$_progressoAtual/$_totalEtapas',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Card de resultado
          if (_syncCompleted) ...[
            Card(
              elevation: 4,
              color:
                  _erros.values.any((lista) => lista.isNotEmpty)
                      ? Colors.orange.shade50
                      : Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(
                      _erros.values.any((lista) => lista.isNotEmpty)
                          ? Icons.warning_amber
                          : Icons.check_circle,
                      size: 64,
                      color:
                          _erros.values.any((lista) => lista.isNotEmpty)
                              ? Colors.orange.shade600
                              : Colors.green.shade600,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _erros.values.any((lista) => lista.isNotEmpty)
                          ? 'Sincronização Concluída com Avisos'
                          : 'Sincronização Concluída com Sucesso!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color:
                            _erros.values.any((lista) => lista.isNotEmpty)
                                ? Colors.orange.shade700
                                : Colors.green.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _erros.values.any((lista) => lista.isNotEmpty)
                          ? 'Alguns problemas foram encontrados durante a sincronização. Verifique os detalhes na aba "Detalhes".'
                          : 'Todos os dados foram sincronizados com sucesso sem nenhum erro.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    if (_erros.values.any((lista) => lista.isNotEmpty)) ...[
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _tabController.animateTo(1),
                        icon: const Icon(Icons.visibility),
                        label: const Text('Ver Detalhes dos Erros'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade600,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _iniciarSincronizacao,
                icon: const Icon(Icons.refresh),
                label: const Text('Sincronizar Novamente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade600,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetalhesTab() {
    final errosComConteudo =
        _erros.entries.where((entry) => entry.value.isNotEmpty).toList();

    if (errosComConteudo.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.green.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum erro encontrado!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'A sincronização foi executada sem problemas.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: errosComConteudo.length,
      itemBuilder: (context, index) {
        final entry = errosComConteudo[index];
        return _buildErrorCard(entry.key, entry.value);
      },
    );
  }

  Widget _buildInfoItem(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String entidade, List<String> erros) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.error_outline,
            color: Colors.red.shade600,
            size: 20,
          ),
        ),
        title: Text(
          entidade,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red.shade700,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          '${erros.length} erro(s) encontrado(s)',
          style: TextStyle(color: Colors.red.shade600, fontSize: 13),
        ),
        children:
            erros.map((erro) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning,
                      color: Colors.orange.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(erro, style: const TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }
}
