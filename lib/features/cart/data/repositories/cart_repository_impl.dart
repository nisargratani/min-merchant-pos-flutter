import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_data_source.dart';

/// Concrete implementation of [CartRepository].
class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource _remoteDataSource;

  CartRepositoryImpl({required CartRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Cart> getCart() async {
    final data = await _remoteDataSource.getCart();
    return Cart.fromJson(data);
  }

  @override
  Future<void> addToCart(int productId, int qty) async {
    await _remoteDataSource.addToCart(productId, qty);
  }

  @override
  Future<void> removeFromCart(int productId) async {
    await _remoteDataSource.removeFromCart(productId);
  }

  @override
  Future<void> clearCart() async {
    await _remoteDataSource.clearCart();
  }
}
