class Sale {
  const Sale({
    required this.id,
    required this.cartId,
    required this.quantity,
    required this.unitPrice,
    required this.paymentMethod,
    required this.createdAt,
  });

  final String id;
  final String cartId;
  final int quantity;
  final int unitPrice;
  final String paymentMethod;
  final DateTime createdAt;

  int get total => quantity * unitPrice;

  Map<String, Object?> toMap() => {
    'id': id,
    'cart_id': cartId,
    'quantity': quantity,
    'unit_price': unitPrice,
    'total': total,
    'payment_method': paymentMethod,
    'created_at': createdAt.toIso8601String(),
    'sync_status': 'pending',
  };
}
