// ignore: unused_import
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/cliente.dart';

class ClienteController {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> inserir(Cliente cliente) async {
    final db = await _databaseHelper.database;
    // Não definir dataUltimaAlteracao automaticamente para novos registros
    // Isso permite identificá-los na sincronização como registros que precisam ser enviados
    return await db.insert('clientes', cliente.toMapDatabase());
  }

  Future<List<Cliente>> listarTodos() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'clientes',
      where: 'deleted = 0',
    );
    return List.generate(maps.length, (i) => Cliente.fromMap(maps[i]));
  }

  Future<Cliente?> buscarPorId(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'clientes',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Cliente.fromMap(maps.first);
    }
    return null;
  }

  Future<int> atualizar(Cliente cliente) async {
    final db = await _databaseHelper.database;
    cliente = cliente.copyWith(dataUltimaAlteracao: DateTime.now());
    return await db.update(
      'clientes',
      cliente.toMapDatabase(),
      where: 'id = ?',
      whereArgs: [cliente.id],
    );
  }

  Future<int> deletar(int id) async {
    final db = await _databaseHelper.database;
    // Fazer soft delete e atualizar data de alteração
    return await db.update(
      'clientes',
      {'deleted': 1, 'data_ultima_alteracao': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deletarDefinitivamente(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete('clientes', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Cliente>> listarDeletados() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'clientes',
      where: 'deleted = 1',
    );
    return List.generate(maps.length, (i) => Cliente.fromMap(maps[i]));
  }

  Future<bool> validarCamposObrigatorios(Cliente cliente) async {
    if (cliente.nome.trim().isEmpty) {
      return false;
    }
    if (cliente.tipo.trim().isEmpty || !['F', 'J'].contains(cliente.tipo)) {
      return false;
    }
    if (cliente.cpfCnpj.trim().isEmpty) {
      return false;
    }
    return true;
  }

  Future<bool> cpfCnpjJaExiste(String cpfCnpj, {int? idExcluir}) async {
    final db = await _databaseHelper.database;
    String where = 'cpf_cnpj = ?';
    List<dynamic> whereArgs = [cpfCnpj];

    if (idExcluir != null) {
      where += ' AND id != ?';
      whereArgs.add(idExcluir);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'clientes',
      where: where,
      whereArgs: whereArgs,
    );
    return maps.isNotEmpty;
  }

  Future<List<Cliente>> buscarPorNome(String nome) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'clientes',
      where: 'nome LIKE ?',
      whereArgs: ['%$nome%'],
    );
    return List.generate(maps.length, (i) => Cliente.fromMap(maps[i]));
  }

  Future<List<Cliente>> buscarAlteradosApos(DateTime data) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'clientes',
      where: 'data_ultima_alteracao > ?',
      whereArgs: [data.toIso8601String()],
    );
    return List.generate(maps.length, (i) => Cliente.fromMap(maps[i]));
  }

  Future<void> atualizarDataUltimaAlteracao(int id) async {
    final db = await _databaseHelper.database;
    await db.update(
      'clientes',
      {'data_ultima_alteracao': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  bool validarCPF(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (cpf.length != 11) return false;

    // Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1*$').hasMatch(cpf)) return false;

    // Calcula o primeiro dígito verificador
    int soma = 0;
    for (int i = 0; i < 9; i++) {
      soma += int.parse(cpf[i]) * (10 - i);
    }
    int resto = soma % 11;
    int digito1 = resto < 2 ? 0 : 11 - resto;

    // Calcula o segundo dígito verificador
    soma = 0;
    for (int i = 0; i < 10; i++) {
      soma += int.parse(cpf[i]) * (11 - i);
    }
    resto = soma % 11;
    int digito2 = resto < 2 ? 0 : 11 - resto;

    return int.parse(cpf[9]) == digito1 && int.parse(cpf[10]) == digito2;
  }

  bool validarCNPJ(String cnpj) {
    cnpj = cnpj.replaceAll(RegExp(r'[^0-9]'), '');
    if (cnpj.length != 14) return false;

    // Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1*$').hasMatch(cnpj)) return false;

    // Calcula o primeiro dígito verificador
    List<int> pesos1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    int soma = 0;
    for (int i = 0; i < 12; i++) {
      soma += int.parse(cnpj[i]) * pesos1[i];
    }
    int resto = soma % 11;
    int digito1 = resto < 2 ? 0 : 11 - resto;

    // Calcula o segundo dígito verificador
    List<int> pesos2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    soma = 0;
    for (int i = 0; i < 13; i++) {
      soma += int.parse(cnpj[i]) * pesos2[i];
    }
    resto = soma % 11;
    int digito2 = resto < 2 ? 0 : 11 - resto;

    return int.parse(cnpj[12]) == digito1 && int.parse(cnpj[13]) == digito2;
  }
}
