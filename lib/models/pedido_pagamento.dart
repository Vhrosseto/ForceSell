class PedidoPagamento {
  int idPedido;
  int? id;
  double valorPagamento;

  PedidoPagamento({
    required this.idPedido,
    this.id,
    required this.valorPagamento,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'idPedido': idPedido, 'valor': valorPagamento};
  }

  /// Método específico para operações do banco de dados local
  Map<String, dynamic> toMapDatabase() {
    return {'id_pedido': idPedido, 'id': id, 'valor_pagamento': valorPagamento};
  }

  factory PedidoPagamento.fromMap(Map<String, dynamic> map) {
    return PedidoPagamento(
      id: map['id'],
      idPedido: map['idPedido'] ?? map['id_pedido'],
      valorPagamento:
          (map['valor'] ?? map['valor_pagamento'])?.toDouble() ?? 0.0,
    );
  }

  PedidoPagamento copyWith({int? idPedido, int? id, double? valorPagamento}) {
    return PedidoPagamento(
      idPedido: idPedido ?? this.idPedido,
      id: id ?? this.id,
      valorPagamento: valorPagamento ?? this.valorPagamento,
    );
  }
}
