// ignore: unused_import
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/produto.dart';

class ProdutoController {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> inserir(Produto produto) async {
    final db = await _databaseHelper.database;
    return await db.insert('produtos', produto.toMapDatabase());
  }

  Future<List<Produto>> listarTodos() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'produtos',
      where: 'deleted = 0',
    );
    return List.generate(maps.length, (i) => Produto.fromMap(maps[i]));
  }

  Future<List<Produto>> listarAtivos() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'produtos',
      where: 'status = ? AND deleted = 0',
      whereArgs: [0],
    );
    return List.generate(maps.length, (i) => Produto.fromMap(maps[i]));
  }

  Future<Produto?> buscarPorId(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'produtos',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Produto.fromMap(maps.first);
    }
    return null;
  }

  Future<int> atualizar(Produto produto) async {
    final db = await _databaseHelper.database;
    produto = produto.copyWith(dataUltimaAlteracao: DateTime.now());
    return await db.update(
      'produtos',
      produto.toMapDatabase(),
      where: 'id = ?',
      whereArgs: [produto.id],
    );
  }

  Future<int> deletar(int id) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'produtos',
      {'deleted': 1, 'data_ultima_alteracao': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> validarCamposObrigatorios(Produto produto) async {
    if (produto.nome.trim().isEmpty) {
      return false;
    }
    if (produto.unidade.trim().isEmpty ||
        !['un', 'cx', 'kg', 'lt', 'ml'].contains(produto.unidade)) {
      return false;
    }
    if (produto.qtdEstoque < 0) {
      return false;
    }
    if (produto.precoVenda <= 0) {
      return false;
    }
    if (![0, 1].contains(produto.status)) {
      return false;
    }
    return true;
  }

  Future<bool> codigoBarraJaExiste(String codigoBarra, {int? idExcluir}) async {
    if (codigoBarra.trim().isEmpty) return false;

    final db = await _databaseHelper.database;
    String where = 'codigo_barra = ?';
    List<dynamic> whereArgs = [codigoBarra];

    if (idExcluir != null) {
      where += ' AND id != ?';
      whereArgs.add(idExcluir);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'produtos',
      where: where,
      whereArgs: whereArgs,
    );
    return maps.isNotEmpty;
  }

  Future<List<Produto>> buscarPorNome(String nome) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'produtos',
      where: 'nome LIKE ? AND deleted = 0',
      whereArgs: ['%$nome%'],
    );
    return List.generate(maps.length, (i) => Produto.fromMap(maps[i]));
  }

  Future<Produto?> buscarPorCodigoBarra(String codigoBarra) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'produtos',
      where: 'codigo_barra = ?',
      whereArgs: [codigoBarra],
    );
    if (maps.isNotEmpty) {
      return Produto.fromMap(maps.first);
    }
    return null;
  }

  Future<void> atualizarEstoque(int id, double novaQuantidade) async {
    final db = await _databaseHelper.database;
    await db.update(
      'produtos',
      {
        'qtd_estoque': novaQuantidade,
        'data_ultima_alteracao': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Produto>> buscarAlteradosApos(DateTime data) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'produtos',
      where: 'data_ultima_alteracao > ?',
      whereArgs: [data.toIso8601String()],
    );
    return List.generate(maps.length, (i) => Produto.fromMap(maps[i]));
  }

  Future<void> atualizarDataUltimaAlteracao(int id) async {
    final db = await _databaseHelper.database;
    await db.update(
      'produtos',
      {'data_ultima_alteracao': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  List<String> get unidadesDisponiveis => ['un', 'cx', 'kg', 'lt', 'ml'];

  Future<int> deletarDefinitivamente(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete('produtos', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Produto>> listarDeletados() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'produtos',
      where: 'deleted = 1',
    );
    return List.generate(maps.length, (i) => Produto.fromMap(maps[i]));
  }
}
