// ignore: unused_import
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/usuario.dart';

class UsuarioController {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> inserir(Usuario usuario) async {
    final db = await _databaseHelper.database;
    // Não definir dataUltimaAlteracao automaticamente para novos registros
    // Isso permite identificá-los na sincronização como registros que precisam ser enviados
    return await db.insert('usuarios', usuario.toMapDatabase());
  }

  Future<List<Usuario>> listarTodos() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'deleted = 0',
    );
    return List.generate(maps.length, (i) => Usuario.fromMap(maps[i]));
  }

  Future<Usuario?> buscarPorId(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Usuario.fromMap(maps.first);
    }
    return null;
  }

  Future<Usuario?> autenticar(String nome, String senha) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'nome = ? AND senha = ?',
      whereArgs: [nome, senha],
    );
    if (maps.isNotEmpty) {
      return Usuario.fromMap(maps.first);
    }
    return null;
  }

  Future<int> atualizar(Usuario usuario) async {
    final db = await _databaseHelper.database;
    usuario = usuario.copyWith(dataUltimaAlteracao: DateTime.now());
    return await db.update(
      'usuarios',
      usuario.toMapDatabase(),
      where: 'id = ?',
      whereArgs: [usuario.id],
    );
  }

  Future<int> deletar(int id) async {
    final db = await _databaseHelper.database;
    // Fazer soft delete e atualizar data de alteração
    return await db.update(
      'usuarios',
      {'deleted': 1, 'data_ultima_alteracao': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deletarDefinitivamente(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete('usuarios', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Usuario>> listarDeletados() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'deleted = 1',
    );
    return List.generate(maps.length, (i) => Usuario.fromMap(maps[i]));
  }

  Future<bool> validarCamposObrigatorios(Usuario usuario) async {
    if (usuario.nome.trim().isEmpty) {
      return false;
    }
    if (usuario.senha.trim().isEmpty) {
      return false;
    }
    return true;
  }

  Future<bool> nomeJaExiste(String nome, {int? idExcluir}) async {
    final db = await _databaseHelper.database;
    String where = 'nome = ?';
    List<dynamic> whereArgs = [nome];

    if (idExcluir != null) {
      where += ' AND id != ?';
      whereArgs.add(idExcluir);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: where,
      whereArgs: whereArgs,
    );
    return maps.isNotEmpty;
  }

  Future<List<Usuario>> buscarAlteradosApos(DateTime data) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'data_ultima_alteracao > ?',
      whereArgs: [data.toIso8601String()],
    );
    return List.generate(maps.length, (i) => Usuario.fromMap(maps[i]));
  }

  Future<void> atualizarDataUltimaAlteracao(int id) async {
    final db = await _databaseHelper.database;
    await db.update(
      'usuarios',
      {'data_ultima_alteracao': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
