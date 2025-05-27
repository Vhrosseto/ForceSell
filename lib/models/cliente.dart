class Cliente {
  int? id;
  String nome;
  String tipo; // F - Física / J - Jurídica
  String cpfCnpj;
  String? email;
  String? telefone;
  String? cep;
  String? endereco;
  String? bairro;
  String? cidade;
  String? uf;
  DateTime? dataUltimaAlteracao;

  Cliente({
    this.id,
    required this.nome,
    required this.tipo,
    required this.cpfCnpj,
    this.email,
    this.telefone,
    this.cep,
    this.endereco,
    this.bairro,
    this.cidade,
    this.uf,
    this.dataUltimaAlteracao,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'tipo': tipo,
      'cpf_cnpj': cpfCnpj,
      'email': email,
      'telefone': telefone,
      'cep': cep,
      'endereco': endereco,
      'bairro': bairro,
      'cidade': cidade,
      'uf': uf,
      'data_ultima_alteracao': dataUltimaAlteracao?.toIso8601String(),
    };
  }

  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      id: map['id'],
      nome: map['nome'],
      tipo: map['tipo'],
      cpfCnpj: map['cpf_cnpj'],
      email: map['email'],
      telefone: map['telefone'],
      cep: map['cep'],
      endereco: map['endereco'],
      bairro: map['bairro'],
      cidade: map['cidade'],
      uf: map['uf'],
      dataUltimaAlteracao:
          map['data_ultima_alteracao'] != null
              ? DateTime.parse(map['data_ultima_alteracao'])
              : null,
    );
  }

  Cliente copyWith({
    int? id,
    String? nome,
    String? tipo,
    String? cpfCnpj,
    String? email,
    String? telefone,
    String? cep,
    String? endereco,
    String? bairro,
    String? cidade,
    String? uf,
    DateTime? dataUltimaAlteracao,
  }) {
    return Cliente(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      cpfCnpj: cpfCnpj ?? this.cpfCnpj,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      cep: cep ?? this.cep,
      endereco: endereco ?? this.endereco,
      bairro: bairro ?? this.bairro,
      cidade: cidade ?? this.cidade,
      uf: uf ?? this.uf,
      dataUltimaAlteracao: dataUltimaAlteracao ?? this.dataUltimaAlteracao,
    );
  }
}
