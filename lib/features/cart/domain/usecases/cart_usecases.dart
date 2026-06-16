import '../../../../core/usecase/usecase.dart';
import '../entities/cart_item.dart';
import '../repositories/cart_repository.dart';

/// Fetches current cart contents.
class GetCartUseCase implements UseCase<Cart, NoParams> {
  final CartRepository _repository;
  GetCartUseCase(this._repository);

  @override
  Future<Cart> call(NoParams params) => _repository.getCart();
}

/// Parameters for adding to cart.
class AddToCartParams {
  final int productId;
  final int qty;
  const AddToCartParams({required this.productId, required this.qty});
}

/// Adds an item to the cart.
class AddToCartUseCase implements UseCase<void, AddToCartParams> {
  final CartRepository _repository;
  AddToCartUseCase(this._repository);

  @override
  Future<void> call(AddToCartParams params) =>
      _repository.addToCart(params.productId, params.qty);
}

/// Removes an item from the cart by product ID.
class RemoveFromCartUseCase implements UseCase<void, int> {
  final CartRepository _repository;
  RemoveFromCartUseCase(this._repository);

  @override
  Future<void> call(int productId) => _repository.removeFromCart(productId);
}

/// Clears all items from the cart.
class ClearCartUseCase implements UseCase<void, NoParams> {
  final CartRepository _repository;
  ClearCartUseCase(this._repository);

  @override
  Future<void> call(NoParams params) => _repository.clearCart();
}
