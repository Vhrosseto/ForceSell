class Usuario {
  int? id;
  String nome;
  String senha;
  DateTime? dataUltimaAlteracao;

  Usuario({
    this.id,
    required this.nome,
    required this.senha,
    this.dataUltimaAlteracao,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'senha': senha,
      'data_ultima_alteracao': dataUltimaAlteracao?.toIso8601String(),
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      nome: map['nome'],
      senha: map['senha'],
      dataUltimaAlteracao:
          map['data_ultima_alteracao'] != null
              ? DateTime.parse(map['data_ultima_alteracao'])
              : null,
    );
  }

  Usuario copyWith({
    int? id,
    String? nome,
    String? senha,
    DateTime? dataUltimaAlteracao,
  }) {
    return Usuario(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      senha: senha ?? this.senha,
      dataUltimaAlteracao: dataUltimaAlteracao ?? this.dataUltimaAlteracao,
    );
  }
}
