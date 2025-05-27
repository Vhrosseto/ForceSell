// ignore: unused_import
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/configuracao.dart';

class ConfiguracaoController {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<Configuracao> obterConfiguracao() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'configuracoes',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Configuracao.fromMap(maps.first);
    } else {
      // Se não existe configuração, criar uma padrão
      final configuracao = Configuracao(linkServidor: 'localhost:8080');
      await inserir(configuracao);
      return configuracao;
    }
  }

  Future<int> inserir(Configuracao configuracao) async {
    final db = await _databaseHelper.database;
    return await db.insert('configuracoes', configuracao.toMap());
  }

  Future<int> atualizar(Configuracao configuracao) async {
    final db = await _databaseHelper.database;

    if (configuracao.id != null) {
      return await db.update(
        'configuracoes',
        configuracao.toMap(),
        where: 'id = ?',
        whereArgs: [configuracao.id],
      );
    } else {
      // Se não tem ID, atualizar o primeiro registro
      final configs = await db.query('configuracoes', limit: 1);
      if (configs.isNotEmpty) {
        return await db.update(
          'configuracoes',
          configuracao.toMap(),
          where: 'id = ?',
          whereArgs: [configs.first['id']],
        );
      } else {
        return await inserir(configuracao);
      }
    }
  }

  Future<void> atualizarLinkServidor(String novoLink) async {
    final configuracao = await obterConfiguracao();
    await atualizar(configuracao.copyWith(linkServidor: novoLink));
  }

  Future<String> obterLinkServidor() async {
    final configuracao = await obterConfiguracao();
    return configuracao.linkServidor;
  }

  bool validarUrl(String url) {
    if (url.trim().isEmpty) return false;

    // Validação básica de URL
    final regex = RegExp(r'^[a-zA-Z0-9.-]+:[0-9]+$');
    return regex.hasMatch(url.trim());
  }

  String formatarUrl(String url) {
    url = url.trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url';
    }
    return url;
  }
}
