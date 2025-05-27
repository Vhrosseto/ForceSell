class Configuracao {
  int? id;
  String linkServidor;

  Configuracao({this.id, required this.linkServidor});

  Map<String, dynamic> toMap() {
    return {'id': id, 'link_servidor': linkServidor};
  }

  factory Configuracao.fromMap(Map<String, dynamic> map) {
    return Configuracao(
      id: map['id'],
      linkServidor: map['link_servidor'] ?? 'localhost:8080',
    );
  }

  Configuracao copyWith({int? id, String? linkServidor}) {
    return Configuracao(
      id: id ?? this.id,
      linkServidor: linkServidor ?? this.linkServidor,
    );
  }
}
