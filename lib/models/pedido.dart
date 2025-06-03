class Pedido {
  int? id;
  int idCliente;
  int idUsuario;
  double totalPedido;
  DateTime dataCriacao;
  DateTime? dataUltimaAlteracao;

  Pedido({
    this.id,
    required this.idCliente,
    required this.idUsuario,
    required this.totalPedido,
    required this.dataCriacao,
    this.dataUltimaAlteracao,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idCliente': idCliente,
      'idUsuario': idUsuario,
      'totalPedido': totalPedido,
      'data_criacao': dataCriacao.toIso8601String(),
      'data_ultima_alteracao': dataUltimaAlteracao?.toIso8601String(),
    };
  }

  /// Método específico para operações do banco de dados local
  Map<String, dynamic> toMapDatabase() {
    return {
      'id': id,
      'id_cliente': idCliente,
      'id_usuario': idUsuario,
      'total_pedido': totalPedido,
      'data_criacao': dataCriacao.toIso8601String(),
      'data_ultima_alteracao': dataUltimaAlteracao?.toIso8601String(),
    };
  }

  factory Pedido.fromMap(Map<String, dynamic> map) {
    return Pedido(
      id: map['id'],
      idCliente: map['idCliente'] ?? map['id_cliente'],
      idUsuario: map['idUsuario'] ?? map['id_usuario'],
      totalPedido:
          (map['totalPedido'] ?? map['total_pedido'])?.toDouble() ?? 0.0,
      dataCriacao: DateTime.parse(map['data_criacao']),
      dataUltimaAlteracao:
          map['ultimaAlteracao'] != null
              ? DateTime.parse(map['ultimaAlteracao'])
              : map['data_ultima_alteracao'] != null
              ? DateTime.parse(map['data_ultima_alteracao'])
              : null,
    );
  }

  Pedido copyWith({
    int? id,
    int? idCliente,
    int? idUsuario,
    double? totalPedido,
    DateTime? dataCriacao,
    DateTime? dataUltimaAlteracao,
  }) {
    return Pedido(
      id: id ?? this.id,
      idCliente: idCliente ?? this.idCliente,
      idUsuario: idUsuario ?? this.idUsuario,
      totalPedido: totalPedido ?? this.totalPedido,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataUltimaAlteracao: dataUltimaAlteracao ?? this.dataUltimaAlteracao,
    );
  }
}
