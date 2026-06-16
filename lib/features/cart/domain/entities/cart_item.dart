/// Cart item entity — domain model.
class CartItem {
  final int productId;
  final String name;
  final double price;
  final int qty;

  const CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.qty,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'] as int,
      name: json['name'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      qty: json['qty'] as int,
    );
  }

  double get total => price * qty;
}

/// Cart aggregate — holds items and running total.
class Cart {
  final List<CartItem> items;
  final double totalAmount;

  const Cart({required this.items, required this.totalAmount});

  factory Cart.fromJson(Map<String, dynamic> json) {
    final itemList = (json['items'] as List<dynamic>?)
            ?.map((e) => CartItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return Cart(
      items: itemList,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static const empty = Cart(items: [], totalAmount: 0.0);
}
