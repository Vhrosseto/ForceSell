// ignore: unused_import
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/pedido.dart';
import '../models/pedido_item.dart';
import '../models/pedido_pagamento.dart';

class PedidoController {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> inserir(
    Pedido pedido,
    List<PedidoItem> itens,
    List<PedidoPagamento> pagamentos,
  ) async {
    final db = await _databaseHelper.database;

    // Validar regras de negócio
    if (!await validarPedido(itens, pagamentos)) {
      throw Exception(
        'Pedido inválido: deve ter pelo menos 1 item e 1 pagamento',
      );
    }

    if (!await validarTotais(itens, pagamentos)) {
      throw Exception(
        'Somatório dos pagamentos deve ser igual ao total dos itens',
      );
    }

    return await db.transaction((txn) async {
      // Inserir pedido - não definir dataUltimaAlteracao automaticamente para novos registros
      // Isso permite identificá-los na sincronização como registros que precisam ser enviados
      int pedidoId = await txn.insert('pedidos', pedido.toMapDatabase());

      // Inserir itens
      for (var item in itens) {
        item = item.copyWith(idPedido: pedidoId);
        await txn.insert('pedido_itens', item.toMapDatabase());
      }

      // Inserir pagamentos
      for (var pagamento in pagamentos) {
        pagamento = pagamento.copyWith(idPedido: pedidoId);
        await txn.insert('pedido_pagamentos', pagamento.toMapDatabase());
      }

      return pedidoId;
    });
  }

  Future<List<Pedido>> listarTodos() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pedidos',
      where: 'deleted = 0',
    );
    return List.generate(maps.length, (i) => Pedido.fromMap(maps[i]));
  }

  Future<Pedido?> buscarPorId(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pedidos',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Pedido.fromMap(maps.first);
    }
    return null;
  }

  Future<List<PedidoItem>> buscarItensPorPedido(int pedidoId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pedido_itens',
      where: 'id_pedido = ?',
      whereArgs: [pedidoId],
    );
    return List.generate(maps.length, (i) => PedidoItem.fromMap(maps[i]));
  }

  Future<List<PedidoPagamento>> buscarPagamentosPorPedido(int pedidoId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pedido_pagamentos',
      where: 'id_pedido = ?',
      whereArgs: [pedidoId],
    );
    return List.generate(maps.length, (i) => PedidoPagamento.fromMap(maps[i]));
  }

  Future<int> atualizar(
    Pedido pedido,
    List<PedidoItem> itens,
    List<PedidoPagamento> pagamentos,
  ) async {
    final db = await _databaseHelper.database;

    // Validar regras de negócio
    if (!await validarPedido(itens, pagamentos)) {
      throw Exception(
        'Pedido inválido: deve ter pelo menos 1 item e 1 pagamento',
      );
    }

    if (!await validarTotais(itens, pagamentos)) {
      throw Exception(
        'Somatório dos pagamentos deve ser igual ao total dos itens',
      );
    }

    return await db.transaction((txn) async {
      // Atualizar pedido com nova data de alteração
      pedido = pedido.copyWith(dataUltimaAlteracao: DateTime.now());
      int result = await txn.update(
        'pedidos',
        pedido.toMapDatabase(),
        where: 'id = ?',
        whereArgs: [pedido.id],
      );

      // Remover itens e pagamentos existentes
      await txn.delete(
        'pedido_itens',
        where: 'id_pedido = ?',
        whereArgs: [pedido.id],
      );
      await txn.delete(
        'pedido_pagamentos',
        where: 'id_pedido = ?',
        whereArgs: [pedido.id],
      );

      // Inserir novos itens
      for (var item in itens) {
        item = item.copyWith(idPedido: pedido.id!);
        await txn.insert('pedido_itens', item.toMapDatabase());
      }

      // Inserir novos pagamentos
      for (var pagamento in pagamentos) {
        pagamento = pagamento.copyWith(idPedido: pedido.id!);
        await txn.insert('pedido_pagamentos', pagamento.toMapDatabase());
      }

      return result;
    });
  }

  Future<int> deletar(int id) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'pedidos',
      {'deleted': 1, 'data_ultima_alteracao': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deletarDefinitivamente(int id) async {
    final db = await _databaseHelper.database;
    return await db.transaction((txn) async {
      // Remover itens e pagamentos
      await txn.delete('pedido_itens', where: 'id_pedido = ?', whereArgs: [id]);
      await txn.delete(
        'pedido_pagamentos',
        where: 'id_pedido = ?',
        whereArgs: [id],
      );

      // Remover pedido
      return await txn.delete('pedidos', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<List<Pedido>> listarDeletados() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pedidos',
      where: 'deleted = 1',
    );
    return List.generate(maps.length, (i) => Pedido.fromMap(maps[i]));
  }

  Future<bool> validarPedido(
    List<PedidoItem> itens,
    List<PedidoPagamento> pagamentos,
  ) async {
    return itens.isNotEmpty && pagamentos.isNotEmpty;
  }

  Future<bool> validarTotais(
    List<PedidoItem> itens,
    List<PedidoPagamento> pagamentos,
  ) async {
    double totalItens = itens.fold(0.0, (sum, item) => sum + item.totalItem);
    double totalPagamentos = pagamentos.fold(
      0.0,
      (sum, pagamento) => sum + pagamento.valorPagamento,
    );

    // Comparar com tolerância para problemas de ponto flutuante
    return (totalItens - totalPagamentos).abs() < 0.01;
  }

  double calcularTotalItens(List<PedidoItem> itens) {
    return itens.fold(0.0, (sum, item) => sum + item.totalItem);
  }

  double calcularTotalPagamentos(List<PedidoPagamento> pagamentos) {
    return pagamentos.fold(
      0.0,
      (sum, pagamento) => sum + pagamento.valorPagamento,
    );
  }

  Future<List<Pedido>> buscarPorCliente(int clienteId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pedidos',
      where: 'id_cliente = ?',
      whereArgs: [clienteId],
    );
    return List.generate(maps.length, (i) => Pedido.fromMap(maps[i]));
  }

  Future<List<Pedido>> buscarPorUsuario(int usuarioId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pedidos',
      where: 'id_usuario = ?',
      whereArgs: [usuarioId],
    );
    return List.generate(maps.length, (i) => Pedido.fromMap(maps[i]));
  }

  Future<List<Pedido>> buscarPorPeriodo(DateTime inicio, DateTime fim) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pedidos',
      where: 'data_criacao BETWEEN ? AND ?',
      whereArgs: [inicio.toIso8601String(), fim.toIso8601String()],
    );
    return List.generate(maps.length, (i) => Pedido.fromMap(maps[i]));
  }

  Future<List<Pedido>> buscarAlteradosApos(DateTime data) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pedidos',
      where: 'data_ultima_alteracao > ?',
      whereArgs: [data.toIso8601String()],
    );
    return List.generate(maps.length, (i) => Pedido.fromMap(maps[i]));
  }

  Future<void> atualizarDataUltimaAlteracao(int id) async {
    final db = await _databaseHelper.database;
    await db.update(
      'pedidos',
      {'data_ultima_alteracao': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
