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
    return {'id_pedido': idPedido, 'id': id, 'valor_pagamento': valorPagamento};
  }

  factory PedidoPagamento.fromMap(Map<String, dynamic> map) {
    return PedidoPagamento(
      idPedido: map['id_pedido'],
      id: map['id'],
      valorPagamento: map['valor_pagamento']?.toDouble() ?? 0.0,
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
