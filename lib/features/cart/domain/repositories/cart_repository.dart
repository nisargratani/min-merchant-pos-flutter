import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/cart_item.dart';

/// Abstract cart repository — domain layer contract.
abstract class CartRepository {
  Future<Either<Failure, Cart>> getCart();
  Future<Either<Failure, void>> addToCart(int productId, int qty);
  Future<Either<Failure, void>> removeFromCart(int productId);
  Future<Either<Failure, void>> clearCart();
}
