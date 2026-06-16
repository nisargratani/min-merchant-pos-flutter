/// Order item — part of an order.
class OrderItem {
  final int productId;
  final String? productName;
  final int qty;
  final double price;

  const OrderItem({
    required this.productId,
    this.productName,
    required this.qty,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] as int,
      productName: json['productName'] as String?,
      qty: json['qty'] as int,
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'qty': qty,
        'price': price,
      };
}

/// Order entity — supports both online and offline orders.
class OrderEntity {
  final String localOrderId;
  final int? serverOrderId;
  final String paymentStatus; // PENDING, SUCCESS, FAILED
  final String paymentMode; // CASH, CARD, OFFLINE
  final double totalAmount;
  final String syncStatus; // PENDING, PAID, SYNCED, FAILED
  final List<OrderItem> items;
  final int createdAt;
  final String? paymentRef; // Transaction ID from payment simulation
  final int? paymentId; // Server-assigned payment ID

  const OrderEntity({
    required this.localOrderId,
    this.serverOrderId,
    required this.paymentStatus,
    required this.paymentMode,
    required this.totalAmount,
    required this.syncStatus,
    required this.items,
    required this.createdAt,
    this.paymentRef,
    this.paymentId,
  });

  factory OrderEntity.fromJson(Map<String, dynamic> json) {
    return OrderEntity(
      localOrderId: json['localOrderId'] as String? ?? '',
      serverOrderId: json['serverOrderId'] as int?,
      paymentStatus: json['paymentStatus'] as String? ?? 'PENDING',
      paymentMode: json['paymentMode'] as String? ?? 'CASH',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      syncStatus: json['syncStatus'] as String? ?? json['status'] as String? ?? 'PENDING',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      paymentRef: json['paymentRef'] as String?,
      paymentId: json['paymentId'] as int?,
    );
  }

  OrderEntity copyWith({
    String? localOrderId,
    int? serverOrderId,
    String? paymentStatus,
    String? paymentMode,
    double? totalAmount,
    String? syncStatus,
    List<OrderItem>? items,
    int? createdAt,
    String? paymentRef,
    int? paymentId,
  }) {
    return OrderEntity(
      localOrderId: localOrderId ?? this.localOrderId,
      serverOrderId: serverOrderId ?? this.serverOrderId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMode: paymentMode ?? this.paymentMode,
      totalAmount: totalAmount ?? this.totalAmount,
      syncStatus: syncStatus ?? this.syncStatus,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      paymentRef: paymentRef ?? this.paymentRef,
      paymentId: paymentId ?? this.paymentId,
    );
  }
}
