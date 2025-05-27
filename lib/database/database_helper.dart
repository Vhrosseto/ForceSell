import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'forcesell.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabela de Usuários
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        senha TEXT NOT NULL,
        data_ultima_alteracao TEXT
      )
    ''');

    // Tabela de Clientes
    await db.execute('''
      CREATE TABLE clientes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        tipo TEXT NOT NULL,
        cpf_cnpj TEXT NOT NULL,
        email TEXT,
        telefone TEXT,
        cep TEXT,
        endereco TEXT,
        bairro TEXT,
        cidade TEXT,
        uf TEXT,
        data_ultima_alteracao TEXT
      )
    ''');

    // Tabela de Produtos
    await db.execute('''
      CREATE TABLE produtos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        unidade TEXT NOT NULL,
        qtd_estoque REAL NOT NULL,
        preco_venda REAL NOT NULL,
        status INTEGER NOT NULL,
        custo REAL,
        codigo_barra TEXT,
        data_ultima_alteracao TEXT
      )
    ''');

    // Tabela de Pedidos
    await db.execute('''
      CREATE TABLE pedidos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_cliente INTEGER NOT NULL,
        id_usuario INTEGER NOT NULL,
        total_pedido REAL NOT NULL,
        data_criacao TEXT NOT NULL,
        data_ultima_alteracao TEXT,
        FOREIGN KEY (id_cliente) REFERENCES clientes (id),
        FOREIGN KEY (id_usuario) REFERENCES usuarios (id)
      )
    ''');

    // Tabela de Itens do Pedido
    await db.execute('''
      CREATE TABLE pedido_itens (
        id_pedido INTEGER NOT NULL,
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_produto INTEGER NOT NULL,
        quantidade REAL NOT NULL,
        total_item REAL NOT NULL,
        FOREIGN KEY (id_pedido) REFERENCES pedidos (id),
        FOREIGN KEY (id_produto) REFERENCES produtos (id)
      )
    ''');

    // Tabela de Pagamentos do Pedido
    await db.execute('''
      CREATE TABLE pedido_pagamentos (
        id_pedido INTEGER NOT NULL,
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        valor_pagamento REAL NOT NULL,
        FOREIGN KEY (id_pedido) REFERENCES pedidos (id)
      )
    ''');

    // Tabela de Configurações
    await db.execute('''
      CREATE TABLE configuracoes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        link_servidor TEXT NOT NULL
      )
    ''');

    // Inserir usuário admin padrão
    await db.insert('usuarios', {'nome': 'admin', 'senha': 'admin'});

    // Inserir configuração padrão
    await db.insert('configuracoes', {'link_servidor': 'localhost:8080'});
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Implementar atualizações de versão do banco aqui
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
