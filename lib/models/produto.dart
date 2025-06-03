class Produto {
  int? id;
  String nome;
  String unidade; // un, cx, kg, lt, ml
  double qtdEstoque;
  double precoVenda;
  int status; // 0 - Ativo / 1 - Inativo
  double? custo;
  String? codigoBarra;
  DateTime? dataUltimaAlteracao;
  bool deleted;

  Produto({
    this.id,
    required this.nome,
    required this.unidade,
    required this.qtdEstoque,
    required this.precoVenda,
    required this.status,
    this.custo,
    this.codigoBarra,
    this.dataUltimaAlteracao,
    this.deleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'unidade': unidade,
      'qtdEstoque': qtdEstoque,
      'precoVenda': precoVenda,
      'Status': status,
      'custo': custo,
      'codigoBarra': codigoBarra,
      'data_ultima_alteracao': dataUltimaAlteracao?.toIso8601String(),
      'deleted': deleted ? 1 : 0,
    };
  }

  /// Método específico para operações do banco de dados local
  Map<String, dynamic> toMapDatabase() {
    return {
      'id': id,
      'nome': nome,
      'unidade': unidade,
      'qtd_estoque': qtdEstoque,
      'preco_venda': precoVenda,
      'status': status,
      'custo': custo,
      'codigo_barra': codigoBarra,
      'data_ultima_alteracao': dataUltimaAlteracao?.toIso8601String(),
      'deleted': deleted ? 1 : 0,
    };
  }

  factory Produto.fromMap(Map<String, dynamic> map) {
    return Produto(
      id: map['id'],
      nome: map['nome'] ?? '',
      unidade: (map['unidade'] ?? 'un').toLowerCase(),
      qtdEstoque: (map['qtdEstoque'] ?? map['qtd_estoque'])?.toDouble() ?? 0.0,
      precoVenda: (map['precoVenda'] ?? map['preco_venda'])?.toDouble() ?? 0.0,
      status: map['Status'] ?? map['status'] ?? 0,
      custo: map['custo']?.toDouble(),
      codigoBarra: map['codigoBarra'] ?? map['codigo_barra'],
      dataUltimaAlteracao:
          map['ultimaAlteracao'] != null
              ? DateTime.parse(map['ultimaAlteracao'])
              : map['data_ultima_alteracao'] != null
              ? DateTime.parse(map['data_ultima_alteracao'])
              : null,
      deleted: (map['deleted'] == 1) || (map['deleted'] == true),
    );
  }

  Produto copyWith({
    int? id,
    String? nome,
    String? unidade,
    double? qtdEstoque,
    double? precoVenda,
    int? status,
    double? custo,
    String? codigoBarra,
    DateTime? dataUltimaAlteracao,
    bool? deleted,
  }) {
    return Produto(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      unidade: unidade ?? this.unidade,
      qtdEstoque: qtdEstoque ?? this.qtdEstoque,
      precoVenda: precoVenda ?? this.precoVenda,
      status: status ?? this.status,
      custo: custo ?? this.custo,
      codigoBarra: codigoBarra ?? this.codigoBarra,
      dataUltimaAlteracao: dataUltimaAlteracao ?? this.dataUltimaAlteracao,
      deleted: deleted ?? this.deleted,
    );
  }
}
