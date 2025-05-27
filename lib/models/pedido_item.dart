class PedidoItem {
  int idPedido;
  int? id;
  int idProduto;
  double quantidade;
  double totalItem;

  PedidoItem({
    required this.idPedido,
    this.id,
    required this.idProduto,
    required this.quantidade,
    required this.totalItem,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_pedido': idPedido,
      'id': id,
      'id_produto': idProduto,
      'quantidade': quantidade,
      'total_item': totalItem,
    };
  }

  factory PedidoItem.fromMap(Map<String, dynamic> map) {
    return PedidoItem(
      idPedido: map['id_pedido'],
      id: map['id'],
      idProduto: map['id_produto'],
      quantidade: map['quantidade']?.toDouble() ?? 0.0,
      totalItem: map['total_item']?.toDouble() ?? 0.0,
    );
  }

  PedidoItem copyWith({
    int? idPedido,
    int? id,
    int? idProduto,
    double? quantidade,
    double? totalItem,
  }) {
    return PedidoItem(
      idPedido: idPedido ?? this.idPedido,
      id: id ?? this.id,
      idProduto: idProduto ?? this.idProduto,
      quantidade: quantidade ?? this.quantidade,
      totalItem: totalItem ?? this.totalItem,
    );
  }
}
