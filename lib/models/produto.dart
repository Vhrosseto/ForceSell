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
  });

  Map<String, dynamic> toMap() {
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
    };
  }

  factory Produto.fromMap(Map<String, dynamic> map) {
    return Produto(
      id: map['id'],
      nome: map['nome'],
      unidade: map['unidade'],
      qtdEstoque: map['qtd_estoque']?.toDouble() ?? 0.0,
      precoVenda: map['preco_venda']?.toDouble() ?? 0.0,
      status: map['status'],
      custo: map['custo']?.toDouble(),
      codigoBarra: map['codigo_barra'],
      dataUltimaAlteracao:
          map['data_ultima_alteracao'] != null
              ? DateTime.parse(map['data_ultima_alteracao'])
              : null,
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
    );
  }
}
