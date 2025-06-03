class Usuario {
  int? id;
  String nome;
  String senha;
  DateTime? dataUltimaAlteracao;
  bool deleted;

  Usuario({
    this.id,
    required this.nome,
    required this.senha,
    this.dataUltimaAlteracao,
    this.deleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'senha': senha,
      'data_ultima_alteracao': dataUltimaAlteracao?.toIso8601String(),
    };
  }

  /// Método específico para operações do banco de dados local
  Map<String, dynamic> toMapDatabase() {
    return {
      'id': id,
      'nome': nome,
      'senha': senha,
      'deleted': deleted ? 1 : 0,
      'data_ultima_alteracao': dataUltimaAlteracao?.toIso8601String(),
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      nome: map['nome'] ?? '',
      senha: map['senha'] ?? '',
      deleted: (map['deleted'] == 1) || (map['deleted'] == true),
      dataUltimaAlteracao:
          map['ultimaAlteracao'] != null
              ? DateTime.parse(map['ultimaAlteracao'])
              : map['data_ultima_alteracao'] != null
              ? DateTime.parse(map['data_ultima_alteracao'])
              : null,
    );
  }

  Usuario copyWith({
    int? id,
    String? nome,
    String? senha,
    bool? deleted,
    DateTime? dataUltimaAlteracao,
  }) {
    return Usuario(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      senha: senha ?? this.senha,
      deleted: deleted ?? this.deleted,
      dataUltimaAlteracao: dataUltimaAlteracao ?? this.dataUltimaAlteracao,
    );
  }
}
