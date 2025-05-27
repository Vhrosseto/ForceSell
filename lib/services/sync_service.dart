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
// ignore: unused_import
import '../models/pedido.dart';

class SyncService {
  final ConfiguracaoController _configController = ConfiguracaoController();
  final UsuarioController _usuarioController = UsuarioController();
  final ClienteController _clienteController = ClienteController();
  final ProdutoController _produtoController = ProdutoController();
  final PedidoController _pedidoController = PedidoController();

  final List<String> _erros = [];

  List<String> get erros => _erros;

  Future<void> sincronizar() async {
    _erros.clear();

    try {
      final baseUrl = await _configController.obterLinkServidor();

      // Buscar dados do servidor
      await _buscarUsuarios(baseUrl);
      await _buscarClientes(baseUrl);
      await _buscarProdutos(baseUrl);

      // Enviar dados para o servidor
      await _enviarUsuarios(baseUrl);
      await _enviarClientes(baseUrl);
      await _enviarProdutos(baseUrl);
      await _enviarPedidos(baseUrl);
    } catch (e) {
      _erros.add('Erro geral de sincronização: $e');
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
        final List<dynamic> data = json.decode(response.body);

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
            _erros.add('Erro ao processar usuário ${item['id']}: $e');
          }
        }
      } else {
        _erros.add('Erro ao buscar usuários: ${response.statusCode}');
      }
    } catch (e) {
      _erros.add('Erro de conexão ao buscar usuários: $e');
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
        final List<dynamic> data = json.decode(response.body);

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
            _erros.add('Erro ao processar cliente ${item['id']}: $e');
          }
        }
      } else {
        _erros.add('Erro ao buscar clientes: ${response.statusCode}');
      }
    } catch (e) {
      _erros.add('Erro de conexão ao buscar clientes: $e');
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
        final List<dynamic> data = json.decode(response.body);

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
            _erros.add('Erro ao processar produto ${item['id']}: $e');
          }
        }
      } else {
        _erros.add('Erro ao buscar produtos: ${response.statusCode}');
      }
    } catch (e) {
      _erros.add('Erro de conexão ao buscar produtos: $e');
    }
  }

  Future<void> _enviarUsuarios(String baseUrl) async {
    try {
      final usuarios = await _usuarioController.listarTodos();
      final usuariosNovos =
          usuarios.where((u) => u.dataUltimaAlteracao == null).toList();

      for (var usuario in usuariosNovos) {
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
            _erros.add(
              'Erro ao enviar usuário ${usuario.id}: ${response.statusCode}',
            );
          }
        } catch (e) {
          _erros.add('Erro ao enviar usuário ${usuario.id}: $e');
        }
      }
    } catch (e) {
      _erros.add('Erro ao enviar usuários: $e');
    }
  }

  Future<void> _enviarClientes(String baseUrl) async {
    try {
      final clientes = await _clienteController.listarTodos();
      final clientesNovos =
          clientes.where((c) => c.dataUltimaAlteracao == null).toList();

      for (var cliente in clientesNovos) {
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
            _erros.add(
              'Erro ao enviar cliente ${cliente.id}: ${response.statusCode}',
            );
          }
        } catch (e) {
          _erros.add('Erro ao enviar cliente ${cliente.id}: $e');
        }
      }
    } catch (e) {
      _erros.add('Erro ao enviar clientes: $e');
    }
  }

  Future<void> _enviarProdutos(String baseUrl) async {
    try {
      final produtos = await _produtoController.listarTodos();
      final produtosNovos =
          produtos.where((p) => p.dataUltimaAlteracao == null).toList();

      for (var produto in produtosNovos) {
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
            _erros.add(
              'Erro ao enviar produto ${produto.id}: ${response.statusCode}',
            );
          }
        } catch (e) {
          _erros.add('Erro ao enviar produto ${produto.id}: $e');
        }
      }
    } catch (e) {
      _erros.add('Erro ao enviar produtos: $e');
    }
  }

  Future<void> _enviarPedidos(String baseUrl) async {
    try {
      final pedidos = await _pedidoController.listarTodos();
      final pedidosNovos =
          pedidos.where((p) => p.dataUltimaAlteracao == null).toList();

      for (var pedido in pedidosNovos) {
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
            _erros.add(
              'Erro ao enviar pedido ${pedido.id}: ${response.statusCode}',
            );
          }
        } catch (e) {
          _erros.add('Erro ao enviar pedido ${pedido.id}: $e');
        }
      }
    } catch (e) {
      _erros.add('Erro ao enviar pedidos: $e');
    }
  }

  Map<String, List<String>> get errosPorEntidade {
    Map<String, List<String>> errosSeparados = {
      'Usuários': [],
      'Clientes': [],
      'Produtos': [],
      'Pedidos': [],
      'Geral': [],
    };

    for (String erro in _erros) {
      if (erro.contains('usuário')) {
        errosSeparados['Usuários']!.add(erro);
      } else if (erro.contains('cliente')) {
        errosSeparados['Clientes']!.add(erro);
      } else if (erro.contains('produto')) {
        errosSeparados['Produtos']!.add(erro);
      } else if (erro.contains('pedido')) {
        errosSeparados['Pedidos']!.add(erro);
      } else {
        errosSeparados['Geral']!.add(erro);
      }
    }

    return errosSeparados;
  }
}
