import '../entities/cart_item.dart';

/// Abstract cart repository — domain layer contract.
abstract class CartRepository {
  Future<Cart> getCart();
  Future<void> addToCart(int productId, int qty);
  Future<void> removeFromCart(int productId);
  Future<void> clearCart();
}
