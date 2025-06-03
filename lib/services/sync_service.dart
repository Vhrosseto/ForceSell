import 'dart:convert';
import 'package:http/http.dart' as http;
import '../controllers/configuracao_controller.dart';
import '../controllers/usuario_controller.dart';
import '../controllers/cliente_controller.dart';
import '../controllers/produto_controller.dart';
import '../controllers/pedido_controller.dart';
import '../models/usuario.dart';
import '../models/cliente.dart';
import '../models/produto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SyncService {
  final ConfiguracaoController _configController = ConfiguracaoController();
  final UsuarioController _usuarioController = UsuarioController();
  final ClienteController _clienteController = ClienteController();
  final ProdutoController _produtoController = ProdutoController();
  final PedidoController _pedidoController = PedidoController();

  final Map<String, List<String>> _erros = {
    'Usuários': [],
    'Clientes': [],
    'Produtos': [],
    'Pedidos': [],
    'Geral': [],
  };

  Map<String, List<String>> get errosPorEntidade => Map.from(_erros);
  List<String> get erros => _erros.values.expand((lista) => lista).toList();

  /// Método auxiliar para processar respostas do servidor
  List<dynamic> _processarResposta(dynamic responseData, String tipoEntidade) {
    if (responseData == null) {
      return [];
    }

    if (responseData is List) {
      return responseData;
    } else if (responseData is Map) {
      // Verificar se tem a propriedade 'dados' (formato do servidor)
      if (responseData.containsKey('dados')) {
        final dados = responseData['dados'];
        if (dados is List) {
          return dados;
        } else if (dados != null) {
          return [dados];
        }
      }
      // Verificar se tem a propriedade 'data' (formato alternativo)
      else if (responseData.containsKey('data')) {
        final data = responseData['data'];
        if (data is List) {
          return data;
        } else if (data != null) {
          return [data];
        }
      }
      // Se é um objeto único, transformar em lista
      else if (responseData.isNotEmpty) {
        return [responseData];
      }
    }

    return [];
  }

  Future<void> sincronizar() async {
    // Limpar erros anteriores
    _erros.forEach((key, value) => value.clear());

    try {
      final baseUrl = await _configController.obterLinkServidor();

      // FASE 1: Buscar dados do servidor (GET) e atualizar registros com datas maiores
      await _sincronizarDoServidor(baseUrl);

      // FASE 2: Enviar novos registros para o servidor (POST)
      await _enviarNovosRegistros(baseUrl);

      // FASE 3: Sincronizar exclusões
      await _sincronizarExclusoes(baseUrl);
    } catch (e) {
      _erros['Geral']!.add('Erro geral de sincronização: $e');
    }
  }

  // FASE 1: Buscar dados do servidor e atualizar com datas maiores
  Future<void> _sincronizarDoServidor(String baseUrl) async {
    await _buscarUsuarios(baseUrl);
    await _buscarClientes(baseUrl);
    await _buscarProdutos(baseUrl);
  }

  // FASE 2: Enviar novos registros para o servidor
  Future<void> _enviarNovosRegistros(String baseUrl) async {
    await _enviarUsuarios(baseUrl);
    await _enviarClientes(baseUrl);
    await _enviarProdutos(baseUrl);
    await _enviarPedidos(baseUrl);
  }

  // FASE 3: Sincronizar exclusões
  Future<void> _sincronizarExclusoes(String baseUrl) async {
    await _sincronizarExclusoesProdutos(baseUrl);
    await _sincronizarExclusoesUsuarios(baseUrl);
    await _sincronizarExclusoesClientes(baseUrl);
    await _sincronizarExclusoesPedidos(baseUrl);
  }

  Future<void> _sincronizarExclusoesProdutos(String baseUrl) async {
    try {
      final produtosDeletados = await _produtoController.listarDeletados();


      for (var produto in produtosDeletados) {
        try {

          final response = await http
              .delete(
                Uri.parse('http://$baseUrl/produtos/${produto.id}'),
                headers: {'Content-Type': 'application/json'},
              )
              .timeout(const Duration(seconds: 10));

          if (response.statusCode == 200 || response.statusCode == 204) {
            // Se a exclusão no servidor foi bem-sucedida, podemos remover o registro localmente
            await _produtoController.deletarDefinitivamente(produto.id!);
          } else {
            _erros['Produtos']!.add(
              'Erro ao sincronizar exclusão do produto ${produto.nome}: HTTP ${response.statusCode}',
            );
          }
        } catch (e) {
          _erros['Produtos']!.add(
            'Erro ao sincronizar exclusão do produto ${produto.nome}: $e',
          );
        }
      }
    } catch (e) {
      _erros['Produtos']!.add(
        'Erro ao processar sincronização de exclusões de produtos: $e',
      );
    }
  }

  Future<void> _sincronizarExclusoesUsuarios(String baseUrl) async {
    try {
      final usuariosDeletados = await _usuarioController.listarDeletados();


      for (var usuario in usuariosDeletados) {
        try {

          final response = await http
              .delete(
                Uri.parse('http://$baseUrl/usuarios/${usuario.id}'),
                headers: {'Content-Type': 'application/json'},
              )
              .timeout(const Duration(seconds: 10));

          if (response.statusCode == 200 || response.statusCode == 204) {
            // Se a exclusão no servidor foi bem-sucedida, podemos remover o registro localmente
            await _usuarioController.deletarDefinitivamente(usuario.id!);
          } else {
            _erros['Usuários']!.add(
              'Erro ao sincronizar exclusão do usuário ${usuario.nome}: HTTP ${response.statusCode}',
            );
          }
        } catch (e) {
          _erros['Usuários']!.add(
            'Erro ao sincronizar exclusão do usuário ${usuario.nome}: $e',
          );
        }
      }
    } catch (e) {
      _erros['Usuários']!.add(
        'Erro ao processar sincronização de exclusões de usuários: $e',
      );
    }
  }

  Future<void> _sincronizarExclusoesClientes(String baseUrl) async {
    try {
      final clientesDeletados = await _clienteController.listarDeletados();


      for (var cliente in clientesDeletados) {
        try {

          final response = await http
              .delete(
                Uri.parse('http://$baseUrl/clientes/${cliente.id}'),
                headers: {'Content-Type': 'application/json'},
              )
              .timeout(const Duration(seconds: 10));

          if (response.statusCode == 200 || response.statusCode == 204) {
            // Se a exclusão no servidor foi bem-sucedida, podemos remover o registro localmente
            await _clienteController.deletarDefinitivamente(cliente.id!);
          } else {
            _erros['Clientes']!.add(
              'Erro ao sincronizar exclusão do cliente ${cliente.nome}: HTTP ${response.statusCode}',
            );
          }
        } catch (e) {
          _erros['Clientes']!.add(
            'Erro ao sincronizar exclusão do cliente ${cliente.nome}: $e',
          );
        }
      }
    } catch (e) {
      _erros['Clientes']!.add(
        'Erro ao processar sincronização de exclusões de clientes: $e',
      );
    }
  }

  Future<void> _sincronizarExclusoesPedidos(String baseUrl) async {
    try {
      final pedidosDeletados = await _pedidoController.listarDeletados();


      for (var pedido in pedidosDeletados) {
        try {

          final response = await http
              .delete(
                Uri.parse('http://$baseUrl/pedidos/${pedido.id}'),
                headers: {'Content-Type': 'application/json'},
              )
              .timeout(const Duration(seconds: 10));

          if (response.statusCode == 200 || response.statusCode == 204) {
            // Se a exclusão no servidor foi bem-sucedida, podemos remover o registro localmente
            await _pedidoController.deletarDefinitivamente(pedido.id!);
          } else {
            _erros['Pedidos']!.add(
              'Erro ao sincronizar exclusão do pedido ID ${pedido.id}: HTTP ${response.statusCode}',
            );
          }
        } catch (e) {
          _erros['Pedidos']!.add(
            'Erro ao sincronizar exclusão do pedido ID ${pedido.id}: $e',
          );
        }
      }
    } catch (e) {
      _erros['Pedidos']!.add(
        'Erro ao processar sincronização de exclusões de pedidos: $e',
      );
    }
  }

  Future<void> _buscarUsuarios(String baseUrl) async {
    try {
      final response = await http
          .get(
            Uri.parse('http://$baseUrl/usuarios'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        List<dynamic> data;

        data = _processarResposta(responseData, 'usuários');

        for (var item in data) {
          try {
            final usuario = Usuario.fromMap(item);
            final usuarioExistente = await _usuarioController.buscarPorId(
              usuario.id!,
            );

            if (usuarioExistente == null) {
              await _usuarioController.inserir(usuario);
            } else if (usuario.dataUltimaAlteracao != null &&
                usuarioExistente.dataUltimaAlteracao != null &&
                usuario.dataUltimaAlteracao!.isAfter(
                  usuarioExistente.dataUltimaAlteracao!,
                )) {
              await _usuarioController.atualizar(usuario);
            }
          } catch (e) {
            _erros['Usuários']!.add(
              'Erro ao processar usuário ${item['id']}: $e',
            );
          }
        }
      } else {
        _erros['Usuários']!.add(
          'Erro ao buscar usuários: ${response.statusCode}',
        );
      }
    } catch (e) {
      _erros['Usuários']!.add('Erro de conexão ao buscar usuários: $e');
    }
  }

  Future<void> _buscarClientes(String baseUrl) async {
    try {
      final response = await http
          .get(
            Uri.parse('http://$baseUrl/clientes'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        List<dynamic> data;

        data = _processarResposta(responseData, 'clientes');

        for (var item in data) {
          try {
            final cliente = Cliente.fromMap(item);
            final clienteExistente = await _clienteController.buscarPorId(
              cliente.id!,
            );

            if (clienteExistente == null) {
              await _clienteController.inserir(cliente);
            } else if (cliente.dataUltimaAlteracao != null &&
                clienteExistente.dataUltimaAlteracao != null &&
                cliente.dataUltimaAlteracao!.isAfter(
                  clienteExistente.dataUltimaAlteracao!,
                )) {
              await _clienteController.atualizar(cliente);
            }
          } catch (e) {
            _erros['Clientes']!.add(
              'Erro ao processar cliente ${item['id']}: $e',
            );
          }
        }
      } else {
        _erros['Clientes']!.add(
          'Erro ao buscar clientes: ${response.statusCode}',
        );
      }
    } catch (e) {
      _erros['Clientes']!.add('Erro de conexão ao buscar clientes: $e');
    }
  }

  Future<void> _buscarProdutos(String baseUrl) async {
    try {
      final response = await http
          .get(
            Uri.parse('http://$baseUrl/produtos'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        List<dynamic> data;

        data = _processarResposta(responseData, 'produtos');

        for (var item in data) {
          try {
            final produto = Produto.fromMap(item);
            final produtoExistente = await _produtoController.buscarPorId(
              produto.id!,
            );

            if (produtoExistente == null) {
              await _produtoController.inserir(produto);
            } else if (produto.dataUltimaAlteracao != null &&
                produtoExistente.dataUltimaAlteracao != null &&
                produto.dataUltimaAlteracao!.isAfter(
                  produtoExistente.dataUltimaAlteracao!,
                )) {
              await _produtoController.atualizar(produto);
            }
          } catch (e) {
            _erros['Produtos']!.add(
              'Erro ao processar produto ${item['id']}: $e',
            );
          }
        }
      } else {
        _erros['Produtos']!.add(
          'Erro ao buscar produtos: ${response.statusCode}',
        );
      }
    } catch (e) {
      _erros['Produtos']!.add('Erro de conexão ao buscar produtos: $e');
    }
  }

  Future<void> _enviarUsuarios(String baseUrl) async {
    try {
      final usuarios = await _usuarioController.listarTodos();

      // Filtrar registros novos (dataUltimaAlteracao == null) e atualizados
      final usuariosParaEnviar =
          usuarios
              .where(
                (u) =>
                    u.dataUltimaAlteracao == null || // Novos registros
                    (u.dataUltimaAlteracao != null &&
                        u.dataUltimaAlteracao!.isAfter(
                          DateTime.now().subtract(const Duration(days: 1)),
                        )), // Atualizações recentes
              )
              .toList();


      for (var usuario in usuariosParaEnviar) {
        try {

          final response = await http
              .post(
                Uri.parse('http://$baseUrl/usuarios'),
                headers: {'Content-Type': 'application/json'},
                body: json.encode(usuario.toMap()),
              )
              .timeout(const Duration(seconds: 10));

          if (response.statusCode == 200 || response.statusCode == 201) {
            await _usuarioController.atualizarDataUltimaAlteracao(usuario.id!);
          } else {
            _erros['Usuários']!.add(
              'Erro ao enviar usuário ${usuario.nome}: HTTP ${response.statusCode}',
            );
          }
        } catch (e) {
          _erros['Usuários']!.add('Erro ao enviar usuário ${usuario.nome}: $e');
        }
      }
    } catch (e) {
      _erros['Usuários']!.add('Erro ao processar envio de usuários: $e');
    }
  }

  Future<void> _enviarClientes(String baseUrl) async {
    try {
      final clientes = await _clienteController.listarTodos();

      // Filtrar registros novos (dataUltimaAlteracao == null) e atualizados
      final clientesParaEnviar =
          clientes
              .where(
                (c) =>
                    c.dataUltimaAlteracao == null || // Novos registros
                    (c.dataUltimaAlteracao != null &&
                        c.dataUltimaAlteracao!.isAfter(
                          DateTime.now().subtract(const Duration(days: 1)),
                        )), // Atualizações recentes
              )
              .toList();


      for (var cliente in clientesParaEnviar) {
        try {

          final response = await http
              .post(
                Uri.parse('http://$baseUrl/clientes'),
                headers: {'Content-Type': 'application/json'},
                body: json.encode(cliente.toMap()),
              )
              .timeout(const Duration(seconds: 10));

          if (response.statusCode == 200 || response.statusCode == 201) {
            await _clienteController.atualizarDataUltimaAlteracao(cliente.id!);
          } else {
            _erros['Clientes']!.add(
              'Erro ao enviar cliente ${cliente.nome}: HTTP ${response.statusCode}',
            );
          }
        } catch (e) {
          _erros['Clientes']!.add('Erro ao enviar cliente ${cliente.nome}: $e');
        }
      }
    } catch (e) {
      _erros['Clientes']!.add('Erro ao processar envio de clientes: $e');
    }
  }

  Future<void> _enviarProdutos(String baseUrl) async {
    try {
      final produtos = await _produtoController.listarTodos();

      // Filtrar registros novos (dataUltimaAlteracao == null) e atualizados
      final produtosParaEnviar =
          produtos
              .where(
                (p) =>
                    p.dataUltimaAlteracao == null || // Novos registros
                    (p.dataUltimaAlteracao != null &&
                        p.dataUltimaAlteracao!.isAfter(
                          DateTime.now().subtract(const Duration(days: 1)),
                        )), // Atualizações recentes
              )
              .toList();


      for (var produto in produtosParaEnviar) {
        try {

          final response = await http
              .post(
                Uri.parse('http://$baseUrl/produtos'),
                headers: {'Content-Type': 'application/json'},
                body: json.encode(produto.toMap()),
              )
              .timeout(const Duration(seconds: 10));

          if (response.statusCode == 200 || response.statusCode == 201) {
            await _produtoController.atualizarDataUltimaAlteracao(produto.id!);
          } else {
            _erros['Produtos']!.add(
              'Erro ao enviar produto ${produto.nome}: HTTP ${response.statusCode}',
            );
          }
        } catch (e) {
          _erros['Produtos']!.add('Erro ao enviar produto ${produto.nome}: $e');
        }
      }
    } catch (e) {
      _erros['Produtos']!.add('Erro ao processar envio de produtos: $e');
    }
  }

  Future<void> _enviarPedidos(String baseUrl) async {
    try {
      final pedidos = await _pedidoController.listarTodos();

      // Filtrar registros novos (dataUltimaAlteracao == null) e atualizados
      final pedidosParaEnviar =
          pedidos
              .where(
                (p) =>
                    p.dataUltimaAlteracao == null || // Novos registros
                    (p.dataUltimaAlteracao != null &&
                        p.dataUltimaAlteracao!.isAfter(
                          DateTime.now().subtract(const Duration(days: 1)),
                        )), // Atualizações recentes
              )
              .toList();


      for (var pedido in pedidosParaEnviar) {
        try {

          final itens = await _pedidoController.buscarItensPorPedido(
            pedido.id!,
          );
          final pagamentos = await _pedidoController.buscarPagamentosPorPedido(
            pedido.id!,
          );

          final dadosPedido = {
            ...pedido.toMap(),
            'itens': itens.map((i) => i.toMap()).toList(),
            'pagamentos': pagamentos.map((p) => p.toMap()).toList(),
          };

          // Se o pedido já existe no servidor (tem dataUltimaAlteracao), usar PUT
          // Caso contrário, usar POST para novo pedido
          final response = await http
              .post(
                Uri.parse('http://$baseUrl/pedidos'),
                headers: {'Content-Type': 'application/json'},
                body: json.encode(dadosPedido),
              )
              .timeout(const Duration(seconds: 15));

          if (response.statusCode == 200 || response.statusCode == 201) {
            await _pedidoController.atualizarDataUltimaAlteracao(pedido.id!);
          } else {
            _erros['Pedidos']!.add(
              'Erro ao enviar pedido ID ${pedido.id}: HTTP ${response.statusCode}',
            );
          }
        } catch (e) {
          _erros['Pedidos']!.add('Erro ao enviar pedido ID ${pedido.id}: $e');
        }
      }
    } catch (e) {
      _erros['Pedidos']!.add('Erro ao processar envio de pedidos: $e');
    }
  }
}

class DatabaseHelper {
  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(
      dbPath,
      'NOME_DO_SEU_BANCO.db',
    ); // Substitua pelo nome real do seu banco
    await deleteDatabase(path);
  }
}
